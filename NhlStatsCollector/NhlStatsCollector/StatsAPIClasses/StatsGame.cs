using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsGame
	{
		public string GamePk { get; set; }
		public string Link { get; set; }
		public string GameType { get; set; }
		public string Season { get; set; }
		public string GameDate { get; set; }
		public StatsTeamCollection Teams { get; set; }
	}
}
