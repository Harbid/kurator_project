' ========== Variables =========================
Dim StartPage ' ������ �������� ������
	StartPage = "http://rutracker.org/forum/viewforum.php?f=2200"
	'StartPage = "http://rutracker.org/forum/viewforum.php?f=187"


Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, TagOpen, TagClose, Text
Dim ArrLimits, ArrFileCounts(100), Limits, Page, LastPage
	
Const GB       = 1024
Const Interval = 50
	ArrLimits  = Array(0,1,5,10,20,50,100,200,300,500, _
					  GB,GB*2,GB*3,GB*4,GB*5,GB*6,GB*7,GB*8,GB*9,GB*10, _
					  GB*11,GB*13,GB*15,GB*20,GB*30,GB*40,GB*50)

' ========== Main ==============================

Call PrepareVars()
Call DownloadHTML(StartPage)
LastPage = GetLastPage(HTML)

Set FileLog = FSO.OpenTextFile("Log.txt",2,True)
	FileLog.WriteLine "�������� ������: "& StartPage & VbCrLf 

For Page = 0 To LastPage-1
	'WScript.Echo "Work with page#"& Page+1 &"; "&Now
	FileLog.WriteLine "Work with page#"& Page+1 &"; "&Now
	Call DownloadHTML(StartPage&"&start="&Page*Interval)
	Call GetSizes(HTML)
Next 

Call FormatResult()

' End 
Set FileResult = FSO.OpenTextFile("Result.txt",2,True)	
	FileResult.Write Text ' ������ ������
	FileResult.Close()
FileLog.Close()

MsgBox "������"

' ========== Functions =========================

Sub PrepareVars() ' ���������� ����������
	TagOpen  = "<td class="&""""&"tCenter med nowrap"&""""&" style="&""""&"padding: 2px 4px;"&""""&">"
	TagClose = "</td>"

	Limits = UBound(ArrLimits)
	For i=0 To Limits : ArrFileCounts(i) = 0 : Next 	
End Sub 

Sub DownloadHTML(P)	' �������� ��������, ���������� ���������� HTML
	objXMLHTTP.open "GET", P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Function DeleteExcessInfo(StrRegExp) ' �������� ������ ���������� �� ���������
Dim ArrExcess, Elem, Result, Count
	' ������ �������� �����
	ArrExcess = Array(TagClose,TagOpen,VbCrLf,vbLf,"	")
	Result = StrRegExp
	Count  = UBound(ArrExcess)

	For i=0 To Count 
		Result = Replace(Result,ArrExcess(i),"")
	Next 
	Result = Replace(Result,".",",")	
	
	DeleteExcessInfo = Result
End Function  

Sub GetSizes(Text) ' ��������� ����� � ��������� ���������� ���������
Dim Result, FSize, FFormat
	
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = TagOpen & "[\s\S]*?" & TagClose
	
Set objMatches = objRegExp.Execute(Text)			': WScript.Echo objMatches.Count
For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i) 				': WScript.Echo objMatch.Value
   		Result = DeleteExcessInfo(objMatch.Value)	': WScript.Echo Result
   	Call SizeType(Result)   	
Next	

End Sub 

Sub SizeType(Info) ' �������������� ������ ������� ����� � ������ ������
'On Error Resume Next 
Dim FSize, FFormat
If (InStr(Info,";")) Then 
	FFormat = Mid(Info,InStr(Info,";")+1)
	FSize   = Mid(Info,1,InStr(Info,"&")-1)
	
	Select Case FFormat
		Case "KB" : FSize = 0
		Case "GB" : FSize = FSize * GB
		Case "TB" : FSize = FSize * GB * GB 
	End Select 
	
	'WScript.Echo FSize & " MB"	
	Call FillStatisticArray(CDbl(FSize)) ' MB
End If 
End Sub 

Sub FillStatisticArray(Size) ' ��������� �������� ������� ���������� �������� ������
Dim Limit
	Limit = Limits
	For i=1 To Limits
		If (Size < ArrLimits(i)) Then
			Limit = i-1 : Exit For 
		End if
	Next 
	ArrFileCounts(Limit) = ArrFileCounts(Limit) + 1
End Sub 

Function StrSizeType(Size) ' ��������������� ������� ��� ������������ ������
	If (Size < GB) Then : StrSizeType = " MB: " : Else : StrSizeType = " GB: " : End If 
End Function  

Function NumSizeType(Size) ' ��������������� ������� ��� ������������ ������
	If (Size < GB) Then : NumSizeType = Size : Else : NumSizeType = Size/GB : End If 
End Function 

Sub FormatResult() ' ������������ ������ ����� ����������
Dim Sum
	Sum = 0 : Text = ""
		
	For i=0 To Limits : Sum = Sum + ArrFileCounts(i) : Next
	Text = Text & "Files in " & StartPage& " : "& Sum & VbCrLf & VbCrLf 
	
	For i=1 To Limits
		Text = Text & "Number of files which size in interval " & NumSizeType(ArrLimits(i-1)) & ".." & NumSizeType(ArrLimits(i)) & StrSizeType(ArrLimits(i-1)) & ArrFileCounts(i-1) & VbCrLf 
	Next 
		Text = Text & "Number of files which size more than " & NumSizeType(ArrLimits(Limits)) & StrSizeType(ArrLimits(Limits)) & ArrFileCounts(Limits)
		
	'WScript.Echo Text 
End Sub 

Function GetLastPage(Text) ' ��������� ��������� �������� �������� ������
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = "<p style="&""""&"float: left"&""""&">" & "[\s\S]*?" & "</p>"
	
Set objMatches = objRegExp.Execute(Text)
Set objMatch   = objMatches.Item(0)
	objRegExp.Pattern = "[\d]+"
	
Set objMatches = Nothing
Set objMatches = objRegExp.Execute(objMatch.Value) 
Set objMatch   = objMatches.Item(1) ' : WScript.Echo objMatch.Value
	
	GetLastPage= CLng(objMatch.Value)
End Function
