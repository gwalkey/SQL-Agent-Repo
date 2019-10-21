USE [SQLAlerts]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AgentAlerts](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Server] [varchar](50) NOT NULL,
	[Database] [varchar](50) NOT NULL,
	[EventTime] [datetime2](7) NOT NULL,
	[ErrorNumber] [varchar](25) NULL,
	[ErrorSeverity] [varchar](25) NULL,
	[ErrorMessage] [varchar](700) NULL,
 CONSTRAINT [PK_AgentAlerts] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

