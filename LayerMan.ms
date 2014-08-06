struct LayerMan
(

	fn sendToLayer layerName =
	(
		local sel = getCurrentSelection()
		
		if sel.count != 0 then
		(
			for obj in sel do 
			(
					if (theLayer = LayerManager.getLayerfromName layerName) == undefined then
						(
							theLayer = LayerManager.newLayerfromName layerName
							theLayer.addNode obj
						)
						else
						(
							theLayer.addNode obj
						)
			)
			print ( "Selection moved to \" " + layerName +"\" Layer")
		) else
		(
			messagebox ("Please select something!")
		)
	),
	
	fn hideLayer layerName =
	(
		if (theLayer = LayerManager.getLayerfromName layerName) != undefined then theLayer.ishidden = true
	),

	fn toggleLayer layerName =
	(
		if (theLayer = LayerManager.getLayerfromName layerName) != undefined then theLayer.ishidden = not theLayer.ishidden
	),
	
	fn deleteEmptyLayers = 
	(
		if querybox "Do you want to delete all empty layers?" beep:true do
		for i = layerManager.count-1 to 0 by -1 do
		(
				layerIndex = layerManager.getLayer i
				layerName = layerIndex.name
				layerManager.deleteLayerByName layerName
		)
	)
	
) --struct


LayerMan = LayerMan()
LayerMan.deleteEmptyLayers()
