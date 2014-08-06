fn autoSmooth tresh: =
(
	if selection.count == 0 then (messageBox "Select Some Objects!" title:"Warning" beep:off)
	else
	(
		local poAS = polyop.setFaceSmoothGroup
		local moAS = meshop.autosmooth
		for o in selection where isKindOf o GeometryClass and not isKindOf o Targetobject do
		(
			if o.modifiers.count != 0 then addModifier o (smooth autosmooth:true threshold:tresh) else
			(
				case classof o of (
					(Editable_Poly): (poAS o o.faces tresh add:false)
					(Editable_Mesh): (moAS o o.faces tresh ; update o)
				)
			)
		)
		redrawViews()
	)
)
autoSmooth tresh:0