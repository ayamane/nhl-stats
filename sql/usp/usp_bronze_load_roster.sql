USE nhl_stats_ldw
GO

CREATE OR ALTER PROCEDURE bronze.usp_bronze_load_roster
	@season VARCHAR(8),
	@month VARCHAR(2),
	@day VARCHAR(2),
	@teamId TINYINT
AS
BEGIN
	DECLARE @teamIdStr VARCHAR(2)
	SET @teamIdStr = CAST(@teamId AS VARCHAR(2))

	DECLARE @execute_sql NVARCHAR(MAX)
	SET @execute_sql = N'
	DECLARE @json NVARCHAR(MAX)
	SELECT @json = BulkColumn FROM OPENROWSET (BULK ''<directory>\season=' + @season + '\month=' + @month + '\day=' + @day + '\rosters\roster_' + @teamIdStr + '.json'', SINGLE_CLOB) as import

	INSERT INTO bronze.roster
	SELECT 
		''' + @season + ''',
		''' + @month + ''',
		''' + @day + ''',
		' + @teamIdStr + ',
		player_id,
		player_name,
		player_link,
		jersey_nbr,
		position_code,
		position_name,
		position_type,
		position_abbrev
	FROM OPENJSON(@json)
		WITH ( roster NVARCHAR(MAX) AS JSON )
		CROSS APPLY OPENJSON(roster)
		WITH (
			person NVARCHAR(MAX) AS JSON,
			position NVARCHAR(MAX) AS JSON,
			jersey_nbr VARCHAR(2) ''$.jerseyNumber''
		)
		CROSS APPLY OPENJSON(person)
		WITH (
			player_id INT ''$.id'',
			player_name VARCHAR(40) ''$.fullName'',
			player_link VARCHAR(30) ''$.link''
		)
		CROSS APPLY OPENJSON(position)
		WITH (
			position_code VARCHAR(2) ''$.code'',
			position_name VARCHAR(15) ''$.name'',
			position_type VARCHAR(10) ''$.type'',
			position_abbrev VARCHAR(3) ''$.abbreviation''
		);'
		--print @execute_sql;
	EXEC sp_executesql @execute_sql;
END