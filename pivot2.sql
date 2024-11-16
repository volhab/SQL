declare @cols nvarchar(max)
declare @dyncols nvarchar(max)
declare @sql nvarchar(max)

SELECT @cols = STRING_AGG(QUOTENAME(n), ',')
FROM (SELECT DISTINCT SUBSTRING(name, CHARINDEX('.', name) + 1, LEN(name) - CHARINDEX('.', name)) as n FROM dbo.Services) as x;
--print @cols

SELECT @dyncols = STRING_AGG(QUOTENAME(n) + ' NVARCHAR(50)', ',')
FROM (SELECT DISTINCT '.' + service_name + '(' + price + ')' as n FROM dbo.Prices) as x;

SET @sql = N' DECLARE @temp TABLE ([username] VARCHAR(50), ' + @dyncols + ')
INSERT INTO @temp
SELECT  *
FROM 
(
	SELECT username, service_name, CONVERT(decimal(10,2), SUBSTRING(price, 2, LEN(price) - 1)) AS price_value 
	from Users u 
	JOIN Services s ON u.id = s.user_id
	JOIN Prices p ON CHARINDEX (p.service_name, s.name) > 0
	WHERE expiration_date > 2021-08-01

) y
PIVOT
(
	SUM(price_value) FOR service_name in (' + @cols + ')
) z

SELECT * FROM @temp';

exec sp_executesql @sql;


