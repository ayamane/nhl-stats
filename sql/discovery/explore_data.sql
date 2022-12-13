USE nhl_stats_ldw
GO

SELECT
	 event_index
	,play_event
	,play_description
	,period
	,period_time
	,period_time_remaining
	,player_0
	,player_0_type
	,player_1
	,player_1_type
	,player_2
	,player_2_type
	,player_3
	,player_3_type
	--,CASE WHEN LEN(period_time) = 4 THEN CONCAT('0', SUBSTRING(period_time, 1, 1)) ELSE SUBSTRING(period_time, 1, 2) END AS 'period_time_minutes'
	--,CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS 'period_time_seconds'
	--,CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC) + --AS 'period_time_minutes_int'
	--CAST(CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS DEC) / 60 AS DEC(5, 2)) AS 'period_time_seconds_dec'
	-- convert the period_time to a game time in decimal format
	,CASE 
		WHEN period = 1 THEN CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC) 
		WHEN period = 2 THEN 20 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
		WHEN period = 3 THEN 40 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
	 END + 
	 CAST(CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS DEC) / 60 AS DEC(5, 2)) AS 'period_time_seconds_dec'
	,LAG(CASE 
		WHEN period = 1 THEN CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC) 
		WHEN period = 2 THEN 20 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
		WHEN period = 3 THEN 40 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
	 END + 
	 CAST(CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS DEC) / 60 AS DEC(5, 2)), 1, 0)
		OVER (ORDER BY event_index) AS prev_time
	-- determine difference from an event to prior event (elapsed time)
	,LAG(CASE 
			WHEN period = 1 THEN CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC) 
			WHEN period = 2 THEN 20 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
			WHEN period = 3 THEN 40 + CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 1, 1) ELSE SUBSTRING(period_time, 1, 2) END AS DEC)
		END
		+ CAST(CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS DEC) / 60 AS DEC(5, 2)), 1, 0)
			OVER (ORDER BY event_index) 
		- CAST(CAST(CASE WHEN LEN(period_time) = 4 THEN SUBSTRING(period_time, 3, 2) ELSE SUBSTRING(period_time, 4, 2) END AS DEC) / 60 AS DEC(5, 2)) AS time_diff

FROM bronze.game_play_data

WHERE play_event IN ('Shot', 'Blocked Shot', 'Missed Shot', 'Goal')

ORDER BY event_index