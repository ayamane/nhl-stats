using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsRoster
	{
		public StatsPerson Person { get; set; }
		public string JerseyNumber { get; set; }
		public StatsPosition Position { get; set; }
		public int TeamId { get; set; }
	}
}
