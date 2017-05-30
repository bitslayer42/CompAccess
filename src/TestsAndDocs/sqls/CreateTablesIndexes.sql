USE [ITForms]
GO

/****** Object:  Table [dbo].[_FormsRedo]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[_FormsRedo](
	[Type] [varchar](10) NULL,
	[Descrip] [varchar](max) NULL,
	[lft] [int] NULL,
	[rgt] [int] NULL,
	[Created] [datetime] NOT NULL,
	[Deleted] [datetime] NULL,
	[HeaderRecord] [bit] NULL,
	[Required] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[AdminEmails]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AdminEmails](
	[AdminID] [varchar](15) NOT NULL,
	[SubscribedNode] [int] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Admins]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Admins](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EMailAddress] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[AdminsREAL]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AdminsREAL](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EMailAddress] [varchar](40) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Forms]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Forms](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](10) NULL,
	[Descrip] [varchar](max) NULL,
	[lft] [int] NULL,
	[rgt] [int] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[HeaderRecord] [bit] NULL,
	[Required] [bit] NULL,
	[ReqResp] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[RequestHiddenFields]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestHiddenFields](
	[ReqID] [int] NOT NULL,
	[FieldID] [int] NOT NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[RequestItems]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RequestItems](
	[RequestID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[ItemValue] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Requests]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Requests](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[SupvID] [varchar](15) NULL,
	[SupvName] [varchar](100) NULL,
	[EnteredDate] [datetime] NULL,
	[Completed] [bit] NULL,
	[headerXML] [xml] NULL,
	[EditedXML] [xml] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[RequestSpecialEMailSent]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestSpecialEMailSent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[SpecialID] [int] NOT NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[Special]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Special](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](15) NOT NULL,
	[Description] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialCriteria]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialCriteria](
	[SpecialID] [int] NOT NULL,
	[Field] [int] NULL,
	[IsNot] [bit] NULL,
	[ItExists] [bit] NULL,
	[IsValue] [varchar](max) NOT NULL,
	[HumanCriteria] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialEmail]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialEmail](
	[SpecialID] [int] NOT NULL,
	[Email] [varchar](200) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialEmailFields]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SpecialEmailFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialID] [int] NOT NULL,
	[FieldID] [int] NOT NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[SpecialFieldsToHide]    Script Date: 5/24/2017 2:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SpecialFieldsToHide](
	[SpecialID] [int] NOT NULL,
	[FieldToHide] [int] NOT NULL
) ON [PRIMARY]

GO


