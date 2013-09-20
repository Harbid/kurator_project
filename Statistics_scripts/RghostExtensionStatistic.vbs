Set Extensions = CreateObject("Scripting.Dictionary")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Dim HTML

' ========================== Main =========================
For Page=1 To 2381
	'WScript.Echo "Page #"&Page&"; "&Now
	DownloadHTML(Page)
	Call GetExtensions(HTML)
Next 
	
Call PrintResult()
' ======================== Functions ======================

Sub DownloadHTML(P)
	objXMLHTTP.open "GET", "http://rghost.ru/files?page="&P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Sub GetExtensions(Text)
Dim Filename, Extension
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern = "title=""(.*?)"""
Set objMatches = objRegExp.Execute(Text)

For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i)
    	Filename = Replace(objMatch.Value,"title=""","")
    	Filename = Replace(Filename,"""","") ' на этом этапе готовое имя файла
    	
       	If InStr(Filename,".") Then 
	       	Extension = LCase(Mid(Filename,InStrRev(Filename,".")))
    	   	''WScript.Echo Extension
    	   	Call IncExtension(Extension)
       	End If        	
Next		
End Sub 

Sub IncExtension(Ext)
	If Extensions.Exists(Ext) Then 
		Extensions.Item(Ext) = Extensions.Item(Ext) + 1
	Else 
		Extensions.Item(Ext) = 1
	End If 
End Sub 

Sub PrintResult()
Set FSO = CreateObject("Scripting.FileSystemObject")
Set Output = FSO.OpenTextFile("RGHost_ExtensionsStatistic.txt",2,True)
Dim Result
	Result = ""
	
	Arr = Extensions.Keys
	For i=0 To Extensions.Count-1 : Result = Result & Arr(i)&": "&Extensions.Item(Arr(i)) & VbCrLf : Next

	'WScript.Echo Result
	Output.Write Result
	Output.Close
End Sub 
