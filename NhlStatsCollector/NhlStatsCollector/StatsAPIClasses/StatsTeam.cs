using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector.StatsAPIClasses
{
	public class StatsTeam
	{
		public int Id { get; set; }
		public string Name { get; set; }
		public string Link { get; set; }
		public StatsVenue Venue { get; set; }
		public string Abbreviation { get; set; }
		public string TeamName { get; set; }
		public string LocationName { get; set; }
		public string FirstYearOfPlay { get; set; }
		public StatsDivision Division { get; set; }
		public StatsConference Conference { get; set; }
		public StatsFranchise Franchise { get; set; }
		public string ShortName { get; set; }
		public string OfficialSiteUrl { get; set; }
		public int FranchiseId { get; set; }
		public bool Active { get; set; }
	}
}
