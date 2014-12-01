fn sendtoLayer obj layerName =
(
	--select obj  --fix for select lights
	if selection.count != 0 then
		(
		for o in selection do 
		(
				if (theLayer = LayerManager.getLayerfromName layerName ) == undefined then
					(
						theLayer = LayerManager.newLayerfromName layerName
						theLayer.addNode o
					)
					else
					(
					theLayer.addNode o
					)
		)
		format "Selection moved to % \n" layerName
		--print ( "Selection moved to \" " + layerName +"\" Layer")
	) else
	(
		messagebox ("Please select something!")
	)
)

fn HideLayer layername =
(
	layer = LayerManager.getLayerfromName layerName
	if (layer != undefined) then layer.ishidden = true

)

fn ToggleLayer layername =
(
	layer = LayerManager.getLayerfromName layerName
	if (layer != undefined) then layer.ishidden = not layer.ishidden
	
)

fn DeleteEmptyLayers =
(
	
	DeleteEmptyObjects()
	for i = layerManager.count-1 to 0 by -1 do
	(
		layerIndex = layerManager.getLayer i
		layerName = layerIndex.name
		layerManager.deleteLayerByName layerName
	)
)