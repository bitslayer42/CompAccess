USE [ITForms]
GO

/****** Object:  Table [dbo].[AdminEmails]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AdminEmails](
	[AdminID] [varchar](15) NOT NULL,
	[SubscribedNode] [int] NOT NULL,
 CONSTRAINT [PK_AdminEmails] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC,
	[SubscribedNode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Admins]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Admins](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EMailAddress] [varchar](40) NULL,
 CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[AdminsREAL]    Script Date: 5/10/2017 2:39:29 PM ******/
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

/****** Object:  Table [dbo].[Forms]    Script Date: 5/10/2017 2:39:29 PM ******/
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
	[ReqResp] [bit] NULL,
 CONSTRAINT [PK_nested_category] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[RequestHiddenFields]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestHiddenFields](
	[ReqID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
 CONSTRAINT [PK_HiddenFields] PRIMARY KEY CLUSTERED 
(
	[ReqID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[RequestItems]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RequestItems](
	[RequestID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[ItemValue] [varchar](max) NULL,
 CONSTRAINT [PK_RequestItem] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Requests]    Script Date: 5/10/2017 2:39:29 PM ******/
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
	[EditedXML] [xml] NULL,
 CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[RequestSFEMailSent]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RequestSFEMailSent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[SpecialForkID] [int] NOT NULL,
 CONSTRAINT [PK_RequestSFEMailSent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[SpecialFork]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialFork](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](15) NOT NULL,
 CONSTRAINT [PK_SpecialFork] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialForkCriteria]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialForkCriteria](
	[SpecialForkID] [int] NOT NULL,
	[Criteria] [varchar](max) NOT NULL,
	[HumanCriteria] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialForkEmail]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialForkEmail](
	[SpecialForkID] [int] NOT NULL,
	[Email] [varchar](200) NOT NULL,
 CONSTRAINT [PK_SpecialForkEmail] PRIMARY KEY CLUSTERED 
(
	[SpecialForkID] ASC,
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[SpecialForkEmailFields]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SpecialForkEmailFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialForkID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
 CONSTRAINT [PK_SpecialForkEmailFields] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[SpecialForkFieldsToHide]    Script Date: 5/10/2017 2:39:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SpecialForkFieldsToHide](
	[SpecialForkID] [int] NOT NULL,
	[FieldsToHide] [varchar](200) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Forms] ADD  CONSTRAINT [DF_Forms_HeaderRecord]  DEFAULT ((0)) FOR [HeaderRecord]
GO

ALTER TABLE [dbo].[Forms] ADD  CONSTRAINT [DF_Forms_Required]  DEFAULT ((0)) FOR [Required]
GO

ALTER TABLE [dbo].[AdminEmails]  WITH CHECK ADD  CONSTRAINT [fk_AdminEmails] FOREIGN KEY([AdminID])
REFERENCES [dbo].[Admins] ([AdminID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AdminEmails] CHECK CONSTRAINT [fk_AdminEmails]
GO

ALTER TABLE [dbo].[RequestItems]  WITH CHECK ADD  CONSTRAINT [fk_RequestItems] FOREIGN KEY([RequestID])
REFERENCES [dbo].[Requests] ([RequestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[RequestItems] CHECK CONSTRAINT [fk_RequestItems]
GO


