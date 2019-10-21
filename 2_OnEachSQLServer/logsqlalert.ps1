[CmdletBinding()]
Param(
    [string]$ServerName,
    [string]$DatabaseName,
    [string]$ErrorNumber,
    [string]$ErrorSeverity,
    [string]$ErrorMessage
)

Import-Module "C:\Program Files\WindowsPowerShell\Modules\Connect_SQLServer_Module.psm1"

# This is the name of your SQL Server that hosts the Centralized Database [SQLAlerts]
$DatabaseServer='sqlprod01'

$SQLErrMsg = $ErrorMessage.Replace([string]([char]39),'')

$sqlcmd1=
"
INSERT INTO dbo.AgentAlerts
(
    [Server],
    [Database],
    [EventTime],
    [ErrorNumber],
    [ErrorSeverity],
    [ErrorMessage]
)
VALUES
(   '$ServerName',
    '$DatabaseName',
    SYSDATETIME(),
    '$ErrorNumber',
    '$ErrorSeverity',
    '$SQLErrMsg'
    )
"
$sqlcmd1

try
{
    $sqlresults = Connect-InternalSQLServer -SQLInstance $DatabaseServer -Database "SQLAlerts" -SQLExec $sqlCMD1 -ErrorAction stop
}
catch
{
    $mailParams=@{
        To = "DBA@Company.com"
        From = "powershell_scripting@company.com"
        Subject = "Error doing INSERT into [SQLAlerts].[dbo].[AgentAlerts] on [$DatabaseServer]"
        SMTPServer = "mail.yourdomain.com"
        Body = $Error[0]
        BodyAsHTML = $True
    }

    send-mailmessage @mailparams
}

