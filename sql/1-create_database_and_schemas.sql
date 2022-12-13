USE master
GO

CREATE DATABASE nhl_stats_ldw
GO

ALTER DATABASE nhl_stats_ldw COLLATE Latin1_General_100_BIN2_UTF8
GO

USE nhl_stats_ldw
GO

-- schema for raw data
CREATE SCHEMA bronze
GO

