#-----------------------------------------
# bankCloneCsvPrl.ps1
# hardev.sanghera@nutanix.com
# Nutanix Inc.
# No support or warranty, supplied "as is"
#
# Takes a csv as input then clones ALL VMs, THEN 
# intializes the data disk for ALL VMs THEN sets
# the hostname and static IP for ALL VMs
#
# Jan '18
#-----------------------------------------
#Clone a VM 
#csv format - column headers, all on one row
# HEADER       EXAMPLE
# ------       -------
# vmname       bnkbnkw1
# networkname  Bootcamp
# ctr          Bootcamp
# vmramgb      16
# vcpus        4
# corespercpu  1
# image        bnkW12-GOLD-template
# datadrivegb  56
# newhostname  bankbank
# staticIP     10.42.20.77
# gway         10.42.20.1
# dns          10.42.196.10
# pref         24
# vmuser       administrator
# vmpw         nutanix/4u
# driveletter  H
# label        HARDEV

Param(
  [Parameter(mandatory=$true)][string]$csvfile #file of specs of VM(s) to clone
)
./
$sleepafterclone = 60 #sleep after deploying the last VM
$sleepafterdiskinit = 55 #sleep after disk init 

#STEP1: Deploy/Clone all VMs from the csv
write-host "csv file: $csvfile"
write-host "which has" (get-content $csvfile | measure).count " lines"
import-csv $csvfile | `
ForEach-Object {
  write-host "Clone VM, Working for " $_.vmname
  write-host "Container " $_.ctr
  [int]$dd = $_.datadrivegb #wouldn't work unless I caste the datadrive size

  #Create the VM - clone it
  .\Create-NTNXVM.ps1 -VMName $_.vmname `
    -vmnetworkname $_.networkname `
    -VMRAMGB $_.vmramgb `
    -VMVcpus $_.vcpus `
    -VMCoresPerVcpu $_.corespercpu `
    -CONTAINER $_.ctr `
    -UseImageStore `
    -ImageName $_.image `
    -AdditionalVolumes $dd
  
  sleep 1
}

sleep $sleepafterclone 

#STEP2: Initialze the data disk in deployed VMs
import-csv $csvfile | `
ForEach-Object {
  write-host "Initialize data disk, Working for " $_.vmname
  $targetvm =  (get-ntnxvm | where vmname -eq $_.vmname)

  if ($targetvm.ipAddresses.count > 1){
     Write-Warning "Target VM has more than 1 IP address - I don't know what to do, bailing!"
     exit
  }
  
  #Initialize the data disk in the VM
  .\Set-Disk.ps1 -VMtoTarget $targetvm.ipAddresses[0] `
      -DriveLetter $_.driveletter `
      -Label $_.label `
      -vmuserid $_.vmuser `
      -vmpw $_.vmpw

  sleep 1
}
  
sleep $sleepafterdiskinit

#STEP3: Set static IP and hostname
#Set hostname and IP address - interface index changes for the version of Windows!
import-csv $csvfile | `
ForEach-Object {
  write-host "Set IP and hostname, Working for " $_.vmname
  $targetvm =  (get-ntnxvm | where vmname -eq $_.vmname)
    .\Set-HostnameAndIp.ps1 -VMtoTarget $targetvm.ipAddresses[0] `
       -newhostname $_.newhostname `
       -staticIP $_.staticIP `
       -defaultgway $_.gway `
       -defaultdns $_.dns `
       -defaultprefix $_.pref `
       -vmuserid $_.vmuser `
       -vmpw $_.vmpw
 sleep 1
}