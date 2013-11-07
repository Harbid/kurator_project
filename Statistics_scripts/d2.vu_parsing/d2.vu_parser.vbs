' ========== Variables =========================
Dim StartPage ' Начальная страница

Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, Text
Dim ArrLimits, ArrFileCounts(100), Limits, Page, LastPage

Const GB   = 1024
Page       = 1
ArrLimits  = Array(0,1,5,10,20,50,100,200,300,500, _
				  GB,GB*2,GB*3,GB*4,GB*5,GB*6,GB*7,GB*8,GB*9,GB*10, _
				  GB*11,GB*13,GB*15,GB*20,GB*30,GB*40,GB*50)
Dim FileResourceName, Site, FilesListURL
	'FileResourceName = "resources.txt"
	FileResourceName = "d2.vu_torrent_ulrs.txt"
	Site             = "http://www.d2.vu"


' ========== Main ==============================
Call LeadUp()
Set FileLog = FSO.OpenTextFile("Log.txt",2,True)

Set FileResource = FSO.OpenTextFile(FileResourceName,1,False)
	While Not(FileResource.AtEndOfStream)
		StartPage = FileResource.ReadLine

		WScript.Echo "Work with page#"& Page &"; "&Now
		FileLog.WriteLine "Work with page#"& Page &"; "&Now
		
		Call DownloadHTML(StartPage)		
		Call GetClickHereLink(HTML)
		Call DownloadHTML(FilesListURL)
		Call GetSizes(HTML)
		
		Page = Page + 1
		If (Page Mod 100 = 0) Then 
			Call FormatResult()
			FileLog.WriteLine Text ' BackUp
		End If 
	Wend  

' End
Call FormatResult()
Set FileResult = FSO.OpenTextFile("Result.txt",2,True)	
	FileResult.Write Text ' Запись отчёта
	FileResult.Close()
	
FileResource.Close()
FileLog.Close()
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

Sub GetClickHereLink(Text) ' Получение ссылки на страницу со списком файлов
Dim TagOpen, TagClose, Result
	TagOpen  = "<a href="&""""
	TagClose = """"&">"
	
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = TagOpen & "[\s\S]*?" & TagClose
	
Set objMatches = objRegExp.Execute(Text)

For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i)  
    If (InStr(objMatch.Value,"#file_list")) Then     
    	Result = Replace(objMatch.Value,TagOpen,"")
    	Result = Replace(Result,TagClose,"")    	
    	FilesListURL = Site&Result ': 
    	
    	'WScript.Echo FilesListURL
    	FileLog.WriteLine FilesListURL
    End If 
Next		
End Sub 

Sub GetSizes(Text) ' Получение строк с размерами Файлов торрента
Dim TagOpen, TagClose, Result
	TagOpen  = "<td class="&""""
	TagClose = "</td>"
	
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = TagOpen & "[\s\S]*?" & TagClose
	
Set objMatches = objRegExp.Execute(Text)

For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i)  
    If (InStr(objMatch.Value,"align=""right""")) Then     
    	Result = Replace(objMatch.Value,TagClose,"")
    	Result = Mid(Result,InStr(Result,">")+1)
    	' формирование числа без разделителей
    	Result = Replace(Result,",","")
    	Result = Replace(Result,".",",")
    	'WScript.Echo Result
    	Call SizeType(Result)
    End If 
Next		
End Sub 

Sub SizeType(Info) ' Преобразование строки размера раздачи в единый формат
Dim FSize, FFormat

	FFormat = Mid(Info,InStr(Info," ")+1)
	FSize   = Mid(Info,1,InStr(Info," ")-1) ': WScript.Echo FSize&" -> "&FFormat
		
	Select Case FFormat
		Case "bytes" FSize = 0
		Case "KB"    FSize = 0
		Case "GB"    FSize = FSize * GB
		Case "TB"    FSize = FSize * GB * GB 
	End Select 

	'WScript.Echo "New: "&FSize&" -> "&FFormat
	Call FillStatisticArray(CDbl(FSize)) ' MB
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
	Text = Text & "Files in " & "d2.vu " & " : "& Sum & VbCrLf & VbCrLf 
	
	For i=1 To Limits
		Text = Text & "Number of files which size in interval " & NumSizeType(ArrLimits(i-1)) & ".." & NumSizeType(ArrLimits(i)) & StrSizeType(ArrLimits(i-1)) & ArrFileCounts(i-1) & VbCrLf 
	Next 
		Text = Text & "Number of files which size more than " & NumSizeType(ArrLimits(Limits)) & StrSizeType(ArrLimits(Limits)) & ArrFileCounts(Limits)
		
	'WScript.Echo Text 
End Sub 