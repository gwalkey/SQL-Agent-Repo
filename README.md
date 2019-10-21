# SQL-Agent-Repo
A Centrailzed Reporting Database for SQL Server Agent Alerts

The default functionality for the SQL Agent is to only Send an Email upon the firing of an Agent Alert

This code will allow you to setup a Centralized Logging Database and associated SSRS Reports for SQL Agent Alerts

Some popular and recommended Alerts are:

* Error Number 17883 - Non-Yielding Worker Process
* Error Number 1205 - Transaction Deadlock
* Error Number 17890 - Most SQL process memory paged out
* Error Number 18204 - Backup Failed
* Error Number 833 - Slow IO

* Consolidates Selected SQL Agent Alerts into one Central Depot for Reporting 
* Uses the SQL Agent, Agent Tokens, Powershell and a SQL Server database
* All Code is Powershell, TSQL
* Includes both SSRS and PowerBI Reports
