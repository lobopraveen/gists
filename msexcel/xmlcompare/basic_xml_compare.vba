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

Private SourceXMLCell As Range
Private TargetXMLCell As Range
Private CompareResultCell As Range

'
' Sets all module level variables
'
Sub SetVariables()
' All cells are relative to SOURCE Search Text cell
    Set SourceXMLCell = Range("B1")
    Set TargetXMLCell = SourceXMLCell.Offset(1, 0)
    Set CompareResultCell = TargetXMLCell.Offset(3, -1)
End Sub

'
' Returns the range of mismatched tags
'
Function MismatchRange() As Range
    TargetXMLCell.Offset(3, -1).Select
    ' Select all down only if there is any value
    If IsEmpty(TargetXMLCell.Offset(4, -1).Value) = False Then
        Range(Selection, Selection.End(xlDown)).Select
    End If

    ' Extend the selection to add three columns
    Selection.Resize(Selection.Rows.Count, 4).Select
    Set MismatchRange = Selection
End Function

'
' Clears the previous results
'
Sub ClearPreviousResults()
    Application.ScreenUpdating = False

    With MismatchRange()
        .ClearContents
        .FormatConditions.Delete
        .Interior.Color = xlNone
        With .Borders
            .LineStyle = xlNone
        End With
    End With

    SourceXMLCell.Font.ColorIndex = 1
    TargetXMLCell.Font.ColorIndex = 1
    TargetXMLCell.Offset(3, -1).Select
    ActiveWindow.ScrollRow = 1
    Application.ScreenUpdating = True
End Sub


'
' Compares the two XMLs from SourceXMLCell and TargetXMLCell and displays
' the mismatches starting CompareResultCell
'
Sub CompareXML()
    SetVariables

    ' Check if xml are provided
    If IsEmpty(SourceXMLCell) Or IsEmpty(TargetXMLCell) Then
        MsgBox ("SOURCE/TARGET XML missing: cannot compare!")
        CompareResultCell.Select
        Exit Sub
    End If

    Dim xml As MSXML2.DOMDocument
    Set xml = New MSXML2.DOMDocument
    xml.async = False: xml.ValidateOnParse = False

    ' Get the SOURCE xml and parse it
    Dim XmlString As String
    XmlString = SourceXMLCell.Value

    On Error GoTo 0
    If Not xml.LoadXML(XmlString) Then
        MsgBox "Parsing the SOURCE XML failed!"
        SourceXMLCell.Select
        Exit Sub
    End If

    Dim XmlNodes As IXMLDOMNodeList
    Dim XmlNode  As IXMLDOMNode

    Set XmlNodes = xml.ChildNodes().Item(0).ChildNodes() 'Because We have only one XML document

    ' setting up a dictionary
    Dim SOURCETagDict As Object
    Set SOURCETagDict = CreateObject("Scripting.Dictionary")
    SOURCETagDict.CompareMode = vbBinaryCompare

    ' load the dictionary with tag and value
    For Each XmlNode In XmlNodes
        SOURCETagDict.Add XmlNode.BaseName, XmlNode.Text
    Next XmlNode

    ' Get the TARGET xml string and parse it
    XmlString = TargetXMLCell.Value

    On Error GoTo 0
    If Not xml.LoadXML(XmlString) Then
        MsgBox "Parsing the TARGET XML failed!"
        TargetXMLCell.Select
        Exit Sub
    End If

    Set XmlNodes = xml.ChildNodes().Item(0).ChildNodes() 'We have only one XML document

    ' All set for comparison; clear any previous results
    ClearPreviousResults

    Dim Count As Integer: Count = 0
    Dim CompareResult As String

    For Each XmlNode In XmlNodes
        If SOURCETagDict.Exists(XmlNode.BaseName) Then
            ' SOURCE matching tag exists
            If StrComp(XmlNode.Text, SOURCETagDict.Item(XmlNode.BaseName), vbBinaryCompare) <> 0 Then
                ' and the values don't match
                CompareResult = "Mismatch"
                Count = Count + 1
            Else
                ' the values match
                CompareResult = "Match"
            End If

            CompareResultCell.Value = XmlNode.BaseName
            CompareResultCell.Offset(0, 1).Value = SOURCETagDict.Item(XmlNode.BaseName)
            CompareResultCell.Offset(0, 2).Value = XmlNode.Text
            CompareResultCell.Offset(0, 3).Value = CompareResult

            ' remove the key from dictionary
            SOURCETagDict.Remove (XmlNode.BaseName)

        Else
            ' No SOURCE matching tag; this is only in TARGET
            CompareResultCell.Value = XmlNode.BaseName
            CompareResultCell.Offset(0, 2).Value = XmlNode.Text
            CompareResultCell.Offset(0, 3).Value = "TARGET Only"

            Count = Count + 1
        End If

        ' move the cell one down
        Set CompareResultCell = CompareResultCell.Offset(1, 0)

    Next XmlNode

    ' Loop through SOURCE tag dictionary and print. These are in SOURCE xml only
    Dim SOURCEOnly As Variant

    For Each SOURCEOnly In SOURCETagDict.Keys()
        CompareResultCell.Value = SOURCEOnly
        CompareResultCell.Offset(0, 1).Value = SOURCETagDict.Item(SOURCEOnly)
        CompareResultCell.Offset(0, 3).Value = "SOURCE Only"

        ' move the cell one down
        Set CompareResultCell = CompareResultCell.Offset(1, 0)
        Count = Count + 1
    Next SOURCEOnly

    If Count > 0 Then
        ' add border
        Application.ScreenUpdating = False
        With MismatchRange()
            With .Borders
                .LineStyle = xlContinuous
            End With
        End With
        ' turn xmls red
        SourceXMLCell.Font.ColorIndex = 3
        TargetXMLCell.Font.ColorIndex = 3
        TargetXMLCell.Offset(3, -1).Select
        Application.ScreenUpdating = True
        MsgBox (Count & " mismatches found!")
    Else
        ' turn xmls green
        SourceXMLCell.Font.ColorIndex = 10
        TargetXMLCell.Font.ColorIndex = 10
        MsgBox ("Success: XMLs match!")
    End If
End Sub
