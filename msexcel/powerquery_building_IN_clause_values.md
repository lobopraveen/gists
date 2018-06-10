

```csharp
let
    KeySource = Excel.CurrentWorkbook(){[Name="Keys"]}[Content],
    KeysWithoutNull = Table.SelectRows(KeySource, each [Keys] <> null),
    DistinctKeyList = List.Distinct(KeysWithoutNull[Keys]),
    INClause = List.Accumulate(DistinctKeyList,"",(state,current)=>if state = "" then "'"& Text.From(current)&"'" else state & ",'"& Text.From(current) &"'" )
in
    INClause
```
