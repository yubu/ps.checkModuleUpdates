# ps.checkModuleUpdates
Powershell module to check and install module updates. Will also create scheduled task which will run weekly and send toast notification with list of outdated modules.

### Installation from Github
```powershell
cd $env:Userprofile\Documents\WindowsPowerShell\Modules\
git clone https://github.com/yubu/ps.checkModuleUpdates.git
Import-Module ps.checkModuleUpdates
``` 
or
```powershell
cd c:\temp
git clone https://github.com/yubu/ps.checkModuleUpdates.git
Import-Module c:\temp\ps.checkModuleUpdates\ps.checkModuleUpdates.psm1
```

### Installation from PowerShell Gallery
```powershell
Install-Module ps.checkModuleUpdates
```

### Getting Started
##### Use powershell help to get commands and examples
```powershell
gcm -module ps.checkModuleUpdates
help -ex Check-ModuleUpdates
```
##### Examples
```powershell
Check-ModuleUpdates -all -sendToast
Check-ModuleUpdates PSReadline -all -sendToast -allowPrerelease -skipUpdate "posh-git|ps.checkModuleUpdates"
Check-ModuleUpdates -createSchedTask
```