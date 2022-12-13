USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_season_game_play
	 @season VARCHAR(8)
	,@month VARCHAR(2) = NULL
	,@day VARCHAR(2) = NULL
AS
BEGIN
	CREATE TABLE #season_sched_games (
		table_id INT,
		season VARCHAR(8),
		game_id INT,
		game_date_local DATETIME2,
		month VARCHAR(2),
		day VARCHAR(2),
		away_team_id TINYINT,
		home_team_id TINYINT
	)

	INSERT INTO #season_sched_games
	SELECT
		ROW_NUMBER() OVER (
			ORDER BY season, 
				DATEADD("hh", -8, CAST(game_date AS DATETIME2)),
				MONTH(dATEADD("hh", -8, CAST(game_date AS DATETIME2))),
				DAY(dATEADD("hh", -8, CAST(game_date AS DATETIME2))), 
				FORMAT(MONTH(game_date), '00'),
				FORMAT(DAY(game_date), '00'),			
				away_team_id), 
		season, 
		game_id,
		DATEADD("hh", -8, CAST(game_date AS DATETIME2)) game_date_local,
		FORMAT(MONTH(DATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') as month, 
		FORMAT(DAY(DATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') as day,
		away_team_id,
		home_team_id
	FROM bronze.schedule
	WHERE season = @season
		AND (@month IS NULL OR FORMAT(MONTH(DATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') = @month)
		AND (@day IS NULL OR FORMAT(DAY(DATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') = @day)

	DECLARE @gameId INT

	DECLARE @total_rows INT = (SELECT COUNT(*) FROM #season_sched_games), @i INT = 1
-- month & day are ending up in bronze table as single digits
	WHILE @i < @total_rows
	BEGIN
		SELECT @season = season,
				@month = month,
				@day = day,
				@gameId = game_id
		FROM #season_sched_games
		WHERE table_id = @i

		EXEC bronze.usp_bronze_load_game_play @season, @month, @day, @gameId;

		SET @i = @i + 1
	END

	DROP TABLE #season_sched_games;
END