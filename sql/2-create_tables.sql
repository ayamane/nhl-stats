USE nhl_stats_ldw
GO

IF OBJECT_ID('bronze.teams') IS NOT NULL
	DROP TABLE bronze.teams
GO

CREATE TABLE bronze.teams (
	season VARCHAR(8),
    id TINYINT,
    name VARCHAR(25),
    team_link VARCHAR(25),
    team_abbrev VARCHAR(4),
    team_name VARCHAR(20),
    location_name VARCHAR(15),
    first_year_of_play SMALLINT,
    short_name VARCHAR(15),
    official_site_url VARCHAR(40),
    active BIT,
	venue_name VARCHAR(30),
	venue_link VARCHAR(25),
	venue_city VARCHAR(15),
	division_id TINYINT,
	division_name VARCHAR(15),
	division_name_short VARCHAR(5),
	division_link VARCHAR(25),
	division_abbrev VARCHAR(1),
	conference_id TINYINT,
	conference_name VARCHAR(10),
	conference_link VARCHAR(25),
    franchise_id TINYINT,
	franchise_team_name VARCHAR(20),
	franchise_link VARCHAR(25)
);

IF OBJECT_ID('bronze.play_types') IS NOT NULL
	DROP TABLE bronze.play_types
GO

CREATE TABLE bronze.play_types (
	season VARCHAR(8),
    play_type_name VARCHAR(15),	
    play_type_id VARCHAR(15),	
    play_cms_key VARCHAR(25),	
    play_code VARCHAR(15),
	player_type VARCHAR(10),
	secondary_event_code_0 VARCHAR(15),
	secondary_event_code_1 VARCHAR(15)
);

IF OBJECT_ID('bronze.schedule') IS NOT NULL
	DROP TABLE bronze.schedule
GO

CREATE TABLE bronze.schedule (
	season VARCHAR(8),
    game_id INT,
    game_link VARCHAR(35),
    game_type VARCHAR(2),
    season_name VARCHAR(8),
	total_games TINYINT,
    game_date VARCHAR(20),
	venue_id SMALLINT,
	away_team_id SMALLINT,
	away_team_name VARCHAR(20),
	home_team_id SMALLINT,
	home_team_name VARCHAR(20)
);

IF OBJECT_ID('bronze.roster') IS NOT NULL
	DROP TABLE bronze.roster
GO

CREATE TABLE bronze.roster (
    season VARCHAR(8),
    month VARCHAR(2),
    day VARCHAR(2),
	team_id TINYINT,
	player_id INT,
	player_name VARCHAR(40),
	player_link VARCHAR(30),
	jersey_nbr VARCHAR(2),
	position_code VARCHAR(2),
	position_name VARCHAR(15), 
	position_type VARCHAR(10), 
	position_abbrev VARCHAR(3)
);

IF OBJECT_ID('bronze.game_info') IS NOT NULL
	DROP TABLE bronze.game_info
GO

CREATE TABLE bronze.game_info (
    season VARCHAR(8),
    month VARCHAR(2),
    day VARCHAR(2),
	game_id INT,
	season_name VARCHAR(8),
	game_type VARCHAR(2),
	game_datetime DATETIME,
	end_datetime DATETIME,
	away_team_id SMALLINT,
	away_team_name VARCHAR(20),
	away_team_abbrev VARCHAR(4),
	home_team_id SMALLINT,
	home_team_name VARCHAR(20), 
	home_team_abbrev VARCHAR(4)
);

IF OBJECT_ID('bronze.game_play_data') IS NOT NULL
    DROP TABLE bronze.game_play_data
GO

CREATE TABLE bronze.game_play_data (
    season VARCHAR(8),
    month VARCHAR(2),
    day VARCHAR(2),
    game_id INT,
    game_type VARCHAR(2),
    play_event VARCHAR(15),
    play_event_type_id VARCHAR(10),
    play_description VARCHAR(100),
    event_index INT,
    period TINYINT,
    period_type VARCHAR(10),
    period_time VARCHAR(6),
    period_time_remaining VARCHAR(6),
    date_time DATETIME2,
    away_goals TINYINT,
    home_goals TINYINT,
    coordinates_x VARCHAR(8),
    coordinates_y VARCHAR(8),
	player_0 INT,
	player_0_type VARCHAR(10),
	player_1 INT,
	player_1_type VARCHAR(10),
	player_2 INT,
	player_2_type VARCHAR(10),
	player_3 INT,
	player_3_type VARCHAR(10)
   );

SELECT * FROM bronze.game_play_data;