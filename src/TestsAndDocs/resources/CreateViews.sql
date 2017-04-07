/****** Object:  View [dbo].[GetNodeList]    Script Date: 4/6/2017 11:12:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[GetNodeList] AS
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

/****** Object:  View [dbo].[Staff]    Script Date: 4/6/2017 11:12:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[Staff] AS 
SELECT BadgeNum, Name, 'onejtw@msj.org' as EmailAddress --EmailAddress
  FROM [data-other-sources].dbo._Staff



GO


