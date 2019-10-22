# SQL-Agent-Repo
A Centralized Reporting Database for SQL Server Agent Alerts

The default functionality for the SQL Agent is to only Send an Email upon the firing of an Agent Alert

This code will allow you to setup a Centralized Logging Database and associated SSRS Reports for SQL Agent Alerts

Some popular and recommended Alerts are:

* Error Number 17883 - Non-Yielding Worker Process
* Error Number 1205 - Transaction Deadlock
* Error Number 17890 - Most SQL process memory paged out
* Error Number 18204 - Backup Failed
* Error Number 833 - Slow IO

Setup instructions in each Subfolder above
1) Setup the Central SQL Server that will hold all the Alerts from all the other SQL Servers you want to monitor
2) Setup the Monitored Servers Agents, install a single Agent Job that calls the Powershell script that drops the Alert info into the central table
3) Use/Write your own SSRS/PowerBI report to surface the global alerts

All Code is Powershell, TSQL

Includes both SSRS and PowerBI Reports

![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/PowerBI.jpg)
![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/Summary.jpg)
![alt text](https://raw.githubusercontent.com/gwalkey/SQL-Agent-Repo/master/Details.jpg)
