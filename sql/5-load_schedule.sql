USE nhl_stats_ldw
GO

DECLARE @json NVARCHAR(MAX)
SELECT @json = BulkColumn FROM OPENROWSET (BULK '<directory>\season=2021-22\schedule.json', SINGLE_CLOB) as import

INSERT INTO bronze.schedule
SELECT
    '2021-22' as season,
    game_id,    
    game_link,  
    game_type,  
    season_name,
    total_games,
    game_date,  
    venue_id,   
    away_team_id,  
    away_team_name,
    home_team_id,  
    home_team_name 
FROM OPENJSON(@json)
    WITH ( 
        metaData NVARCHAR(MAX) AS JSON,
        dates NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(dates)
    WITH (
        date VARCHAR(10),
        totalItems TINYINT,
        total_games TINYINT '$.totalGames',
        games NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(games)
    WITH (
        game_id INT '$.gamePk',
        game_link VARCHAR(35) '$.link',
        game_type VARCHAR(2) '$.gameType',
        season_name VARCHAR(8) '$.season',
        game_date VARCHAR(20) '$.gameDate',
        teams NVARCHAR(MAX) AS JSON,
        venue NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(venue)
    WITH (
        venue_id SMALLINT '$.id'
    )
    CROSS APPLY OPENJSON(teams)
    WITH (
        away NVARCHAR(MAX) AS JSON,
        home NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(away)
    WITH (
        away_team NVARCHAR(MAX) '$.team' AS JSON
    )
    CROSS APPLY OPENJSON(away_team)
    WITH (
        away_team_id SMALLINT '$.id',
        away_team_name VARCHAR(20) '$.name'
    )
    CROSS APPLY OPENJSON(home)
    WITH (
        home_team NVARCHAR(MAX) '$.team' AS JSON
    )
    CROSS APPLY OPENJSON(home_team)
    WITH (
        home_team_id SMALLINT '$.id',
        home_team_name VARCHAR(20) '$.name'
    )