USE [HDSVault]
GO

/****** Object:  Table [biz].[dimProviderAgreement_base]    Script Date: 10/10/2025 9:42:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [biz].[dimProviderAgreement_base](
	[ProviderAgreementPK] [int] IDENTITY(1,1) NOT NULL,
	[SourceID] [varchar](50) NULL,
	[SourceDescription] [varchar](50) NULL,
	[ProviderAgreementID] [char](12) NULL,
	[AgreementEffFromDt] [datetime] NULL,
	[AgreementTermDt] [datetime] NULL,
	[AgreementCategory] [char](1) NULL,
	[AgreementDescription] [varchar](255) NULL,
	[AgreementTypeDesc] [varchar](255) NULL,
	[AgreementType] [char](4) NULL,
	[RiskWithholdPercent] [money] NULL,
	[RiskWithholdIndicator] [char](1) NULL,
	[InpatientPriceIndicator] [char](1) NULL,
	[OutpatientPriceIndicator] [char](1) NULL,
	[HospitalOutlierIndicator] [char](1) NULL,
	[HospitalOutlierDiscountPercent] [money] NULL,
	[HospitalOutlierLimit] [money] NULL,
	[StraightDiscountPercent] [money] NULL,
	[StraightDiscountIndicator] [char](1) NULL,
	[StraightDiscountMethod] [char](1) NULL,
	[SupplementalDiscountPercent] [money] NULL,
	[ServiceDefinitionPrefix] [char](4) NULL,
	[AmbulatorySurgeryPrefix] [char](4) NULL,
	[PreauthPrefix] [char](4) NULL,
	[StoplossPrefix] [char](4) NULL,
	[ExclusionPrefix] [char](4) NULL,
	[DRGPrefix] [char](4) NULL,
	[RoomtypePrefix] [char](4) NULL,
	[PricingProfileIndicator] [char](1) NULL,
	[OverrideProfilePrefix] [char](12) NULL,
	[NKHash] [binary](20) NULL,
	[Type1Hash] [binary](20) NULL,
	[dss_start_date] [datetime] NULL,
	[dss_end_date] [datetime] NULL,
	[dss_current_flag] [char](1) NULL,
	[dss_version] [int] NULL,
	[dss_create_time] [datetime] NULL,
	[dss_update_time] [datetime] NULL,
 CONSTRAINT [dimProviderAgreement_base_idx_0] PRIMARY KEY CLUSTERED 
(
	[ProviderAgreementPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [biz].[dimProviderAgreement_base] ADD  DEFAULT ('1900-01-01') FOR [dss_start_date]
GO

ALTER TABLE [biz].[dimProviderAgreement_base] ADD  DEFAULT ('2999-12-31') FOR [dss_end_date]
GO

ALTER TABLE [biz].[dimProviderAgreement_base] ADD  DEFAULT ('Y') FOR [dss_current_flag]
GO

ALTER TABLE [biz].[dimProviderAgreement_base] ADD  DEFAULT ((1)) FOR [dss_version]
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Generated artificial key' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'ProviderAgreementPK'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Datetime a business key was started.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_start_date'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Datetime a business key was retired.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_end_date'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Flag to indicate the current (latest) version of a business key.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_current_flag'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Version number of a business key.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_version'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Date and time the row was created in the data warehouse.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_create_time'
GO

EXEC sys.sp_addextendedproperty @name=N'Comment', @value=N'Date and time the row was updated in the data warehouse.' , @level0type=N'SCHEMA',@level0name=N'biz', @level1type=N'TABLE',@level1name=N'dimProviderAgreement_base', @level2type=N'COLUMN',@level2name=N'dss_update_time'
GO


