#-----------------------------------------
# Set-HostnameAndIp.ps1
# hardev.sanghera@nutanix.com
# Nutanix Inc.
# No support or warranty, supplied "as is"
#
# Jan '18
#-----------------------------------------
 
<#
.SYNOPSIS
Set hostname and a static IP address on the target windows VM.
 
.EXAMPLE
Set-HostnameAndIP.ps1 -VMtoTarget "10.21.80.55" -newhostname "DC" -staticIP "10.21.80.40" -defaultgway "10.21.80.1" -defaultdns "10.21.196.1" -ifIndexdefault 12 -defaultprefix 24 -vmuserid administrator -vmpw "mypass"
 
.NOTES
Change the ifIndexdefault paramter for Windows 2012r2 vs 2016 (you may need to test what your image uses).
The network mask is not passed as a parameter - if you need edit it do it below.  
 
#>
 
Param(
  [Parameter(mandatory=$true)][string]$VMtoTarget,
  [Parameter(mandatory=$true)][string]$newhostname,
  [Parameter(mandatory=$true)][string]$staticIP,
  [Parameter(mandatory=$true)][string]$defaultgway,
  [Parameter(mandatory=$false)][string]$defaultdns = "10.21.253.10", #The default nameserver
  [Parameter(mandatory=$false)][string]$ifIndexdefault = 12,        #(No need to input/send as a aparamter) usually the NIC interface is 12 for WIn2012, 3 for Win 2016 - but we work it out 
  [Parameter(mandatory=$false)][string]$defaultprefix = 24,        #netmask for POC networks
  [Parameter(mandatory=$false)][string]$vmuserid,         
  [Parameter(mandatory=$false)][string]$vmpw
)
# Variables / parameters
 
$defaultmask = "255.255.255.0" #default netmask
 
#
write-host "Target VM: $VMtoTarget"
write-host "New IP: $staticIP"
write-host "Network prefix: $defaultprefix ($defaultmask)"
write-host "Default gateway: $defaultgway"
write-host "DNS: $defaultdns"
write-host "New hostname: $newhostname"
write-host "Userid/pw: $vmuserid/$vmpw"
 
#Save credentials
$vmsecurepw = ($vmpw | ConvertTo-SecureString -AsPlainText -Force)
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmuserid,$vmsecurepw

#Need the interfaceindex
$ifIndexdefault = invoke-command -computername $VMtoTarget -Credential $creds -scriptblock {(get-NetIPAddress -IPAddress $args[0]).interfaceindex} -ArgumentList $VMtoTarget
write-host "Interface: $ifIndexdefault"

#Send a job to the target VM  
write-host "===== Sending Job to $VMtoTarget to change IP address to $staticIP and hostname to $newhostname"
write-host "===== This will take about a minute then the target Vm will reboot"

Invoke-Command $VMtoTarget -Credential $creds -AsJob -ScriptBlock {param($ifIndexdefault, $staticIP, $defaultprefix, $defaultgway, $defaultdns, $newhostname) sleep 15; New-NetIPAddress -InterfaceIndex $ifIndexdefault –IPAddress $staticIP –PrefixLength $defaultprefix -DefaultGateway $defaultgway;sleep 15;Set-DnsClientServerAddress -InterfaceIndex $ifIndexdefault -ServerAddresses $defaultdns ;sleep 30; Rename-Computer -newname $newhostname -Restart} -ArgumentList $ifIndexdefault, $staticIP, $defaultprefix, $defaultgway, $defaultdns, $newhostname