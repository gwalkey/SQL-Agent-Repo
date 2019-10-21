USE [SQLAlerts]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--- Edit This List to include any Alert Numbers you want
CREATE VIEW [dbo].[vw_FailedLogins]
AS
SELECT        ID, Server, [Database], EventTime, ErrorNumber, ErrorSeverity, ErrorMessage
FROM            dbo.AgentAlerts
WHERE        (ErrorNumber IN ('17806', '18452', '18456'))
GO

---Hint: Look in this project's FREEBIES folder for Powershell Script to Download/Upload current Agent Alerts from your existing servers
