#-----------------------------------------
# Get-Config.ps1
# hardev.sanghera@nutanix.com
# Nutanix Inc.
# No support or warranty, supplied "as is"
#
# Jan '18
#-----------------------------------------
 
<#
.SYNOPSIS
Report on a system's hostname, volumes:driveletter, filesystem, sizeGB
 
.EXAMPLE
Set-Disk.ps1 -VMtoTarget "10.21.80.55" -vmuserid "administrator" -vmpw "mypassword"
 
.NOTES

 
#>
 
Param(
  [Parameter(mandatory=$true)][string]$VMtoTarget,
  [Parameter(mandatory=$false)][string]$vmuserid,         
  [Parameter(mandatory=$false)][string]$vmpw
)
# Variables / parameters
 
#
write-host "Target VM: $VMtoTarget"
write-host "Userid/pw: $vmuserid/$vmpw"

$F = 0
 
#Save credentials
$vmsecurepw = ($vmpw | ConvertTo-SecureString -AsPlainText -Force)
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmuserid,$vmsecurepw
 
#Send a job to the target VM  
write-host "===== Sending Job to $VMtoTarget to query config"
 
#output hostname, driveletter, filesystem, size in GB
Write-Host "-------------------------------------------------"
Write-Host "hostname:"
Invoke-Command $VMtoTarget -Credential $creds -ScriptBlock {hostname;Write-Host "OS: ";Write-Host(((Get-WmiObject win32_operatingsystem).name).split("|",2))[0];Get-Volume | ft driveletter, filesystem, @{Label="sizeGB"; Expression={ ($_.size/1024/1024/1024).ToString("#.##")}}}