Set oShell = CreateObject ("Wscript.Shell")
Dim strArgs
strArgs = "powershell -ExecutionPolicy Bypass -File C:\ProgramData\WindowsNT\connoff.ps1"
oShell.Run strArgs, 0, false