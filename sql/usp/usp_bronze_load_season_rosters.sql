USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_season_rosters
	@season VARCHAR(8)
AS
BEGIN
	CREATE TABLE #season_sched_teams (
		table_id INT,
		season VARCHAR(8),
		game_date_local DATETIME2,
		month VARCHAR(2),
		day VARCHAR(2),
		away_team_id TINYINT,
		home_team_id TINYINT
	)

	INSERT INTO #season_sched_teams
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
		DATEADD("hh", -8, CAST(game_date AS DATETIME2)) game_date_local,
		FORMAT(MONTH(dATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') as month, 
		FORMAT(DAY(dATEADD("hh", -8, CAST(game_date AS DATETIME2))), '00') as day, 
		away_team_id, 
		home_team_id
	FROM bronze.schedule
	WHERE season = @season
		--AND MONTH(dATEADD("hh", -8, CAST(game_date AS DATETIME2))) = 1
		--AND DAY(dATEADD("hh", -8, CAST(game_date AS DATETIME2))) = 1
	GROUP BY season, 
		DATEADD("hh", -8, CAST(game_date AS DATETIME2)),
		MONTH(DATEADD("hh", -8, CAST(game_date AS DATETIME2))),
		DAY(DATEADD("hh", -8, CAST(game_date AS DATETIME2))), 
		FORMAT(MONTH(game_date), '00'),
		FORMAT(DAY(game_date), '00'), away_team_id, home_team_id

	DECLARE @month VARCHAR(2),
			@day VARCHAR(2),
			@away_team_id TINYINT,
			@home_team_id TINYINT

	DECLARE @total_rows INT = (SELECT COUNT(*) FROM #season_sched_teams), @i INT = 1

	WHILE @i < @total_rows
	BEGIN
		SELECT @season = season,
				@month = month,
				@day = day,
				@away_team_id = away_team_id,
				@home_team_id = home_team_id
		FROM #season_sched_teams
		WHERE table_id = @i

		EXEC bronze.usp_bronze_load_roster @season, @month, @day, @away_team_id;
		EXEC bronze.usp_bronze_load_roster @season, @month, @day, @home_team_id;

		SET @i = @i + 1
	END

	DROP TABLE #season_sched_teams;
END