using System;
using System.Collections.Generic;
using System.Text;

namespace NhlStatsCollector
{
	public class CollectionEventArgs : EventArgs
	{
		public CollectionStatus CollectionStatus { get; set; }
		public string CollectionName { get; set; }
		public CollectionEventArgs(CollectionStatus status, string collectionName)
		{
			CollectionStatus = status;
			CollectionName = collectionName;
		}
	}

	public enum CollectionStatus
	{
		Started,
		Processing,
		CollectionDone,
		Completed
	}
}
