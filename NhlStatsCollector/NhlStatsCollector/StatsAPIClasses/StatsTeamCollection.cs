using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsTeamCollection
	{
		public StatsGameTeamDetails Away { get; set; }
		public StatsGameTeamDetails Home { get; set; }
	}
}
