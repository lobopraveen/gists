'
' MIT License
'
' Copyright (c) 2018 Praveen Lobo (praveenlobo.com)
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in all
' copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
' SOFTWARE.
'

'
' NOTE: Microsoft Scripting Runtime is required for file operations.
'       Add it from Tools > References
'

'
' Sub for button click
'
Sub SearchButton()
 FileSearch Range("B1"), Range("B2"), Range("B3")
End Sub

'
' Searches a file for the first occurrence of a given text
'
Sub FileSearch(FileLocationCell As Range, SearchTextCell As Range, SearchResultCell As Range)
    'SetVariables

    Dim SearchText As String
    Dim fso As New FileSystemObject
    Dim file As TextStream
    Dim line As String

    If IsEmpty(SearchTextCell) Then
        MsgBox ("Please provide a search text!")
        SearchTextCell.Select
        Exit Sub
    End If

    ' Get the search string and reset any existing value
    SearchText = SearchTextCell.Value
    SearchResultCell.Value = ""

    Set file = fso.OpenTextFile(FileLocationCell.Value)

    ' loop through line by line searching for the first occurrence of the string
    Do While Not file.AtEndOfLine
        line = file.ReadLine
        If InStr(1, line, SearchText, vbTextCompare) > 0 Then
            SearchResultCell.Value = line
            Exit Do
        End If
    Loop

    file.Close
    Set file = Nothing
    Set fso = Nothing

    If IsEmpty(SearchResultCell.Value) Then
        MsgBox (SearchText + " not found in the file!")
        SearchTextCell.Select
        Exit Sub
    End If

End Sub
