using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NhlStatsCollector.StatsAPIClasses;
using RestSharp;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace NhlStatsCollector
{
	/// <summary>
	/// Stats Collector fetches data from NHL's public API endpoints and writes the json data out
	/// in json files
	/// </summary>
	public class StatsAPIDataCollector
	{
		private string _baseUrlForStatsApiWeb = "https://statsapi.web.nhl.com/api/v1/";
		private string _fullDailyFilenamePath;
		private string _fullMonthlyFilenamePath;
		private string _fullSeasonFilenamePath;
		private RunLogger _logger;
		private RestClient _client;
		private string _season;
		private int[] _teamIds;
		private long[] _gameIds;
		private StatsSchedule _schedule;
		private RunParameters _runParameters;

		public event EventHandler<CollectionEventArgs> OnCollectionEvent = delegate { };

		public StatsAPIDataCollector(RunParameters runParameters)
		{
			_runParameters = runParameters;
			if (!_runParameters.RunDate.HasValue)
			{
				_runParameters.RunDate = DateTime.Now;
			}

			_season = Helpers.GetSeasonStringForPath(runParameters.RunDate);
			_fullSeasonFilenamePath = $"{runParameters.BaseDirectory}\\season={_season}\\";
			if (!Directory.Exists(_fullSeasonFilenamePath))
			{
				Directory.CreateDirectory(_fullSeasonFilenamePath);
			}
		}

		public void CollectionEvent(CollectionStatus status, string collection)
		{
			OnCollectionEvent(this, new CollectionEventArgs(status, collection));
		}

		public async void ProcessCollection()
		{
			_logger = new RunLogger();
			LogRunInfo();

			CollectionEvent(CollectionStatus.Started, "RUN");
			_client = new RestClient(_baseUrlForStatsApiWeb);
			//ExtractGameDetails(_runParameters.RunDate.Value);
			await RunCollections();

			CollectionEvent(CollectionStatus.Completed, "DONE");
			_logger.WriteLogLineFinished();
		}

		/// <summary>
		/// Check for directories, create if not found
		/// </summary>
		private void CheckPaths()
		{
			if (!Directory.Exists(_fullSeasonFilenamePath))
			{
				Directory.CreateDirectory(_fullSeasonFilenamePath);
			}

			if (!Directory.Exists(_fullMonthlyFilenamePath))
			{
				Directory.CreateDirectory(_fullMonthlyFilenamePath);
			}

			if (!Directory.Exists(_fullDailyFilenamePath))
			{
				Directory.CreateDirectory(_fullDailyFilenamePath);
			}
		}

		private void GetFilePaths(DateTime date)
		{
			_fullMonthlyFilenamePath = _fullSeasonFilenamePath + $"month={date.Month:00}\\";
			_fullDailyFilenamePath = _fullMonthlyFilenamePath + $"day={date.Day:00}\\";
			CheckPaths();
		}

		/// <summary>
		/// Runs the various data collections
		/// </summary>
		/// <returns></returns>
		private async Task RunCollections()
		{
			await CollectScheduleFromStatsApi();
			await CollectLookupData();
			await CollectTeamsFromStatsApi();
			if (_runParameters.IsFullSeasonRun)
			{
				DateTime scheduleDate;
				// extract dates from the schedule
				foreach (StatsDate date in _schedule.Dates)
				{
					if (int.TryParse(date.Date.Substring(0, 4), out int year)
						&& int.TryParse(date.Date.Substring(5, 2), out int month)
						&& int.TryParse(date.Date.Substring(8, 2), out int day))
					{
						scheduleDate = new DateTime(year, month, day);
						if (scheduleDate > DateTime.Now)
						{
							break;
						}

						GetFilePaths(scheduleDate);
						if (_runParameters.IsRunPlayByPlay)
						{
							foreach (StatsGame game in date.Games)
							{
								await CollectRosterFromStatsApiById(game.Teams.Home.Team.Id);
								await CollectRosterFromStatsApiById(game.Teams.Away.Team.Id);
								if (long.TryParse(game.GamePk, out long gameId))
								{
									string jsonContent = await CollectGamePlayByPlayByGameId(gameId);
									await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.LiveFeed, _fullDailyFilenamePath + "livefeed\\", $"livefeed_{gameId}", $"", "");
									CollectionEvent(CollectionStatus.CollectionDone, $"GameId: {gameId}");
								}
								else
								{
									_logger.WriteLogLine($"Error: Couldn't convert gamePk {game.GamePk} to a long");
								}
							}
						}
					}
					else
					{
						// log error
						_logger.WriteLogLine($"Error:  Couldn't covert date string {date} to a date");
					}
				}
			}
			else
			{
				GetFilePaths(_runParameters.RunDate.Value);
				await CollectTeamsFromStatsApi();
				await CollectRostersByDate(_runParameters.RunDate.Value);
				await CollectGamePlayByPlayFromStatsApi(_runParameters.RunDate.Value);
			}
		}

		/// <summary>
		/// Gets all the team rosters for teams that are scheduled on the given date
		/// </summary>
		/// <param name="date"></param>
		/// <returns></returns>
		private async Task CollectRostersByDate(DateTime date)
		{
			string dateAsString = $"{date.Year}-{date.Month}-{date.Day}";
			StatsDate statsDate = _schedule.Dates.Where(d => d.Date == dateAsString).FirstOrDefault();
			if (statsDate != null)
			{
				foreach (StatsGame game in statsDate.Games)
				{
					await CollectRosterFromStatsApiById(game.Teams.Home.Team.Id);
					await CollectRosterFromStatsApiById(game.Teams.Away.Team.Id);
				}
			}
		}

		/// <summary>
		/// In theory the "season" data shouldn't change.  There may be rare occurrences where a game
		/// gets rescheduled.  Unknown at this point whether the underlying data would change.  Some
		/// of the date-related data would change, but would the gamePk (gameId) change?
		/// </summary>
		/// <param name="statsApiType"></param>
		/// <returns></returns>
		private bool HasSeasonLookupData(Helpers.StatsAPIType statsApiType)
		{
			bool fileExists = false;
			switch (statsApiType)
			{
				case Helpers.StatsAPIType.PlayType:
					if (File.Exists(_fullSeasonFilenamePath + "play_types.json")) { fileExists = true; }
					break;
				case Helpers.StatsAPIType.Teams:
					if (File.Exists(_fullSeasonFilenamePath + "teams.json")) { fileExists = true; }
					break;
				case Helpers.StatsAPIType.Schedule:
					if (File.Exists(_fullSeasonFilenamePath + "schedule.json")) { fileExists = true; }
					break;
			}

			return fileExists;
		}

		#region Lookups
		/// <summary>
		/// Collects the Lookup data
		/// </summary>
		/// <returns></returns>
		private async Task CollectLookupData()
		{
			if (HasSeasonLookupData(Helpers.StatsAPIType.PlayType)) return;

			var request = new RestRequest("playTypes");
			var response = await _client.GetAsync(request);
			string jsonContent = response.Content;
			await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.PlayType, _fullSeasonFilenamePath, "play_types", "", "");
			CollectionEvent(CollectionStatus.CollectionDone, "Play Types");
		}
		#endregion

		#region Teams
		private async Task CollectTeamsFromStatsApi()
		{
			// only collect the team data if it hasn't been pulled for the season
			if (HasSeasonLookupData(Helpers.StatsAPIType.Teams))
			{
				string json = GetJsonFromFile(_fullSeasonFilenamePath + "teams.json");
				if (!string.IsNullOrEmpty(json))
				{
					_teamIds = ExtractTeamIds(json);
				}

				return;
			}

			try
			{
				var request = new RestRequest("teams");
				var response = await _client.GetAsync(request);
				string jsonContent = response.Content;
				await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.Teams, _fullSeasonFilenamePath, "teams", "", "");
				CollectionEvent(CollectionStatus.CollectionDone, $"Teams");

				_teamIds = ExtractTeamIds(jsonContent);
			}
			catch (Exception e)
			{
				Console.WriteLine(e.Message);
				Console.WriteLine(e.StackTrace);
			}
		}

		private int[] ExtractTeamIds(string json)
		{
			JObject jobject = JObject.Parse(json);
			JArray teams = (JArray)jobject["teams"];
			int[] ids = new int[teams.Count];
			for (int i = 0; i < ids.Length; i++)
			{
				ids[i] = (int)teams[i]["id"];
			}

			return ids;
		}
		#endregion

		#region Roster
		private async Task CollectRosterFromStatsApi()
		{
			try
			{
				foreach (int id in _teamIds)
				{
					if (File.Exists(_fullDailyFilenamePath + $"rosters\\roster_{id}.json"))
					{
						continue;
					}

					var request = new RestRequest($"teams/{id}/roster");
					var response = await _client.GetAsync(request);
					string jsonContent = response.Content;
					await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.Teams, _fullDailyFilenamePath + "rosters\\", $"roster_{id}", "", "");
					CollectionEvent(CollectionStatus.CollectionDone, $"Roster for team: {id}");
				}
			}
			catch (Exception e)
			{
				Console.WriteLine(e.Message);
				Console.WriteLine(e.StackTrace);
			}
		}

		/// <summary>
		/// Collects the team roster data for the given team id
		/// </summary>
		/// <param name="id"></param>
		/// <returns></returns>
		private async Task CollectRosterFromStatsApiById(int id)
		{
			try
			{
				// only collect roster data if it doesn't exist for the day
				if (File.Exists(_fullDailyFilenamePath + $"rosters\\roster_{id}.json"))
				{
					return;
				}

				var request = new RestRequest($"teams/{id}/roster");
				var response = await _client.GetAsync(request);
				string jsonContent = response.Content;
				await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.Teams, _fullDailyFilenamePath + "rosters\\", $"roster_{id}", "", "");
				CollectionEvent(CollectionStatus.CollectionDone, $"Roster for team: {id}");
			}
			catch (Exception e)
			{
				Console.WriteLine(e.Message);
				Console.WriteLine(e.StackTrace);
			}
		}
			#endregion

			#region Season Schedule
			private async Task CollectScheduleFromStatsApi()
		{
			if (HasSeasonLookupData(Helpers.StatsAPIType.Schedule))
			{
				string json = GetJsonFromFile(_fullSeasonFilenamePath + $"{Helpers.StatsAPIType.Schedule.ToString().ToLower()}.json");
				DeserializeSchedule(json);
				return;
			}

			var request = new RestRequest($"schedule?season={_season.Replace("-", "20")}");
			var response = await _client.GetAsync(request);
			string jsonContent = response.Content;
			await WriteJsonToDisk (jsonContent, Helpers.StatsAPIType.Schedule, _fullSeasonFilenamePath, "schedule", "", "");
			CollectionEvent(CollectionStatus.CollectionDone, "Schedules");
			DeserializeSchedule(jsonContent);
		}

		private void DeserializeSchedule(string scheduleJson)
		{
			_schedule = JsonConvert.DeserializeObject<StatsSchedule>(scheduleJson);
		}
		#endregion

		#region GamePlayByPlay
		private async Task CollectGamePlayByPlayFromStatsApi(DateTime dateToRun)
		{
			if (!HasSeasonLookupData(Helpers.StatsAPIType.Schedule)) { return; }

			string json = GetJsonFromFile(_fullSeasonFilenamePath + $"{Helpers.StatsAPIType.Schedule.ToString().ToLower()}.json");
			if (!string.IsNullOrEmpty(json))
			{
				_gameIds = GetGameIds(json, dateToRun.Date);
			}

			if (_gameIds.Length > 0)
			{
				try
				{
					foreach (long gameId in _gameIds)
					{
						string jsonContent = await CollectGamePlayByPlayByGameId(gameId);
						await WriteJsonToDisk(jsonContent, Helpers.StatsAPIType.LiveFeed, _fullDailyFilenamePath + "livefeed\\", $"livefeed_{gameId}", $"", "");
						CollectionEvent(CollectionStatus.CollectionDone, $"Play by play for game: {gameId}");
					}
				}
				catch (Exception e)
				{
					Console.WriteLine(e.Message);
					Console.WriteLine(e.StackTrace);
				}
			}
		}

		private string GetJsonFromFile(string filepath)
		{
			return File.ReadAllText(filepath);
		}

		/// <summary>
		/// Fetches the play by play data for the given game Id
		/// </summary>
		/// <param name="gameId">Game Id to fetch data for (note: this is the gamePk property)</param>
		/// <returns>The data as json</returns>
		private async Task<string> CollectGamePlayByPlayByGameId(long gameId)
		{
			var request = new RestRequest($"game/{gameId}/feed/live");
			var response = await _client.GetAsync(request);
			return response.Content;
		}

		/// <summary>
		/// Gets the gameIds for the given date and json data
		/// </summary>
		/// <param name="json">The json to pull the gameIds from</param>
		/// <param name="date">The date to get the gameIds for</param>
		/// <returns></returns>
		private long[] GetGameIds(string json, DateTime date)
		{
			Dictionary<DateTime, long[]> gameDateDictionary = ExtractGameIds(json, date);
			long[] gameIds = new long[1];
			if (_runParameters.IsFullSeasonRun)
			{
				foreach (KeyValuePair<DateTime, long[]> kvp in gameDateDictionary)
				{
					//gameIds. = gameDateDictionary
				}
			}
			else if (gameDateDictionary.ContainsKey(date))
			{
				gameIds = gameDateDictionary[date.Date];
			}
			else
			{
				gameIds = new long[0];
			}

			return gameIds;
		}

		/// <summary>
		/// Extracts the list of gameIds from the json data
		/// </summary>
		/// <param name="json"></param>
		/// <param name="dateToRun"></param>
		/// <returns>a Dictionary containing the date as the key and an array of long gameIds</returns>
		private Dictionary<DateTime, long[]> ExtractGameIds(string json, DateTime dateToRun)
		{
			JObject jobject = JObject.Parse(json);
			JArray dates = (JArray)jobject["dates"];
			int[] dateArray = new int[dates.Count];
			Dictionary<DateTime, long[]> gameDateDictionary = new Dictionary<DateTime, long[]>();
			for (int i = 0; i < dateArray.Length; i++)
			{
				DateTime? date = Helpers.GetDateFromJsonDate((string)dates[i]["date"]);
				if (!date.HasValue)
				{
					continue;
				}

				// if running single date, only get games on that date
				if (!_runParameters.IsFullSeasonRun && date.Value != dateToRun)
				{
					continue;
				}

				JArray games = (JArray)dates[i]["games"];
				List<long> theGameIds = games.Select(g => (long)g["gamePk"]).ToList();
				if (!gameDateDictionary.ContainsKey(date.Value.Date))
				{
					gameDateDictionary.Add(date.Value.Date, theGameIds.ToArray());
				}
			}

			return gameDateDictionary;
		}

		private void ExtractGameDetails(DateTime dateToRun)
		{
			string json = GetJsonFromFile(_fullSeasonFilenamePath + $"{Helpers.StatsAPIType.Schedule.ToString().ToLower()}.json");

			JObject jobject = JObject.Parse(json);
			JArray dates = (JArray)jobject["dates"];
			string searchDate = $"{dateToRun.Year}-{dateToRun.Month}-{dateToRun.Day}";
			string datesKey = "$..dates[?(@.date == '" + searchDate + "')]";
			IEnumerable<JToken> gameInfo = jobject.SelectTokens(datesKey);
			JArray temp = (JArray)jobject[datesKey]["games"]["teams"];
			if (gameInfo.Count() > 0)
			{
				IEnumerable<JToken> games = gameInfo.First();
				foreach (JToken game in games)
				{
					JArray teams = (JArray)game["teams"];
				}
			}
		}

		//private long ExtractGameIdByDate(string json, DateTime date)
		//{
		//	JObject jobject = JObject.Parse(json);
		//	var gameId =
		//		from g in jobject["dates"]["date"]
		//			.Where(d => d["date"].Value<string>() == Helpers.FormatDateForJsonSearch(date))
		//			.SelectMany(d => d["games"])
		//		select g;

		//	return gameId.Value<long>();
		//}
		#endregion

		/// <summary>
		/// Writes the JSON string to a file
		/// </summary>
		/// <param name="json"></param>
		/// <param name="statsType"></param>
		/// <param name="statsFilename"></param>
		/// <param name="Id">Id of the data being collected</param>
		/// <param name="IdName">Name of the Id</param>
		private async Task WriteJsonToDisk(string json, Helpers.StatsAPIType statsType, string path, string statsFilename, string Id, string IdName)
		{
			if (!Directory.Exists(path))
			{
				Directory.CreateDirectory(path);
			}

			using StreamWriter file = new StreamWriter($"{path}{statsFilename}{Id}.json", append: false);
			await file.WriteLineAsync(json);
			bool showId = string.IsNullOrEmpty(Id) ? false : true;
			string logOtherInfo = showId ? $"({IdName}={Id})" : string.Empty;
			_logger.WriteLogLine($"StatsAPI {statsType} {logOtherInfo} Done");
		}

		private void LogRunInfo()
		{
			_logger.WriteLogLine($"Running NHL Stats Collection.....");
			_logger.WriteLogLine($"\tParameters:");
			_logger.WriteLogLine($"\t\tRun Full Season? {_runParameters.IsFullSeasonRun}");
			_logger.WriteLogLine($"\t\tRun Play By Play? {_runParameters.IsRunPlayByPlay}");
			_logger.WriteLogLine($"\t\tRun Date: {_runParameters.RunDate.Value.ToShortDateString()}");
			_logger.WriteLogLine($"\t\tBase Directory: {_runParameters.BaseDirectory}");
		}
	}
}
