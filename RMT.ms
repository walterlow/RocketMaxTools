( 
	
	global RMT
	
	struct _RMT_
	(
		script_path,
		working_path,
		final_path,
		shader_path,
		ext,
		
		
		baseTexName,
		diffuseTex,
		speclevelTex,
		glassSpeclevelTex,
		bumpnormalTex,
		alphaTex,
		bumpTex,
		bump2Tex,
		lightmapTex,
		silhouetteTex,
		decalTex,
		
		fn InitVariables =
		(
			RMT.script_path = getDir #userscripts
			RMT.working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\"
			RMT.final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
			RMT.shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
			RMT.ext = ".png"
		),
		
		fn InitTextures =
		(
			if(getFilenameFile maxFileName != "") then
			(
				RMT.baseTexName = getFilenameFile maxFileName
				RMT.diffuseTex = RMT.final_path + RMT.baseTexName + "-A" + RMT.ext
				RMT.speclevelTex = RMT.final_path + RMT.baseTexName + "-A" + "_S" + RMT.ext
				RMT.glassSpeclevelTex = RMT.final_path + RMT.baseTexName + "-B" + "_S" + RMT.ext
				RMT.bumpnormalTex = RMT.final_path + RMT.baseTexName + "-A" +"_N" + RMT.ext

				RMT.alphaTex = RMT.final_path + RMT.baseTexName + "-B" + RMT.ext
				RMT.bumpTex = RMT.final_path + RMT.baseTexName + "-C" + RMT.ext
				RMT.bump2Tex = RMT.final_path + RMT.baseTexName + "-D" + RMT.ext
				RMT.lightmapTex = RMT.final_path + RMT.baseTexName + "-E" + RMT.ext
				RMT.silhouetteTex = RMT.final_path + RMT.baseTexName + "-F" + RMT.ext
				RMT.decalTex = RMT.final_path + RMT.baseTexName + "-G" + RMT.ext
				
				format "Initialize texture path for % scene. \n" RMT.baseTexName 
			) 
			else ( print ("Fail to setup materials. Please save and name your file first.") )
		),
		
		fn InitCallbacks =
		(
			-- refresh UI if scene changed (load, reset, new, nodes renamed, deleted)
			callbacks.addScript #systemPostNew "RMT.callback_SceneChanged()" id:#RMT_callback_RefreshUI
			callbacks.addScript #systemPostReset "RMT.callback_SceneChanged()" id:#RMT_callback_RefreshUI
			callbacks.addScript #filePostOpen "RMT.callback_SceneChanged()" id:#RMT_callback_RefreshUI
			callbacks.addScript #filePostSave "RMT.callback_SceneChanged()" id:#RMT_callback_RefreshUI
		),
		
		fn DestroyCallbacks=
		(
			callbacks.removeScripts id:#RMT_callback_RefreshUI
		),
		
		fn callback_SceneChanged =
		(
			InitTextures()
		),
		
		fn OneObject = 
		(
			local obj, theobj, objArray
			
			undo on
			(
				if (selection.count != 0) then
				(
					theobj = selection[1]
					convertToPoly theobj
					objArray = getcurrentselection()
					for obj in objArray do ( theobj.EditablePoly.attach obj theobj )
				)
				else
				(
					Messagebox("Please select more than 1 objects")
				)
			)
		),
		
		fn existFile strFileName = (getfiles strFileName).count != 0, 
		
		fn SetupMats =
		(
			RMT.InitTextures()
			
			if sceneMaterials["Main_2UV"] == undefined then
			(
				meditMaterials[7] = DirectX_9_Shader ()
				meditMaterials[7].name = "Main_2UV"  --eg, Simple_2UV
				meditMaterials[7].effectfile = RMT.shader_path + "simple-2uv.fx"
				meditMaterials[7].technique = 0
				meditMaterials[7].renderMaterial = StandardMaterial name:"simple-2uv_renderstyle"
				meditMaterials[7].Shininess = 30
				meditMaterials[7].BloodWallDepth = 2.5
				meditMaterials[7].BloodBlend = 1.75
				meditMaterials[7].ShadowFactor = 0.25
				meditMaterials[7].HighlightMultiplier = 0.1
				if (RMT.existFile (RMT.diffuseTex)) do (meditMaterials[7].TexDiffuse = openBitMap (RMT.diffuseTex) ) 
				if (RMT.existFile (RMT.bumpTex)) do (meditMaterials[7].TexBump = openBitMap (RMT.bumpTex) ) 
				if (RMT.existFile (RMT.lightmapTex)) do (meditMaterials[7].TexLightMap = openBitMap (RMT.lightmapTex) )  
			)
			else ( meditMaterials[7] =  sceneMaterials["Main_2UV"] )
		),
		
		fn CleanMats =
		(
			local obj, objArray
			undo on (
				objArray = getCurrentSelection()
		
				if objArray.count == 0 then
				(
					if querybox "Do you want to clear all object materials in the scene?" beep:true do
					$*.material = undefined
					macros.run "Medit Tools" "clear_medit_slots"
				)
				else
				(
					for obj in objArray do
					(
						obj.material = undefined
					)
					select objArray
				)
			)
		),
		
		fn BakeObject obj texsize =
		(
			local render_path, bp, lm, ilm, ao
			
			if(classof $ == Editable_Poly and selection.count != 0) then
			(
			
			try (destroyDialog gTextureBakeDialog)catch()
			--macros.run "Render" "BakeDialog"
			--mr = renderers.current = mental_ray_renderer()
			
			render_path = RMT.working_path + getFileNameFile maxFileName + "\\"

			--WTF IS THIS ABSTRACT CODE?  (sets the default output folder of RTT)
			
			if (not (doesfileExist render_path) ) then ( MAKEDir render_path)
			else
			(
				try(
				RTT_SceneData_AppData_Index = 0x41dd73d5
				RTT_data.FileOutput_FilePath = render_path
				setAppData rootNode (RTT_SceneData_AppData_Index+4) RTT_data.FileOutput_FilePath
				) catch()
			)
			
			bp = obj.INodeBakeProperties
			bp.removeAllBakeElements()
			bp.bakeEnabled = true
			bp.bakeChannel = 2
			bp.nDilations = 2


			--Lightmap
			lm = LightingMap()
			lm.outputSzX = lm.outputSzY = texsize
			--lm.filenameUnique = true
			
			--lm.fileType = render_path + $.name + lm.elementName + ".png"
			--lm.fileName = render_path + $.name + lm.elementName + ".png"
			
			lm.fileType = render_path + $.name + "_Light"  + ".png"
			lm.fileName = render_path + $.name + "_Light"  + ".png"

			lm.shadowsOn = true
			lm.directOn = true
			lm.indirectOn = false
			
			
			--Indirect Lightmap
			ilm = LightingMap()
			ilm.outputSzX = ilm.outputSzY = texsize
			--ilm.filenameUnique = true
			ilm.fileType = render_path + $.name + "_IL" + ".png"
			ilm.fileName = render_path + $.name + "_IL" + ".png"
			
			ilm.shadowsOn = false
			ilm.directOn = false
			ilm.indirectOn = true
			
			--AOmap
			ao = Ambient_Occlusion()
			ao.outputSzX = ao.outputSzY = texsize
			--ao.filenameUnique = true
			ao.fileType = render_path + $.name + "_AO" + ".png"
			ao.fileName = render_path + $.name + "_AO" + ".png"
			
			ao.samples = 512
			ao.spread = 1
			ao.maxDistance = 1
			ao.falloff = 1
			
			--Add elements
			bp.addBakeElement lm
			bp.addBakeElement ilm
			bp.addBakeElement ao
			
			--Render
			--mr = renderers.current = mental_ray_renderer()
			--mr.DistributedEnable = true
			--render rendertype:#bakeSelected outputwidth:Xsize outputheight:Ysize outputfile:(fPath+fName+fType)
			--render rendertype:#bakeSelected vfb:on progressBar:true outputSize:[2048,2048]
			render renderType:#bakeSelected frame:#current vfb:true progressBar:true outputwidth:texsize outputheight:texsize
		)
		else( MessageBox("Select Something!") )
	),
	
	fn saveCurrentFinal =
	(
		if querybox "Save current working file AND a copy in \Assets\Screens. Proceed?" beep:false then
		(
			work_path = ( RMT.working_path + (getFilenameFile maxFileName) + "\\" + maxFileName  ) --current
			screens_path = ( RMT.final_path + maxFileName ) --final
			savemaxFile screens_path useNewFile:false
			savemaxFile work_path 
		)
	),
	
	fn exportSelectedDAE =
	(
		local filename = getFilenameFile maxFileName
		local fileext = ".dae"
		local fileExportName =  final_path + filename + fileext
		
		if (selection.count != 0) then
		(
		exportFile (fileExportName) selectedOnly:true using:ColladaExporter 
		) else (messageBox "Select Something!")
	),
	
	fn createMRSkyPortal =
	(
		local rgbmul = 255
		local mrsp
		
		mrsp = mr_Sky_Portal light_Width:1.85 light_length:1.054 on:on pos:[0,0,0] isSelected:on
		mrsp.rgbFilter = color (0.996*rgbmul) (1*rgbmul) (0.8*rgbmul)
		mrsp.multiplier = 10
		mrsp.castShadows = on
		mrsp.shadow_samples = 4
		mrsp.mode = 1
		rotate $ (angleaxis 90 [0,0,1])
	),

	fn createMROmni =
	(
		local mrom
		
		mrom = MiAreaLightomni pos:[0,0,0] isSelected:on
		mrom.castShadows = on 
		mrom.multiplier = 1
		mrom.rgb = color 254 255 204
		mrom.mr_EnableLightShader
		mrom.attenDecay = 3 	-- 3 = inverse square
		
		mrom.useNearAtten = true
		mrom.nearAttenStart = 0.08
		mrom.nearAttenEnd = 0.2
		
		mrom.useFarAtten = true
		mrom.farAttenStart = 0.33
		mrom.farAttenEnd = 4.396
	),
	
	fn sendtoLayer obj layerName =
	(
		local o, theLayer
		
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
		) else( messagebox ("Please select something!") )
	),
	
	fn HideLayer layername =
	(
		local layer
		layer = LayerManager.getLayerfromName layerName
		if (layer != undefined) then layer.ishidden = true
	),

	fn ToggleLayer layername =
	(
		local layer
		layer = LayerManager.getLayerfromName layerName
		if (layer != undefined) then layer.ishidden = not layer.ishidden
	),
	
	fn DeleteEmptyLayers =
	(
		local layerIndex, layername
		
		for i = LayerManager.count-1 to 0 by -1 do
		(
			layerIndex = layerManager.getLayer i
			layerName = layerIndex.name
			layerManager.deleteLayerByName layerName
		)
	),
	
	fn DeleteEmptyObjects =
	(
		delete (for obj in Geometry where classof obj == Editable_Poly and polyop.getNumFaces obj == 0 collect obj)
		delete (for obj in Geometry where classof obj == Editable_Mesh and meshop.getNumFaces obj == 0 collect obj)
	),
	
	fn WeldVertices =
	(
		local obj, allVerts, selVerts
		
		for obj in selection do
		( 
				
				if (subobjectlevel == 0) then
				(
					undo on
					(
						obj.weldThreshold = 0.001 -- set weld threshold value
						allVerts = #{1..(polyop.getNumVerts obj)} -- get all verts list
						--print	("verts: " + allVerts.count as string)
						if (allVerts.count != 0) then
						(
							print ("Welded: " + allVerts.count as string  + " verts.")
							polyop.weldVertsByThreshold obj allVerts -- Weld
						)
					)
				)
				
				if (subobjectlevel == 1) then
				(
					undo on
					(
						$.weldThreshold = 0.001 -- set weld threshold value
						selVerts = $.selectedverts
						--print	("verts: " + selVerts.count as string)
						if (selVerts.count !=0 ) then
						(
						print ("Welded: " + selVerts.count as string + " verts.")
						$.EditablePoly.weldFlaggedVertices ()
						)
						else (messagebox("Select verts to weld!"))
					)
				) 
		)
	),
	
	fn ResetXFPoly = 
	(
		undo on
		(
			for obj in (selection) do
			(
				resetXForm obj
				convertToPoly obj
			)
		)
		print "Reseted XForms"
	),
	
	fn CenPivot = 
	(
		local selected_vert, selected_vert_pos, selected_edge, selected_edge_verts
		
		if (selection.count != 0) then
		(
			for obj in selection do
			(
				
				if obj.pivot != obj.center then
				(
				obj.pivot = obj.center
				) 
			)

			if (subobjectlevel == 1) then
			(
				selected_vert = polyop.getVertSelection $ as array
				if (selected_vert.count == 1) then
				(
					selected_vert_pos = polyop.getVert $ selected_vert[1]
					$.pivot = selected_vert_pos
					subobjectlevel = 0
				) else (Messagebox "Select a vertex!")
			)
			
			if (subobjectlevel == 2) then
			(
				selected_edge = polyop.getEdgeSelection $
				selected_edge_verts = (polyop.getVertsUsingEdge $ selected_edge ) as array
				if (selected_edge_verts.count == 2) then
				(
					selected_edge_center = ( (polyop.getVert $ selected_edge_verts[1]) + (polyop.getVert $ selected_edge_verts[2]) ) / 2
					$.pivot = selected_edge_center
					subobjectlevel = 0
				) else (Messagebox "Select an edge!")
			)
			
		)
		redrawviews()
	),

	fn centerPivotWorld =
	(
		for obj in selection do
		(
			obj.pivot = [0,0,0]
		)
	),
	
	fn DetachFace thename: (uniquename "detached") =
	(
		local selectedFaces
		
		if(subobjectlevel == 0 ) then ()
		else
		(
			selectedFaces = polyop.getFaceSelection $
			if (selectedFaces.isEmpty) then (messagebox("Please select some faces!"))
			else
			(	
				selectedFaces = polyop.getFaceSelection $
				polyop.detachFaces $ selectedFaces asNode:true name:thename
				--could also use #selection instead of selectedFaces
			)
		)
	),
	
	fn CreateBouncer =
	(
		local b, themat
	
		if sceneMaterials["bouncer"] == undefined then
		(
			themat = StandardMaterial name:"bouncer" specularLevel:30 glossiness:10 diffusecolor: (color 50 50 50)
		)
		
		if ($Bouncer == undefined) then
		(
			b = Plane length:12 width: 43 pos:[20,-1,6] isSelected:on lengthsegs:1 widthsegs:1
			rotate b (angleaxis -90 [1,0,0])
			convertToPoly b
			b.name = "Bouncer"
			b.boxmode = on
			b.castShadows = off
			b.receiveshadows = off
			b.ApplyAtmospherics = off
			b.inheritVisibility = off
			b.primaryVisibility = off
			b.secondaryVisibility = off
			b.material = themat
			sendtoLayer b "Bouncer"

		)
		else
		(
			Messagebox("Bouncer exists!")
			sendtoLayer $ "Bouncer"
		)

	),
	
	fn QuickPlanarUV2 =
	(
		if (selection.count == 1) then
		(
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		$.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
		--$.modifiers[#unwrap_uvw].unwrap.edit ()
		--do not reset uv2 for our workflow.	
		polyCount = polyop.getNumFaces $;
		$.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..polyCount} $
		$.modifiers[#unwrap_uvw].unwrap5.quickPlanarMap ()
		ConvertToPoly $
		Messagebox($.name + " Planar mapped!")
		) else (Messagebox "Select 1 object")
	),

	fn ApplyUV2 = 
	(
		if(selection.count != 0) then (
		modPanel.addModToSelection (Unwrap_UVW ()) ui:on
		for obj in selection do
		(
			obj.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
			ConvertToPoly obj
		)
		Messagebox("Selected objects UV2 applied")
		)
		else(
			Messagebox("Select something!")
		)
	),

	fn UVPack =
	(
		if (selection.count == 1) then
		(
			if querybox "This will pack and overide UV Chn2. Continue?" beep:true then
			(
				modPanel.addModToSelection (UV_Packer ()) ui:on
				$.modifiers[#UV_Packer].channel = 2
				$.modifiers[#UV_Packer].padding = 8
				$.modifiers[#UV_Packer].width = 2048
				$.modifiers[#UV_Packer].height = 2048
				$.modifiers[#UV_Packer].aspect = 1
				$.modifiers[#UV_Packer].pack()
			)
			else
			(
				Messagebox ("Packing cancelled")
			)
		) else
		(
			Messagebox ("Select 1 object only.")
		)

	),
	
	fn AutoDoors =
	(
		local p1, p2, p3, p4, p5, p6, p7, p8
		
		p5 = "E*_Breakable"
		p6 = "E*_Frame"
		p7 = "E*_Hole"
		p8 = "E*_Wall"
		
		p1 = "*_Breakable???*"
		p2 = "*_Frame???*"
		p3 = "*_Hole???*"
		p4 = "*_Wall???*"
		
		
		with redraw off
		(
			for obj in objects do 
			(
				if (matchPattern obj.name pattern: p1 or matchPattern obj.name pattern: p5) do
				(
					format "Matched Pattern: % or % --> % \n" p1 p5 obj.name 
					select obj
					sendtoLayer obj "Exit_Breakable"
				)
				
				if (matchPattern obj.name pattern: p2 or matchPattern obj.name pattern: p6) do
				(
					format "Matched Pattern: % or % --> % \n" p2 p6 obj.name 
					select obj
					sendtoLayer obj "Exit_Frame"
				)
				
				if (matchPattern obj.name pattern: p3 or matchPattern obj.name pattern: p7) do
				(
					format "Matched Pattern: % or % --> % \n" p3 p7 obj.name 
					select obj
					sendtoLayer obj "Exit_Hole"
				)
				
				if (matchPattern obj.name pattern: p4 or matchPattern obj.name pattern: p8) do
				(
					format "Matched Pattern: % or % --> % \n" p4 p8 obj.name 
					select obj
					sendtoLayer obj "Exit_Wall"
				)
				
			)
		)
	),
	
	fn EditNormalFix =
	(
		local smoothMod, obj
		
		smoothMod = Smooth()
		--smoothMod.autosmooth = on
		smoothMod.smoothingBits = 1
		smoothMod.threshold = 180
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
	),

	
	fn BuildRun =
	(
		shellLaunch "C:\Projects\Cow2\Tools\buildandrun.bat" ""
		print("Building...")
	)


	) -- end struct

	RMT = _RMT_()
	RMT.InitVariables()
	RMT.InitCallbacks()
-- 	RMT.SetupMats()
	
)

