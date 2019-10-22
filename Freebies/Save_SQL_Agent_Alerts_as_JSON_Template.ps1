<#
.SYNOPSIS
    Export SQL Agent Alerts as JSON Document
	
.DESCRIPTION   
    One file for all Alerts
   
.EXAMPLE
    Save_SQL_Agent_Alerts_as_JSON_Template.ps1 localhost
	
.EXAMPLE
    Save_SQL_Agent_Alerts_as_JSON_Template.ps1 server01 sa password

.Inputs
    ServerName, [SQLUser], [SQLPassword]

.Outputs
    Json document in current folder [SQLAgentAlerts.json]
    Json document in current folder [SQLAgentNotifications.json]
    	
.NOTES
    Requires Helper Powershell Modules
    SQLTranscriptase
	
.LINK
    https://github.com/gwalkey
	
	
#>
[CmdletBinding()]
Param(
  [string]$SQLInstance='localhost',
  [string]$myuser,
  [string]$mypass
)

# Load Common Modules and .NET Assemblies
Import-Module ".\SQLTranscriptase.psm1"

# Init
Set-StrictMode -Version latest;
[string]$BaseFolder = (Get-Item -Path ".\" -Verbose).FullName
Write-Host  -f Yellow -b Black "Export SQL Agent Alerts"
Write-Output "Server $SQLInstance"

$SQLCMD1 = "select serverproperty('productversion') as 'Version'"
try
{
    if ($mypass.Length -ge 1 -and $myuser.Length -ge 1) 
    {
        Write-Output "Testing SQL Auth"        
        $myver = ConnectSQLAuth -SQLInstance $SQLInstance -Database "master" -SQLExec $SQLCMD1 -User $myuser -Password $mypass -ErrorAction Stop| select -ExpandProperty Version
        $serverauth="sql"
    }
    else
    {
        Write-Output "Testing Windows Auth"
		$myver = ConnectWinAuth -SQLInstance $SQLInstance -Database "master" -SQLExec $SQLCMD1 -ErrorAction Stop | select -ExpandProperty Version
        $serverauth = "win"
    }

    if($myver -ne $null)
    {
        Write-Output ("SQL Version: {0}" -f $myver)
    }

}
catch
{
    Write-Host -f red "$SQLInstance appears offline."
    Set-Location $BaseFolder
	exit
}


 # Get the Alerts
$sqlCMD2 = 
"
SELECT 
	tsha.[Name] AS AlertName,
	tsha.message_id,
	tsha.severity,
	tsha.[enabled],
	tsha.delay_between_responses,
	tsha.include_event_description,
	sj.[name] AS 'JobName',
	tsha.performance_condition
FROM 
	msdb.dbo.sysalerts tsha
LEFT JOIN
	[msdb].[dbo].[sysjobs] sj
ON
	tsha.job_id = sj.job_id
"


# Get the Notifications for Each Alert - can have multiple
$sqlCMD3 = 
"
select 
	A.[name] AS 'AlertName',
	O.[name] AS 'OperatorName',
	notification_method
from 
	[msdb].[dbo].[sysalerts] a
inner join 
	[msdb].[dbo].[sysnotifications] n
ON
	a.id = n.alert_id
inner join
	[msdb].[dbo].[sysoperators] o
on 
	n.operator_id = o.id
"

$fullfolderPath = "$BaseFolder\$sqlinstance"
if(!(test-path -path $fullfolderPath))
{
	mkdir $fullfolderPath | Out-Null
}

Write-Output('Exporting Alerts and Notifications...')	
# Get ALerts
if ($serverauth -eq 'sql')
{
	Write-Output "Using SQL Auth"
    
    # Alerts
    $AgentAlerts = ConnectSQLAuth -SQLInstance $SQLInstance -Database 'master' -SQLExec $sqlCMD2 -User $myuser -Password $mypass    
    if ($AgentAlerts -eq $null)
    {
        Write-Output "No Agent Alerts Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\No Agent Alerts Found.txt"
        Set-Location $BaseFolder
        exit
    }
    # Export
    $AgentAlerts| select-object AlertName, message_id, severity, enabled, delay_between_responses, include_event_description, JobName, performance_condition| ConvertTo-Json | out-file "$fullfolderPath\SQLAgentAlerts.json" -force -Encoding ascii 
    Write-Output ("Exported: {0} Alerts" -f @($AgentAlerts).count)

    # Notifications    
	$AgentNotifications = ConnectSQLAuth -SQLInstance $SQLInstance -Database 'master' -SQLExec $sqlCMD3 -User $myuser -Password $mypass
    if ($AgentNotifications -eq $null)
    {
        Write-Output "No Agent Alert Notifications Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\No Agent Alert Notifications Found.txt"
        Set-Location $BaseFolder
        exit
    }
    # Export
    $AgentNotifications | select-object AlertName, OperatorName, notification_method | ConvertTo-Json  | out-file "$fullfolderPath\SQLAgentNotifications.json" -force -Encoding ascii
    Write-Output ("Exported: {0} Alert Notifications" -f @($AgentNotifications).count)
}
else
{
	Write-Output "Using Windows Auth"
    
    # Alerts
    $AgentAlerts =  ConnectWinAuth -SQLInstance $SQLInstance -Database 'master' -SQLExec $sqlCMD2
    if ($AgentAlerts -eq $null)
    {
        Write-Output "No Agent Alerts Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\No Agent Alerts Found.txt"
        Set-Location $BaseFolder
        exit
    }
    # Export
    $AgentAlerts| select-object AlertName, message_id, severity, enabled, delay_between_responses, include_event_description, JobName, performance_condition| ConvertTo-Json | out-file "$fullfolderPath\SQLAgentAlerts.json" -force -Encoding ascii 
    Write-Output ("{0} Alerts Exported" -f @($AgentAlerts).count)

    # Notifications
    $AgentNotifications = ConnectWinAuth -SQLInstance $SQLInstance -Database 'master' -SQLExec $sqlCMD3
    if ($AgentNotifications -eq $null)
    {
        Write-Output "No Agent Alert Notifications Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\No Agent Alert Notifications Found.txt"
        Set-Location $BaseFolder
        exit
    }
    # Export
    $AgentNotifications | select-object AlertName, OperatorName, notification_method | ConvertTo-Json  | out-file "$fullfolderPath\SQLAgentNotifications.json" -force -Encoding ascii
    Write-Output ("{0} Alert Notifications Exported" -f @($AgentNotifications).count)

}

# Return To Base
set-location $BaseFolder
