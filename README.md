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

##### Scheduled task
```powershell
cmu -createSchedTask
```
When scheduled task is created, it will send the [toast notification](https://blogs.msdn.microsoft.com/tiles_and_toasts/2015/07/08/toast-notification-and-action-center-overview-for-windows-10/) with list of outdated modules.
This notification will disappear after few seconds. To make it's appearance permanent in the action center (WinKey+A) you'll need to do the following:
1. Go to Settings (WinKey+I)
2. In the search field ("Find a setting") type "notification"
3. Select "Notifications & actions"
4. Scroll down to the section "Get notification from these senders"
5. Find Windows Powershell and/or Powershell 6 (x64)
6. Click on it and enable "Notifications" and "Show notification in action center"

The toast notification will stay in the action center (WinKey+A) until it will be manually dismissed.

Then you can run the update command on modules of your choice:
```powershell
cmu -allowPrerelease -all -update "module|module|module"
```
