USE [ITForms]
GO

/****** Object:  View [dbo].[GetFieldList]    Script Date: 5/24/2017 2:13:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GetFieldList] AS
-- Used by SP GetSpecial
-- select * from GetFieldList ORDER BY FormName, Sorter
SELECT node.ID, node.Descrip, form.Descrip AS FormName, node.lft AS Sorter FROM (
	SELECT * FROM Forms
	WHERE Type IN ('INPUT','DATE','RADIO','SELECT','CHECKBOX','NODE')
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

/****** Object:  View [dbo].[GetNodeList]    Script Date: 5/24/2017 2:13:11 PM ******/
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

/****** Object:  View [dbo].[Staff]    Script Date: 5/24/2017 2:13:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[Staff] AS 
SELECT BadgeNum, Name, EmailAddress
  FROM [data-other-sources].dbo._Staff





GO

/****** Object:  View [dbo].[vSpecialEmail]    Script Date: 5/24/2017 2:13:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSpecialEmail]
AS
SELECT        dbo.Special.ID, dbo.Special.Action, dbo.SpecialCriteria.Field, dbo.SpecialCriteria.IsNot, dbo.SpecialCriteria.IsValue, dbo.SpecialCriteria.HumanCriteria, 
                         Forms_1.Type AS CriteriaFieldType, Forms_1.Descrip AS CriteriaField, dbo.SpecialEmail.Email, dbo.SpecialEmailFields.FieldID, dbo.Forms.Type AS EmailFieldType, 
                         dbo.Forms.Descrip AS EmailField
FROM            dbo.SpecialEmail RIGHT OUTER JOIN
                         dbo.Special LEFT OUTER JOIN
                         dbo.Forms RIGHT OUTER JOIN
                         dbo.SpecialEmailFields ON dbo.Forms.ID = dbo.SpecialEmailFields.FieldID ON dbo.Special.ID = dbo.SpecialEmailFields.SpecialID ON 
                         dbo.SpecialEmail.SpecialID = dbo.Special.ID LEFT OUTER JOIN
                         dbo.SpecialCriteria LEFT OUTER JOIN
                         dbo.Forms AS Forms_1 ON dbo.SpecialCriteria.Field = Forms_1.ID ON dbo.Special.ID = dbo.SpecialCriteria.SpecialID
WHERE        (dbo.Special.Action = 'SENDEMAIL')

GO

/****** Object:  View [dbo].[vSpecialToHide]    Script Date: 5/24/2017 2:13:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSpecialToHide]
AS
SELECT        dbo.Special.ID, dbo.Special.Action, dbo.SpecialCriteria.Field, dbo.SpecialCriteria.IsNot, dbo.SpecialCriteria.IsValue, dbo.SpecialCriteria.HumanCriteria, 
                         dbo.SpecialFieldsToHide.FieldToHide, dbo.Forms.Type, dbo.Forms.Descrip
FROM            dbo.Forms RIGHT OUTER JOIN
                         dbo.SpecialFieldsToHide ON dbo.Forms.ID = dbo.SpecialFieldsToHide.FieldToHide RIGHT OUTER JOIN
                         dbo.Special ON dbo.SpecialFieldsToHide.SpecialID = dbo.Special.ID LEFT OUTER JOIN
                         dbo.SpecialCriteria ON dbo.Special.ID = dbo.SpecialCriteria.SpecialID
WHERE        (dbo.Special.Action = 'HIDERESPONSE')

GO


