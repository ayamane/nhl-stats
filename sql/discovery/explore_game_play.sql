USE nhl_stats_ldw
GO

DECLARE @json NVARCHAR(MAX)
SELECT @json = BulkColumn FROM OPENROWSET (BULK '<directory>\season=2021-22\month=01\day=01\livefeed\livefeed_2021020566.json', SINGLE_CLOB) as import
SELECT
    '2021-22' season,
    '01' month,
    '01' day,
    game_id,
    season_name,  
    game_type,           
    play_event,              
    play_event_code,     
    play_event_type_id,
    play_description,
    event_index,
    event_id,   
    period,
    period_type,
    ordinal_nbr,
    period_time,
    period_time_remaining,
    date_time,
    away_goals,
    home_goals,
    coordinates_x,
    coordinates_y,
    CAST(JSON_VALUE(players, '$[0].player.id') AS INT) as player_0,
    CAST(JSON_VALUE(players, '$[0].playerType') AS VARCHAR(10)) as player_0_type,
    CAST(JSON_VALUE(players, '$[1].player.id') AS INT) as player_1,
    CAST(JSON_VALUE(players, '$[1].playerType') AS VARCHAR(10)) as player_1_type,
    CAST(JSON_VALUE(players, '$[2].player.id') AS INT) as player_2,
    CAST(JSON_VALUE(players, '$[2].playerType') AS VARCHAR(10)) as player_2_type,
    CAST(JSON_VALUE(players, '$[3].player.id') AS INT) as player_3,
    CAST(JSON_VALUE(players, '$[3].playerType') AS VARCHAR(10)) as player_3_type
FROM OPENJSON(@json)
    WITH (
        gameData NVARCHAR(MAX) AS JSON,
        liveData NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(gameData)
    WITH (
        game NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(game)
    WITH (
        game_id INT '$.pk',
        season_name VARCHAR(8) '$.season',
        game_type VARCHAR(2) '$.type'
    )
    /* LIVE DATA AREA */
    CROSS APPLY OPENJSON(liveData)
    WITH (
        plays NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(plays)
    WITH (
        allPlays NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(allPlays)
    WITH (
        players NVARCHAR(MAX) AS JSON,
        result NVARCHAR(MAX) AS JSON,
        about NVARCHAR(MAX) AS JSON,
        coordinates NVARCHAR(MAX) AS JSON,
        team NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(result)
    WITH (
        play_event VARCHAR(15) '$.event',
        play_event_code VARCHAR(10) '$.eventCode',
        play_event_type_id VARCHAR(10) '$.eventTypeId',
        play_description VARCHAR(100) '$.description'
    )
    CROSS APPLY OPENJSON(about)
    WITH (
        event_index SMALLINT '$.eventIdx',
        event_id SMALLINT '$.eventId',
        period TINYINT '$.period',
        period_type VARCHAR(10) '$.periodType',
        ordinal_nbr VARCHAR(3) '$.ordinalNum',
        period_time VARCHAR(6) '$.periodTime',
        period_time_remaining VARCHAR(6) '$.periodTimeRemaining',
        date_time DATETIME2 '$.dateTime',
        goals NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(goals)
    WITH (
        away_goals TINYINT '$.away',
        home_goals TINYINT '$.home'
    )
    CROSS APPLY OPENJSON(coordinates)   -- note: x is defined as -99 to 99, y as -42 to 42 (representing 200 x 85' rink)
    WITH (
        coordinates_x VARCHAR(8) '$.x',
        coordinates_y VARCHAR(8) '$.y'
    )