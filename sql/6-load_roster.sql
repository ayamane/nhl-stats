USE nhl_stats_ldw
GO

DECLARE @json NVARCHAR(MAX)
SELECT @json = BulkColumn FROM OPENROWSET (BULK '<discovery>\season=2021-22\month=01\day=01\rosters\roster_55.json', SINGLE_CLOB) as import

INSERT INTO bronze.roster
SELECT 
    '2021-22' season,
    '01' month,
    '01' day,
	55 team,
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
        jersey_nbr VARCHAR(2) '$.jerseyNumber'
    )
    CROSS APPLY OPENJSON(person)
    WITH (
        player_id INT '$.id',
        player_name VARCHAR(40) '$.fullName',
        player_link VARCHAR(30) '$.link'
    )
    CROSS APPLY OPENJSON(position)
    WITH (
        position_code VARCHAR(2) '$.code',
        position_name VARCHAR(15) '$.name',
        position_type VARCHAR(10) '$.type',
        position_abbrev VARCHAR(3) '$.abbreviation'
    )