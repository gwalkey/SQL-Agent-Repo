### Setup Instructions on each Server you want to Monitor

1) Copy the **logsqlalert.ps1** Powershell Script to a common Powershell folder like [C:\PSScripts]
2) Edit SQL Script **1_Create_SQL_Job_to_Call_the_Powershell_Script.sql**, and change the [@notify_email_operator_name] to be your SQL Server Agent Operator
3) Create a new SQL agent Job using the TSQL Script **1_Create_SQL_Job_to_Call_the_Powershell_Script.sql**
4) Enable SQL Agent Tokens either manually in SSMS or using the script **2_SQL_Agent_Turn_Tokens_On.sql**, then restart the Agent
5) Edit each Agent Alert that you want to send to the Central Database and set the Response to call the SQL Agent Job **_SQL_Alerts_Call_Powershell**
6) Test the System by creating an Alert for 18456 (Login Error) and trying a bad password in SSMS in SQL Auth mode (SA/something)
7) The Alert row should show up in the **AgentAlerts** table on your central server Database
