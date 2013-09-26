' ========== Variables ==========	
Dim FileNameInput
	FileNameInput = "Mail.txt"
	
Set FSO = CreateObject("Scripting.FileSystemObject")
Dim Info

' ========== Main ==========
If FSO.FileExists(FileNameInput) Then 
	Set Input = FSO.OpenTextFile(FileNameInput,1,False)
		Info  = Input.ReadAll
		Input.Close
		
	Set Output = FSO.OpenTextFile("Result.txt",2,True)
		Output.Write Decoder(Info)
		Output.Close
	
	WScript.Echo "Готово"
Else 
	WScript.Echo "Отсутствует файл с данными"
	WScript.Quit(1)
End If   

' ========== Functions ==========
Function  Decoder(Text)
Dim ArrChar, Length, NewText	
	NewText = ""
	
	Text = Replace(Text,VbCrLf,"")
	ArrChar = Split(Text,";")
	Length  = UBound(ArrChar)
	
	For i=0 To Length
		NewText = NewText & Chr(ArrChar(i))
	Next 
	
	Decoder = NewText
End Function 