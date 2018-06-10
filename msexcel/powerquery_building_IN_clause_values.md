## Power Query to build IN clause from a list of values

Builds a comma separated list of values from a table in the spreadsheet.

|Search Keys|
|---|
|Praveen|
|Preetham|
|John Doe|

to

`'Praveen','Preetham','John Doe'`



```m
let
    KeySource = Excel.CurrentWorkbook(){[Name="SearchKeys"]}[Content],
    KeysWithoutNull = Table.SelectRows(KeySource, each [Keys] <> null),
    DistinctKeyList = List.Distinct(KeysWithoutNull[Keys]),
    INClause = List.Accumulate(DistinctKeyList,"",(state,current)=>if state = "" then "'"& Text.From(current)&"'" else state & ",'"& Text.From(current) &"'" )
in
    INClause
```
