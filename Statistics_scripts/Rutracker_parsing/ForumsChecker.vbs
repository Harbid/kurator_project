' ========== Variables =========================
Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 

Dim TimeStart, TimeEnd
Dim ErrorCount, ForumNumber
Dim HTML, URL, URLPattern, DefaultStr
	URLPattern = "http://rutracker.org/forum/viewforum.php?f="
	DefaultStr = "No data"
	
' ========== Main ==============================
'ForumNumber = 1  ' Такого форума не существует
'ForumNumber = 2  ' Нет торрентов в форуме (форум есть)
'ForumNumber = 4  ' Торренты есть, но они все пустые
'ForumNumber = 5  ' Есть непустые торренты
'ForumNumber = 12 ' Запрашивает логин и пароль

Set FileValidForums = FSO.OpenTextFile("Valid_Forums.txt",2,True)
Set FileErrorLog    = FSO.OpenTextFile("Error_Log.txt",2,True)

On Error Resume Next ' для обработки запроса логина/пароля

ErrorCount  = 0
ForumNumber = 1
TimeStart   = Now 

FileErrorLog.WriteLine "Start: "&TimeStart&VbCrLf 

While (ErrorCount < 200)
	HTML = DefaultStr
	URL  = URLPattern&ForumNumber	
	Call DownloadHTML(URL)
	If (HTML = DefaultStr) Then 
		FileErrorLog.WriteLine URL & "; Error: Требуется логин/пароль." 
		ErrorCount = ErrorCount + 1
	Else 
		Call TestPage(HTML)
	End If 
	ForumNumber = ForumNumber + 1
Wend 

TimeEnd = Now 
FileErrorLog.WriteLine "Error: Превышено допустимое число подряд идущих ошибок." & VbCrLf & "Остановка процесса." & VbCrLf & VbCrLf & "End: "&TimeEnd
FileErrorLog.Close()
FileValidForums.Close()

MsgBox "Process was stopped;"&VbCrLf&"Start: "&vbtab&TimeStart&VbCrLf&"End: "&vbtab&TimeEnd

' ========== Functions =========================

Sub DownloadHTML(P)	' Загрузка страницы;
	objXMLHTTP.open "GET", P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Sub TestPage(Text)
	objRegExp.Pattern = "tCenter med nowrap" ' 4,5
	If (objRegExp.Test(Text)) Then 
		FileValidForums.WriteLine URL 
		ErrorCount = 0
	Else 
		objRegExp.Pattern = "forumline message" ' 1
		If (objRegExp.Test(Text)) Then 
			FileErrorLog.WriteLine URL & "; Error: Такого форума не существует." 
			ErrorCount = ErrorCount + 1
		Else 
			FileErrorLog.WriteLine URL & "; Error: На форуме отсутствуют торрены." 
			ErrorCount = ErrorCount + 1
		End If 
	End If 
End Sub 