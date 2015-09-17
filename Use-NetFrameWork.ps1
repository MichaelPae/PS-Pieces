Clear-Host
""
"Magie-Beispiel"
""
"Bsp.-Aufgabe: BaseName für Log-Filenamen extrahieren"
""
"pures PowerShell:"
$Script1 = $myInvocation.MyCommand.Name
$Log1 = $Script1.BaseName + ".log"
Write-Host "Script-Name: "$Script1.ToString()
Write-Host "   Log-Name: "$Log1.ToString()
""
".Net-Klasse in PowerShell:"
$Script2 = $myInvocation.MyCommand.Name
$Log2 = ([system.io.fileinfo]$Script2).BaseName + ".log"
Write-Host "Script-Name: "$Script2.ToString()
Write-Host "   Log-Name: "$Log2.ToString() 

<#
""
"Wie isses nur möglich? - Casting-Magie!"
$Script2 = $myInvocation.MyCommand.Name
$Script2.GetType()
([system.io.fileinfo]$Script2).GetType()
#>