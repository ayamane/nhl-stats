USE nhl_stats_ldw
GO
DECLARE @json NVARCHAR(MAX)
SELECT @json = BulkColumn FROM OPENROWSET (BULK '<directory>\season=2021-22\play_types.json', SINGLE_CLOB) as import

INSERT INTO bronze.play_types
SELECT 
    '2021-22',
    play_type_name,
    play_type_id,
    play_cms_key,
    play_code,
    player_type,
    CAST(JSON_VALUE(secondaryEventCodes, '$[0]') AS VARCHAR(15)) secondary_event_code_0,
    CAST(JSON_VALUE(secondaryEventCodes, '$[1]') AS VARCHAR(15)) secondary_event_code_1
FROM OPENJSON(@json)
    WITH (
        play_type_name VARCHAR(15)	'$.name',
        play_type_id VARCHAR(15)	'$.id',
        play_cms_key VARCHAR(25)	'$.cmsKey',
        play_code VARCHAR(15)		'$.code',
        playerTypes NVARCHAR(MAX) AS JSON,
        secondaryEventCodes NVARCHAR(MAX) AS JSON
    )
    CROSS APPLY OPENJSON(playerTypes)
    WITH (
        player_type VARCHAR(10) '$.playerType'
    )
GO