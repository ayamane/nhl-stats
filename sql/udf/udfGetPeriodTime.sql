USE nhl_stats_ldw
GO

CREATE OR ALTER FUNCTION udfGetPeriodTime(@periodtime NVARCHAR(6), @period INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @minuteStr AS VARCHAR(2)
		,@minutes AS INT

	SET @minuteStr = SUBSTRING(@periodtime, 1, 2)
	SET @minutes = CAST(@minuteStr AS INT) + ((@period - 1) * 20)
	SET @minuteStr = FORMAT(@minutes, '00')

	RETURN CONCAT(@minuteStr, ':', SUBSTRING(@periodtime, 4, 2))
END

-- code below for testing
--DECLARE @periodtime NVARCHAR(6), @period INT
--SET @periodtime = '00:02'
--SET @period = 1

--DECLARE @finaltime AS NVARCHAR(6)

--SELECT SUBSTRING(@periodtime, 1, 2)
--	,CAST(SUBSTRING(@periodtime, 1, 2) AS INT) + ((@period - 1) * 20)
--	,FORMAT(CONCAT(CAST((CAST(SUBSTRING(@periodtime, 1, 2) AS INT) + ((@period - 1) * 20)) AS NVARCHAR(2)), '00'), ':', SUBSTRING(@periodtime, 4, 2))