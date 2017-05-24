USE [ITForms]
GO

/****** Object:  View [dbo].[GetNodeList]    Script Date: 5/10/2017 2:40:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[GetNodeList] AS
-- Used by SP GetAdmin
-- select * from GetNodeList ORDER BY Sorter
SELECT node.ID, node.Descrip, form.Descrip AS FormName, node.lft AS Sorter FROM (
	SELECT * FROM Forms
	WHERE Type = 'NODE'
	AND Deleted IS NULL
) AS node
INNER JOIN (
	SELECT * FROM Forms
	WHERE Type IN ('FORM','UNPUB')
	AND Deleted IS NULL
) AS form
ON form.lft < node.lft
AND form.rgt > node.rgt



GO

/****** Object:  View [dbo].[SpecialForkAll]    Script Date: 5/10/2017 2:40:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SpecialForkAll]
AS
SELECT        TOP (100) PERCENT dbo.SpecialFork.ID, dbo.SpecialFork.Action, dbo.SpecialForkCriteria.Criteria, dbo.SpecialForkCriteria.HumanCriteria, 
                         dbo.SpecialForkFieldsToHide.FieldsToHide, dbo.SpecialForkEmail.Email, dbo.SpecialForkEmailFields.FieldID, dbo.Forms.Type, dbo.Forms.Descrip
FROM            dbo.Forms RIGHT OUTER JOIN
                         dbo.SpecialForkEmailFields RIGHT OUTER JOIN
                         dbo.SpecialFork ON dbo.SpecialForkEmailFields.SpecialForkID = dbo.SpecialFork.ID LEFT OUTER JOIN
                         dbo.SpecialForkEmail ON dbo.SpecialFork.ID = dbo.SpecialForkEmail.SpecialForkID LEFT OUTER JOIN
                         dbo.SpecialForkCriteria ON dbo.SpecialFork.ID = dbo.SpecialForkCriteria.SpecialForkID LEFT OUTER JOIN
                         dbo.SpecialForkFieldsToHide ON dbo.SpecialFork.ID = dbo.SpecialForkFieldsToHide.SpecialForkID ON dbo.Forms.ID = dbo.SpecialForkEmailFields.FieldID
ORDER BY dbo.SpecialFork.ID

GO

/****** Object:  View [dbo].[SpecialFormAllShort]    Script Date: 5/10/2017 2:40:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SpecialFormAllShort]
AS
SELECT        TOP (100) PERCENT dbo.SpecialFork.ID, dbo.SpecialFork.Action, dbo.SpecialForkCriteria.Criteria, dbo.SpecialForkCriteria.HumanCriteria, 
                         dbo.SpecialForkFieldsToHide.FieldsToHide, dbo.SpecialForkEmail.Email
FROM            dbo.SpecialFork LEFT OUTER JOIN
                         dbo.SpecialForkEmail ON dbo.SpecialFork.ID = dbo.SpecialForkEmail.SpecialForkID LEFT OUTER JOIN
                         dbo.SpecialForkCriteria ON dbo.SpecialFork.ID = dbo.SpecialForkCriteria.SpecialForkID LEFT OUTER JOIN
                         dbo.SpecialForkFieldsToHide ON dbo.SpecialFork.ID = dbo.SpecialForkFieldsToHide.SpecialForkID
ORDER BY dbo.SpecialFork.ID

GO

/****** Object:  View [dbo].[Staff]    Script Date: 5/10/2017 2:40:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[Staff] AS 
SELECT BadgeNum, Name, EmailAddress
  FROM [data-other-sources].dbo._Staff





GO


