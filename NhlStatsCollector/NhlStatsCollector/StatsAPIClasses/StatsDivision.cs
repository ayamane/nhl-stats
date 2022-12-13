using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsDivision
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public string NameShort { get; set; }
		public string Link { get; set; }
		public string Abbreviation { get; set; }
	}
}
