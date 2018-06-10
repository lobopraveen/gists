

```csharp
let
    KeySource = Excel.CurrentWorkbook(){[Name="SearchKeys"]}[Content],
    KeysWithoutNull = Table.SelectRows(KeySource, each [Keys] <> null),
    DistinctKeyList = List.Distinct(KeysWithoutNull[Keys]),
    OneLiner = List.Accumulate(DistinctKeyList,"",(state,current)=>if state = "" then "'"& Text.From(current)&"'" else state & ",'"& Text.From(current) &"'" ),
    DBData = Sql.Database("server", "db", [Query="SELECT * FROM dbo.tablename WHERE somecolumn IN ("& OneLiner &")"])
in
    DBData
```
