Set FSO = CreateObject("Scripting.FileSystemObject")
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")

Dim HTML, FileName, FileNameResult, MusicSize, Page
Dim ArrLimits(100)

FileNameResult = "Result_RGHost_AllFiles.txt"

' ========================== Main =========================
Set Output = FSO.OpenTextFile(FileNameResult,2,True)
For i=0 To 100 : ArrLimits(i)=0 : Next 	

For Page=1 To 2381
	'WScript.Echo "Page #"&Page&"; "&Now
	DownloadHTML(Page)
	Call GetSizes(HTML)	
Next 

Call PrintResult()
Output.Close
' ================= Functions =============================

Sub DownloadHTML(P) ' http://rghost.ru/files?page=5
	objXMLHTTP.open "GET", "http://rghost.ru/files?page="&P, False 
	objXMLHTTP.send()
	HTML = objXMLHTTP.responseText
End Sub 

Sub GetSizes(Text)
Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global = True 
	objRegExp.Multiline = True 
	objRegExp.Pattern = "<span class='filesize'>[\s\S]*?</span>"
Set objMatches = objRegExp.Execute(Text)

For i=0 To objMatches.Count-1
    Set objMatch = objMatches.Item(i)
    
   	MusicSize = Replace(objMatch.Value,"<span class='filesize'>","")
   	MusicSize = Replace(MusicSize,"</span>","")
   	MusicSize = Replace(MusicSize," МБ","")
   	MusicSize = Replace(MusicSize,vbCr,"")
   	MusicSize = Replace(MusicSize,".",",")
    	
   	''WScript.Echo MusicSize '&" "& Int(MusicSize)
   	Call FillArray(MusicSize)
Next	
End Sub 

Sub FillArray(Info)
Dim Number
	If (IsNumeric(Info)) Then ' MB
		Number = Int(Info)
		If (Number<100) Then 
			ArrLimits(Number) = ArrLimits(Number) + 1
		Else 
			ArrLimits(100) = ArrLimits(100) + 1 
		End If 		
	Else ' KB
		ArrLimits(0) = ArrLimits(0) + 1
	End If 
End Sub 

Sub PrintResult()
	For i=1 To 100
		'WScript.Echo "Количество файлов размера " & i-1 & ".." & i & " МБ: " & ArrLimits(i-1)
		Output.WriteLine "Количество файлов размера " & i-1 & ".." & i & " МБ: " & ArrLimits(i-1)
	Next 
		'WScript.Echo "Количество файлов размера более 100 МБ: " & ArrLimits(100)
		Output.WriteLine "Количество файлов размера более 100 МБ: " & ArrLimits(100)
End Sub 
