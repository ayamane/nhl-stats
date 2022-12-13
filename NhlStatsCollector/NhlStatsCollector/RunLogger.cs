using System;
using System.IO;

namespace NhlStatsCollector
{
	public class RunLogger : IDisposable
	{
		private readonly string _baseDirectory = @"c:\nhl\nhl_stats\logs";
		private readonly string _fullPath;
		private readonly DateTime _today = DateTime.Now;
		private StreamWriter _logger;

		public RunLogger()
		{
			Helpers.CheckDirectories(_baseDirectory, _today);

			_fullPath = $"{_baseDirectory}\\{_today.Year}\\{_today.Month:00}\\{_today.Day:00}\\";
			_logger = new StreamWriter($"{_fullPath}{_today.Year}{_today.Month:00}{_today.Day:00}log.txt", append: true);
			WriteLogLine("Starting logger");
		}

		public void WriteLogLine(string logline)
		{
			_logger?.WriteLine($"{DateTime.Now:O},{logline}");
		}

		public void WriteLogLineFinished()
		{
			_logger?.WriteLine($"{DateTime.Now:O},Finished Data Collection");
			this.Dispose();
		}

		public void Dispose()
		{
			if (_logger != null)
			{
				_logger.Dispose();
				_logger = null;
			}
		}
	}
}
