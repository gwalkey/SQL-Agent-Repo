# SQL-Agent-Repo
A Centralized Reporting Database for SQL Server Agent Alerts

The default functionality for the SQL Agent is to only Send an Email upon the firing of an Agent Alert

This code will allow you to capture all those Alerts from all your SQL Servers into a Central Reporting Database

Some popular and recommended Alerts are:

* Error Number 17883 - Non-Yielding Worker Process
* Error Number 1205 - Transaction Deadlock
* Error Number 17890 - Most SQL process memory paged out
* Error Number 18204 - Backup Failed
* Error Number 833 - Slow IO

Setup instructions in each Subfolder above
1) Setup the Central SQL Server that will hold all the Alerts from all the other SQL Servers you want to monitor
2) Setup the Monitored Servers by installing an Agent Job that calls the Powershell script passing in the Alert params
3) Use My/Write your own SSRS/PowerBI reports to surface your SQL Estate-Wide alerts

All Code is Powershell, TSQL

Includes both SSRS and PowerBI Reports

![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/PowerBI.jpg)
![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/Summary.jpg)
![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/Details.jpg)
