using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Globalization;

namespace NhlStatsCollector
{
	public static class Helpers
	{
		public static void CheckDirectories(string directory, DateTime date)
		{
			if (!Directory.Exists($"{directory}\\{date.Year}"))
			{
				Directory.CreateDirectory($"{directory}\\{date.Year}");
			}

			if (!Directory.Exists($"{directory}\\{date.Year}\\{date.Month:00}"))
			{
				Directory.CreateDirectory($"{directory}\\{date.Year}\\{date.Month:00}");
			}

			if (!Directory.Exists($"{directory}\\{date.Year}\\{date.Month:00}\\{date.Day:00}"))
			{
				Directory.CreateDirectory($"{directory}\\{date.Year}\\{date.Month:00}\\{date.Day:00}");
			}
		}

		/// <summary>
		/// Converts a date to a string in the format YYYY-MM-DD
		/// </summary>
		/// <param name="dateToFormat">The date to format</param>
		/// <returns>A string in YYYY-MM-DD format</returns>
		public static string FormatDateForJsonSearch(DateTime dateToFormat)
		{
			return $"{dateToFormat.Year}-{dateToFormat.Month:00}-{dateToFormat.Day:00}";
		}

		/// <summary>
		/// Gets a <see cref="DateTime"/> for the given date string
		/// formatted as YYYY-MM-DD
		/// </summary>
		/// <param name="dateString">The date string to convert</param>
		/// <returns>The date as a DateTime object</returns>
		public static DateTime? GetDateFromJsonDate(string dateString)
		{
			if (string.IsNullOrEmpty(dateString)) { return null; }

			CultureInfo culture = CultureInfo.CreateSpecificCulture("en-US");
			string[] dateParts = dateString.Split('-');
			if (dateParts.Length >= 3 && DateTime.TryParse($"{dateParts[1]}/{dateParts[2]}/{dateParts[0]}", culture, DateTimeStyles.AssumeLocal, out DateTime date))
			{
				return date;
			}
			else
			{
				return null;
			}
		}

		/// <summary>
		/// Gets the NHL Season as YYYY-YY(+1), e.g. 2022-23, for the given
		/// date.  Assumes the league year runs 8/1 - 7/31
		/// </summary>
		/// <param name="date">The date to get the season for</param>
		/// <returns>The NHL season or an empty string if the date has no value</returns>
		public static string GetSeasonStringForPath(DateTime? date)
		{
			if (!date.HasValue)
			{
				return string.Empty;
			}

			string season = string.Empty;

			// NHL Season will be defined as start 8/01/YYYY - 7/31/YYYY+1
			if (date.Value.Month >= 8 && date.Value.Month <= 12)
			{
				season = $"{date.Value.Year}-{(date.Value.Year + 1).ToString().Substring(2, 2)}";
			}
			else
			{
				season = $"{date.Value.Year - 1}-{(date.Value.Year).ToString().Substring(2, 2)}";
			}

			return season;
		}

		public enum StatsAPIType
		{
			Teams,
			Roster,
			Schedule,
			LiveFeed,
			PlayType
		}
	}
}
