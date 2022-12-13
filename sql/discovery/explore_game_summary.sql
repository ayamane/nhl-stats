USE nhl_stats_ldw
GO

CREATE TABLE #game_roster (
	team_id TINYINT,
	player_id INT,
	team_type VARCHAR(4)
)

INSERT INTO #game_roster
select s.away_team_id, away.player_id 'player', 'away' from bronze.schedule s
left join bronze.roster away
on s.away_team_id = away.team
where s.game_id = 2021020615
group by s.away_team_id, away.player_id
union all
select s.home_team_id, home.player_id 'player', 'home' from bronze.schedule s
left join bronze.roster home
on s.home_team_id = home.team
where s.game_id = 2021020615
group by s.home_team_id, home.player_id

select
	 gpd.game_id
	,gpd.play_event
	,SUM(CASE WHEN gpd.play_event = 'Shot' AND gpd.player_0_type = 'Shooter' AND p0.team_type = 'home' THEN 1 ELSE 0 END) 'home_shots_on_goal'
	,SUM(CASE WHEN gpd.play_event = 'Blocked Shot' AND gpd.player_0_type = 'Blocker' AND p0.team_type = 'home' THEN 1 ELSE 0 END) 'home_shots_blocked'
	,SUM(CASE WHEN gpd.play_event = 'Missed Shot' AND gpd.player_0_type = 'Shooter' AND p0.team_type = 'home' THEN 1 ELSE 0 END) 'home_shots_missed'
	,SUM(CASE WHEN gpd.play_event = 'Goal' AND gpd.player_0_type = 'Scorer' AND p0.team_type = 'home' THEN 1 ELSE 0 END) 'home_goals'
	,SUM(CASE WHEN gpd.play_event = 'Shot' AND gpd.player_1_type = 'Goalie' AND p1.team_type = 'home' THEN 1 ELSE 0 END) 'home_saves'

	,SUM(CASE WHEN gpd.play_event = 'Shot' AND gpd.player_0_type = 'Shooter' AND p0.team_type = 'away' THEN 1 ELSE 0 END) 'away_shots_on_goal'
	,SUM(CASE WHEN gpd.play_event = 'Blocked Shot' AND gpd.player_0_type = 'Blocker' AND p0.team_type = 'away' THEN 1 ELSE 0 END) 'away_shots_blocked'
	,SUM(CASE WHEN gpd.play_event = 'Missed Shot' AND gpd.player_0_type = 'Shooter' AND p0.team_type = 'away' THEN 1 ELSE 0 END) 'away_shots_missed'
	,SUM(CASE WHEN gpd.play_event = 'Goal' AND gpd.player_0_type = 'Scorer' AND p0.team_type = 'away' THEN 1 ELSE 0 END) 'away_goals'
	,SUM(CASE WHEN gpd.play_event = 'Shot' AND gpd.player_1_type = 'Goalie' AND p1.team_type = 'away' THEN 1 ELSE 0 END) 'away_saves'
from bronze.game_play_data gpd

LEFT JOIN #game_roster p0
ON gpd.player_0 = p0.player_id
LEFT JOIN #game_roster p1
ON gpd.player_1 = p1.player_id
LEFT JOIN #game_roster p2
ON gpd.player_2 = p2.player_id
LEFT JOIN #game_roster p3
ON gpd.player_3 = p3.player_id

where gpd.month = '1' and gpd.day = '8' and gpd.game_id = 2021020615
	AND gpd.play_event in ('Shot', 'Blocked Shot', 'Missed Shot', 'Goal')

group by 
	 gpd.game_id
	,gpd.play_event

DROP TABLE #game_roster