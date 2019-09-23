Invoke-Command -ScriptBlock {tzUtil /s "Eastern Standard Time"}
$path = "C:\SQLServerFull"
if (-not (Test-Path $path))
{
net localgroup administrators PARAGON\TFSSqlSvrSvc /add
Get-Disk | Where-Object Number -eq '2' | Initialize-Disk -PartitionStyle GPT -PassThru -confirm:$false | New-Partition -DriveLetter S  -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$false
Get-Disk | Where-Object Number -eq '3' | Initialize-Disk -PartitionStyle GPT -PassThru -confirm:$false | New-Partition -DriveLetter L  -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "LOGS" -Confirm:$false
Get-Disk | Where-Object Number -eq '4' | Initialize-Disk -PartitionStyle GPT -PassThru -confirm:$false | New-Partition -DriveLetter T  -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "TEMP" -Confirm:$false
New-Item -Path "S:\" -Name "Data01" -ItemType "directory"
New-Item -Path "L:\" -Name "Log01" -ItemType "directory"
New-Item -Path "T:\" -Name "Temp01" -ItemType "directory"
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
Copy-Item -Path \\CLTSYSENGBOX01\en_sql_server_2014_enterprise_edition_x64_dvd_VLK -Destination C:\SQLServerFull\ -Recurse -Force
cd\
cd SQLServerFull
./Setup.exe /ACTION=INSTALL /CONFIGURATIONFILE=ConfigurationFile.ini /INDICATEPROGRESS /IAcceptSQLServerLicenseTerms=true
Start-Sleep -Seconds 60
cd\
cd SQLServerFull
./Setup.exe /ACTION=INSTALL /CONFIGURATIONFILE=SSRSConfigurationFile.ini /INDICATEPROGRESS /IAcceptSQLServerLicenseTerms=true
Start-Sleep -Seconds 60
cd\
cd SQLServerFull
.\SQLServer2014SP2-KB3171021-x64-ENU.exe /allinstances /IAcceptSQLServerLicenseTerms=true /quiet
Start-Sleep -Seconds 240
cd\
cd SQLServerFull
.\Server_Modern_FireAMPSetup.exe /S /desktopicon 0 /startmenu 0 /D="C:\Program Files\Cisco\AMP"
shutdown -r -t 00
}
Else {
cd\
rmdir SQLServerFull -Recurse -Force
Exit
}
