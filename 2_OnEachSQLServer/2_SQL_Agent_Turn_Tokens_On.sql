USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @alert_replace_runtime_tokens=1
GO


-- Must Bounce/Restart SQL Agent after this