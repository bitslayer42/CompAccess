/****** Object:  UserDefinedFunction [dbo].[GetParent]    Script Date: 4/6/2017 11:13:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetParent](@ID INT) 
-- SELECT dbo.GetParent(24)
RETURNS INT
AS
BEGIN
	DECLARE @ParID INT 
	SELECT @ParID = ID FROM Forms WHERE lft = (
		SELECT MAX(parent.lft) AS parlft from Forms parent
		INNER JOIN (
			SELECT * FROM Forms
			WHERE ID = @ID
		) As child
		ON  parent.lft < child.lft
		AND parent.rgt > child.rgt
	)
	RETURN @ParID
END

GO


