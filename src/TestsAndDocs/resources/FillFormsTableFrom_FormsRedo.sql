/*
delete from [dbo].[_FormsRedo]
INSERT INTO [dbo].[_FormsRedo]
           ([Type]
           ,[Descrip]
           ,[lft]
           ,[rgt]
           ,[Created]
           ,[Deleted]
           ,[HeaderRecord]
           ,[Required])
SELECT [Type]
      ,[Descrip]
      ,[lft]
      ,[rgt]
           ,[Created]
           ,[Deleted]
      ,[HeaderRecord]
      ,[Required]
  FROM [dbo].[Forms]
  order by lft
*/
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

INSERT INTO [dbo].[Forms] 
           ([Type]
           ,[Descrip]
           ,[lft]
           ,[rgt]
           ,[Created]
           ,[Deleted]
           ,[HeaderRecord]
           ,[Required])
SELECT [Type]
      ,[Descrip]
      ,[lft]
      ,[rgt]
           ,[Created]
           ,[Deleted]
      ,[HeaderRecord]
      ,[Required]
  FROM [dbo].[_FormsRedo]
  order by lft
GO

/*
INSERT INTO [dbo].[Forms] 
([Type]
,[Descrip]
,[lft]
,[rgt]
,[Created]
)
VALUES(
'ROOT',
'Root of Tree',
1,
2,
GETDATE()
)
*/


