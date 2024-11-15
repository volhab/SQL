declare @cols nvarchar(max)
declare @sql nvarchar(max)

select @cols = STRING_AGG(quotename(attribute), ',')
from (select distinct attribute from attributes) as attrList;

set @sql = N'select name, ' + @cols + ' from (select s.sname as name, a.attribute, a.value from subjects s join attributes a on a.id = s.id) as st 
pivot (sum(value) for attribute in (' + @cols + ')) as pt';

exec sp_executesql @sql;

go
