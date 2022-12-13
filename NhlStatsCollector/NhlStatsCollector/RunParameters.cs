using System;

namespace NhlStatsCollector
{
	public class RunParameters
	{
		public DateTime? RunDate { get; set; }
		public bool IsFullSeasonRun { get; set; } = false;
		public bool IsRunPlayByPlay { get; set; } = false;
		public string BaseDirectory { get; set; }
	}
}
