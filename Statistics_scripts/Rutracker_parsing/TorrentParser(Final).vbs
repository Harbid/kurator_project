' ========== Variables =========================
Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, TagOpen, TagClose, Text
Dim ArrLimits, ArrFileCounts(100), Limits, Page, LastPage, StartPage, FLogName
	
Const GB       = 1024
Const Interval = 50
	ArrLimits  = Array(0,1,5,10,20,50,100,200,300,500, _
					  GB,GB*2,GB*3,GB*4,GB*5,GB*6,GB*7,GB*8,GB*9,GB*10, _
					  GB*11,GB*13,GB*15,GB*20,GB*30,GB*40,GB*50)
					  
' (special)
Dim ArrBackUp(100), StartLineNumber, FResultName, FListFile, ForumURL, LineNumber
	FResultName = "Result.txt"
	FListFile   = "Valid_Forums.txt"
	FLogName    = "WorkLog.txt"
	StartLineNumber = 1 ' отметка о стартовой строке, с которой начинать считывание

' ========== Main ==============================
Set FileLog    = FSO.OpenTextFile(FLogName,8,True)
	LineNumber = 0
	
Set ForumsListFile = FSO.OpenTextFile(FListFile,1,False)
While Not(ForumsListFile.AtEndOfStream)	

	StartPage = ForumsListFile.ReadLine 
	LineNumber = LineNumber + 1
		
	If (LineNumber >= StartLineNumber) Then 
		Call LeadUp()
		Call DownloadHTML(StartPage)
		LastPage = GetLastPage(HTML)

		FileLog.WriteLine "Обратока форума: "& StartPage & ";" & VbCrLf  & _ 
						  "Номер строки в файле " & FListFile & " = "& LineNumber & VbCrLf & _
						  "Всего страниц на форуме: "& LastPage & ";"

		For Page = 0 To LastPage-1
			'WScript.Echo "Forum#"&LineNumber&" - Work with page#"& Page+1 &"; "&Now
			FileLog.WriteLine "Forum#"&LineNumber&" - Work with page#"& Page+1 &"; "&Now
			Call DownloadHTML(StartPage&"&start="&Page*Interval)
			Call GetSizes(HTML)
		Next 

		Call FormatResult() 
		Call BackUpArray()
		Call WriteResult()
	End If 
		
Wend 

' End of script
FileLog.Close() : ForumsListFile.Close()
MsgBox "Готово"

' ========== Functions =========================
Sub BackUpArray()
	FileLog.Write "Резервная копия размеров форума: "
	For i=0 To Limits-1 
		FileLog.Write ArrFileCounts(i)&","
	Next
		FileLog.WriteLine ArrFileCounts(Limits) & VbCrLf 
End Sub 

Sub WriteResult()
Set Result = FSO.OpenTextFile(FResultName,2,True)
	Result.WriteLine Text ': WScript.Echo Text 
	Result.Close
End Sub 

Sub LeadUp() ' Подготовка переменных
Dim ArrIterator
	TagOpen  = "<td class="&""""&"tCenter med nowrap"&""""&" style="&""""&"padding: 2px 4px;"&""""&">"
	TagClose = "</td>"

	Limits = UBound(ArrLimits)
	For i=0 To Limits : ArrFileCounts(i) = 0 : Next 
	
	Set BackUp = FSO.OpenTextFile(FResultName,1,False)
		ArrIterator = 0
		While Not(BackUp.AtEndOfStream) 	
			BackUpLine = BackUp.ReadLine ': WScript.Echo CLng(Mid(BackUpLine,InStrRev(BackUpLine," ")))
			ArrBackUp(ArrIterator) = CLng(Mid(BackUpLine,InStrRev(BackUpLine," ")))
			ArrIterator = ArrIterator + 1
		Wend 
		BackUp.Close()
End Sub 

Sub FormatResult() ' Формирование текста общей статистики
Dim Sum
	Sum = 0 : Text = ""
		
	For i=0 To Limits : Sum = Sum + ArrFileCounts(i) : Next	
	For i=1 To Limits
		Text = Text & "Number of files which size in interval " & NumSizeType(ArrLimits(i-1)) & ".." & NumSizeType(ArrLimits(i)) & StrSizeType(ArrLimits(i-1)) & (ArrFileCounts(i-1) + ArrBackUp(i-1)) & VbCrLf 
	Next 
		Text = Text & "Number of files which size more than " & NumSizeType(ArrLimits(Limits)) & StrSizeType(ArrLimits(Limits)) & (ArrFileCounts(Limits) + ArrBackUp(i-1))
End Sub 

Sub DownloadHTML(P)	' Загрузка страницы, заполнение глобальной HTML
	objXMLHTTP.open "GET", P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Function DeleteExcessInfo(StrRegExp) ' Удаление лишней информации из регулярки
Dim ArrExcess, Elem, Result, Count
	' Массив мусорных строк
	ArrExcess = Array(TagClose,TagOpen,VbCrLf,vbLf,"	")
	Result = StrRegExp
	Count  = UBound(ArrExcess)

	For i=0 To Count 
		Result = Replace(Result,ArrExcess(i),"")
	Next 
	Result = Replace(Result,".",",")	
	
	DeleteExcessInfo = Result
End Function  

Sub GetSizes(Text) ' Получение строк с размерами выложенных торрентов
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

Sub SizeType(Info) ' Преобразование строки размера файла в единый формат
'On Error Resume Next 
Dim FSize, FFormat
If (InStr(Info,";")) Then 
	FFormat = Mid(Info,InStr(Info,";")+1)
	FSize   = Mid(Info,1,InStr(Info,"&")-1)
	
	Select Case FFormat
		Case "KB"
			FSize = 0
		Case "GB"
			FSize = FSize * GB
		Case "TB"
			FSize = FSize * GB * GB 
	End Select 
	
	'WScript.Echo FSize & " MB"	
	Call FillStatisticArray(CDbl(FSize)) ' MB
End If 
End Sub 

Sub FillStatisticArray(Size) ' Инкремент значений массива интервалов размеров файлов
Dim Limit
	Limit = Limits
	For i=1 To Limits
		If (Size < ArrLimits(i)) Then
			Limit = i-1 : Exit For 
		End if
	Next 
	ArrFileCounts(Limit) = ArrFileCounts(Limit) + 1
End Sub 

Function StrSizeType(Size) ' Вспомогательная функция для формирования отчёта
	If (Size < GB) Then : StrSizeType = " MB: " : Else : StrSizeType = " GB: " : End If 
End Function  

Function NumSizeType(Size) ' Вспомогательная функция для формирования отчёта
	If (Size < GB) Then : NumSizeType = Size : Else : NumSizeType = Size/GB : End If 
End Function 

Function GetLastPage(Text) ' Получение последней страницы текущего форума
Set objRegExp = CreateObject("VBScript.RegExp")
On Error Resume Next
	Err.Clear	
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = "<p style="&""""&"float: left"&""""&">" & "[\s\S]*?" & "</p>"
		
Set objMatches = objRegExp.Execute(Text)
Set objMatch   = objMatches.Item(0)
	If (Err.Number<>0) Then 
		GetLastPage = 1
	Else 
		objRegExp.Pattern = "[\d]+"
	
		Set objMatches = Nothing
		Set objMatches = objRegExp.Execute(objMatch.Value) 
		Set objMatch   = objMatches.Item(1) ' : WScript.Echo objMatch.Value
	
		GetLastPage= CLng(objMatch.Value)
	End If 
End Function
