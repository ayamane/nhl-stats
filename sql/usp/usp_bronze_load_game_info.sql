USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_game_info
	@season VARCHAR(8),
	@month VARCHAR(2),
	@day VARCHAR(2),
	@gameId INT
AS
BEGIN
	DECLARE @gameIdStr VARCHAR(12)
	SET @gameIdStr = CAST(@gameId AS VARCHAR(12))

	DECLARE @execute_sql NVARCHAR(MAX)
	SET @execute_sql = N'
	DECLARE @json NVARCHAR(MAX)
	SELECT @json = BulkColumn FROM OPENROWSET (BULK ''<directory>\season=' + @season + '\month=' + @month + '\day=' + @day + '\livefeed\livefeed_' + @gameIdStr + '.json'', SINGLE_CLOB) as import

	INSERT INTO bronze.game_info
	SELECT
		''' + @season + ''',
		''' + @month + ''',
		''' + @day + ''',
		' + @gameIdStr + ',
		season_name,
		game_type,
		game_datetime,
		end_datetime,
		away_team_id,
		away_team_name,
		away_team_abbrev,
		home_team_id,
		home_team_name,
		home_team_abbrev
	FROM OPENJSON(@json)
		WITH (
			gameData NVARCHAR(MAX) AS JSON,
			game_id INT ''$.gameData.game.pk'',
			season_name VARCHAR(8) ''$.gameData.game.season'',
			game_type VARCHAR(2) ''$.gameData.game.type'',
			game_datetime DATETIME ''$.gameData.datetime.dateTime'',
			end_datetime DATETIME ''$.gameData.datetime.endDateTime''
		)
		CROSS APPLY OPENJSON(gameData)
		WITH (
			game NVARCHAR(MAX) AS JSON,
			teams NVARCHAR(MAX) AS JSON
		)
		CROSS APPLY OPENJSON(teams)
		WITH (
			away NVARCHAR(MAX) AS JSON,
			home NVARCHAR(MAX) AS JSON
		)
		CROSS APPLY OPENJSON(away)
		WITH (
			away_team_id SMALLINT ''$.id'',
			away_team_name VARCHAR(20) ''$.name'',
			away_team_abbrev VARCHAR(4) ''$.abbreviation''
		)
		CROSS APPLY OPENJSON(home)
		WITH (
			home_team_id SMALLINT ''$.id'',
			home_team_name VARCHAR(20) ''$.name'',
			home_team_abbrev VARCHAR(4) ''$.abbreviation''
		)'
--print @execute_sql;
	EXEC @execute_sql;
END