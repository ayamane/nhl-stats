USE nhl_stats_ldw
GO

CREATE OR ALTER FUNCTION udfGetPlayerPosition(@player_id INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @position_code NVARCHAR(2)
	SELECT @position_code = position_code
	FROM bronze.roster
	WHERE player_id = @player_id
	GROUP BY player_id, position_code

	RETURN @position_code
END