using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsTimeZone
	{
		public string Id { get; set; }
		public int Offset { get; set; }
		public string Tz { get; set; }
	}
}
