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
			) 
			else ( messagebox("Please save and name your file first.") )
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
	)

	) -- end struct

	RMT = _RMT_()
	RMT.InitVariables()
-- 	RMT.SetupMats()
	
)

