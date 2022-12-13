using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsDate
	{
		/// <summary>
		/// note: formatted as YYYY-MM-DD
		/// </summary>
		public string Date { get; set; }
		public int TotalGames { get; set; }
		public List<StatsGame> Games { get; set; } = new List<StatsGame>();
	}
}
