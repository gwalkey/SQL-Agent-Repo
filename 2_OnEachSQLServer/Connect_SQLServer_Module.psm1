<#
.SYNOPSIS
    Connects to SQL Server using the Powershell SQL Data Adapter for returing Multiple Datasets
	
.DESCRIPTION
    Connects to SQL Server using the Powershell SQL Data Adapter for returing Multiple Datasets
   
.EXAMPLE
    

.Inputs
     $SQLInstance = SQL Server Name\SQL Instance
     $Database = SQL Server Database to connect to
     $SQLExec = T-SQL to be run

.Outputs
	$SQLResults = Query Results returned from the SQL Server
	
.NOTES
	This Module allows for the retrieval of data from SQL Server Databases.  
	
.LINK
	
	
#>
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

Function Connect-SQLServerExecuteNonQuery
{
    [CmdletBinding()]
    Param([String]$SQLExec,
          [String]$SQLInstance,
          [String]$Database)

    Process
    {
        # Open connection with Conn string
        $SQLConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;Integrated Security=SSPI;"
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $SQLConnectionString
        $Connection.Open()

        # Create SqlCommand object, define command text, and set the connection
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQlExec

        $SqlCmd.Connection = $Connection

        # Execute Table Truncation statement 
        $RowsInserted = $SqlCmd.ExecuteNonQuery()  

        # Close Conn
        $Connection.Close()


    }
}

Function Connect-ExternalSQLServer
{
    [CmdletBinding()]
    Param([String]$SQLExec,
          [String]$SQLInstance,
          [String]$Database,
          [String]$User,
          [String]$Password)    
    
    Process
    {
        # Open connection and Execute sql against server using Windows Auth
        $DataSet = New-Object System.Data.DataSet
        $SQLConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;User ID=$User;Password=$Password" 
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $SQLConnectionString
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQlExec
        $SqlCmd.Connection = $Connection
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
   
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

Function Connect-SQLServerExecuteNonQueryDMZ
{
    [CmdletBinding()]
    Param([String]$SQLExec,
          [String]$SQLInstance,
          [String]$Database,
          [String]$User,
          [String]$Password) 

    Process
    {
        # Open connection with Conn string
        $SQLConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;User ID=$User;Password=$Password"
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $SQLConnectionString
        $Connection.Open()

        # Create SqlCommand object, define command text, and set the connection
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQlExec

        $SqlCmd.Connection = $Connection

        # Execute Table Truncation statement 
        $RowsInserted = $SqlCmd.ExecuteNonQuery()  

        # Close Conn
        $Connection.Close()

    }
}

Function Connect-SQLServerExecuteScalar
{   
    [CmdletBinding()]
    Param([String]$SQLExec,
          [String]$SQLInstance,
          [String]$Database)

    Process
    {
        # Open connection with Conn string
        $SQLConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;Integrated Security=SSPI;"
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $SQLConnectionString
        $Connection.Open()

        # Create SqlCommand object, define command text, and set the connection
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQlExec
        $SqlCmd.Connection = $Connection

        # Execute Table Truncation statement 
        $Scalar = $SqlCmd.ExecuteScalar()  

        Write-Output $Scalar

        # Close Conn
        $Connection.Close()
    }
}

Function Connect-BulkInsert
{
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory=$true)]
            [String]$SQLInstance,
            [Parameter(Mandatory=$true)]
            [String]$Database,
            [Parameter(Mandatory=$true)]
            [String]$Table,
            [Parameter(Mandatory=$true)]
            [PSObject]$Datatable
         )

    Process
    {
        # Bulk it up to SQL
        $Connection = New-Object System.Data.SqlClient.SqlConnection    
        $Connection.ConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;Integrated Security=SSPI;"
        $Connection.Open()
    

        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $Connection
        $bulkCopy.DestinationTableName = "[$($Database)].[dbo].[$($Table)]"
        $bulkCopy.BatchSize = 1000
        $bulkCopy.BulkCopyTimeout = 10000
        $bulkCopy.WriteToServer($($Datatable))  
        $Connection.Close()

    }
}

Function Connect-DMZBulkInsert
{
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory=$true)]
            [String]$SQLInstance,
            [Parameter(Mandatory=$true)]
            [String]$Database,
            [Parameter(Mandatory=$true)]
            [String]$User,
            [Parameter(Mandatory=$true)]
            [String]$Password,
            [Parameter(Mandatory=$true)]
            [String]$Table,
            [Parameter(Mandatory=$true)]
            [PSObject]$Datatable
         )

    Process
    {
        # Bulk it up to SQL
        $Connection = New-Object System.Data.SqlClient.SqlConnection    
        $Connection.ConnectionString = "Data Source=$SQLInstance;Initial Catalog=$Database;User ID=$User;Password=$Password"
        $Connection.Open()
    

        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $Connection
        $bulkCopy.DestinationTableName = "[$($Database)].[dbo].[$($Table)]"
        $bulkCopy.BatchSize = 1000
        $bulkCopy.BulkCopyTimeout = 10000
        $bulkCopy.WriteToServer($($Datatable))  
        $Connection.Close()

    }
}
