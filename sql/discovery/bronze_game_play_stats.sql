use nhl_stats_ldw
go


--select season, month, day, count(game_id) from bronze.game_play_data
--group by season, month, day
--order by season, month, day


select
	 gpd.game_id
	,gpd.game_type
	,gpd.play_event
	,gpd.play_description
	,gpd.period
	,gpd.period_time
	,dbo.udfGetPeriodTime(period_time, period) 'run_period_time'
	,gpd.date_time
	,gpd.player_0
	--,p0.player_name
	,gpd.player_0_type
	,gpd.player_1
	--,p1.player_name
	,gpd.player_1_type
	,gpd.player_2
	--,p2.player_name
	,gpd.player_2_type
	,gpd.player_3
	--,p3.player_name
	,gpd.player_3_type
	,gpd.coordinates_x
	,gpd.coordinates_y
from bronze.game_play_data gpd

--left join bronze.roster p0
--on gpd.player_0 = p0.player_id
--left join bronze.roster p1
--on gpd.player_1 = p1.player_id
--left join bronze.roster p2
--on gpd.player_2 = p2.player_id
--left join bronze.roster p3
--on gpd.player_3 = p3.player_id

where gpd.month = '1' and gpd.day = '8' and gpd.game_id = 2021020615
	AND gpd.play_event in ('Shot', 'Blocked Shot', 'Missed Shot', 'Goal')

order by gpd.month, gpd.day, gpd.game_id, gpd.event_index