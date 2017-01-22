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

function Show-Menu () {
	$selection = 0
	Clear-Host
	if($selection -eq 'x'){Write-Host "yep"}
	Write-Host "Select action:
	1 - install server updates
	2 - install PS6 SSH remoting
	x - exit script"
	$selection = Read-Host "Input option"
	return $selection
}

function Install-PS6(){
	Write-Host "This function will install PowerShell version 6-alpha-14"
	Write-Host "Downloading..."
	Invoke-WebRequest 'https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.14/PowerShell_6.0.0.14-alpha.14-win10-x64.msi' | Out-File './ps6.msi'
	Write-Host "Unpacking..."
	$msi = (Get-ChildItem -Filter 'ps6.msi').FullName
	#$currentDir = (Get-Childitem ./)[0].FullName
	$installTarget = 'c:\Program Files\PowerShell'
	if(!(Test-Path $installTarget)){
	try{
		mkdir $installTarget
	}catch{
		Write-Host "Unable to create target dir at c:\Program Files. Not enough permission?"
		Start-Sleep -Seconds 10
		exit
	}}
	
}

function Install-Updates(){
	$updatesList = @{"kb3176936"="http://download.windowsupdate.com/c/msdownload/update/software/crup/2016/09/windows10.0-kb3176936-x64_5cff7cd74d68a8c7f07711b800008888b0fa8e81.msu";
	"kb3192366"="http://download.windowsupdate.com/d/msdownload/update/software/crup/2016/09/windows10.0-kb3192366-x64_af96b0015c04f5dcb186b879f07a31c32cf2e494.msu"}
$cabLocation = "./KB/cab"
if (!(Test-Path "./KB")){
	mkdir "./KB"
	}
foreach($kb in $updatesList.Keys){
	$kbName = $kb + ".msu"
	$kbUrl = $updatesList[$kb]
	$expandedName = "./KB/" + $kbName + "_ext"
	if(!(Test-Path $cabLocation)){
		mkdir $cabLocation
		}
	if(Test-Path ("./KB" + $kbName)){
		Write-Host "KB aleady exists."
		}
	else{
		Write-Host "Starting download of $kbName"
		Invoke-WebRequest $kbUrl | Out-File ("./KB/" + $kbName)	
		}
	if(!(Test-Path $expandedName)){
		Write-Host "Extracting $kbName"
		mkdir $expandedName
		Expand "./KB/" + $kbName -F:* $expandedName
		}
	Write-Host "Copying .cab"
	foreach($cab in (Get-ChildItem $expandedName -Filter "*.cab")){
			Copy-Item $cab.FullName $cabLocation
		}
	}
Write-Host "Download and extraction complete. Proceeding with installation..."
Write-Host "This operation will restart the server. Continue? [yes/no]"
if((Read-Host).ToLower() -ne "yes"){
	Write-Host "Bye!"
	exit
	}
foreach($update in (Get-ChildItem $cabLocation)){
	Add-WindowsPackage -Online -PackagePath $update.FullName
	}
Restart-Computer; exit
}