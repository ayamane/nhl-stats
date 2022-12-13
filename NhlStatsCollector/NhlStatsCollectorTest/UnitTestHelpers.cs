using NhlStatsCollector;
using System;
using Xunit;

namespace NhlStatsCollectorTest
{
	public class UnitTestHelpers
	{
		[Fact]
		public void TestFormatDateForJsonSearch()
		{
			string jsonDate = "2022-02-22";
			Assert.Equal(jsonDate, Helpers.FormatDateForJsonSearch(new DateTime(2022, 2, 22)));
			Assert.NotEqual(jsonDate, Helpers.FormatDateForJsonSearch(new DateTime(2021, 2, 22)));
		}

		[Fact]
		public void TestGetDateFromJsonDate()
		{
			// should get a valid date or return null if invalid date is passed
			DateTime? date = null;
			Assert.Equal(date, Helpers.GetDateFromJsonDate(string.Empty));
			Assert.Equal(date, Helpers.GetDateFromJsonDate("22-22-22"));
			date = new DateTime(2022, 5, 9);
			Assert.Equal(date, Helpers.GetDateFromJsonDate("2022-05-09"));
		}

		[Fact]
		public void TestGetSeasonStringForPath()
		{
			// should return a string with yyyy-yy(+1), e.g. 2020-21 or empty string if no date passed
			DateTime? date = null;
			Assert.Equal(string.Empty, Helpers.GetSeasonStringForPath(date));
			// check end of season date
			date = new DateTime(2022, 7, 31);
			Assert.Equal("2021-22", Helpers.GetSeasonStringForPath(date));
			// check start of season
			date = date.Value.AddDays(1);
			Assert.Equal("2022-23", Helpers.GetSeasonStringForPath(date));
			// check some other random dates
			Assert.Equal("2022-23", Helpers.GetSeasonStringForPath(new DateTime(2022, 12, 31)));
			Assert.Equal("2022-23", Helpers.GetSeasonStringForPath(new DateTime(2023, 2, 28)));
			Assert.Equal("2022-23", Helpers.GetSeasonStringForPath(new DateTime(2023, 7, 31)));
		}
	}
}
