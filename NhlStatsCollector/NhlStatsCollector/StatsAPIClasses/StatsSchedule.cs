using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsSchedule
	{
		public string Copyright { get; set; }
		public int TotalGames { get; set; }
		public List<StatsDate> Dates { get; set; }
	}
}
