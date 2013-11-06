' ========== Variables =========================
Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML, Text
Dim Page, LastPage, Site, StartPage
	LastPage  = 201
	Site      = "http://www.d2.vu"
	StartPage = "http://www.d2.vu/files/?to=0&uid=0&category=0&subcategory=0&language=0&seeded=2&quality=0&external=2&query=&sort=&page="
' ========== Main ==============================

Set FileResult = FSO.OpenTextFile("d2.vu_torrent_ulrs.txt",2,True)

For Page = 1 To LastPage
	WScript.Echo "Work with page#"& Page &"; "&Now
	Call DownloadHTML(StartPage&Page)
	Call GetLinks(HTML)
Next 

' End 
FileResult.Close()	
MsgBox "Готово"

' ========== Functions =========================

Sub DownloadHTML(P)	' Загрузка страницы, заполнение глобальной HTML
	objXMLHTTP.open "GET", P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Sub GetLinks(Text)
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
    If (InStr(objMatch.Value,"/files/details/")) Then 
    
    	Result = Replace(objMatch.Value,TagOpen,"")
    	Result = Replace(Result,TagClose,"")
    	
    	'WScript.Echo Site&Result
    	FileResult.WriteLine Site&Result
    End If 
Next		
End Sub 