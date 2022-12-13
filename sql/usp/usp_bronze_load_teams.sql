USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_teams
	@season VARCHAR(8)
AS
BEGIN
	DECLARE @execute_sql NVARCHAR(MAX)
	SET @execute_sql = N'
	DECLARE @json NVARCHAR(MAX)
	SELECT @json = BulkColumn FROM OPENROWSET (BULK ''<directory>\season=' + @season + '\teams.json'', SINGLE_CLOB) as import;
	INSERT INTO bronze.teams
	SELECT
		''' + @season + ''',
		id,      -- 55
		name,  -- 21
		team_link,  -- 16
		team_abbrev,    -- 3
		team_name,    -- 14
		location_name,    -- 12
		first_year_of_play,  -- 4
		short_name,  -- 12
		official_site_url,    -- 34
		active,        -- 1
		venue_name,       -- 24
		venue_link,  -- 19
		venue_city,  -- 12
		division_id,   -- 18
		division_name,    -- 12
		division_name_short,    -- 5
		division_link,    -- 20
		division_abbrev,   -- 1
		conference_id,    -- 6
		conference_name,    -- 7
		conference_link,    -- 21
		franchise_id,      -- 39
		franchise_team_name,    -- 14
		franchise_link       -- 21
	FROM OPENJSON(@json)
	WITH
	(
		copyright NVARCHAR(MAX),
		teams NVARCHAR(MAX) AS JSON
	) as jsonDoc
	CROSS APPLY OPENJSON(teams)
		WITH (
			id TINYINT,
			name VARCHAR(25),
			team_link VARCHAR(25) ''$.link'',
			team_abbrev VARCHAR(4) ''$.abbreviation'',
			team_name VARCHAR(20) ''$.teamName'',
			location_name VARCHAR(15) ''$.locationName'',
			first_year_of_play SMALLINT ''$.firstYearOfPlay'',
			short_name VARCHAR(15) ''$.shortName'',
			official_site_url VARCHAR(40) ''$.officialSiteUrl'',
			franchise_id TINYINT ''$.franchiseId'',
			active BIT,
			/* child json */
			venue NVARCHAR(MAX) AS JSON,
			division NVARCHAR(MAX) AS JSON,
			conference NVARCHAR(MAX) AS JSON,
			franchise NVARCHAR(MAX) AS JSON
		) as team
		CROSS APPLY OPENJSON(venue)
		WITH (
			venue_name VARCHAR(30) ''$.name'',
			venue_link VARCHAR(25) ''$.link'',
			venue_city VARCHAR(15) ''$.city''
			-- also contains child timeZone with id, offset, tz keys
		) AS team_venue
		CROSS APPLY OPENJSON(division)
		WITH (
			division_id TINYINT ''$.id'',
			division_name VARCHAR(15) ''$.name'',
			division_name_short VARCHAR(5) ''$.nameShort'',
			division_link VARCHAR(25) ''$.link'',
			division_abbrev VARCHAR(1) ''$.abbreviation''
		) as league_divisions
		CROSS APPLY OPENJSON(conference)
		WITH (
			conference_id TINYINT ''$.id'',
			conference_name VARCHAR(10) ''$.name'',
			conference_link VARCHAR(25) ''$.link''
		) as league_conferences
		CROSS APPLY OPENJSON(franchise)
		WITH (
			franchise_team_name VARCHAR(20) ''$.teamName'',
			franchise_link VARCHAR(25) ''$.link''
		) as franchises';

	EXEC sp_executesql @execute_sql;
END

