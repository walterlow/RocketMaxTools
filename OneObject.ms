fn OneObject = 
(
	undo on
	(
		if (selection.count != 0) then
		(
			theobj = selection[1]
			convertToPoly selection[1]
			objarray = getcurrentselection()
			for obj in objarray do ( theobj.EditablePoly.attach obj theobj )
		)
		else
		(
			Messagebox("Please select more than 1 objects")
		)
	)
)