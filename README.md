Use a csv file as input to deploy custom VMs into a Nutanix Cluster.  The main Create-NTNXVM.ps1 script has been changed to accommodate my project (also some fizes).

1. Create you template images and place them on EACH storage container that you want to deply VMs on.
  - Create your storage containers first
  - Use the Image service via Prism to upload your VM image (assuming Windows 2012r2 or 2016) to EACH storage container
  - You could also use existing VMs to make your images - see Nutanix KB2663 at https://portal.nutanix.com/#/page/kbs/details?targetId=kA032000000TTqoCAG
  - Also useful: Export an ISO (or Image) from Image service (AHV) at http://joshsinclair.com/?p=602
1. Edit 12VMs.csv for your needs - you don't need to have 12 VMs to deploy (or you could deploy more!)
2. Run ./CloneCsvPrl.ps1 -csvfile ./12VMs.csv (enter cluster/userid/password when prompted)

What gets done?
1.  A VM gets cloned with chosen attributes such as vCPU/vRAM/OS Disk/Data Disk(size and label)/hostname/Static IP address

Files:
csvfile ./12VMs.csv (enter cluster/userid/password when prompted)

What gets done?
1.  A VM gets cloned with chosen attributes such as vCPU/vRAM/OS Disk/Data Disk(size and label)/hostname/Static IP address

Files:
1.  CloneCsvPrl.ps1 - main cloning script
2.  12VMs.csv - input to 1.
3.  Create-NTNXVM.ps1 / Connect-Nutanix.ps1 (should be in /lib directory below main scripts), get this from https://github.com/hardevsanghera/nutanix-powershell as it's been edited / tailored.  The repo also provides \lib\Connect-Nutanix.ps1 and Destroy-Nutanix.ps1
4.  Set-HostnameandIP.ps1
5.  Set-Disk.ps1 - Intialize and assign a drive letter to a single data disk.
6.  Clone.ps1 - use direct parameters rather than input from csv (use instead of 1.)
7.  Get-Config.ps1 - query a VM's hostname, Installed OS and disk configs

Templates:
1.  Use any method to build your golden image VM, once built I recommend that you create an Image (via the Image service) on each storage container that your would deploy on - this way your gold source VM is idependant of the Image used to deploy - plus your can't power on and fiddle with an image.

Assumptions:
1. Nutanix AHV cluster is the target for deployment
2. VMs first boot and get an IP address etal via DHCP - from an UNMANAGED AHV network

Watch out!
1. The source Windows system that you execute the scripts from should have run (from Powershell started with Administratror priveliges):
 - Set_executionPolicy RemoteSigned
 - Set-Item WSMan:\\localhost\Client\TrustedHosts *
   (or you could add your known IP addresses - plus the DHCP ones when your VMs first boot).

NB:
You should test the scripts to make sure they meet your needs, feel free to use the scripts (please ensure that Nutanix gets acknowledged if you amend them) - no support or warranty is provided, they are offered "as is".

Watch out!
1. The source Windows system that you execute the scripts from should have run (from Powershell started with Administratror priveliges):
 - Set-executionPolicy RemoteSigned
 - Set-Item WSMan:\\localhost\Client\TrustedHosts *

NB:
You should test the scripts to make sure they meet your needs, feel free to use the scripts (please ensure that Nutanix gets acknowledged if you amend them) - no support or warranty is provided, they are offered "as is".

