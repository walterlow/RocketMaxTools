( 
	
	global RMT
	
	global rf_MainFloater
	global ro_doorHelper
	global ro_doorHelper2
	global ro_TransferUV
	global ro_animHelper
	global ro_Menu01
	global ro_Menu02
	global ro_Menu03
	global ro_Menu04
	global ro_RocketBirds
	
	struct _RMT_
	(
		scriptName = "RocketMaxTools",
		settingsfile = getDir #userscripts + "\\" + scriptName + "\\" + "RMTSettings.ini",
		script_path,
		working_path,
		final_path,
		shader_path,
		ext,
		mrRender,
		slRender,
		
		--texture variables
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
		
		--mat ids for detaching
		ladderID,
		glassID,
		alphaID,
		
		sceneObjects,
		
		fn InitVariables =
		(
			--RMT.settingsfile = getDir #userscripts + "\\" + RMT.scriptName + "\\" + "RMTSettings.ini"
			RMT.script_path = getDir #userscripts
			RMT.working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\"
			RMT.final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
			RMT.shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
			RMT.ext = ".png"
			RMT.mrRender = renderers.current = mental_ray_renderer()
			RMT.slRender = Default_Scanline_Renderer()
			
			RMT.ladderID = 500
			RMT.glassID = 600
			RMT.alphaID = 700
			
			RMT.sceneObjects = RMT.collectSceneObjects()
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
			else ( print ("Fail to init texture paths. Please save and name your file first.") )
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
			RMT.DestroyCallbacks()
			RMT.InitTextures()
			RMT.InitCallbacks()
			RMT.collectSceneObjects()
		),
		
		fn getMaxFileName =
		(
			local filename = getFilenameFile maxfilename
			return filename 
		),
		
		fn makeDirName dirName =
		(
			if (not (doesfileExist dirName) ) then ( MAKEDir dirName)
			else ( format "% dirName exists! \n" dirName )
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
		
		fn existFile strFileName = ( (getfiles strFileName).count != 0 ), 
		
		fn SetupMats =
		(
			--reinit png paths
			RMT.InitTextures()
		
  			try(
			---------------------- FX materials --------------------------
			macros.run "Medit Tools" "clear_medit_slots"
			
			if sceneMaterials["Main_2UV"] == undefined  then
			(
				main2uv = DxMaterial ()
				main2uv.name = "Main_2UV"  --eg, Simple_2UV
				 
				main2uv.effectfile = RMT.shader_path + "simple-2uv.fx"
				main2uv.technique = 0
				main2uv.renderMaterial = StandardMaterial name:"simple-2uv_renderstyle"
				main2uv.Shininess = 30
				main2uv.BloodWallDepth = 2.5
				main2uv.BloodBlend = 1.75
				main2uv.ShadowFactor = 0.25
				main2uv.HighlightMultiplier = 0.1
				
				if (RMT.existFile (RMT.diffuseTex)) do (main2uv.TexDiffuse = openBitMap (RMT.diffuseTex) ) 
				if (RMT.existFile (RMT.bumpTex)) do (main2uvTexBump = openBitMap (RMT.bumpTex) ) 
				if (RMT.existFile (RMT.lightmapTex)) do (main2uv.TexLightMap = openBitMap (RMT.lightmapTex) )
					
				meditMaterials[7] = main2uv

			)
			else ( meditMaterials[7] = sceneMaterials["Main_2UV"] )
			
			if sceneMaterials["Simple"] == undefined then
			(
				simple = DxMaterial ()
				simple.name = "Simple"  --eg, Simple_2UV
				 
				simple.effectfile = RMT.shader_path + "simple.fx"
				simple.technique = 0
				simple.renderMaterial = StandardMaterial name:"simple_renderstyle"
				
				if (RMT.existFile  (RMT.diffuseTex)) do (simple.TexDiffuse = openBitMap (RMT.diffuseTex) ) 
					
				meditMaterials[8] = simple
			)
			else ( meditMaterials[8] = sceneMaterials["Simple"]   )
				
			
	 		if sceneMaterials["SimpleCastShadow_2UV"] == undefined then
			(
				SimpleCastShadow2uv = DxMaterial ()
				SimpleCastShadow2uv.name = "SimpleCastShadow_2UV"  --eg, Simple_2UV
				SimpleCastShadow2uv.effectfile = RMT.shader_path + "simple-2uv-castshadow.fx"
				SimpleCastShadow2uv.technique = 0
				SimpleCastShadow2uv.renderMaterial = StandardMaterial name:"simple_renderstyle"
				SimpleCastShadow2uv.Shininess = 30
				SimpleCastShadow2uv.BloodWallDepth = 2.5
				SimpleCastShadow2uv.BloodBlend = 1.75
				SimpleCastShadow2uv.ShadowFactor = 0.25
				SimpleCastShadow2uv.HighlightMultiplier = 0.1
					
				if (RMT.existFile (RMT.diffuseTex)) do (SimpleCastShadow2uv.TexDiffuse = openBitMap (RMT.diffuseTex) ) 
				if (RMT.existFile (RMT.bumpTex)) do (SimpleCastShadow2uv.TexBump = openBitMap (RMT.bumpTex) ) 
				if (RMT.existFile (RMT.lightmapTex)) do (SimpleCastShadow2uv.TexLightMap = openBitMap (RMT.lightmapTex) ) 
					
				meditMaterials[14] = SimpleCastShadow2uv
			)
			 else ( meditMaterials[14] = sceneMaterials["SimpleCastShadow_2UV"]  ) 
			
			if sceneMaterials["Silhouette"] == undefined then
			(
				Silhouette = DxMaterial ()
				Silhouette.name = "Silhouette"  --eg, Simple_2UV
				Silhouette.effectfile = RMT.shader_path + "silhouette.fx"
				Silhouette.technique = 0
				Silhouette.renderMaterial = StandardMaterial name:"silhouette_renderstyle"
				
				if (RMT.existFile (RMT.silhouetteTex)) do (Silhouette.TexDiffuse = openBitMap (RMT.silhouetteTex) ) 
					
				meditMaterials[9] = Silhouette
			)
			 else ( meditMaterials[9] = sceneMaterials["Silhouette"] )
				
			if sceneMaterials["Black"] == undefined then
			(
				blackfx = DxMaterial ()
				blackfx.name = "Black"  --eg, Simple_2UV
				blackfx.effectfile = RMT.shader_path + "black.fx"
				blackfx.technique = 0
				blackfx.renderMaterial = StandardMaterial name:"black_renderstyle"
				
				meditMaterials[10] = blackfx
			)
			 else ( meditMaterials[10] = sceneMaterials["Black"] )
				
			if sceneMaterials["Alpha"] == undefined then
			(
				alphafx = DxMaterial ()
				alphafx.name = "Alpha"  --eg, Simple_2UV
				alphafx.effectfile = RMT.shader_path + "simple-alpha.fx"
				alphafx.technique = 0
				alphafx.renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
				alphafx.Blend = 0.7
				alphafx.Show_Transparency = 0.5
				
				if (RMT.existFile (RMT.decalTex)) do (alphafx.TexDiffuse = openBitMap (RMT.decalTex) ) 
				
				meditMaterials[11] = alphafx
			)
			 else ( meditMaterials[11] = sceneMaterials["Alpha"] )

		 	if sceneMaterials["Alpha_2UV"] == undefined then
			(
				alpha2uv = DxMaterial ()
				alpha2uv.name = "Alpha_2UV"  --eg, Simple_2UV
				alpha2uv.effectfile = RMT.shader_path + "simple-alpha-2uv.fx"
				alpha2uv.technique = 0
				alpha2uv.renderMaterial = StandardMaterial name:"simple-alpha-2uv_renderstyle"
				alpha2uv.Shininess = 30
				alpha2uv.BloodWallDepth = 2.5
				alpha2uv.BloodBlend = 1.75
				alpha2uv.ShadowFactor = 0.25
				alpha2uv.HighlightMultiplier = 0.1
				
				if (RMT.existFile (RMT.alphaTex)) do (alpha2uv.TexDiffuse = openBitMap (RMT.alphaTex) ) 
				if (RMT.existFile (RMT.bump2Tex)) do (alpha2uv.TexBump = openBitMap (RMT.bump2Tex) ) 
				if (RMT.existFile (RMT.lightmapTex)) do (alpha2uv.TexLightMap = openBitMap (RMT.lightmapTex) ) 
					
				meditMaterials[12] = alpha2uv
					
			)
			 else ( meditMaterials[12] = sceneMaterials["Alpha_2UV"] ) 
				
		 	if sceneMaterials["Multiply"] == undefined then
			(
				multiplyfx = DxMaterial ()
				multiplyfx.name = "Multiply"  --eg, Simple_2UV
				multiplyfx.effectfile =  RMT.shader_path + "simple-multiply.fx"
				multiplyfx.technique = 0
				multiplyfx.renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
				multiplyfx.Blend = 1
				
				if (RMT.existFile (RMT.decalTex)) do (multiplyfx.TexDiffuse = openBitMap (RMT.decalTex) ) 

				meditMaterials[13] = multiplyfx
			)
			 else ( meditMaterials[13] = sceneMaterials["Multiply"] ) 
			
			
			if sceneMaterials["BreakableAlpha"] == undefined then
			(
				breakablealpha = DxMaterial ()
				breakablealpha.name = "BreakableAlpha"  --eg, Simple_2UV
				breakablealpha.effectfile = (RMT.shader_path + "simple-multiply.fx")
				breakablealpha.technique = 0
				breakablealpha.renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
				breakablealpha.Blend = 1
				
				if (RMT.existFile (RMT.diffuseTex)) do (breakablealpha.TexDiffuse = openBitMap (RMT.diffuseTex) ) 
					
				meditMaterials[15] = breakablealpha
			)
			 else ( meditMaterials[15] = sceneMaterials["BreakableAlpha"] )
			
			if sceneMaterials["Chicken"] == undefined then
			(
				chickenfx = DxMaterial ()
				chickenfx.name = "Chicken"
				chickenfx.effectfile = RMT.shader_path + "character-background.fx"
				chickenfx.technique = 0
				chickenfx.renderMaterial = StandardMaterial name:"character-background_renderstyle"
				chickenfx.Shininess = 30
				
				if (RMT.existFile (RMT.diffuseTex)) do (chickenfx.TexDiffuse = openBitMap (RMT.diffuseTex) ) 
				if (RMT.existFile (RMT.bumpTex)) do (chickenfx.TexBump = openBitMap (RMT.bumpTex) ) 
					
				meditMaterials[16] = chickenfx
			)
			 else ( meditMaterials[16] = sceneMaterials["Chicken"] )
			
			if sceneMaterials["Stars"] == undefined  then
			(
				starsfx = DxMaterial ()
				starsfx.name = "Stars"  --eg, Simple_2UV
				starsfx.effectfile = RMT.shader_path + "simple-alpha.fx"
				starsfx.technique = 0
				starsfx.renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
				starsfx.Blend = 1
				starsfx.Show_Transparency = 1
				
				if (RMT.existFile (alphaTex)) do (starsfx.TexDiffuse = openBitMap (RMT.alphaTex) ) 
					
				meditMaterials[17] = starsfx
			)
			 else ( meditMaterials[17] = sceneMaterials["Stars"] )
			
			
			if sceneMaterials["Terminator"] == undefined then
			(
			terminatorfx = DxMaterial () 
			terminatorfx.name = "Terminator"  --eg, Simple_2UV
			terminatorfx.effectfile = RMT.shader_path + "simple-alpha.fx"
			terminatorfx.technique = 0
			terminatorfx.renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
			terminatorfx.Blend = 1
			terminatorfx.Show_Transparency = 1		
				
			if (RMT.existFile (RMT.alphaTex)) do (terminatorfx.TexDiffuse = openBitMap (RMT.alphaTex) ) 
				
			meditMaterials[18] = terminatorfx
			)
			 else ( meditMaterials[18] = sceneMaterials["Terminator"]  )
			
		) --end try
  		catch( messagebox "Script Error: Please restart max or contact Walter. ;)")

			---------------------- Non-FX materials --------------------------
			
			meditMaterials[1] = StandardMaterial name:"Main" showInViewport:true
			meditMaterials[1].diffuseMapEnable = on
			meditMaterials[1].twoSided = on
			meditMaterials[1].diffuseMap = Bitmaptexture fileName:  (RMT.diffuseTex)

			meditMaterials[1].specularLevelMapEnable = on
			meditMaterials[1].specularLevelMap = Bitmaptexture fileName: (RMT.speclevelTex)
			
			meditMaterials[1].bumpMapEnable = on
			meditMaterials[1].bumpMap = Normal_Bump ()
			meditMaterials[1].bumpMap.normal_map = Bitmaptexture fileName: (RMT.bumpnormalTex)
			meditMaterials[1].bumpMapAmount = 100
			
			------
			
			meditMaterials[3] = StandardMaterial name:"Glass" showInViewport:true
			meditMaterials[3].diffuseMapEnable = on
			meditMaterials[3].twoSided = on
			meditMaterials[3].diffuseMap = Bitmaptexture fileName:  (RMT.alphaTex)
			
			meditMaterials[3].specularLevelMapEnable = on
			meditMaterials[3].specularLevelMap = Bitmaptexture fileName: (RMT.glassSpeclevelTex)
			
			meditMaterials[3].bumpMapAmount = 100
		),
		
		fn CleanMats =
		(
			local objArray
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
		
		fn SetupMR =
		(
			
-- 			if (renderers.current != RMT.mrRender) then renderers.current = RMT.mrRender
			
			--FG BASICS
			RMT.mrRender.FinalGatherEnable2 = true 
			RMT.mrRender.FinalGatherDensity = 0.3
			RMT.mrRender.FinalGatherAccuracy = 1100
			RMT.mrRender.FinalGatherBounces = 4
			
			--FG INTERPOLATION
			RMT.mrRender.FinalGatherUseRadiusInterpolation = true
			RMT.mrRender.FinalGatherView = false
			RMT.mrRender.UseFinalGatherRadius = true
			RMT.mrRender.UseFinalGatherMinRadius = true
			RMT.mrRender.FinalGatherRadius = 32
			RMT.mrRender.FinalGatherMinRadius = 3.3
			
			RMT.mrRender.MaximumReflections = 1
			RMT.mrRender.MaximumRefractions = 1
			
			
			------------------------draft------------------------------
			
-- 			--FG BASICS
-- 			RMT.mrRender.FinalGatherEnable2 = true 
-- 			RMT.mrRender.FinalGatherDensity = 0.1
-- 			RMT.mrRender.FinalGatherAccuracy = 50
-- 			RMT.mrRender.FinalGatherBounces = 0
-- 			
-- 			--FG INTERPOLATION
-- 			RMT.mrRender.FinalGatherUseRadiusInterpolation = false
-- 			RMT.mrRender.FinalGatherView = false
-- 			RMT.mrRender.UseFinalGatherRadius = false
-- 			RMT.mrRender.UseFinalGatherMinRadius = false
-- 			RMT.mrRender.FinalGatherRadius = 1
-- 			RMT.mrRender.FinalGatherMinRadius = 1
-- 			
-- 			RMT.mrRender.MaximumReflections = 1
-- 			RMT.mrRender.MaximumRefractions = 1
	
			print ("MentalRay FG Settings Loaded")
		),
		
		fn BakeObject obj texsize =
		(
			local render_path, bp, lm, ilm, ao
			
-- 			if renderers.current != RMT.mrRender then ( RMT.mrRender ; print"swap")
			
			if(classof $ == Editable_Poly and selection.count == 1 ) then
			(
			
			try (destroyDialog gTextureBakeDialog)catch()
			--macros.run "Render" "BakeDialog"
			--mr = renderers.current = mental_ray_renderer()
			
			render_path = RMT.working_path + getFileNameFile maxFileName + "\\"

			RMT.makeDirName(render_path)
			
			/* if (not (doesfileExist render_path) ) then ( MAKEDir render_path)
			else
			(
				try(
				RTT_SceneData_AppData_Index = 0x41dd73d5
				RTT_data.FileOutput_FilePath = render_path
				setAppData rootNode (RTT_SceneData_AppData_Index+4) RTT_data.FileOutput_FilePath
				) catch()
			) */
			
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
	
	fn importFX = 
	(
		
		mergemaxfile (RMT.script_path + "\\RocketMaxTools\\Assets\\FX\\FX.max") #select #useSceneMtlDups
		
		if scenematerials["Multiply"] != undefined then
		(
			$FXMultiply*.material = scenematerials["Multiply"] 
		) 
		else
		(
			print ("Please setup Multiply material.")
		)
		
		if scenematerials["Alpha"] != undefined then
		(
			$FXAlpha*.material = scenematerials["Alpha"] 
		) 
		else
		(
			print ("Please setup Alpha material.")
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
	
	fn TransferUV source target sourcechn targetchn = 
	(
	ChannelInfo.CopyChannel source 3 sourcechn
	ChannelInfo.PasteChannel target 3 targetchn
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
					RMT.sendtoLayer obj "Exit_Breakable"
				)
				
				if (matchPattern obj.name pattern: p2 or matchPattern obj.name pattern: p6) do
				(
					format "Matched Pattern: % or % --> % \n" p2 p6 obj.name 
					select obj
					RMT.sendtoLayer obj "Exit_Frame"
				)
				
				if (matchPattern obj.name pattern: p3 or matchPattern obj.name pattern: p7) do
				(
					format "Matched Pattern: % or % --> % \n" p3 p7 obj.name 
					select obj
					RMT.sendtoLayer obj "Exit_Hole"
				)
				
				if (matchPattern obj.name pattern: p4 or matchPattern obj.name pattern: p8) do
				(
					format "Matched Pattern: % or % --> % \n" p4 p8 obj.name 
					select obj
					RMT.sendtoLayer obj "Exit_Wall"
				)
				
			)
		)
	),
	
	fn SelectSimilar =
	(
		if selection.count !=0 then
		(
	
		local FindBySimilarSize = true
		local FindBySimilarRatio = true
		local SimilarityTolerance = 0.005 -- higher tolerance selects more objects which are not quite so similar. must be less than 1.
		local FindByMatchingFaceCount = true
		local FindByInstances = true
		local FindByMaxSelectSimilar = false -- false by defualt because this gets lots of stuff which isnt necessarily similar.
		local FindByWireColor = false -- false by default since this may find lots of stuff
		local DoNotSelectHidden = true
		
		(
					
			 obj = selection[1]
			 if subobjectlevel == 4 or subobjectlevel == 5 then
			 (
			  print "select matching elements"
			  selectedfaces = polyop.getFaceSelection obj
			  facecount = selectedfaces.numberset
			  allfaces = obj.faces
			  newselection = polyop.getFaceSelection obj
			  discardedfaces = #{}
			  
			  for face in allfaces do (
			   if (newselection[face.index] == false and discardedfaces[face.index] == false) then 
			   (
				-- we havent seen this face before.
				thiselement = polyop.getElementsUsingFace obj face
				if thiselement.numberset == facecount then (
				 --print "found a matching element"
				 join newselection thiselement
				) else (
				 join discardedfaces thiselement
				)
			   )
			  )
			  
			  polyop.setfaceselection obj newselection
			  redrawviews()
			 )
			 else
			 (
			  matchingobjs = #()
			  append matchingobjs obj
			  print "select matching objects"
				 
			  if superclassof(obj) == GeometryClass and classof(obj) != Biped_Object then
			  (
			   --find geometry with matching bounding size OR face count
			   
			   if FindBySimilarSize or FindBySimilarRatio then (
				 originalrotation = obj.rotation
				 originalposition = obj.position
				 obj.rotation = (quat 0 0 0 0)

				XDimension = (obj.max.x - obj.min.x)
				YDimension = (obj.max.y - obj.min.y)
				ZDimension = (obj.max.z - obj.min.z)
				
				XZRatio = XDimension / ZDimension
				YZRatio = YDimension / ZDimension
				
				obj.rotation = originalrotation
				obj.position = originalposition
				
				max modify mode
				
				for checkobj in geometry do (
				 originalrotation = checkobj.rotation
				 originalposition = checkobj.position
				 checkobj.rotation = (quat 0 0 0 0)
				 
				 if FindBySimilarSize then
				 (
				  if XDimension > ((checkobj.max.x - checkobj.min.x) * (1.0 - SimilarityTolerance)) and XDimension < ((checkobj.max.x - checkobj.min.x) * (1 / (1.0 - SimilarityTolerance))) and
				   YDimension > ((checkobj.max.y - checkobj.min.y) * (1.0 - SimilarityTolerance)) and YDimension < ((checkobj.max.y - checkobj.min.y) * (1 / (1.0 - SimilarityTolerance))) and
				   ZDimension > ((checkobj.max.z - checkobj.min.z) * (1.0 - SimilarityTolerance)) and ZDimension < ((checkobj.max.z - checkobj.min.z) * (1 / (1.0 - SimilarityTolerance)))  then
				  ( 
				   print (checkobj.name + " is a similarsize match")
				   appendIfUnique matchingobjs checkobj
				  )
				 )
				 
				 if FindBySimilarRatio then 
				 (
				  checkXZRatio = (checkobj.max.x - checkobj.min.x) / (checkobj.max.z - checkobj.min.z)
				  checkYZRatio = (checkobj.max.y - checkobj.min.y) / (checkobj.max.z - checkobj.min.z)
				  
				  if XZRatio > (checkXZRatio * (1.0 - SimilarityTolerance)) and XZRatio < (checkXZRatio * (1 / (1.0 - SimilarityTolerance))) and
				   YZRatio > (checkYZRatio * (1.0 - SimilarityTolerance)) and YZRatio < (checkYZRatio * (1 / (1.0 - SimilarityTolerance))) then
				  ( 
				   print (checkobj.name + " is a similarratio match")
				   appendIfUnique matchingobjs checkobj
				  )
				 )
				 
				 
				 checkobj.rotation = originalrotation
				 checkobj.position = originalposition
				)
			   )
			   

			   if FindByMatchingFaceCount and ((classof obj) == editable_poly or (classof obj) == editable_mesh) then
			   (
				for eachobj in geometry do
				(
				 if classof eachobj == editable_poly or classof eachobj == editable_mesh then
				 (
				  if obj.faces.count == eachobj.faces.count then
				  (
					appendIfUnique matchingobjs eachobj
				  )
				 )
				)
			   )
			   
			   if FindByWireColor then
			   (
				for eachobj in geometry do
				(
				 if eachobj.wirecolor == obj.wirecolor then
				 (
				  appendIfUnique matchingobjs eachobj
				 )
				)
			   )
			   
			  )
			  else
			  (
			   --select all objects matching class
			   for eachobj in $* do 
			   (
				if classof eachobj == classof(obj) then
				(
				 appendIfUnique matchingobjs eachobj
				)
			   )
			  )
			  
			  clearselection()
			  
			  if FindByMaxSelectSimilar then
			  (
			   actionMan.executeAction 0 "40099"  -- Selection: Select Similar
			  )

			  if FindByInstances then
			  (
			   InstanceMgr.GetInstances obj &instances
			   selectmore instances
			  )
			  
			  selectmore matchingobjs
			  
			  
			  if DoNotSelectHidden == true then
			  (
			   currentselection = getcurrentselection()
			   clearselection()
			   for eachobj in currentselection do
			   (
				if eachobj.ishidden == false then (selectmore eachobj)
			   )
			  )
			  
			 )
			)
			
		)
	), --end fn selectsimilar
	
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
	
	fn sendtoLayerByName objName layerName =
	(
		local theLayer

		if (theLayer = LayerManager.getLayerfromName layerName ) == undefined then
		(
			theLayer = LayerManager.newLayerfromName layerName
			theLayer.addNode ( getNodeByName objName)
		)
		else
		(
			theLayer.addNode ( getNodeByName objName)
		)
			
		format "Selection moved to % \n" layerName
	),

	fn Detach matid objname =
	(
		local selectedFaces
		
		$.selectByMaterial matid
		selectedFaces = polyop.getFaceSelection $
		polyop.detachFaces $ selectedFaces asNode:true name: objname
	),
	
	
	fn collectNodesbyName namepattern =
	(
		local a = #()

		for obj in RMT.sceneObjects do
		(
			if matchpattern obj.name pattern:namepattern then
			(
				append a (getNodeByName(obj.name))
				format "Collected % based on % pattern \n" a namepattern 
			)
		)
		a
	),
	
	fn collectSceneObjects =
	(
		RMT.sceneObjects = for obj in objects collect obj
	),

	fn assignOthersMatID =
	(
			RMT.collectSceneObjects()

			RMT.assignObjGenericMatID (RMT.collectNodesbyName "*Glass-*")  RMT.glassID
			RMT.assignObjGenericMatID (RMT.collectNodesbyName "*Glass*")  RMT.glassID
			RMT.assignObjGenericMatID (RMT.collectNodesbyName "*FireExtinguisherAlpha-*")  RMT.alphaID
			RMT.assignObjGenericMatID (RMT.collectNodesbyName "*FireExtAlpha*")  RMT.alphaID
			RMT.assignObjGenericMatID (RMT.collectNodesbyName "*Ladder*")  RMT.ladderID

	),
	
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
		print "Doors marked..."
	),
	
	
	fn assignObjGenericMatID sel id =
	(
		for obj in sel do
		(
			polyop.setFaceMatID obj #{1..(polyop.getNumFaces obj)} id   
		)
	),
	
	fn assignFaceGenericMatID id =
	(
		local selectedFaces
		
		if selection.count == 1 then
		(
			if subobjectlevel == 0 do messagebox "Select faces or elements"
			
			if subobjectlevel == 4 or subobjectlevel == 5 then
			(
				selectedFaces = polyOp.getFaceSelection $
				if ( not selectedFaces.isEmpty) then polyop.setFaceMatID $ selectedFaces id
				else ( messagebox "Select faces or elements")
			) 
		) 	else ( messagebox "Select 1 obj")
	),
	

	
	fn markLadders = 
	(
		RMT.assignFaceGenericMatID RMT.ladderID
		subobjectlevel = 0
	),
	
	fn BulkDoorDetach =	
	(
		local totalFaces, selectedFaces, objName, layer
		
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
		RMT.sendtoLayerByName objName layer
		
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
		RMT.sendtoLayerByName objName layer
		
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
		RMT.sendtoLayerByName objName layer
		
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
		RMT.sendtoLayerByName objName layer
	),
	
	fn splitDetachables =
	(
		local id, layer

		for i = 0 to 7 do
		(
			id = ("10" + i as string)
			layer = ("Exit" + i as string + "_Breakable")
			RMT.Detach (id as integer) layer
		)

		for i = 0 to 7 do
		(
			id = ("20" + i as string)
			layer = ("Exit" + i as string + "_Frame")
			RMT.Detach (id as integer) layer
		)

		for i = 0 to 7 do
		(
			id = ("30" + i as string)
			layer = ("Exit" + i as string + "_Hole")
			RMT.Detach (id as integer) layer
		)

		for i = 0 to 7 do
		(
			id = ("40" + i as string)
			layer = ("Exit" + i as string + "_Wall")
			RMT.Detach (id as integer) layer
		)
		
		RMT.DeleteEmptyObjects()
		--delete (for obj in Geometry where classof obj == Editable_Poly and polyop.getNumFaces obj == 0 collect obj)
		--AutoDoors()
	),
	
	fn splitOthers =
	(
		RMT.Detach 600 "Glass"
		RMT.Detach 700 "FireExtAlpha"
		
		RMT.sendtoLayerByName "Glass" "Main"
		RMT.sendtoLayerByName "FireExtAlpha" "Main"
	),

	fn splitLadders =
	(
		RMT.Detach 500 "Ladders"
		RMT.sendtoLayerByName "Ladders" "Ladders"
	),
	
	fn Backup =
	(
		local raw_mfn = maxfilename 
		local mfn = getfilenamefile maxfilename
		local fList, fCount, fVer, fOut, fFilter, a, ver
		
		fList = getfiles( RMT.working_path + mfn + "\\" + "*_Backup_*.max" )
		fCount = 0

			
		if fList.count == 0 then
		(
			fCount += 1
			fVer = formattedprint fCount format: ".3d"
			fOut = RMT.working_path + mfn + "\\" + mfn + "_Backup_" + fVer+ ".max"
			savemaxfile fOut usenewfile:false
			print ("Saved: " + fOut)
		)
		else
		(
			-- print fList
			a = #()
				
			for i=1 to fList.count do
			(
				fFilter = filterstring fList[i] "_"
				ver = substring fFilter[3] (fFilter[3].count-6) 3
				append a ver
			)
			
			sort a
			fCount = a[a.count] as integer
			
			fCount += 1
			fVer = formattedprint fCount format: ".3d"
			
			fOut = RMT.working_path + mfn + "\\" + mfn + "_Backup_" + fVer+ ".max"
			savemaxfile fOut usenewfile: false
			print ("Saved: " + fOut)
		)
	),
	
	fn SemiAutoSetup =
	(
		local importedFile, tokens, fileTitle
		
		importedFile = getOpenFileName "Import RocketEd dae" filename:"C:\\Projects\\Cow2\\Assets\\Screens\\" types: "OpenCollada(*.dae)|*.dae|"
		
		if importedFile != undefined then
		(
			tokens = filterString importedFile "\\"
			fileTitle = substring tokens[6] 1 (tokens[6].count-4) -- start from int 1 to tokenlength-4

			suspendEditing which:#modify
	
-- 			if (not (doesFileExist (RMT.working_path + fileTitle))) do
-- 			(
-- 				makeDir  (RMT.working_path + fileTitle)
-- 			)
			
			RMT.makeDirName(RMT.working_path + fileTitle)
				
			savemaxFile (RMT.working_path + fileTitle + "\\"+ fileTitle + ".max")
				
			importFile importedFile #noPrompt using:DAEIMP

			format " ** Imported File: % **\n" fileTitle

			--importerPlugin.classes
			--exporterPlugin.classes

			select $*
			RMT.ResetXFPoly()
			RMT.AutoDoors()
			RMT.assignDoorMatID()
			RMT.assignOthersMatID()
			RMT.SetupMats()
			$*.material = meditmaterials[1]
			RMT.createBouncer()
			RMT.sendtoLayer $Bouncer "Bouncer"
			clearSelection()

			--save file, 
			--set up materials
			
			for o in objects do
			(
				if matchpattern o.name pattern: "*Silhouette*" then
				(
					--o.material = sceneMaterials["Silhouette"]
					o.material = meditmaterials[9]
					RMT.sendtoLayerByName o.name "Silhouette"
					format "found: %" o.name
				)
				
			)

			for o in objects where (classof o.baseobject == Editable_Poly) do
			(
-- 				ChannelInfo.CopyChannel o 3 1
-- 				ChannelInfo.PasteChannel o 3 2	
				RMT.TransferUV o o 1 2
				collapseStack o
			)
			
			resumeEditing which:#modify
		)
	),
	
	fn BuildRun =
	(
		shellLaunch "C:\Projects\Cow2\Tools\buildandrun.bat" ""
		print("Building...")
	),
	
	fn CreateUI =
	(
		
		RMT.InitCallbacks()
		
		rf_MainFloater = newRolloutFloater "RocketMaxTools" 260 780
		rf_MainFloater.pos.x = (getINISetting RMT.settingsfile "General" "Window Pos X") as integer
		rf_MainFloater.pos.y = (getINISetting RMT.settingsfile "General" "Window Pos Y") as integer
		
		addRollout ro_Menu01 rf_MainFloater
		addRollout ro_Menu02 rf_MainFloater
		addRollout ro_Menu03 rf_MainFloater
		addRollout ro_Menu04 rf_MainFloater
		
		addRollout ro_animHelper rf_mainFloater
		addRollout ro_TransferUV rf_MainFloater
		addrollout ro_doorHelper rf_MainFloater
		addRollout ro_Rocketbirds rf_MainFloater

		
	),
	
	fn ExitUI =
	(
		--
		--setINISetting 
		try( setINISetting RMT.settingsfile "General" "Window Pos X" ((rf_MainFloater.pos.x as integer) as string) )catch();
		try( setINISetting RMT.settingsfile "General" "Window Pos Y" ((rf_MainFloater.pos.y as integer) as string) )catch();
		--
		
		
		RMT.DestroyCallbacks()
		
		if rf_MainFloater !=undefined then closeRolloutFloater rf_MainFloater
		if ro_doorHelper !=undefined then destroyDialog ro_doorHelper
		if ro_TransferUV !=undefined then destroyDialog ro_TransferUV
		if ro_doorHelper2 !=undefined then destroyDialog ro_doorHelper2
		if ro_animHelper !=undefined then destroyDialog ro_animHelper
			
		
		
	)


	) -- end RMT struct



----------------------------------------------------------- Start of MAIN ROLLOUTS BlOCK ---------------------------------------------
	( -- MAIN ROLLOUTS
	
		rollout ro_Menu01 "Layering Tools" width:256 height:144
		(
			local importList = #( "Chicken", "FX", "Grates", "Lines", "Abattoir Lines")
			
			button btn_lightLayers "Lights" pos:[8,8] width:50 height:21
			button btn_Black "Black" pos:[60,8] width:50 height:21 toolTip:"Black"
			button btn_fullBright "FB" pos:[108,8] width:50 height:21 toolTip:"Full Bright"
			button btn_silhouette "1ClickSemi" pos:[159,7] width:81 height:21
				
			button btn_blocker "Blocker" pos:[8,32] width:50 height:21
			button btn_fx "FX" pos:[60,32] width:50 height:21
			button btn_main "Main" pos:[112,32] width:50 height:21
			button btn_ladder "Ladders" pos:[164,32] width:50 height:21
			
			groupBox grp1 "" pos:[4,56] width:252 height:42
			button btn_bouncer "Bouncer" pos:[8,70] width:50 height:21
			colorPicker theColor "" pos:[58,70] width:44 height:20 color:[50,50,50]
			dropdownList ddl_import "" pos:[108,70] width:80 height:21 items:#("Chicken", "FX", "Grates", "Lines", "Abattoir Lines") across:2
			button btn_import "Import" pos:[190,70] width:45 height:21
			
			button btn_delEmptyLayers "Del Empty Layers" pos:[8,104] width:100 height:24 across:2
			button btn_delemptyobjects "Del Empty Objects" pos:[112,104] width:103 height:24 items:#("Chicken", "FX", "Grates", "Lines", "Abattoir Lines")

			on btn_lightLayers pressed do
				(RMT.sendtoLayer (select lights)  "Lights")
			on btn_Black pressed do
				(RMT.sendtoLayer selection "Black")
			on btn_fullBright pressed do
				(RMT.sendtoLayer selection "FullBright")
			on btn_silhouette pressed do
				( RMT.SemiAutoSetup() )
			on btn_blocker pressed do
				(RMT.sendtoLayer selection "Blocker")
			on btn_fx pressed do
				(RMT.sendtoLayer selection "FX")
			on btn_main pressed do
				(RMT.sendtoLayer selection "Main")
			on btn_ladder pressed do
				(RMT.sendtoLayer selection "Ladders")
			on btn_bouncer pressed do
				(RMT.CreateBouncer())
			on theColor changed new_col do
				(if sceneMaterials["bouncer"] != undefined then sceneMaterials["bouncer"].diffusecolor = new_col)
			on btn_import pressed do
			(
				case ddl_import.selected of
				(
					"Chicken": mergemaxfile (RMT.script_path + "\\RocketMaxTools\\Assets\\Chicken\\RiggedChicken.max") #select #useSceneMtlDups
					"FX": RMT.importFX()
					"Grates": mergemaxfile (RMT.script_path  + "\\RocketMaxTools\\Assets\\Grates\\Grates.max") #select #useSceneMtlDups
					"Lines": mergemaxfile (RMT.script_path  + "\\RocketMaxTools\\Assets\\Lines\\Lines.max") #select #useSceneMtlDups
					"Abattoir Lines": mergemaxfile (RMT.script_path  + "\\RocketMaxTools\\Assets\\Lines\\AbattoirLines.max") #select #useSceneMtlDups
			
				)
			)
			on btn_delEmptyLayers pressed do
			(
				if querybox "Do you want to delete all empty layers?" beep:true do
				RMT.DeleteEmptyLayers()
			)
			on btn_delemptyobjects pressed do
				(RMT.DeleteEmptyObjects())
		)
		--endRollout
		
		
	rollout ro_doorHelper "Door Helper" width:200
	(
		local w = 40
		
		group ""
		(
			button btn_selectsimilar "Select Similar" tooltip:"Select Similar elements"  width:100 height: 25 across:1
		)
		
		group "Exit_Breakable" (
		button btn_break "Breakables"  across:2 width:90 height: 25
		button btn_btoggle "Show/Hide" width:60 height: 25
		button btn_b0 "0" across:4 width:w
		button btn_b1 "1"  width:w
		button btn_b2 "2" width:w
		button btn_b3 "3" width:w
		button btn_b4 "4" across:4 width:w
		button btn_b5 "5"  width:w
		button btn_b6 "6" width: w
		button btn_b7 "7" width: w
		)
		
		group "Exit_Frame" (
		button btn_frame "Frames"  across:2 width:90 height: 25
		button btn_ftoggle "Show/Hide" width:60 height: 25
		button btn_f0 "0" across:4 width: w
		button btn_f1 "1"  width:w
		button btn_f2 "2"  width:w
		button btn_f3 "3" width:w
		button btn_f4 "4" across:4 width:w
		button btn_f5 "5" width:w
		button btn_f6 "6" width:w
		button btn_f7 "7" width:w
		)
		
		group "Exit_Hole" (
		button btn_hole "Holes"  across:2 width:90 height: 25
		button btn_htoggle "Show/Hide" width:60 height: 25
		button btn_h0 "0" across:4 width:w
		button btn_h1 "1" width:w
		button btn_h2 "2" width:w
		button btn_h3 "3" width:w
		button btn_h4 "4" across:4 width:w
		button btn_h5 "5" width:w
		button btn_h6 "6" width:w
		button btn_h7 "7" width:w
		)
		
		group "Exit_Wall" (
		button btn_wall "Walls"  across:2 width:90 height: 25
		button btn_wtoggle "Show/Hide" width:60 height: 25
		button btn_w0 "0" across:4 width:w
		button btn_w1 "1"  width:w
		button btn_w2 "2"  width:w
		button btn_w3 "3" width:w
		button btn_w4 "4" across:4 width:w
		button btn_w5 "5" width:w
		button btn_w6 "6" width:w
		button btn_w7 "7" width:w
		)
		
		fn bulkDoor targetname layername =
		(

			local prevobj
			if selection.count == 1 then
			(
				prevobj = $
				RMT.DetachFace thename:targetname 
				RMT.sendtoLayer ( select( getnodebyname(targetname) ) ) layername
				RMT.HideLayer layername
				select prevobj
			)
			else (messagebox "Select Something") 
		)
		
		fn splitDoor targetname layername =
		(
			if selection.count == 1 then
			(
				RMT.DetachFace thename:targetname
				RMT.sendtoLayer ( select( getnodebyname(targetname) ) ) layername
			)
			else (messagebox "Select Something") 
		)
		
		on btn_selectsimilar pressed do	( RMT.selectsimilar() ) --door helper
		
		on btn_break pressed do( bulkDoor "_Breakable" "Exit_Breakable" )
		on btn_frame pressed do( bulkDoor "_Frame" "Exit_Frame"  )
		on btn_hole pressed do( bulkDoor "_Hole" "Exit_Hole")
		on btn_wall pressed do( bulkDoor "_Wall" "Exit_Wall" )
		
			
		on btn_btoggle pressed do ( RMT.ToggleLayer "Exit_Breakable" )
		on btn_b0 pressed do ( splitDoor "Exit0_Breakable" "Exit_Breakable")
		on btn_b1 pressed do ( splitDoor "Exit1_Breakable" "Exit_Breakable")
		on btn_b2 pressed do ( splitDoor "Exit2_Breakable" "Exit_Breakable")
		on btn_b3 pressed do ( splitDoor "Exit3_Breakable" "Exit_Breakable")
		on btn_b4 pressed do ( splitDoor "Exit4_Breakable" "Exit_Breakable")
		on btn_b5 pressed do ( splitDoor "Exit5_Breakable" "Exit_Breakable")
		on btn_b6 pressed do ( splitDoor "Exit6_Breakable" "Exit_Breakable")
		on btn_b7 pressed do ( splitDoor "Exit7_Breakable" "Exit_Breakable")
			
		on btn_ftoggle pressed do ( RMT.ToggleLayer "Exit_Frame" )
		on btn_f0 pressed do ( splitDoor "Exit0_Frame" "Exit_Frame")
		on btn_f1 pressed do ( splitDoor "Exit1_Frame" "Exit_Frame")
		on btn_f2 pressed do ( splitDoor "Exit2_Frame" "Exit_Frame")
		on btn_f3 pressed do ( splitDoor "Exit3_Frame" "Exit_Frame")
		on btn_f4 pressed do ( splitDoor "Exit4_Frame" "Exit_Frame")
		on btn_f5 pressed do ( splitDoor "Exit5_Frame" "Exit_Frame")
		on btn_f6 pressed do ( splitDoor "Exit6_Frame" "Exit_Frame")
		on btn_f7 pressed do ( splitDoor "Exit7_Frame" "Exit_Frame")
		
		on btn_htoggle pressed do ( RMT.ToggleLayer "Exit_Hole" )
		on btn_h0 pressed do ( splitDoor "Exit0_Hole" "Exit_Hole")
		on btn_h1 pressed do ( splitDoor "Exit1_Hole" "Exit_Hole")
		on btn_h2 pressed do ( splitDoor "Exit2_Hole" "Exit_Hole")
		on btn_h3 pressed do ( splitDoor "Exit3_Hole" "Exit_Hole")
		on btn_h4 pressed do ( splitDoor "Exit4_Hole" "Exit_Hole")
		on btn_h5 pressed do ( splitDoor "Exit5_Hole" "Exit_Hole")
		on btn_h6 pressed do ( splitDoor "Exit6_Hole" "Exit_Hole")
		on btn_h7 pressed do ( splitDoor "Exit7_Hole" "Exit_Hole")
		
		on btn_wtoggle pressed do ( RMT.ToggleLayer "Exit_Wall" )
		on btn_w0 pressed do ( splitDoor "Exit0_Wall" "Exit_Wall")
		on btn_w1 pressed do ( splitDoor "Exit1_Wall" "Exit_Wall")
		on btn_w2 pressed do ( splitDoor "Exit2_Wall" "Exit_Wall")
		on btn_w3 pressed do ( splitDoor "Exit3_Wall" "Exit_Wall")
		on btn_w4 pressed do ( splitDoor "Exit4_Wall" "Exit_Wall")
		on btn_w5 pressed do ( splitDoor "Exit5_Wall" "Exit_Wall")
		on btn_w6 pressed do ( splitDoor "Exit6_Wall" "Exit_Wall")
		on btn_w7 pressed do ( splitDoor "Exit7_Wall" "Exit_Wall")
	) --end rollout
			
	rollout ro_TransferUV "Transfer UV"
	(
		
		local ePolyFilter
		local obj
		
		fn ePolyFilter obj = classof obj.baseObject == Editable_Poly

		pickbutton btn_source "Source" width:140 filter:ePolyFilter
		spinner spn_sourcechn "uv chn: " range:[1,4,1] type:#integer scale:1
		
		pickbutton btn_target "Target" width:140 filter:ePolyFilter
		spinner spn_targetchn "uv chn: " range:[1,4,1] type:#integer scale:1
		
		button btn_Transfer "Transfer!" tooltip: "Transfer UVW Channel 1 only."
		
		--remove this soon
		fn TransferUV = 
		(
		ChannelInfo.CopyChannel btn_source.object  3 spn_sourcechn.value
		--modPanel.setCurrentObject target.baseObject ui:false
	-- 	modPanel.setCurrentObject target.baseobject
		ChannelInfo.PasteChannel btn_target.object 3 spn_targetchn.value
	-- 	modPanel.setCurrentObject target.modifiers[#UVW_Mapping_Paste]
		--maxOps.CollapseNodeTo target 2 off
		)

	-- 	modPanel.setCurrentObject $Terminator002.modifiers[#UVW_Mapping_Paste]
	-- deleteModifier $Terminator002 1
	-- maxOps.CollapseNodeTo $Terminator002 2 off

		--If the user picked an object, then
		on btn_source picked obj do
		(
			if obj != undefined do
			(
				btn_source.text = "Source: " + obj.name
			)
			
		)--end on
		
		on btn_target picked obj do
		(
			if obj != undefined do
			(
				btn_target.text =  "Target: " + obj.name
			)
		)--end on
		
		on btn_Transfer pressed do
		(
-- 			TransferUV()
			RMT.TransferUV btn_source.object btn_target.object spn_sourcechn.value spn_targetchn.value
		)
	)--end rollout
		
		
	Rollout ro_doorHelper2 "Detachables Helper" 
	(
		group ""(
		button btn_markDoorsAndOthers "1.Assign Door & Others ids"
		button btn_markLadders "2.Select and mark Ladders"
		)
		
		group ""(
		button btn_bulkDoorDetach "3.Detach Bulk Doors"
		button btn_singleDoorDetach "4.Split Bulk Doors"
		
		button btn_splitOthers "5.Detach Others" tooltip: "Split Glass, FireExtAlpha.."
		button btn_splitLadders "6.Detach Ladders"
		)
		
		on btn_markDoorsAndOthers pressed do
		(
			for obj in selection do
			(
				if sceneMaterials["Main"] != undefined do obj.material = sceneMaterials["Main"]
			)
			RMT.assignDoorMatID()
			RMT.assignOthersMatID() 
		)
		on btn_markLadders pressed do ( RMT.markLadders() )
		on btn_bulkDoorDetach pressed do ( RMT.BulkDoorDetach() )
		on btn_singleDoorDetach pressed do ( RMT.splitDetachables() )
		
		on btn_splitOthers pressed do ( RMT.splitOthers() )
		on btn_splitLadders pressed do ( RMT.splitLadders() )
	) --end rollout
		
	rollout ro_animHelper "Anim Helper" width:232 height:488
	(
		local originalEndRange = animationrange.end
		local pc

		groupBox grp1 "Add Path:" pos:[8,8] width:216 height:264
		button btn_assignPC "Assign Path Constraint" pos:[16,32] width:200 height:24
		button btn_delPC "Remove Path Constraint" pos:[16,64] width:200 height:24
		listBox path_list "Select Path to follow:" pos:[16,104] width:200 height:8 items: (for o in objects where superclassof o == shape collect o.name)
		button btn_assignPath "Add Path" pos:[16,240] width:56 height:24
		button btn_deletePath "Delete Path" pos:[80,240] width:64 height:24
		button btn_refresh "Refresh" pos:[152,240] width:64 height:24
		
		groupBox grp2 "Bake It:" pos:[8,280] width:216 height:88
		button btn_BakeKeys "Bake Keys" pos:[144,296] width:72 height:40
		spinner spn_step "Step:" pos:[48,304] width:80 height:16 range:[0,9999,25] type:#integer scale:1
		
		groupBox grp3 "Duplicate" pos:[8,376] width:216 height:56
		spinner spn_copies "Copies" pos:[30,400] width:64 height:16 range:[0,9999,1] type:#integer scale:1
		button btn_offSet "Offset Animation!" pos:[96,392] width:120 height:32
		button btn_reset "UNDO" pos:[8,440] width:80 height:32
		button btn_deleteKeys "Delete All Keys" pos:[96,440] width:128 height:32
		editText edt_fend "End Frame:" pos:[16,344] width:112 height:16 text: "500" 
		button btn_go "Set" pos:[144,344] width:72 height:20
		
		--functions
		
		on btn_assignPC pressed do
		(
			pc = Path_Constraint()
			if selection.count > 0 do
			(
			$.position.controller = pc
			)
			max motion mode
		)
		
		on btn_delPC pressed do
		(
			
			for o in selection do
			(
				o.pos.controller = Position_XYZ ()
			)			
		)
		
		on btn_assignPath pressed do
		(
			if  getnodebyname (path_list.selected) !=undefined then
			(
				pc.path = getnodebyname (path_list.selected)
			)
			else (messageBox "Path not found. Please refresh")
		)
		
		on btn_deletePath pressed do
		(
			pc.deleteTarget 1
		)
		
		on btn_refresh pressed do
		(
			for i = path_list.items.count to 1 by -1 do
			(
				path_list.items = deleteItem path_list.items i
			)
			
			a = for o in objects where superclassof o == shape collect o.name
			path_list.items = (for o in objects where superclassof o == shape collect o.name)
		)
		
		on btn_BakeKeys pressed do
		(
			undo on 
			(
				
			local TempPoint = point()
			local step = spn_step.value
				
			for i=animationrange.start to i=animationrange.end by step do
				(
					with animate on 
					at time i
					TempPoint.transform = $.Transform
				)
				$.Transform.Controller = TempPoint.Transform.Controller
				delete TempPoint	
			)
		)
		
		on btn_go pressed do
		(
			animationrange = interval 0 (edt_fend.text as integer)
			local originalEndRange = (edt_fend.text as integer)
		)

		
		fn createCopies =
		(
			local fstart = animationrange.start
			local fend = animationrange.end
			local originalEndRange = fend
			local copies = spn_copies.value
			
			max motion mode
			suspendEditing which:#motion
			
			undo "copyanim" on
			(
				for i = 1 to copies-1 do
				(
					
					maxOps.cloneNodes selection cloneType:#copy newNodes:&objs
					select objs
					for i = 1 to objs.count do
					(
						local selkeys = selectKeys objs[i].controller
						moveKeys objs[i].controller -(fend/copies) #selection
						--objs[i].controller.keys.time -= (fend/copies) 
						--deselectKeys nnl[i].controller
					)
					
				)
				animationRange = interval 0 (fend/copies)
			) --end undo
			
			resumeEditing which:#motion
		) --end fn block
		


		on spn_copies.value changed do (copies = spn_copies.value)
		
		on btn_offSet pressed do (createCopies())
		
		on btn_reset pressed do
		( 
		
			max motion mode
			suspendEditing which:#motion
			max undo
			animationRange = interval 0 (originalEndRange)
			resumeEditing which:#motion
		)
		
		on btn_deleteKeys pressed do
		(
			undo on
			(
			sliderTime = 0f
			local userSel = getCurrentSelection ()
			deleteKeys userSel #allKeys
			)
		)
		
	)
--end rollout
		
	rollout ro_Menu02 "Geometry Tools"
	(
		--button btn_mirrorflip "Mirror and Flip Normals" width: buttonWidth
		button btn_xform "Reset XForms" pos:[8,8] width:100 tooltip: "Convert to Editable Poly and Resets XForm" across:2
		button btn_weldVertices "Weld Vertices" pos:[108,8] width:100 tooltip: "Weld ALL vertices of selected objects at 0.001" align:#right
		button btn_centerPivot "Center Pivot"  pos:[8,30] width: 100 tooltip: "Set pivot to center, selected vertex or edge" across:2
		button btn_oneobject "One Object" pos:[108,30] width: 100 tooltip: "Attach all objects in selection" 
		button btn_normalfix "FIX" pos:[208,8] width:38 height: 43
		
		on btn_xform pressed do ( RMT.ResetXFPoly() )
		on btn_weldVertices pressed do ( RMT.WeldVertices() )
		on btn_centerPivot pressed do ( RMT.CenPivot(); if keyboard.controlPressed do RMT.centerPivotWorld() )
		on btn_oneobject pressed do( RMT.OneObject() )
		on btn_normalfix pressed do ( RMT.EditNormalFix() )
		
		group "Door Helper" (
		button btn_selectsimilar "Select Similar" tooltip:"Select Similar elements" pos:[8,80] width:80 
		button btn_detachFaces "Quick Detach" tooltip:"Detach selected faces as object" pos:[88,80] width:80
		button btn_autoDoors "Auto Doors"  pos:[8,102] width: 80
		button btn_doorHelper "Door Helper" tooltip:"Launch door helper tool"  pos:[88,102]  width: 80
		button btn_doorHelper2 "DoorHelperV2" pos:[168,80] width:70 height: 43 
		)
		
		on btn_selectsimilar pressed do	( RMT.selectsimilar() )
		on btn_detachFaces pressed do ( RMT.DetachFace() )
		on btn_autoDoors pressed do ( RMT.AutoDoors() )
		on btn_doorHelper pressed do ( try(destroyDialog ro_doorHelper)catch(); createDialog ro_doorHelper)
		on btn_doorHelper2 pressed do ( try(destroyDialog ro_doorHelper2)catch(); createDialog ro_doorHelper2)
		
		group "Anim Helper"(
		button btn_animHelper "Animation Helper" pos:[8,150] 
		)
		on btn_animHelper pressed do ( try(destroyDialog ro_animHelper) catch(); createDialog ro_animHelper width:232 height:488)

	)	--endrollout
	
	rollout ro_Menu03 "Bake Tools"
	(
		group "Materials"(
			button btn_SetupMats "SetupMats" across:3 tooltip: "Create common Max materials and fx materials"
			button btn_CleanMats "CleanMats" tooltip: "Select nothing to clean all, otherwise clean selected objects"
			button btn_setupFG "SetupFG" tooltip: "Load preset FG settings"
		)

		group "Lights"(
			button btn_MRSP "MRSkyPortal" across:2
			button btn_MROM "MROmni"
		)
		
		group "UVs"(
			button btn_ApplyUV2 "UV2" tooltip: "Applies a chn 2 uv and collapse the stack" across:2
			button btn_QPUV2 "QPlanar" tooltip: "Planar map selected. Apply this for the \n \"big flat walls\". " 
			button btn_UVPacker "UV-Packer" tooltip: "Apply UV-Packer modifier to UV2 with presets and PACK."  across:2
			button btn_TransferUV "TransferUV" tooltip: "TransferUV"
		)
		
		group "Bake"(
			button btn_bakeSelected "Bake Mains" tooltip:"Bake Selected Objects with presets to correct folders" across:3
			dropDownList ddl_bakeSize "" width:50 items:#("128","256", "512", "1024", "2048") selection:5
			checkbox chkbox_NR "Net Render" checked:false tooltip:"Enable Distributed Rendering."
		)
		

		on btn_bakeSelected pressed do( RMT.BakeObject $ (ddl_bakeSize.selected as integer))
		on chkbox_NR changed theState do ( RMT.mrRender.DistributedEnable = theState; format "Net Render %\n" theState )
		on btn_setupFG pressed do ( RMT.SetupMR() )
		on btn_SetupMats pressed do ( RMT.SetupMats() )
		on btn_CleanMats pressed do ( RMT.CleanMats() )
		on btn_MRSP pressed do ( RMT.createMRSkyPortal() )
		on btn_MROM pressed do ( RMT.createMROmni() )
		on btn_ApplyUV2 pressed do ( RMT.ApplyUV2() )	
		on btn_QPUV2 pressed do( RMT.QuickPlanarUV2() )
		on btn_UVPacker pressed do ( RMT.UVPack() )
		on btn_TransferUV pressed do ( try(destroyDialog ro_TransferUV) catch(); createDialog ro_TransferUV)
	) --end rollout
	
	
	
	rollout ro_Menu04 "File Tools" width:256 height:72
	(
		edittext et_projName "Filename:" pos:[8,8] width:112 height:20 fieldwidth:60 text:"L99-S99" across:3
		button btn_createProj "Create" pos:[130,7] width:47 height:24 toolTip:"Makes project folder and saves file"
		button btn_backup "Backup" pos:[184,8] width:56 height:24 toolip:"Backup a file in working folder"
		button btn_save2copies "Save 2 Copies" pos:[8,40] width:85 height:21 toolTip:"Save current and another copy in Screens" across:3
		button btn_exportDAE "Export DAE" pos:[96,40] width:70 height:21 toolTip:"Export selected as DAE" 
 
 
		button btn_buildandrun "Build & Run" pos:[168,40] width:70 height:21 toolTip:"Build then Press any key to run"

		on btn_createProj pressed do
		(
			makeDir (working_path + et_projName.text )
			savemaxFile (working_path + et_projName.text + "\\" + et_projName.text + ".max")
		)
		on btn_backup pressed do
			( RMT.Backup() )
		on btn_save2copies pressed do
			( RMT.saveCurrentFinal() )
		on btn_exportDAE pressed do
			( RMT.exportSelectedDAE() )
		on btn_buildandrun pressed do
			( RMT.BuildRun() )
	)
	--endrollout
	
	rollout ro_Rocketbirds "Rocketbirds" rolledup:true
	(
		local imglogo = GetDir #userScripts + "\\RocketMaxTools\\rb.bmp"
		button btn_logo "" tooltip:"Open Working Folder"align:#center width:256 height:128 images:#(imglogo,undefined,1,1,1,1,1) enabled:true
		
		on btn_logo pressed do (shellLaunch "explorer.exe" RMT.working_path)
			
	) --endrollout


	) ----------------------------------------------------------- End of MAIN ROLLOUTS BlOCK ---------------------------------------------
	
	--instace of struct
	RMT = _RMT_()  
	RMT.ExitUI()
	RMT.CreateUI()
	RMT.InitVariables()



	
-- 	if MainFloater !=undefined then closeRolloutFloater MainFloater
	
) -- End of tool scope

