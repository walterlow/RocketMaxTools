--fn setAllFaceID 

-- "BBB-prefab_FireHose_Glass-mesh_42_1"
-- "BBB-prefab_FireExtinguisherAlpha-mesh_43_0"

-- "BBB-prefab_AbattoirWindowLarge01-Glass-Right-mesh_31_0"
-- "BBB-prefab_AbattoirWindowLarge01-Glass-Left-mesh_29_0"
-- "BBB-prefab_AbattoirWindowLarge01-Glass-Mid-mesh_30_0"
-- "BBB-prefab_AbattoirWindowSmallClear01-Glass-Left-mesh_35_0"
-- "BBB-prefab_AbattoirWindowSmall01-Glass-Left-mesh_35_0"

--Ladders id: 500
--Glass  id: 600
--FireExtAlpha: 700


fn sendtoLayerByName objName layerName =
(

	if (theLayer = LayerManager.getLayerfromName layerName ) == undefined then
	(
		theLayer = LayerManager.newLayerfromName layerName
		theLayer.addNode ( getNodeByName objName)
	)
	else
	(
		theLayer.addNode ( getNodeByName objName)
	)
		
	print ( "Selection moved to \" " + layerName +"\" Layer")
)


fn Detach matid objname =
(
	$.selectByMaterial matid
	selectedFaces = polyop.getFaceSelection $
	polyop.detachFaces $ selectedFaces asNode:true name: objname
)

fn collectGlassObj =
(
	a = #()
	
	for obj in objects do
	(
		if obj.name == "*Glass-*" then
		(
			append a getNodeByName(obj.name)
		)
	)
	return a
)

fn assignOthersMatID =
(
	for obj in objects do
	(
		if obj.name == "*Glass-*" then
		(
			polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 600
		)
		
		if obj.name == "*FireExtinguisherAlpha-*" then
		(
			polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 700
		)
	)	
)

fn assignDoorMatID =
(
	for obj in objects do
	(
		case obj.name of
		(
			"Exit0_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 100
			"Exit1_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 101
			"Exit2_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 102
			"Exit3_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 103
			"Exit4_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 104
			"Exit5_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 105
			"Exit6_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 106
			"Exit7_Breakable" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 107
			
			"Exit0_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 200
			"Exit1_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 201
			"Exit2_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 202
			"Exit3_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 203
			"Exit4_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 204
			"Exit5_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 205
			"Exit6_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 206
			"Exit7_Frame" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 207
			
			"Exit0_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 300
			"Exit1_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 301
			"Exit2_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 302
			"Exit3_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 303
			"Exit4_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 304
			"Exit5_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 305
			"Exit6_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 306
			"Exit7_Hole" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 307
			
			"Exit0_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 400
			"Exit1_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 401
			"Exit2_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 402
			"Exit3_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 403
			"Exit4_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 404
			"Exit5_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 405
			"Exit6_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 406
			"Exit7_Wall" : polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} 407
		)
	)
)

fn BulkDoorDetach =	
(
	totalFaces = #()
	for i = 0 to 7 do
	(
		id = ("10" + i as string)
		$.selectByMaterial (id as integer)
		selectedFaces = polyop.getFaceSelection $
		join totalFaces selectedFaces
	)
	objName = "_Breakables"
	layer = "Exit_Breakable"
	polyop.detachFaces $ totalFaces asNode:true name: objName
	sendtoLayerByName objName layer
	
	totalFaces = #()
	for i = 0 to 7 do
	(
		id = ("20" + i as string)
		$.selectByMaterial (id as integer)
		selectedFaces = polyop.getFaceSelection $
		join totalFaces selectedFaces
	)
	objName = "_Frames"
	layer = "Exit_Frame"
	polyop.detachFaces $ totalFaces asNode:true name: "_Frames"
	sendtoLayerByName objName layer
	
	totalFaces = #()
	for i = 0 to 7 do
	(
		id = ("30" + i as string)
		$.selectByMaterial (id as integer)
		selectedFaces = polyop.getFaceSelection $
		join totalFaces selectedFaces
	)
	objName = "_Hole"
	layer = "Exit_Hole"
	polyop.detachFaces $ totalFaces asNode:true name: "_Hole"
	sendtoLayerByName objName layer
	
	totalFaces = #()
	for i = 0 to 7 do
	(
		id = ("40" + i as string)
		$.selectByMaterial (id as integer)
		selectedFaces = polyop.getFaceSelection $
		join totalFaces selectedFaces
	)
	objName = "_Wall"
	layer = "Exit_Wall"
	polyop.detachFaces $ totalFaces asNode:true name: "_Wall"
	sendtoLayerByName objName layer
)

fn splitDetachables =
(

	for i = 0 to 7 do
	(
		id = ("10" + i as string)
		layer = ("Exit" + i as string + "_Breakable")
		Detach (id as integer) layer
	)

	for i = 0 to 7 do
	(
		id = ("20" + i as string)
		layer = ("Exit" + i as string + "_Frame")
		Detach (id as integer) layer
	)

	for i = 0 to 7 do
	(
		id = ("30" + i as string)
		layer = ("Exit" + i as string + "_Hole")
		Detach (id as integer) layer
	)

	for i = 0 to 7 do
	(
		id = ("40" + i as string)
		layer = ("Exit" + i as string + "_Wall")
		Detach (id as integer) layer
	)
	
	--replace with del empty objects
	delete (for obj in Geometry where classof obj == Editable_Poly and polyop.getNumFaces obj == 0 collect obj)
	
	--Auto doors
)

fn splitOthers =
(
	Detach 600 layer "Glass"
	Detach 700 layer "FireExtAlpha"
)

--assign unique mat ids to detachable objects
--merge obj, uv-pack, 


--do the magic here--
--select by material, detach faces, send to layer


--bake