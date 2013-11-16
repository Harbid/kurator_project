' ========== Variables =========================
Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, Text, Page, LastPage, StartPage
Dim FileResourceName, Site, FilesListURL
	'FileResourceName = "d2.vu_torrent_ulrs.txt"
	FileResourceName = "URL.txt"
	Site = "http://www.d2.vu"
	Page = 1


' ========== Main ==============================
Set FileLog = FSO.OpenTextFile("Log.txt",2,True)
Set FileResult = FSO.OpenTextFile("Result.txt",2,True)	

Set FileResource = FSO.OpenTextFile(FileResourceName,1,False)
While Not(FileResource.AtEndOfStream)
	StartPage = FileResource.ReadLine
	
	WScript.Echo "Work with page#"& Page &"; "&Now
	FileLog.WriteLine "Work with page#"& Page &"; "&Now
	
	Call DownloadHTML(StartPage)		
	Call GetClickHereLink(HTML)
	Call DownloadHTML(FilesListURL)
	Call GetFilesList(HTML)
	
	Page = Page + 1
Wend  

' End	
FileResult.Close()	
FileResource.Close()
FileLog.Close()
MsgBox "Готово"

' ========== Functions =========================
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

Sub GetFilesList(Text) ' Получение списка файлов с раздачи и вывод результата в файл
Dim TagOpen, TagClose, Result, Info
Dim FileName, FileSize
	TagOpen  = "<td class="&""""&"tone_"
	TagClose = "</td>"
	
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global    = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern   = TagOpen & "[\s\S]*?" & TagClose
	
Set objMatches = objRegExp.Execute(Text)

For i=2 To objMatches.Count-1
    Set objMatch = objMatches.Item(i) 
    
    	t1 = InStr(objMatch.Value,">")+1
    	t2 = InStr(objMatch.Value,"</td>")
    	Info =  Mid(objMatch.Value,t1,t2-t1)
    	
    	If (i=2) Then :  Info = Mid(Info,InStrRev(Info,">")+1) : End If     	
    	
    	Result = Result & Info & " "
    	
    	If (i Mod 2 <> 0) Then 
    		'WScript.Echo Result	
    		On Error Resume Next    	
    		FileResult.WriteLine Result ' Запись отчёта	
    		Result = ""
    	End If 
Next	
End Sub 
