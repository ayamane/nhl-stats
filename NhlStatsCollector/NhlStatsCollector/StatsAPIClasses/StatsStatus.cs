using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsStatus
	{
		public string AbstractGameState { get; set; }
		public string CodedGameState { get; set; }
		public string DetailedState { get; set; }
		public string StatusCode { get; set; }
		public bool StartTimeTBD { get; set; }
	}
}
