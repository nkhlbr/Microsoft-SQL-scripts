USE [Se2Fast_NextRelease]
GO

/****** Object:  Table [dbo].[TreasuryRateTableDt]    Script Date: 1/20/2016 10:57:13 AM ******/
DROP TABLE [dbo].[TreasuryRateTableDt]
GO

/****** Object:  Table [dbo].[TreasuryRateTableDt]    Script Date: 1/20/2016 10:57:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TreasuryRateTableDt](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DT_PRIORITY] [int] NULL,
	[TempCalcValuesMVARemainingTerm] [float] NULL,
	[TempCalcValuesEffectiveDate] [date] NULL,
	[TreasuryRate] [varchar](500) NULL,
	CONSTRAINT UNICREATE_ UNIQUE (TempCalcValuesMVARemainingTerm,TempCalcValuesEffectiveDate)
) ON [AppData]

GO

SET ANSI_PADDING OFF
GO


