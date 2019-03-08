function Get-ModuleUpdates {
	<#
	.Synopsis
		Check powershell modules for updates
	.Description
		Check powershell modules for updates
	.Example
		Check-ModuleUpdates
		Check imported modules for updates
	.Example
		Check-ModuleUpdates -all
		Check all available modules for updates 
	.Example
		Check-ModuleUpdates PowershellGet -all
		Check module PowershellGet for updates
	.Example
		Check-ModuleUpdates -update -skipUpdate "PSReadLine"
		Will update all imported modules except module PSReadLine
	.Example
		Check-ModuleUpdates PackageManagement -all -update
		Will check and update module PackageManagement
	.Example
		Check-ModuleUpdates -all -update
		Will try to update all available modules
	.Example
		Check-ModuleUpdates -all -update -skipUpdate "PSReadLine|PSWindowsUpdate"
		Will update all modules available except modules PSReadLine and PSWindowsUpdate
	.Example
		Check-ModuleUpdates -all -skipUpdate "VMware.VimAutomation.Srm|VMware.VimAutomation.Storage"
		For PowerCLI, only VMware.PowerCLI should be installed	
	.Example
		Check-ModuleUpdates -allowPrerelease -all
		Will check also prerelease versions
	.Example
		Check-ModuleUpdates -allowPrerelease -update "PSReadLine"
		Will update PSReadLine to higher prerelease
	.Example
		Check-ModuleUpdates -all -sendToast
		Will check all modules for updates and send toast notification to Action center
	.Example
		Check-ModuleUpdates -createSchedTask
		Will create scheduled task to run the script every Friday at 5am. SchedTask will be created for powershell edition, the command was ran from
	#>
	[CmdletBinding()]
	[Alias("cmu","Check-ModuleUpdates")]
	param([switch]$update,[switch]$all,[switch]$sendToast,[switch]$createSchedTask,$module="",$skipUpdate="",$schedTaskScriptPath="",[switch]$allowPrerelease)
	
	begin {
		$exclude="excludePermanetSomethingIfNeeded"
		[string[]]$changelist=""
		# $schedTaskScriptPath=$psScriptRoot+"\"+$PSCmdlet.MyInvocation.MyCommand.Name+".ps1"
		
		# Set toast
		[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
		[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
		$ToastXml=[Windows.Data.Xml.Dom.XmlDocument]::new()
		# Get-StartApps  | sort name
		$appID='{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
	}

	Process {
		# Create sched task
		if ($createSchedTask) {
			# $actionArgCommandString="-command . $SchedTaskScriptPath; Check-ModuleUpdates -all -sendToast"
			$actionArgCommandString="-command import-module ps.checkModuleUpdates; Check-ModuleUpdates -all -sendToast"
			if ($PSVersionTable.PSEdition -eq "Core") {
				$splatNewSchT=@{
					Execute="pwsh"
					Argument=$actionArgCommandString
				}
				$splatArgs=@{
					Action=New-ScheduledTaskAction @splatNewSchT
					Trigger=New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 5am
					TaskName="RunModuleUpdateScriptCore"
				}
			}
			elseif ($PSVersionTable.PSEdition -eq "Desktop") {
				$splatNewSchT=@{
					Execute="powershell"
					Argument=$actionArgCommandString
				}
				$splatArgs=@{
					Action=New-ScheduledTaskAction @splatNewSchT
					Trigger=New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 5am
					TaskName="RunModuleUpdateScript"
				}
			}
			Register-ScheduledTask @splatArgs
			return
		}
		
		if ($all) {$gModParam=@{ListAvailable=$true}} else {$gModParam=@{ListAvailable=$false}}
			if ($allowPrerelease) { 
				get-module @gModParam | ? name -notmatch "$exclude" | ? name -match "$module" | select -Unique -pv localModule | %{
					"--> $_ --> $($_.author)", $(
						if ($_.PrivateData.psdata.prerelease) {$localPrerel=$_.version.ToString()+"-"+$_.PrivateData.psdata.prerelease;"$localPrerel"} 
						else {$_.version.toString()}), 
						(
							find-module -name $_ -ea silent -AllowPrerelease | %{
								if ($localPrerel) {
									if (diff $_.version ($localPrerel)) {$_.version.ToString() + " <--"; [array]$changelist+=$localModule.name} else {($_.version).tostring()}
									$localPrerel=""
								}
								elseif ($_.version -match '[a-zA-Z]') {if (diff $_.version $localModule.version.toString()) {$_.version.ToString() + " <--"; [array]$changelist+=$localModule.name} else {($_.version).tostring()}}
								else {if ([version]$_.version -gt $localModule.version) {$_.version + ' <--'; [array]$changelist+=$localModule.name} else {($_.version).tostring()} }
							}
						)
				} 
			}
			else { get-module @gModParam | ? name -notmatch "$exclude" | ? name -match "$module" | select -Unique -pv localModule | %{"--> $_ --> $($_.author)", $_.version.ToString(), (find-module -name $_ -ea silent | %{if ([version]$_.version -gt $localModule.version) {$_.version + ' <--'; [array]$changelist+=$localModule.name} else {($_.version).tostring()} })} }
		
		$changelist=$changelist | ?{$_}
		if ($skipUpdate) {$changelist=$changelist | ?{$_ -notmatch "$skipUpdate"} | ?{$_}}

		if (!$changelist -and !$skipUpdate) {write-host "All is up to date." -f green}
		elseif (!$changelist -and $skipUpdate) {write-host "All is up to date." -f green; write-host "Module(s) skipped: " -f green -nonewline; write-host "$skipUpdate" -f yellow}
		elseif ($changelist -and $skipUpdate) {Write-Host "Module(s) to update: " -f yellow -nonewline; Write-Host "$changelist" -f red; write-host "Module(s) skipped: " -f green -nonewline; write-host "$skipUpdate" -f yellow}
		elseif ($update -and $skipUpdate -and !$changelist) {write-host "All is up to date." -f green; write-host "Module(s) skipped: " -f green -nonewline; write-host "$skipUpdate" -f yellow}
		else {Write-Host "Module(s) to update: " -f yellow -nonewline; Write-Host "$changelist" -f red}
		if ($update -and $changelist -and $allowPrerelease) {
			Write-Output "`nWill update: $changelist ..."; foreach ($modName in $changelist) {install-module $modName -force -allowClobber -AllowPrerelease}
		}
		elseif ($update -and $changelist) {Write-Output "`nWill update: $changelist ..."; install-module $changelist -force -allowClobber}
		
		# Send toast
		if ($sendToast -and $changelist) {
			if ($PSVersionTable.PSEdition -eq "Core") {
				$XmlString = @"
				<toast>
				<visual>
					<binding template="ToastGeneric">
					<text>Module updates (PSCore):</text>
					<text>$changelist</text>
					</binding>
				</visual>
				</toast>
"@
			}
			elseif ($PSVersionTable.PSEdition -eq "Desktop") {
				$XmlString = @"
				<toast>
				<visual>
					<binding template="ToastGeneric">
					<text>Module updates:</text>
					<text>$changelist</text>
				</binding>
				</visual>
				</toast>
"@
			}
			$ToastXml.LoadXml($XmlString)
			$toast=[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appID)
			$toast.Show($ToastXml)
		}
	
	}
}
