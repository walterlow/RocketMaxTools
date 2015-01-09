(
-- 	macroScript RendererSwitcher category:"RocketBirds"
-- 	tooltip:"RendererSwitcher"
-- 	(
-- 		::fileIn(GetDir #userScripts + "\RendererSwitcher.ms")
-- 	)
	
	global ro_BakeTool
	try (destroyDialog ro_BakeTool)catch()

	rollout ro_BakeTool "Bake Props Tool 0.1" width:232 height:232
	(

		local fullpath = ( getFileNamePath (maxFilePath+maxFileName) + getFilenamefile(maxFilePath+maxFileName) )
		local render_path =  fullpath + "\\" + "baked\\"
		local textureSizes = #("128", "256", "512", "1024", "2048")
		
		
		checkButton ckb_Diffuse "Diffuse" pos:[8,64] width:78 height:28	
		checkButton ckb_Normal "Normal" pos:[88,64] width:78 height:28
		checkButton ckb_AO "AO" pos:[168,64] width:48 height:28
		
		button btn_Bake "Bake It!" pos:[88,112] width:56 height:40
		button btn_OpenOutput "Open Output" pos:[152,112] width:80 height:40
		
		dropDownList ddl_textureSizes "Texture Size:" pos:[8,104] width:80 height:40 items: textureSizes selection: 3
		editText edt_Output "" pos:[8,24] width:168 height:24
		label lbl_Output "Set Output Folder: " pos:[8,8] width:136 height:16
		button btn_setFolder "Set" pos:[184,24] width:40 height:24
		
		
		fn GetMods obj ModType =
		(
			return (for m in obj.modifiers where classof m == ModType collect m)
		)
			
		fn GetProj obj =
		(
			Projs = GetMods obj Projection
			if Projs.count == 0 then return undefined
			return Projs[1]
		)

		fn BakeProps obj texsize =
		(
				local bp, bpp, df, ao, nm, mr
				
				if (classof obj.baseobject == Editable_Poly and selection.count == 1 ) then
				(
	
					if (not (doesfileExist render_path) ) then ( MAKEDir render_path) else ( format "\n % dirName exists!" render_path )

					bp = obj.INodeBakeProperties
					bp.removeAllBakeElements()
					bp.bakeEnabled = true
					bp.bakeChannel = 1
					bp.nDilations = 2
					
					proj = GetProj obj
					bpp = obj.INodeBakeProjProperties
					bpp.enabled = true
					bpp.UseCage = true
					bpp.projectionMod = proj
					bpp.hitMatchMtlID = false
					
					--Diffuse
					df = DiffuseMap()
					df.outputSzX = df.outputSzY = texsize
					df.fileType = render_path + obj.name + "_DiffuseMask" + ".png"
					df.fileName = render_path + obj.name + "_DiffuseMask" + ".png"
					
					--Normals
					nm = NormalsMap()
					nm.outputSzX = nm.outputSzY = texsize
					nm.fileType = render_path + obj.name + "_Normals" + ".png"
					nm.fileName = render_path + obj.name + "_Normals" + ".png"
			
					--AOmap
					ao = Ambient_Occlusion()
					ao.outputSzX = ao.outputSzY = texsize
					ao.fileType = render_path + obj.name + "_AO" + ".png"
					ao.fileName = render_path + obj.name + "_AO" + ".png"
					
					ao.samples = 16
					ao.spread = 1.5
					ao.maxDistance = 0.3
					ao.falloff = 1
					
					----------------------
					-- AO PASS -- (Mental ray)
					bp.removeAllBakeElements()
					if ckb_AO.checked then bp.addBakeElement ao
						

					mr = renderers.current = mental_ray_renderer()
					mr.FinalGatherEnable2 = false
					mr.MinimumSamples = 0
					mr.MaximumSamples = 2

					------------------------
									
					------------------------
					-- DIFFUSE AND NORMAL PASS -- (Scanline)
					bp.removeAllBakeElements()	
					if ckb_Diffuse.checked then bp.addBakeElement df
					if ckb_Normal.checked then bp.addBakeElement nm
					
					sl = renderers.current = Default_Scanline_Renderer()
					sl.antiAliasFilter = Catmull_Rom()
					sl.globalSamplerEnabled = true
					sl.globalSamplerSampleMaps = true
					sl.globalSamplerClassByName = "Hammersley"
					sl.globalSamplerQuality = 1.0
					
					if (bp.numBakeElements() != 0 ) then
					(
						render renderType:#bakeSelected frame:#current vfb:true progressBar:true outputwidth:texsize outputheight:texsize
					) else
					(
						Messagebox ("Select maps to bake!")
						return false
					)
					---------------------------
			
			)
			else( MessageBox("Select Something!") )
		)
		

		
		
		on ro_BakeTool open do
		(
			edt_Output.text = render_path
			ckb_Diffuse.checked = true
			ckb_Normal.checked = true
			ckb_AO.checked = true
		)
		
		on btn_Bake pressed do
		(
			BakeProps $ (ddl_textureSizes.selected as integer)
			
			--check ckb btns
			/*
			if chked.state 
				add element
			
			if chked.state 
				add element
			
			if chked.state 
				add element
			
			
			*/
		)
		
		on btn_OpenOutput pressed do
		(
			shellLaunch "explorer.exe" edt_Output.text
		)
	)

)

createDialog ro_BakeTool


