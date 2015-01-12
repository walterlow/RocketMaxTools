macroScript BakeTool category:"RocketBirds"
tooltip:"Bake Props Tool"
(
	::fileIn(GetDir #userScripts + "\RocketMaxTools" + "\BakeTool.ms")
)

(
	
	
	global ro_BakeTool
	try (destroyDialog ro_BakeTool)catch()

	rollout ro_BakeTool "RocketBakeTool 0.1" width:400 height:332
	(
		
		local fullpath
		local render_path
		local inipath = getdir #userscripts + "\\RocketMaxTools\\"
		local iniFile = inipath + "BakeTools.ini"
		
		
		local LP = #()
		
		checkbutton ckb_Diffuse "Diffuse" pos:[8,143] width:78 height:28	
	
		checkbutton ckb_Normal "Normal" pos:[88,143] width:78 height:28
		checkbutton ckb_AO "AO" pos:[168,143] width:56 height:28
		checkbutton ckb_UVW "UVW" pos:[8,176] width:78 height:28
		
		
		button btn_Bake "Bake It!" pos:[80,220] width:60 height:40
		button btn_OpenOutput "Open Output" pos:[144,220] width:80 height:40
		
		dropdownList ddl_textureSizes "Texture Size:" pos:[4,212] width:64 height:40 items:#("128", "256", "512", "1024", "2048")
		edittext edt_Output "" pos:[4,103] width:176 height:24
		label lbl_Output "Output Folder: " pos:[8,87] width:136 height:16
		button btn_setFolder "Set" pos:[188,103] width:40 height:24
		
		checkbox chk_showvfb "Show VFB" pos:[4,272] width:88 height:22
		checkbox chk_autoclosevfb "Auto close VFB" pos:[96,272] width:92 height:22
		
		label lbl1 "OPTIONAL: " pos:[12,4] width:60 height:16
		button btn_SetLowPoly "Mark/Select LP" pos:[4,23] width:76 height:24 toolTip:"Marking a LP is OPTIONAL but can be useful if you wanna continue working on your HP \n\nYou can bake the LP without selecting it afterwards."
		label lbl_LowPoly "   " pos:[84,23] width:144 height:52 style_sunkenedge:true
		button btn_clear "Clear" pos:[4,51] width:76 height:24
		
 		--label lbl_author "Author: walterlow88@gmail.com --" pos:[8,272] width:162 height:32

		fn InitCallbacks =
		(
			-- refresh UI if scene changed (load, reset, new, nodes renamed, deleted)
			callbacks.addScript #systemPostNew "ro_BakeTool.callback_SceneChanged()" id:#callback_RefreshUI
			callbacks.addScript #systemPostReset "ro_BakeTool.callback_SceneChanged()" id:#callback_RefreshUI
			callbacks.addScript #filePostOpen "ro_BakeTool.callback_SceneChanged()" id:#callback_RefreshUI

		)
		
		fn DestroyCallbacks=
		(
			callbacks.removeScripts id:#callback_RefreshUI
		)
		
		fn callback_SceneChanged =
		(
			ro_BakeTool.DestroyCallbacks()
			ro_BakeTool.InitCallbacks()
			
			ro_BakeTool.edt_Output.text = ro_BakeTool.GetRenderPath()
			ro_BakeTool.LP = #()
			ro_BakeTool.lbl_lowPoly.caption = "  "
		)
		
		fn GetRenderPath =
		(
			local fullpath
			local render_path
			
			if (  getFileNamePath (maxFilePath+maxFileName) == "" ) then
			(
				fullpath = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\"
			)
			else
			(
				fullpath = getFileNamePath (maxFilePath+maxFileName)
			)
				
			render_path =  fullpath + "baked\\"
			return render_path
		)
		
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
		
		fn filter_LP obj =
		(
			superclassof obj == GeometryClass
		)
		
		
		fn GetUVW obj =
		(
			UVW = GetMods obj Unwrap_UVW
			if UVW.count == 0 then return undefined
			return UVW[1]
		)
		
		fn RenderUVW obj =
		(

		)

		fn BakeProps obj texsize =
		(
			local bp, bpp, df, ao, nm, mr, vfb, uvs, uvmod, tempLP
			-- re-set path if user changes output dir
			render_path = edt_Output.text
			
			if (selection.count == 1 OR LP.count == 1) then
			(
				if (classof obj.baseobject == Editable_Poly or classof $.baseobject == Editable_Poly or classof LP[1].baseobject == Editable_Poly) then
				(
					if (not (doesfileExist render_path) ) then ( MAKEDir render_path)

					bp = obj.INodeBakeProperties
					bp.removeAllBakeElements()
					bp.bakeEnabled = true
					bp.bakeChannel = 1
					bp.nDilations = 2
					
					proj = GetProj obj
					
					if proj != undefined then proj.setGeomSelNodesVisibility true
					
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
					
					ao.samples = 256
					ao.spread = 1.5
					ao.maxDistance = 0.3
					ao.falloff = 1
					
					----------------------
					-- AO PASS -- (Mental ray)
					--bp.removeAllBakeElements()
					
					if ckb_AO.checked then
					(
						bp.removeAllBakeElements()
						bp.addBakeElement ao
						
						mr = renderers.current = mental_ray_renderer()
						mr.FinalGatherEnable2 = false
						mr.MinimumSamples = 0
						mr.MaximumSamples = 2
						
						obj.visibility = 0.0
						vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsize outputheight:texsize
						obj.visibility = 1.0
						if ro_BakeTool.chk_autoclosevfb.state then close vfb	
					)
	

					
-- 					if (bp.findByName "Ambient Occlusion (MR)" != 0 ) then
-- 					(
-- 						obj.visibility = 0.0
-- 						vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsize outputheight:texsize
-- 						obj.visibility = 1.0
-- 						if ro_BakeTool.chk_autoclosevfb.state then close vfb			
-- 					)
				
					
					mr = Default_Scanline_Renderer()
					mr.antiAliasFilter = Catmull_Rom()
					mr.globalSamplerEnabled = true
					mr.globalSamplerSampleMaps = true
					mr.globalSamplerClassByName = "Hammersley"
					mr.globalSamplerQuality = 1.0
					
					-- DIFFUSE AND NORMAL PASS -- (Scanline)
					
					if ckb_Diffuse.checked then
					(
						bp.removeAllBakeElements()
						bp.addBakeElement df
						bp.nDilations = 0
						vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsize outputheight:texsize
						if ro_BakeTool.chk_autoclosevfb.state then close vfb
					)
							
					if ckb_Normal.checked then
					(
						bp.removeAllBakeElements()
						bp.addBakeElement nm
						bp.nDilations = 2
						vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsize outputheight:texsize
						if ro_BakeTool.chk_autoclosevfb.state then close vfb
					)
					
-- 					if (bp.numBakeElements() != 0 ) then
-- 					(
-- 						vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsize outputheight:texsize
-- 						if ro_BakeTool.chk_autoclosevfb.state then close vfb
-- 					) 
					
					if ckb_UVW.checked then
					(
						max modify mode
						tempLP = copy obj
						select tempLP
						
						uvmod = Unwrap_UVW()
						addmodifier tempLP uvmod
			
						uvmod.renderuv_width = texsize
						uvmod.renderuv_height = texsize
						
						uvmod.renderuv_showframebuffer = false
						uvmod.renderuv_showoverlap = false
						
						uvmod.renderuv_seamColor = green
						uvmod.renderuv_edgeColor = white
						uvmod.renderuv_fillColor = white
						
						uvmod.renderuv_fillmode = 0
						uvmod.renderuv_visibleedges = true
				
						uvmod.renderUV (render_path + obj.name + "_UV" + ".png")
 						delete tempLP
						select obj
					)
					
	
				)
			)
			else( MessageBox("Select Something!") )
		) --end fn


-------------------------------------------------
		on ro_BakeTool open do
		(
			InitCallBacks()
			
			--Init 
			if not doesFileExist iniFile then 
			(
				--create ini file
				setINISetting iniFile  "Elements" "Diffuse" "true" 
				setINISetting iniFile 	"Elements" "Normals" "true" 
				setINISetting iniFile  "Elements" "AO" "true" 
				setINISetting iniFile  "Elements" "UVW" "true" 
				
				setINISetting iniFile "Settings" "ShowVFB" "true"
				setINISetting iniFile "Settings" "AutoCloseVFB" "true"
				setINISetting iniFile "Settings" "TexSize" "3"
						
				setINISetting iniFile "Settings" "WinPosX" "0"
				setINISetting iniFile "Settings" "WinPosY" "0"
			)
				
		
			edt_Output.text = GetRenderPath()
				
			ckb_Diffuse.checked = (getINISetting iniFile "Elements" "Diffuse") as BooleanClass
			ckb_Normal.checked = (getINISetting iniFile "Elements" "Normals") as BooleanClass
			ckb_AO.checked = (getINISetting iniFile "Elements" "AO") as BooleanClass
			ckb_UVW.checked = (getINISetting iniFile "Elements" "UVW") as BooleanClass
			ddl_textureSizes.selection = (getINISetting iniFile "Settings" "TexSize") as integer
			chk_showvfb.checked = (getINISetting iniFile "Settings" "ShowVFB") as BooleanClass
			chk_autoclosevfb.checked = (getINISetting iniFile "Settings" "AutoCloseVFB") as BooleanClass
			
			SetDialogPos ro_BakeTool [ (getINISetting iniFile "Settings" "WinPosX") as float , (getINISetting iniFile "Settings" "WinPosY") as float]
			
		)
		on ro_BakeTool close do
		(
			
			DestroyCallbacks()
			
			setINISetting iniFile  "Elements" "Diffuse" (ckb_Diffuse.checked as String)
			setINISetting iniFile 	"Elements" "Normals" (ckb_Normal.checked as String)
			setINISetting iniFile  "Elements" "AO" (ckb_AO.checked as String)
			setINISetting iniFile  "Elements" "UVW" (ckb_UVW.checked as String)
			
			setINISetting iniFile "Settings" "TexSize" (ddl_textureSizes.selection as String)
			setINISetting iniFile "Settings" "ShowVFB" (chk_showvfb.checked as String)
			setINISetting iniFile "Settings" "AutoCloseVFB" (chk_autoclosevfb.checked as String)
			
			local pos = GetDialogPos ro_BakeTool
			
			setINISetting iniFile "Settings" "WinPosX" (pos[1] as String)
			setINISetting iniFile "Settings" "WinPosY" (pos[2] as String)
		
		)
		on btn_Bake pressed do
		(
			
			if LP.count == 1 then
			(
				clearSelection()
				select LP[1]
				unhide LP[1]
				BakeProps LP[1] (ddl_textureSizes.selected as integer)
			)
			
			if LP.count == 0 and selection.count == 0  then
			(	
				messageBox ("Error 1: Select something or check Projection Mod")
			)
			
			if LP.count == 0 and selection.count == 1  then
			(	
				if GetProj selection[1] != undefined then
				(
					--messageBox ("Bake selection[activeSelection]")	
					BakeProps selection[1] (ddl_textureSizes.selected as integer)
				)
				else ( messageBox ("Error 2: check Projection Mod") )
			)
						---=====================================================-----
			
			--todo: force override buggy.
		-- 			if LP.count == 1 and selection.count == 1 then
		-- 			(	
		-- 				if GetProj selection[1] != undefined then
		-- 				(
		-- 					messageBox ("Bake selection[activeSelection]: ")
		-- 					BakeProps selection[1] (ddl_textureSizes.selected as integer)
		-- 				)
		-- 				else
		-- 				(
		-- 					messageBox ("Error 3: Select something or check Projection Mod")
		-- 					
		-- 				)	
		-- 			)
			
			--if LP is marked and nothing is selected, then we select the marked LP
			if LP.count == 1 and selection.count == 0  then
			(	
				if GetProj LP[1] != undefined then
				(
					--messageBox ("Bake marker: ")
					select LP[1]
					unhide LP[1]
					BakeProps LP[1] (ddl_textureSizes.selected as integer)
				)
				else ( messageBox ("Error 4: Select something or check Projection Mod"); select LP[1] )
			)
			
		)
		on btn_OpenOutput pressed do
		(
			--print edt_Output.text
			shellLaunch "explorer.exe" edt_Output.text
		)
		on edt_Output changed txt do
		(
			if txt != "" then ( edt_Output.text = txt )
		)
		on btn_setFolder pressed do
		(
			savepath = getSavePath caption:"Select folder to save textures" initialDir: "C:\\Projects\\Cow2\\Assets\\"
			if savepath != undefined then edt_Output.text = savepath + "\\"
		)
		on btn_SetLowPoly pressed do
		(
			
			if selection.count == 1 then
			(
				LP = #()
				append LP selection[1]
				lbl_lowPoly.caption = LP[1].name
			)
			
			if LP.count !=0 then ( select(LP[1]) )
		)
		on btn_clear pressed do
		(
			LP = #()
			lbl_lowPoly.caption = "LP: "
		)
	)
	
createDialog ro_BakeTool
	
) --end script block




