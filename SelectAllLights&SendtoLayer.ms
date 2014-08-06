(
	select lights
	for lightobj in selection do 
	(
			if (lightLayer = LayerManager.getLayerfromName "Lights") == undefined then
				(
					lightLayer = LayerManager.newLayerfromName "Lights"
					lightLayer.addNode lightobj
					--PromptBox "Layers Created."
				)
				else
				(
					lightLayer.addNode lightobj
				)
	)
	messagebox "Lights moved to Lights Layer"
) 