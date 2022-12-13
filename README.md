# nhl-stats
Collection of projects related to gathering and analyzing publicly accessible statistics and raw data from NHL games.

- NhlStatsCollector - contains the C# code to build the data collector console application.  Collects data from various endpoints of the NHL API (https://statsapi.web.nhl.com/api/v1/) writing to json files
  - Current endpoints collected:  Schedule, PlayTypes, Teams, Rosters, LiveFeed 
  - note: collecting a completed full season (e.g. 2021-22) takes roughly 10 min and 750Mb of free disk space
  - I will work on more documentation as time allows
- sql folder - contains sql scripts for creating the bronze, silver, gold schemas and some of the bronze tables, along with code for loading the json files from the data collector.  Also contains some code for Azure Synapse Analytics if you have access to that and some DataLake gen2 storage
