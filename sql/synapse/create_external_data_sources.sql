USE nhl_stats_ldw;

-- find documentation: https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-overview

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'nhl_stats_src')
    CREATE EXTERNAL DATA SOURCE nhl_stats_src
    WITH
    (
        LOCATION = '<azure-storage-account>'
    );