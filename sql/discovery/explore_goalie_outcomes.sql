USE nhl_stats_ldw
GO

select
	 gpd.game_id
	,gpd.game_type
	,gpd.play_event
	,gpd.play_description
	--,gpd.period
	--,gpd.period_time
	,dbo.udfGetPeriodTime(period_time, period) 'run_period_time'
	--,gpd.date_time
	,gpd.player_0
	,dbo.udfGetPlayerPosition(gpd.player_0) 'player_0_position'
	--,p0.player_name
	,gpd.player_0_type
	,gpd.player_1
	,dbo.udfGetPlayerPosition(gpd.player_1) 'player_1_position'
	--,p1.player_name
	,gpd.player_1_type
	,gpd.player_2
	,dbo.udfGetPlayerPosition(gpd.player_2) 'player_2_position'
	--,p2.player_name
	,gpd.player_2_type
	,gpd.player_3
	,dbo.udfGetPlayerPosition(gpd.player_3) 'player_3_position'
	--,p3.player_name
	,gpd.player_3_type
	--,gpd.coordinates_x
	--,gpd.coordinates_y
from bronze.game_play_data gpd

where gpd.month = '1' and gpd.day = '8' and gpd.game_id = 2021020615
	-- select the appropriate plays (note: goalies occasionally take penalties)
	AND gpd.play_event in ('Shot', 'Blocked Shot', 'Missed Shot', 'Goal')
	AND (gpd.player_0 IN (SELECT 
							player_id
						FROM bronze.roster
						WHERE position_code = 'G'

						GROUP BY
							player_id)
	OR gpd.player_1 IN (SELECT 
							player_id
						FROM bronze.roster
						WHERE position_code = 'G'

						GROUP BY
							player_id)
	OR gpd.player_2 IN (SELECT 
							player_id
						FROM bronze.roster
						WHERE position_code = 'G'

						GROUP BY
							player_id)
	OR gpd.player_3 IN (SELECT 
							player_id
						FROM bronze.roster
						WHERE position_code = 'G'

						GROUP BY
							player_id))

order by gpd.month, gpd.day, gpd.game_id, gpd.event_index

--SELECT 
--	player_id
--FROM bronze.roster
--WHERE position_code = 'G'

--GROUP BY
--	player_id