' ========== Variables =========================
Dim StartPage ' Начальная страница

Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, Text
Dim ArrLimits, ArrFileCounts(100), Limits, Page, LastPage

Const GB   = 1024
LastPage   = 99
ArrLimits  = Array(0,1,5,10,20,50,100,200,300,500, _
				  GB,GB*2,GB*3,GB*4,GB*5,GB*6,GB*7,GB*8,GB*9,GB*10, _
				  GB*11,GB*13,GB*15,GB*20,GB*30,GB*40,GB*50)


' ========== Main ==============================

Call LeadUp()
Set FileLog = FSO.OpenTextFile("Log.txt",2,True)
	
Set Resources = FSO.OpenTextFile("resources.txt",1,False)
While Not(Resources.AtEndOfStream)
	StartPage = Resources.ReadLine
	
	FileLog.WriteLine VbCrLf & "Обработка раздела: "& StartPage 
	WScript.Echo VbCrLf & "Обработка раздела: "& StartPage 

	For Page = 0 To LastPage
		WScript.Echo "Work with page#"& Page+1 &"; "&Now
		FileLog.WriteLine "Work with page#"& Page+1 &"; "&Now
		Call DownloadHTML(StartPage&"/"&Page&"/3")
		Call GetSizesTPB(HTML)
	Next 
	
Wend 

' End
Call FormatResult()
Set FileResult = FSO.OpenTextFile("Result.txt",2,True)	
	FileResult.Write Text ' Запись отчёта
	FileResult.Close()
	
FileLog.Close()
Resources.Close()

MsgBox "Готово"

' ========== Functions =========================

Sub LeadUp() ' Подготовка переменных
	Limits = UBound(ArrLimits)
	For i=0 To Limits : ArrFileCounts(i) = 0 : Next 	
End Sub 

Sub DownloadHTML(P)	' Загрузка страницы, заполнение глобальной HTML
	objXMLHTTP.open "GET", P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Sub GetSizesTPB(Text) ' Получение строк с размерами выложенных торрентов
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern = "Size "&"(.*?)"&"B"

Set objMatches = objRegExp.Execute(Text)
For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i)
    tmp = DeleteExcessInfo(objMatch.Value)
    Call SizeType(tmp)
Next	
End Sub 

Function DeleteExcessInfo(StrRegExp) ' Удаление лишней информации из регулярки
Dim Result
	Result = StrRegExp
	Result = Replace(Result,"Size ","")
	Result = Replace(Result,"&nbsp;",";")	
	Result = Replace(Result,".",",")	
		
	DeleteExcessInfo = Result
End Function  

Sub SizeType(Info) ' Преобразование строки размера раздачи в единый формат
Dim FSize, FFormat

If (InStr(Info,";")) Then 
	FFormat = Mid(Info,InStr(Info,";")+1)
	FSize   = Mid(Info,1,InStr(Info,";")-1) ' : WScript.Echo FFormat&" -> "&FSize
		
	Select Case FFormat
		Case "KiB" FSize = 0
		Case "GiB" FSize = FSize * GB
		Case "TiB" FSize = FSize * GB * GB 
	End Select 

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

Sub FormatResult() ' Формирование текста общей статистики
Dim Sum
	Sum = 0 : Text = ""
		
	For i=0 To Limits : Sum = Sum + ArrFileCounts(i) : Next
	Text = Text & "Files in " & "http://thepiratebay.sx/browse " & " : "& Sum & VbCrLf & VbCrLf 
	
	For i=1 To Limits
		Text = Text & "Number of files which size in interval " & NumSizeType(ArrLimits(i-1)) & ".." & NumSizeType(ArrLimits(i)) & StrSizeType(ArrLimits(i-1)) & ArrFileCounts(i-1) & VbCrLf 
	Next 
		Text = Text & "Number of files which size more than " & NumSizeType(ArrLimits(Limits)) & StrSizeType(ArrLimits(Limits)) & ArrFileCounts(Limits)
		
	WScript.Echo Text 
End Sub 


