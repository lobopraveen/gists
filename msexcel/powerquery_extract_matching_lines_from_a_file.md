

```csharp
let
    KeySource = Excel.CurrentWorkbook(){[Name="SearchKeys"]}[Content],
    KeysWithoutNull = Table.SelectRows(KeySource, each [Keys] <> null),
    DistinctKeyList = List.Distinct(KeysWithoutNull[Keys]),
    TxtFileData = Table.FromColumns({Lines.FromBinary(File.Contents("File_Location_here"))}),
    FilteredRows = Table.SelectRows(TxtFileData, each List.AnyTrue(List.Transform(DistinctKeyList, (substring) => Text.Contains([Column1], substring)))),
    RenameColumn = Table.RenameColumns(FilteredRows,{{"Column1", "Lines From File"}})
in
    RenameColumn
```    
