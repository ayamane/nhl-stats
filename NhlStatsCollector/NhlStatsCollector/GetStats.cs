using Newtonsoft.Json;
using NhlStatsCollector.StatsAPIClasses;
using NhlStatsCollector.StatsIOClasses;
using RestSharp;
using System;
using System.Collections.Generic;
using System.IO;

namespace NhlStatsCollector
{
	public class GetStats
	{
		private readonly string _baseDirectory = @"c:\nhl\nhl_stats";
		private readonly string _baseUrlForStatsIO = "https://api.sportsdata.io/v3/nhl/scores/json/";
		private readonly string _statsIOKey = "Ocp-Apim-Subscription-Key";
		private readonly string _statsIOSecret = "a807aca35c8b407bacf64deea8353b79";

		private string _jsonContent = string.Empty;
		private List<IOTeam> _teams;
		private DateTime _runDate = DateTime.Now;

		public GetStats(DateTime? dateToRun)
		{
			_runDate = dateToRun ?? DateTime.Now;
			Helpers.CheckDirectories(_baseDirectory, _runDate);

			DeserializeTeams();
		}

		private void CollectTeamsFromSportsData<T>()
		{
			string requestUrl = _baseUrlForStatsIO + "teams";

			try
			{
				var client = new RestClient(requestUrl);

				var request = new RestRequest();
				request.AddHeader(_statsIOKey, _statsIOSecret);
				RestResponse response = client.Execute<IOTeam>(request);
				_jsonContent = response.Content;
			 }
			catch (Exception e)
			{
				Console.WriteLine(e.Message);
				Console.WriteLine(e.StackTrace);
			}
		 }

		private void DeserializeTeams()
		{
			List<StatsTeam> statsTeams = JsonConvert.DeserializeObject<List<StatsTeam>>(_jsonContent);
			WriteIOTeamsToDisk();
		}

		private async void WriteIOTeamsToDisk()
		{
			string path = $"{_baseDirectory}\\{_runDate.Year}\\{_runDate.Month:00}\\{_runDate.Day:00}\\ioteams.txt";

			using StreamWriter file = new StreamWriter(path, append: true);
			foreach (IOTeam team in _teams)
			{
				string line = $"{team.TeamID},{team.Key},{team.Active},{team.City},{team.Name}," +
					$"{team.StadiumID},{team.Conference},{team.Division},{team.PrimaryColor},{team.SecondaryColor}," +
					$"{team.TertiaryColor},{team.QuaternaryColor},{team.WikipediaLogoUrl},{team.WikipediaWordMarkUrl}," +
					$"{team.GlobalTeamID}";
				await file.WriteLineAsync(line);
			}
		}

		//private string json =

			// sample IOTeam data
			//@"
			//[
			//	{
			//		'TeamID': 1,
			//		'Key': 'BOS',
			//		'Active': true,
			//		'City': 'Boston',
			//		'Name': 'Bruins',
			//		'StadiumID': 3,
			//		'Conference': 'Eastern',
			//		'Division': 'Atlantic',
			//		'PrimaryColor': '010101',
			//		'SecondaryColor': 'FFB81C',
			//		'TertiaryColor': null,
			//		'QuaternaryColor': null,
			//		'WikipediaLogoUrl': 'https://upload.wikimedia.org/wikipedia/en/1/12/Boston_Bruins.svg',
			//		'WikipediaWordMarkUrl': null,
			//		'GlobalTeamID': 30000001
			//	},
			//	{
			//		'TeamID': 36,
			//		'Key': 'SEA',
			//		'Active': true,
			//		'City': 'Seattle',
			//		'Name': 'Kraken',
			//		'StadiumID': 43,
			//		'Conference': 'Western',
			//		'Division': 'Pacific',
			//		'PrimaryColor': '001425',
			//		'SecondaryColor': '96D8D8',
			//		'TertiaryColor': '355464',
			//		'QuaternaryColor': '639FB6',
			//		'WikipediaLogoUrl': 'https://upload.wikimedia.org/wikipedia/en/4/48/Seattle_Kraken_official_logo.svg',
			//		'WikipediaWordMarkUrl': null,
			//		'GlobalTeamID': 30000036
			//	}
			//]";
	}
}
