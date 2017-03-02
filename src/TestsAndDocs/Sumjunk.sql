SELECT inr2.ID AS FormID, inr2.depth, inr2.Type, inr2.Descrip, ParentID, ItemValue FROM (
	SELECT inr.ID, inr.depth, inr.Type, inr.Descrip, inr.lft, (SELECT TOP 1 ID 
			   FROM Forms parent 
			   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
			   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
	FROM (
		SELECT node.ID, (COUNT(parent.ID) - 1) AS depth, 
		node.lft, node.rgt, node.Type, node.Descrip
		FROM Forms AS node
		INNER JOIN Forms AS parent
		ON node.lft BETWEEN parent.lft AND parent.rgt
		WHERE node.ID IN (
			SELECT DISTINCT Forms.ID
			FROM RequestItems 
			INNER JOIN Forms 
			ON RequestItems.FieldID = Forms.ID
			WHERE RequestID = 37
			UNION
			SELECT ID
			FROM Forms
			WHERE Deleted IS NULL
		)
		GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip
	) As inr
	INNER JOIN (
		SELECT *
		FROM Forms
		WHERE ID = 2
	) AS newroot
	ON inr.lft BETWEEN newroot.lft AND newroot.rgt
) AS inr2
LEFT JOIN (
	SELECT FieldID, ItemValue
	FROM RequestItems
	WHERE RequestID = 37
) AS req
ON inr2.ID = req.FieldID
ORDER BY inr2.lft



/*
ALTER PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 2
-- GetForm 0, 37
IF @FormID = 0 
BEGIN
	SELECT @FormID = RequestItems.FieldID
	FROM RequestItems INNER JOIN Forms ON RequestItems.FieldID = Forms.ID
	WHERE Forms.Type = 'FORM'
	AND RequestItems.RequestID = @RequestID
	SELECT * FROM Requests WHERE RequestID = @RequestID

	SELECT inr2.ID AS FormID, inr2.depth, inr2.Type, inr2.Descrip, ParentID, ItemValue FROM (
		SELECT inr.ID, inr.depth, inr.Type, inr.Descrip, inr.lft, (SELECT TOP 1 ID 
				   FROM Forms parent 
				   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
				   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
		FROM (
			SELECT node.ID, (COUNT(parent.ID) - 1) AS depth, 
			node.lft, node.rgt, node.Type, node.Descrip
			FROM Forms AS node
			INNER JOIN Forms AS parent
			ON node.lft BETWEEN parent.lft AND parent.rgt
			--WHERE node.Deleted IS NULL 
			GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip
		) As inr
		INNER JOIN (
			SELECT *
			FROM Forms
			WHERE ID = @FormID
		) AS newroot
		ON inr.lft BETWEEN newroot.lft AND newroot.rgt
	) AS inr2
	LEFT JOIN (
		SELECT FieldID, ItemValue
		FROM RequestItems
		WHERE RequestID = @RequestID
	) AS req
	ON inr2.ID = req.FieldID
	ORDER BY inr2.lft
END
ELSE
BEGIN
	SELECT * FROM Requests WHERE RequestID = @RequestID
	SELECT inr2.ID AS FormID, inr2.depth, inr2.Type, inr2.Descrip, ParentID, ItemValue FROM (
		SELECT inr.ID, inr.depth, inr.Type, inr.Descrip, inr.lft, (SELECT TOP 1 ID 
				   FROM Forms parent 
				   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
				   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
		FROM (
			SELECT node.ID, (COUNT(parent.ID) - 1) AS depth, 
			node.lft, node.rgt, node.Type, node.Descrip
			FROM Forms AS node
			INNER JOIN Forms AS parent
			ON node.lft BETWEEN parent.lft AND parent.rgt
			WHERE node.Deleted IS NULL
			GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip
		) As inr
		INNER JOIN (
			SELECT *
			FROM Forms
			WHERE ID = @FormID
		) AS newroot
		ON inr.lft BETWEEN newroot.lft AND newroot.rgt
	) AS inr2
	LEFT JOIN (
		SELECT FieldID, ItemValue
		FROM RequestItems
		WHERE RequestID = @RequestID
	) AS req
	ON inr2.ID = req.FieldID
	ORDER BY inr2.lft
END
GO


		SELECT DISTINCT Forms.ID
		FROM RequestItems 
		INNER JOIN Forms 
		ON RequestItems.FieldID = Forms.ID
		INNER JOIN Forms parents
		ON  Forms.lft <= parents.lft
		AND Forms.rgt >= parents.rgt
		WHERE RequestID = 37
		UNION
		SELECT ID
		FROM Forms
		WHERE Deleted IS NULL
*/