## Power Query to run a query against a database

The last line shows how to connect and run a query. Rest of the lines demonstrate building of IN clause for a query from values in "SearchKeys" named range. 

```m
let
    KeySource = Excel.CurrentWorkbook(){[Name="SearchKeys"]}[Content],
    KeysWithoutNull = Table.SelectRows(KeySource, each [Keys] <> null),
    DistinctKeyList = List.Distinct(KeysWithoutNull[Keys]),
    OneLiner = List.Accumulate(DistinctKeyList,"",(state,current)=>if state = "" then "'"& Text.From(current)&"'" else state & ",'"& Text.From(current) &"'" ),
    DBData = Sql.Database("server", "db", [Query="SELECT * FROM dbo.tablename WHERE somecolumn IN ("& OneLiner &")"])
in
    DBData
```
