using System;
using System.IO;
using System.Threading.Tasks;

namespace NhlStatsCollector
{
	class Program
	{
		private static bool _doneProcessing = false;
		static void Main(string[] args)
		{
			var dateToRun = PromptForValidInput<DateTime>("Enter date to fetch stats for", TryDate);
			var isFullSeasonRun = PromptForValidInput<bool>("Fetch Full Season Stats? Y/N", TryGetBooleanInput);
			var isRunPlayByPlay = PromptForValidInput<bool>("Run Play by Play? Y/N", TryGetBooleanInput);
			var baseDirectory = PromptForValidInput<string>("Enter base folder for results", TryGetDirectory);

			RunParameters parameters = new RunParameters()
			{
				RunDate = dateToRun,
				IsFullSeasonRun = isFullSeasonRun,
				IsRunPlayByPlay = isRunPlayByPlay,
				BaseDirectory = baseDirectory
			};

			Console.WriteLine($"Running Stats Collector for Date: {dateToRun}");
			StatsAPIDataCollector statsCollector = new StatsAPIDataCollector(parameters);
			statsCollector.OnCollectionEvent += StatsCollector_OnCollectionEvent;
			statsCollector.ProcessCollection();

			while (!_doneProcessing)
			{
				Task.Delay(5000);
			}

			if (_doneProcessing)
			{
				Console.WriteLine("Press any key to exit");
				var input = Console.ReadKey();
			}
		}

		private static void StatsCollector_OnCollectionEvent(object sender, CollectionEventArgs e)
		{
			if (e.CollectionStatus == CollectionStatus.CollectionDone)
			{
				Console.WriteLine($"Collection {e.CollectionName} done.");
			}

			if (e.CollectionStatus == CollectionStatus.Completed)
			{
				_doneProcessing = true;
			}
		}

		private static T PromptForValidInput<T>(string prompt, Func<string, Optional<T>> tryParse)
		{
			while (true)
			{
				Console.Write($"{prompt}: ");
				var input = Console.ReadLine();
				var result = tryParse(input);
				if (result.HasValue)
					return result.Value;
				Console.WriteLine("Invalid input.");
			}
		}
		private static Optional<DateTime> TryDate(string input)
		{
			var result = DateTime.TryParse(input, out DateTime runDate);
			if (runDate == DateTime.MinValue)
				return Optional.Empty;

			return runDate;
		}

		private static Optional<bool> TryGetBooleanInput(string input)
		{
			if (!string.Equals(input, "Y", StringComparison.OrdinalIgnoreCase)
				&& !string.Equals(input, "N", StringComparison.OrdinalIgnoreCase))
			{
				return Optional.Empty;
			}

			bool result = input.ToUpper() == "Y" ? true : false;

			return result;
		}

		private static Optional<string> TryGetDirectory(string input)
		{
			if (!Directory.Exists(input))
			{
				return Optional.Empty;
			}

			return input;
		}
	}
}
