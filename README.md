# ps.checkModuleUpdates
Powershell module to check and install module updates. Will also create scheduled task which will run weekly and send toast notification with list of outdated modules.

### Default scopes
- For Windows Powershell: AllUsers
- For Powershell Core: CurrentUser
- It could be changed by -Scope and/or -ScopeCore parameters

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
Check-ModuleUpdates -all -sendToast -allowPrerelease -skipUpdate "posh-git|ps.checkModuleUpdates"
Check-ModuleUpdates "posh-git|ps.checkModuleUpdates" -sendToast -allowPrerelease
Check-ModuleUpdates -createSchedTask
Check-ModuleUpdates -createSchedTaskWithTranscript

cmu "posh-git|ps.checkModuleUpdates" -update -allowPrerelease -skipScan
"posh-git|ps.checkModuleUpdates" | cmu -allowPrerelease -update -skipScan
Will install/update modules right away with no scanning their installed versions

cmu -compressTranscriptDir 
Will save the space by set the compression attribute to log/transcript directory ($env:USERPROFILE\.ps.checkModuleUpdate)
```

##### Scheduled task
```powershell
cmu -createSchedTask
Will create scheduled task to run the script every Friday at 5am. SchedTask will be created for powershell edition, the command was ran from

cmu -createSchedTaskWithTranscript
Will create scheduled task with transcript enabled

cmu -getLastUpdateCommand | iex
Retrieve and execute the update command from the transcript file of latest scheduled task run
```
When scheduled task is created, it will send the [toast notification](https://blogs.msdn.microsoft.com/tiles_and_toasts/2015/07/08/toast-notification-and-action-center-overview-for-windows-10/) with list of outdated modules.
This notification will disappear after few seconds. To make it's appearance permanent in the action center (WinKey+A) you'll need to do the following:
1. Go to Settings (WinKey+I)
2. In the search field ("Find a setting") type "notification"
3. Select "Notifications & actions"
4. Scroll down to the section "Get notification from these senders"
5. Find Windows Powershell and/or Powershell 6 (x64)
6. Click on it and enable "Notifications" and "Show notification in action center"

The toast notification will stay in the action center (WinKey+A) until it will be manually dismissed

Then you can run the update command on modules of your choice:
```powershell
cmu -allowPrerelease -all -update "module1|module2|module3"
cmu -getLastUpdateCommand | iex
```
