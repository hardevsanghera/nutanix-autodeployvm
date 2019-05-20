#-----------------------------------------
# Set-Disk.ps1
# hardev.sanghera@nutanix.com
# Nutanix Inc.
# No support or warranty, supplied "as is"
#
# Jan '18
#-----------------------------------------
 
<#
.SYNOPSIS
Init, Parition and Format Windows Disk
 
.EXAMPLE
Set-Disk.ps1 -VMtoTarget "10.21.80.55" -DriveLetter "D" -Label "DATA" -vmuserid "administrator" -vmpw "mypassword"
 
.NOTES

 
#>
 
Param(
  [Parameter(mandatory=$true)][string]$VMtoTarget,
  [Parameter(mandatory=$false)][string]$DriveLetter = "D",
  [Parameter(mandatory=$false)][string]$Label = "DATA",
  [Parameter(mandatory=$false)][string]$vmuserid,         
  [Parameter(mandatory=$false)][string]$vmpw
)
# Variables / parameters
 
#
write-host "Target VM: $VMtoTarget"
write-host "DriveLetter: $DriveLetter"
write-host "Userid/pw: $vmuserid/$vmpw"

$F = 0
 
#Save credentials
$vmsecurepw = ($vmpw | ConvertTo-SecureString -AsPlainText -Force)
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmuserid,$vmsecurepw
 
#Send a job to the target VM  
write-host "===== Sending Job to $VMtoTarget to setup new disk: $DriveLetter"
 
Invoke-Command $VMtoTarget -Credential $creds -AsJob -ScriptBlock {param($DriveLetter, $Label, $F) sleep 10;  Get-Disk | Where partitionstyle -eq ‘raw’ | Set-Disk -IsOffline $F ; sleep 10;  Get-Disk | Where partitionstyle -eq ‘raw’ | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter $DriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:0} -ArgumentList $DriveLetter, $Label, $F