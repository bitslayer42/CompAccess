/****** Object:  Table [dbo].[Forms]    Script Date: 3/2/2017 8:29:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
drop table Forms
GO
CREATE TABLE [dbo].[Forms](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](10) NULL,
	[Descrip] [varchar](max) NULL,
	[lft] [int] NULL,
	[rgt] [int] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[HeaderRecord] [bit] NULL CONSTRAINT [DF_Forms_HeaderRecord]  DEFAULT ((0)),
	[Required] [bit] NULL CONSTRAINT [DF_Forms_Required]  DEFAULT ((0)),
 CONSTRAINT [PK_nested_category] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


----------------------------------------------------------------------------------
INSERT INTO dbo.Forms(Type,Descrip,lft,rgt,Created)
VALUES
('ROOT','Root of Tree',1,2,GETDATE()
)
----------------------------------------------------------------------------------

/****** Object:  Table [dbo].[AdminEmails]    Script Date: 3/2/2017 8:29:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AdminEmails](
	[AdminID] [varchar](15) NOT NULL,
	[System] [varchar](10) NOT NULL,
 CONSTRAINT [PK_AdminEmails] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC,
	[System] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Admins]    Script Date: 3/2/2017 8:29:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Admins](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EmailForAll] [bit] NULL,
 CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[Edits]    Script Date: 3/2/2017 8:29:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Edits](
	[RequestID] [int] NULL,
	[StaffID] [varchar](15) NULL,
	[StaffName] [varchar](100) NULL,
	[EditDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


GO
SET ANSI_PADDING OFF
GO

/****** Object:  Table [dbo].[RequestItems]    Script Date: 3/2/2017 8:29:20 AM ******/
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

/****** Object:  Table [dbo].[Requests]    Script Date: 3/2/2017 8:29:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Requests](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[SupvName] [varchar](100) NULL,
	[EnteredDate] [datetime] NULL,
	[Completed] [bit] NULL,
	[headerXML] [xml] NULL,
 CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[RequestItems]  WITH CHECK ADD  CONSTRAINT [fk_RequestItems] FOREIGN KEY([RequestID])
REFERENCES [dbo].[Requests] ([RequestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[RequestItems] CHECK CONSTRAINT [fk_RequestItems]
GO


