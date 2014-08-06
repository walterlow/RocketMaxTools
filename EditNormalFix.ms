fn EditNormalFix =
(
	smoothMod = Smooth()
	smoothMod.autosmooth = on
	smoothMod.threshold = 60
	obj = getCurrentSelection()
	
	if (obj.count != 0) then
	(
		for i = 1 to obj.count where canConvertTo obj[i] Editable_Poly == true do
		(
			addModifier obj[i] (Edit_Poly())
			addModifier obj[i] smoothMod
			CollapseStack obj[i]
			--obj.autoSmoothThreshold = 60
			--allfaces = polyOp.getNumFaces obj
			--polyOp.setFaceSmoothGroup obj #{1..allfaces} 0 
			--polyop.autosmooth obj
			
		)
		
	) else (messagebox ("Select some objects"))
	print "Normals reseted"
)
