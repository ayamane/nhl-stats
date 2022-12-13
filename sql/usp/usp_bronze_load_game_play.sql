USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_game_play
	@season VARCHAR(8),
	@month VARCHAR(2),
	@day VARCHAR(2),
	@gameId INT
AS
BEGIN
	DECLARE @gameIdStr NVARCHAR(10)
	SET @gameIdStr = CONVERT(NVARCHAR(10), @gameId)

	DECLARE @execute_sql NVARCHAR(MAX)
	SET @execute_sql = N'
	DECLARE @json NVARCHAR(MAX)
	SELECT @json = BulkColumn FROM OPENROWSET (BULK ''<directory>\season=' + @season + '\month=' + @month + '\day=' + @day + '\livefeed\livefeed_' + @gameIdStr + '.json'', SINGLE_CLOB) as import
	INSERT INTO bronze.game_play_data
	SELECT
		' + @season + ' season,
		' + @month + ' month,
		' + @day + ' day,
		game_id,
		game_type,           
		play_event,    
		play_event_type_id,
		play_description,
		event_index, 
		period,
		period_type,
		period_time,
		period_time_remaining,
		date_time,
		away_goals,
		home_goals,
		coordinates_x,
		coordinates_y,
		CAST(JSON_VALUE(players, ''$[0].player.id'') AS INT) as player_0,
		CAST(JSON_VALUE(players, ''$[0].playerType'') AS VARCHAR(10)) as player_0_type,
		CAST(JSON_VALUE(players, ''$[1].player.id'') AS INT) as player_1,
		CAST(JSON_VALUE(players, ''$[1].playerType'') AS VARCHAR(10)) as player_1_type,
		CAST(JSON_VALUE(players, ''$[2].player.id'') AS INT) as player_2,
		CAST(JSON_VALUE(players, ''$[2].playerType'') AS VARCHAR(10)) as player_2_type,
		CAST(JSON_VALUE(players, ''$[3].player.id'') AS INT) as player_3,
		CAST(JSON_VALUE(players, ''$[3].playerType'') AS VARCHAR(10)) as player_3_type
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
			game_id INT ''$.pk'',
			game_type VARCHAR(2) ''$.type''
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
			play_event VARCHAR(15) ''$.event'',
			play_event_type_id VARCHAR(10) ''$.eventTypeId'',
			play_description VARCHAR(100) ''$.description''
		)
		CROSS APPLY OPENJSON(about)
		WITH (
			event_index SMALLINT ''$.eventIdx'',
			period TINYINT ''$.period'',
			period_type VARCHAR(10) ''$.periodType'',
			period_time VARCHAR(6) ''$.periodTime'',
			period_time_remaining VARCHAR(6) ''$.periodTimeRemaining'',
			date_time DATETIME2 ''$.dateTime'',
			goals NVARCHAR(MAX) AS JSON
		)
		CROSS APPLY OPENJSON(goals)
		WITH (
			away_goals TINYINT ''$.away'',
			home_goals TINYINT ''$.home''
		)
		CROSS APPLY OPENJSON(coordinates)
		WITH (
			coordinates_x VARCHAR(8) ''$.x'',
			coordinates_y VARCHAR(8) ''$.y''
		)'
	--print @execute_sql;
	EXEC sp_executesql @execute_sql;
END