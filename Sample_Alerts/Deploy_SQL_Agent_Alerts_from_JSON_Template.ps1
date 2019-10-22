<#
.SYNOPSIS
    Deploy SQL Agent Alerts stored in JSON Document to a list of SQL Servers
	
.DESCRIPTION   
    Deploy SQL Agent Alerts stored in JSON Document to a list of SQL Servers
   
.EXAMPLE
    Deploy_SQL_Agent_Alerts_from_JSON_Template.ps1 localhost
	
.Inputs
    Create List of Servers to push Alerts to below in section "Add Servers"

.Outputs
    SQL Agent Alerts Exist
	
.NOTES
    Requires Helper Powershell module
    SQLTranscriptase
	
.LINK
	https://github.com/gwalkey
	
#>

# Load Common Modules and .NET Assemblies
Import-Module ".\SQLTranscriptase.psm1"

# Init
Set-StrictMode -Version latest;
[string]$BaseFolder = (Get-Item -Path ".\" -Verbose).FullName
Write-Host  -f Yellow -b Black "Import SQL Agent Alerts"
$DeleteExisting = $true

# Create Server Datatable to work with
$Servers = New-Object System.Data.DataTable
$col1 = New-object system.Data.DataColumn ServerName,([string])
$col2 = New-object system.Data.DataColumn UserName,([string])
$col3 = New-object system.Data.DataColumn Password,([string])
$Servers.columns.add($col1)
$Servers.columns.add($col2)
$Servers.columns.add($col3)

function Add-ServerList
{
    [CmdletBinding()]
    Param(
        [string]$ServerName,
        [string]$UserName,
        [string]$Password
    )

    # Add Server To DataTable
    $row = $global:Servers.NewRow()
    $row.ServerName = $ServerName
    $row.UserName = $UserName
    $row.Password = $Password
    $Global:Servers.Rows.Add($row)

}

# Add Servers
Add-ServerList 'sqlprod01'
Add-ServerList 'dmzsqlprod01' 'username' 'password'


# Input File Existence Check
$AlertsInputFile = $BaseFolder+'\SQLAgentAlerts.json'
$NotifyInputFile = $BaseFolder+'\SQLAgentNotifications.json'
if(!(test-path -path $AlertsInputFile))
{
	Write-Warning('Alert File [{0}] Not Found in {1}' -f 'SQLAgentAlerts.json',$BaseFolder)
    exit
}

if(!(test-path -path $NotifyInputFile))
{
	Write-Warning('Notifications File [{0}] Not Found in {1}' -f 'SQLAgentNotifications.json',$BaseFolder)
    exit
}

# Import the Alerts
$AgentAlerts = Get-Content -Path "$BaseFolder\SQLAgentAlerts.json" | ConvertFrom-Json

# Import the Notifications for Each Alert - can have multiple
$AgentNotifications = Get-Content -Path "$BaseFolder\SQLAgentNotifications.json" | ConvertFrom-Json

# --------------------
# Process Each Server
# --------------------
Foreach($Server in $Servers)
{
    $SQLInstance = $Server.servername
    Write-Output('Processing Server [{0}]' -f $SQLInstance)

    if ([bool]($Server.PSobject.Properties.name -match "UserName"))
    {
        $myuser = $Server.UserName
    }
    else
    {
        $myuser = ''
    }

    if ([bool]($Server.PSobject.Properties.name -match "Password"))
    {
        $mypass = $Server.Password
    }
    else
    {
        $mypass = ''
    }
    
    # Get Auth Type
    $SQLCMD1 = "select serverproperty('productversion') as 'Version'"
    try
    {
        if ($mypass.Length -ge 1 -and $myuser.Length -ge 1) 
        {
            $myver = ConnectSQLAuth -SQLInstance $SQLInstance -Database "master" -SQLExec $SQLCMD1 -User $myuser -Password $mypass -ErrorAction Stop| select -ExpandProperty Version
            $serverauth="SQL"
        }
        else
        {
		    $myver = ConnectWinAuth -SQLInstance $SQLInstance -Database "master" -SQLExec $SQLCMD1 -ErrorAction Stop | select -ExpandProperty Version
            $serverauth = "Win"
        }

        if($myver -ne $null)
        {
            Write-Output ("SQL Version: {0}" -f $myver)
        }

    }
    catch
    {
        Write-Host -f red "$SQLInstance appears offline."
        continue
    }

   
    # SQL Auth
    if ($serverauth -eq 'sql')
    {
	    Write-Output "Using SQL Auth"
    
        # Alerts
        foreach ($Alert in $AgentAlerts)
        {

            # Delete Existing Alert with linked Notifications
            if ($DeleteExisting -eq $true)
            {
                $SQLCMD1=
                "
                EXEC msdb.dbo.sp_delete_alert @name ='$($Alert.AlertName)'

                "
                try
                {
                    $sqldelete1 = ConnectSQLAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLCMD1 -User $myuser -Password $mypass 
                }
                catch
                {
                    Write-Output("Error Deleting Existing SQL Alert [{0}], Error:{1}" -f $Alert.AlertName, $Error[0])
                }
            }

            # Construct Create Alert SQL Statement        
            $SQLNewAlert=
            "
            EXEC msdb.dbo.sp_add_alert 
            @name=N'$($Alert.AlertName)'
            ,@message_id=$($Alert.message_id)
            ,@severity=$($Alert.severity)
            ,@enabled=$($Alert.enabled)
            ,@delay_between_responses=$($Alert.delay_between_responses)
            ,@include_event_description_in=$($Alert.include_event_description)
            ,@job_Name=N'$($Alert.JobName)'
            ,@performance_condition='$($Alert.performance_condition)'
            "

            try
            {
                $sqlresult1 = ConnectSQLAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLNewAlert -User $myuser -Password $mypass    
            }
            catch
            {
                Write-Output("Error Creating SQL Alert [{0}], Error:{1}" -f $Alert.AlertName, $SQLInstance)
            }
        }

        # Notifications
        foreach($Notify in $AgentNotifications)
        {
            # Construct Create Notification SQL Statement 
            $SQLNewNotify=
            "
            EXEC msdb.dbo.sp_add_notification 
            @alert_name =N'$($Notify.AlertName)'
            ,@operator_name = N'$($Notify.OperatorName)'
            ,@notification_method=$($Notify.notification_method)
            "
            try
            {
                $sqlresult2 = ConnectSQLAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLNewNotify -User $myuser -Password $mypass 
            }
            catch
            {
                Write-Output("Error Creating SQL Notify [{0}], Error:{1}" -f $Notify.AlertName, $Error[0])
            }
        }

    }
    else
    # Win auth
    {
	    Write-Output "Using Windows Auth"
        # Alerts
        foreach ($alert in $AgentAlerts)
        {

            # Delete Existing Alert with linked Notifications
            if ($DeleteExisting -eq $true)
            {
                $SQLCMD1=
                "
                EXEC msdb.dbo.sp_delete_alert @name ='$($Alert.AlertName)'

                "
                try
                {
                    $sqldelete1 = ConnectWinAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLCMD1
                }
                catch
                {
                    Write-Output("Error Deleting Exising SQL Alert [{0}], Error:{1}" -f $Alert.AlertName, $Error[0])
                }
            }

            # Construct Create Alert SQL Statement        
            $SQLNewAlert=
            "
            EXEC msdb.dbo.sp_add_alert 
            @name=N'$($Alert.AlertName)'
            ,@message_id=$($Alert.message_id)
            ,@severity=$($Alert.severity)
            ,@enabled=$($Alert.enabled)
            ,@delay_between_responses=$($Alert.delay_between_responses)
            ,@include_event_description_in=$($Alert.include_event_description)
            ,@job_Name=N'$($Alert.JobName)'
            ,@performance_condition='$($Alert.performance_condition)'
            "
        
            try
            {
                $sqlresult1 = ConnectWinAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLNewAlert
            }
            catch
            {
                Write-Output("Error Creating SQL Alert [{0}], Error:{1}" -f $Alert.AlertName, $Error[0])
            }
        }

        # Notifications
        foreach($Notify in $AgentNotifications)
        {
            # Construct Create Notification SQL Statement 
            $SQLNewNotify=
            "
            EXEC msdb.dbo.sp_add_notification 
            @alert_name =N'$($Notify.AlertName)'
            ,@operator_name = N'$($Notify.OperatorName)'
            ,@notification_method=$($Notify.notification_method)
            "
            try
            {
                $sqlresult2 = ConnectWinAuth -SQLInstance $SQLInstance -Database 'msdb' -SQLExec $SQLNewNotify
            }
            catch
            {
                Write-Output("Error Creating SQL Notify [{0}], Error:{1}" -f $Notify.AlertName, $Error[0])
            }
        }
    }

    Write-Output('Wrote {0} Alerts to {1}' -f @($AgentAlerts).Count, $SQLInstance)
    Write-Output('Wrote {0} Notifs to {1}`r`n' -f @($AgentNotifications).Count, $SQLInstance)

}

# Return To Base
set-location $BaseFolder



