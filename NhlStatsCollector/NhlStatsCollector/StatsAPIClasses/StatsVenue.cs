using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsVenue
	{
		public string Name { get; set; }
		public string Link { get; set; }
		public string City { get; set; }
		public StatsTimeZone TimeZone { get; set; }
	}
}
