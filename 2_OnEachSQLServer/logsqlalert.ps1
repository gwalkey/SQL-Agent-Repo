<#
.SYNOPSIS
	Sends SQL Agent Alert Tokens and INSERTs into a SQL Database
.DESCRIPTION
	
.EXAMPLE
 	
.EXAMPLE
 
.EXAMPLE
 
.Inputs
   
.Outputs

.NOTES
   
.LINK
    https://github.com/gwalkey/SQL-Agent-Repo

#>

[CmdletBinding()]
Param(
    [string]$ServerName,
    [string]$DatabaseName,
    [string]$ErrorNumber,
    [string]$ErrorSeverity,
    [string]$ErrorMessage
)

Function Connect-InternalSQLServer
{   
    [CmdletBinding()]
    Param([String]$SQLExec,
          [String]$SQLInstance,
          [String]$Database)

    Process
    {
        # Open connection and Execute sql against server using Windows Auth
        $DataSet = New-Object System.Data.DataSet
        $SQLConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;Integrated Security=SSPI;" 
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $SQLConnectionString
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQLExec
        $SqlCmd.Connection = $Connection
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $SqlCmd.CommandTimeout=60
   
        # Insert results into Dataset table
        $SqlAdapter.Fill($DataSet) | out-null
        # Eval Return Set
        if ($DataSet.Tables.Count -ne 0) 
        {
            $sqlresults = $DataSet.Tables[0]
        }
        else
        {
            $sqlresults =$null
        }

        # Close connection to sql server
        $Connection.Close()

        Write-Output $sqlresults
    }
}


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

