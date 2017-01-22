#################################################
#												#
#.NAME											#
#	Microsoft Windows Server Nano Manager		#
#												#
#.AUTHOR										#
#	Ivan Temchenko								#
#												#
#.VERSION										#
#	1.0											#
#												#
#################################################


Import-Module ./Nano-Goodies.psm1
$selection = Show-Menu

switch ($selection) {
	1 { Install-Updates }
	2 { Write-Host "Two"}
	'x' { exit }
	Default {Show-Menu}
}