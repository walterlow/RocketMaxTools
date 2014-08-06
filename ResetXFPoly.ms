fn ResetXFPoly = 
(
	undo on
	(
	for obj in (selection) do ( resetXForm obj)
	for obj in (selection) do ( convertToPoly obj)
	)
	print "Reseted XForms"
)
