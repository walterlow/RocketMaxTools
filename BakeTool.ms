/*******************************************************************************************************
-- Created: 		09-Jan-2015
-- Last Updated:	19-Sep-2015
-- Version:			0.24
--
-- Author :  Walter Low / walterlow88@gmail.com / walterlow.com
-- Version:  3ds max 2011
--
-- Description: Tool for easier baking of props.
-- Usage: RUN IT
--
-- Todo:
+	Removing the marking of low poly as its redundant.

-- Changelog:
0.24:
+	added option for matching material ids.
0.23:
+	Add custom padding option for diffuse mask.
0.22:
*	fixed script crash when cancelling a render.
0.21:
*	cancel all renders if an element was cancelled.
0.2: 
+	uv copying to clipboard.
+	added AO sample options.
+	added custom folder option.
*	changed method of marking low poly
0.1:
*	inital tool

*******************************************************************************************************/
(

	global ro_BakeTool
	
	try (destroyDialog ro_BakeTool)catch()

	rollout ro_BakeTool "RocketBakeTool 0.24" width:406 height:268
	(
		
		local fullpath
		local render_path
		local inipath = getdir #userscripts + "\\RocketMaxTools\\"
		local iniFile = inipath + "BakeTools.ini"
		local LP = #()
		local bCancelled = false
		local vfb

		checkbutton ckb_Diffuse "Diffuse" pos:[88,154] width:78 height:28	
		checkbutton ckb_Normal "Normal" pos:[168,154] width:78 height:28
		checkbutton ckb_AO "AO" pos:[248,154] width:56 height:28
		checkbutton ckb_UVW "UVW" pos:[4,154] width:78 height:28
		checkbox chk_uvclipboard "Copy UV to clipboard" pos:[4,184] width:84 height:28
		spinner spn_diffpadding "Padding" pos:[88,184] width:80 height:4 range:[0,64,0] type:#integer scale:1 fieldwidth:20 tooltip:"Padding for Diffuse only"
		checkBox chk_hitMatchID "Hit Match ID" pos:[175,184] 
		
		button btn_Bake "Bake It!" pos:[4,216] width:180 height:48
		button btn_OpenOutput "Open Output" pos:[188,216] width:100 height:48
		
		dropdownList ddl_textureSizes "Texture Size:" pos:[244,44] width:64 height:40 items:#("128", "256", "512", "1024", "2048")
		
		checkbox chk_fixratio "1:1" pos:[360,98] width:39 height:15
		checkbox chk_customsize "Custom" pos:[344,40] width:59 height:15
		spinner spn_xsize "Width:" pos:[330,60] width:70 height:16 range:[0,9999,1] type:#integer scale:1 fieldwidth:40
		spinner spn_ysize "Height:" pos:[330,80] width:70 height:16 range:[0,9999,1] type:#integer scale:1 fieldwidth:40
		
		edittext edt_Output "" pos:[0,113] width:352 height:17
		label lbl_Output "Output Folder: " pos:[8,97] width:136 height:16
		
		radiobuttons rdo_folder "" pos:[89,96] width:244 height:16 labels:#("Use default", "Use Custom Folder") default:1 columns:2
-- 		button btn_setFolder "Set" pos:[356,114] width:40 height:24
		
		checkbox chk_showvfb "Show VFB" pos:[244,2] width:88 height:22
		checkbox chk_autoclosevfb "Auto close VFB" pos:[244,22] width:92 height:22
		
		button btn_SelectLowPoly "Select LP" pos:[4,32] width:76 height:24
		label lbl_LowPoly "   " pos:[84,28] width:144 height:52 style_sunkenedge:true
		button btn_clear "Clear" pos:[4,60] width:76 height:24
		checkbox chk_rmblowpoly "Remember Low Poly" pos:[92,4] width:123 height:20
		
		button btn_markLP "Mark LP" pos:[4,4] width:76 height:24
		spinner spn_samples "Samples" pos:[330,156] width:70 height:16 range:[0,999,256] type:#integer scale:1 fieldwidth:40 
 
		spinner spn_spread "Spread" pos:[330,176] width:70 height:16 range:[0,999,1.5] fieldwidth:40
		spinner spn_maxdist "Max Dist" pos:[330,196] width:70 height:16 range:[0,999,0.3] fieldwidth:40
		
 		--label lbl_author "Author: walterlow88@gmail.com --" pos:[8,272] width:162 height:32
		
		
		-------------------------------------------------
		--Methods--
		-------------------------------------------------	

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
		
		fn RenderUVW obj texsizeX texsizeY render_path =
		(
			--rendering uv template requires the mod panel to be active.
			max modify mode
			
			local btmp = bitmap texsizeX texsizeY
			
			if obj != undefined then
			(
				--tempLP = copy obj
				--select tempLP
				
				uvmod = Unwrap_UVW()
				--addmodifier tempLP uvmod
				addmodifier obj uvmod
				
				uvmod.renderuv_width = texsizeX
				uvmod.renderuv_height = texsizeY
				
				uvmod.renderuv_showframebuffer = false
				uvmod.renderuv_showoverlap = false
				
				uvmod.renderuv_seamColor = green
				uvmod.renderuv_edgeColor = white
				--uvmod.renderuv_fillColor = white
				
				uvmod.renderuv_fillmode = 0
				uvmod.renderuv_visibleedges = true
				
				theFileName = (render_path + obj.name + "_UV" + ".png")--define a temp.file name 
				uvmod.renderUV theFileName
				
				if chk_uvclipboard.checked == true then
				(
					btmp = openBitMap theFileName;
					setclipboardBitmap btmp
					print ("UVs copied to clipboard")
					--deleteFile theFileName; --delete the temp. file
				)

				--delete tempLP
				deletemodifier obj uvmod
				select obj
			)
			
		)

		fn BakeProps obj texsizeX texsizeY render_path =
		(
			local bp, bpp, df, ao, nm, mr, vfb, uvs, uvmod, tempLP
			
			if (selection.count == 1 OR LP.count == 1) then
			(
				if (classof obj.baseobject == Editable_Poly or classof LP[1].baseobject == Editable_Poly) then
				(
					if (not (doesfileExist render_path) ) then ( MAKEDir render_path)
					
					proj = GetProj obj
					
					if proj != undefined then proj.setGeomSelNodesVisibility true
					
					bp = obj.INodeBakeProperties
					bp.removeAllBakeElements()
					bp.bakeEnabled = true
					bp.bakeChannel = 1
					bp.nDilations = 2
					
					bpp = obj.INodeBakeProjProperties
					bpp.enabled = true
					bpp.UseCage = true
					bpp.projectionMod = proj
					bpp.hitMatchMtlID = chk_hitMatchID.checked
					
					
					renderers.current = Default_Scanline_Renderer()
					renderers.current.antiAliasFilter = Catmull_Rom()
					renderers.current.globalSamplerEnabled = true
					renderers.current.globalSamplerSampleMaps = true
					renderers.current.globalSamplerClassByName = "Hammersley"
					renderers.current.globalSamplerQuality = 1.0
					
					obj.visibility = true

					-- DIFFUSE PASS -- (Scanline)	
					if ckb_Diffuse.checked then
					(
						print("Baking DiffuseMask Pass")

						bp.removeAllBakeElements()
						bp.nDilations = 0
						bp.nDilations = spn_diffpadding.value
						
						df = DiffuseMap()
						df.outputSzX = texsizeX
						df.outputSzY = texsizeY
						df.fileType = render_path + obj.name + "_DiffuseMask" + ".png"
						df.fileName = render_path + obj.name + "_DiffuseMask" + ".png"
						
						bp.addBakeElement df
						
						if (not bCancelled) do
						(
							vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsizeX outputheight:texsizeY cancelled: &bCancelled
							
						)
						
						if ro_BakeTool.chk_autoclosevfb.state then close vfb
					)
					
					-- NORMAL PASS -- (Scanline)
					if ckb_Normal.checked then
					(	
						print("Baking Normal Pass")
						
						bp.removeAllBakeElements()
						bp.nDilations = 2
						
						--Normals
						nm = NormalsMap()
						nm.outputSzX = texsizeX
						nm.outputSzY = texsizeY
						nm.fileType = render_path + obj.name + "_Normals" + ".png"
						nm.fileName = render_path + obj.name + "_Normals" + ".png"

						bp.addBakeElement nm

						if (not bCancelled) do
						(
							vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsizeX outputheight:texsizeY cancelled: &bCancelled
						)
						
						if ro_BakeTool.chk_autoclosevfb.state and vfb != undefined then close vfb
					)
					
					
					-- AO PASS -- (Mental ray)
					if ckb_AO.checked then
					(
						print("Baking AO Pass")
						
						renderers.current  = mental_ray_renderer()	
						renderers.current.FinalGatherEnable2 = false
						renderers.current.MinimumSamples = 0
						renderers.current.MaximumSamples = 2
						
						bp.removeAllBakeElements()
						bp.nDilations = 2
	
						ao = Ambient_Occlusion()	
						ao.outputSzX = texsizeX
						ao.outputSzY = texsizeY
						ao.fileType = render_path + obj.name + "_AO" + ".png"
						ao.fileName = render_path + obj.name + "_AO" + ".png"
						
						ao.samples = spn_samples.value
						ao.spread = spn_spread.value
						ao.maxDistance = spn_maxdist.value
						ao.falloff = 1
						
						bp.addBakeElement ao
										
						obj.visibility = off
						if (not bCancelled) do
						(
							vfb = render renderType:#bakeSelected frame:#current vfb:ro_BakeTool.chk_showvfb.state progressBar:true outputwidth:texsizeX outputheight:texsizeY cancelled: &bCancelled
							
						)
						
						if ro_BakeTool.chk_autoclosevfb.state then close vfb
							
						obj.visibility = on
							
						
					)
					
					bCancelled = false
				)
			)
			

			
			else( MessageBox("Select Something!") )
		) --end fn


-------------------------------------------------
		--UI EVENT HANDLERS--
-------------------------------------------------	
		
		on ro_BakeTool open do
		(
			InitCallBacks()
			
			--Init 
			if not doesFileExist iniFile then 
			(
				--create ini file
				makeDir inipath

				setINISetting iniFile  "Elements" "Diffuse" "true" 
				setINISetting iniFile 	"Elements" "Normals" "true" 
				setINISetting iniFile  "Elements" "AO" "true" 
				setINISetting iniFile  "Elements" "UVW" "true"
				
				setINISetting iniFile  "Settings" "UVClipboard" "true" 	
				setINISetting iniFile "Settings" "ShowVFB" "true"
				setINISetting iniFile "Settings" "AutoCloseVFB" "true"
				
				setINISetting iniFile "Settings" "TexSize" "3"
				setINISetting iniFile "Settings" "CustomSize" "false"
				setINISetting iniFile "Settings" "CustomSizeX" "1"
				setINISetting iniFile "Settings" "CustomSizeY" "1"
				setINISetting iniFile "Settings" "FixedRatio" "true"
						
				setINISetting iniFile "Settings" "WinPosX" "0"
				setINISetting iniFile "Settings" "WinPosY" "0"
			)
			else 
			(
				ckb_Diffuse.checked = (getINISetting iniFile "Elements" "Diffuse") as BooleanClass
				ckb_Normal.checked = (getINISetting iniFile "Elements" "Normals") as BooleanClass
				ckb_AO.checked = (getINISetting iniFile "Elements" "AO") as BooleanClass
				ckb_UVW.checked = (getINISetting iniFile "Elements" "UVW") as BooleanClass
				
				ddl_textureSizes.selection = (getINISetting iniFile "Settings" "TexSize") as integer
				chk_showvfb.checked = (getINISetting iniFile "Settings" "ShowVFB") as BooleanClass
				chk_autoclosevfb.checked = (getINISetting iniFile "Settings" "AutoCloseVFB") as BooleanClass
				chk_uvclipboard.checked = (getINISetting iniFile "Settings" "UVClipboard") as BooleanClass
				
				chk_customsize.checked = (getINISetting iniFile "Settings" "CustomSize") as BooleanClass
				spn_xsize.value = (getINISetting iniFile "Settings" "CustomSizeX") as integer
				spn_ysize.value = (getINISetting iniFile "Settings" "CustomSizeY") as integer
				
				chk_fixratio.checked = (getINISetting iniFile "Settings" "FixedRatio") as BooleanClass
				
				SetDialogPos ro_BakeTool [ (getINISetting iniFile "Settings" "WinPosX") as float , (getINISetting iniFile "Settings" "WinPosY") as float]
			)
				
			if (hasINISetting iniFile "Settings" "CustomFolder") then
			(
				rdo_folder.state = 2
				edt_Output.text = (getINISetting iniFile "Settings" "CustomFolder") 
			)
			else
			(
				rdo_folder.state = 1
				edt_Output.text = GetRenderPath()
			)
						

			
		)
		on ro_BakeTool close do
		(
			
			DestroyCallbacks()
			
			setINISetting iniFile  "Elements" "Diffuse" (ckb_Diffuse.checked as String)
			setINISetting iniFile  "Elements" "Normals" (ckb_Normal.checked as String)
			setINISetting iniFile  "Elements" "AO" (ckb_AO.checked as String)
			setINISetting iniFile  "Elements" "UVW" (ckb_UVW.checked as String)
			setINISetting iniFile  "Settings" "UVClipboard" (chk_uvclipboard.checked as String)
			
			setINISetting iniFile "Settings" "TexSize" (ddl_textureSizes.selection as String)
			setINISetting iniFile "Settings" "CustomSize" (chk_customsize.checked as String)
			setINISetting iniFile "Settings" "CustomSizeX" (spn_xsize.value as String)
			setINISetting iniFile "Settings" "CustomSizeY" (spn_ysize.value as String)
					
			setINISetting iniFile "Settings" "FixedRatio" (chk_fixratio.checked as String)
			
			setINISetting iniFile "Settings" "ShowVFB" (chk_showvfb.checked as String)
			setINISetting iniFile "Settings" "AutoCloseVFB" (chk_autoclosevfb.checked as String)
			
			
			--store custom folder
			if (rdo_folder.state == 2) then
			(
				setINISetting iniFile "Settings" "CustomFolder" edt_Output.text
			)
			
			local pos = GetDialogPos ro_BakeTool
			
			setINISetting iniFile "Settings" "WinPosX" (pos[1] as String)
			setINISetting iniFile "Settings" "WinPosY" (pos[2] as String)
		
		)
		on btn_Bake pressed do
		(
			--------------------------------------------
			-------- bake elements methods----------
			----------------------------------------------
 			local texsize, texsizeX, texsizeY
			
			if (chk_customsize.checked == true and chk_fixratio.checked == true) then
			(
				texsizeX = spn_xsize.value as integer
				texsizeY = spn_ysize.value as integer
			)
			
			if (chk_customsize.checked == true and chk_fixratio.checked == false) then
			(
				texsizeX = spn_xsize.value as integer
				texsizeY = spn_ysize.value as integer
			)
			
			if (chk_customsize.checked == false ) then
			(
				texsizeX = (ddl_textureSizes.selected as integer)
				texsizeY = (ddl_textureSizes.selected as integer)
			)
			
			
			
			-------------Scenario 1-------------------
			if LP.count == 0 and selection.count == 0 then
			(	
				messageBox ("Error 1: Select something")
			)
			
			-------------Scenario 2-------------------
			if LP.count == 0 and selection.count == 1  then
			(	
				if GetProj selection[1] != undefined then
				(
					--messageBox ("Bake selection[activeSelection]")	
					BakeProps selection[1] texsizeX texsizeY edt_Output.text
					
				)
				else
				(
					
					if ( ckb_UVW.checked == true ) then
					(
						Print("No Projection Mod Found, render UVs only")
						RenderUVW selection[1] texsizeX texsizeY edt_Output.text
					)
					else
					(
						messageBox ("Error 2: check Projection Mod")
					)
					
				)
			)
			
			-------------Scenario 3-------------------
			--todo: force override marked.
			if (LP.count == 1 and selection.count == 1 and chk_rmblowpoly.checked == false) then
			(	
				if GetProj selection[1] != undefined then
				(
					--messageBox ("Bake selection[activeSelection_forceoveride] ")
					BakeProps selection[1] texsizeX texsizeY edt_Output.text
				)
				else
				(
					if ( ckb_UVW.checked == true ) then
					(
						print("No Projection Mod Found, render UVs only")
						RenderUVW selection[1] texsizeX texsizeY edt_Output.text
					)
					else
					(
						messageBox ("Error 3: Select something or check Projection Mod")
					)
						
				)	
			)
			
			-------------Scenario 4-------------------
			if (LP.count == 1 and selection.count == 1 and chk_rmblowpoly.checked == true) then
			(	
				if GetProj LP[1] != undefined then
				(
					--messageBox ("Bake marker: ")
					select LP[1]
					unhide LP[1]
					BakeProps LP[1] texsizeX texsizeY edt_Output.text
				)
				else
				(
					if ( ckb_UVW.checked == true ) then
					(
						print("No Projection Mod Found, render UVs only")
						RenderUVW LP[1] texsizeX texsizeY edt_Output.text
					)
					else
					(
						messageBox ("Error 4: Select something or check Projection Mod"); select LP[1]
					)
					
				)
			)
		
			-------------Scenario 5-------------------
			--if LP is marked and nothing is selected, then we select the marked LP
			if (LP.count == 1 and selection.count == 0 and chk_rmblowpoly.checked == true) then
			(	
				if GetProj LP[1] != undefined then
				(
					--messageBox ("Bake marker: ")
					select LP[1]
					unhide LP[1]
					BakeProps LP[1] texsizeX texsizeY edt_Output.text
				)
				else
				(
					if ( ckb_UVW.checked == true ) then
					(
						print("No Projection Mod Found, render UVs only")
						RenderUVW LP[1] texsizeX texsizeY edt_Output.text
					)
					else
					(
						messageBox ("Error 4: Select something or check Projection Mod"); select LP[1]
					)
					
				)
			)
			
			-------------Scenario 6-------------------
			--if LP is marked and nothing is selected, then we select the marked LP
			if (LP.count == 1 and selection.count == 0 and chk_rmblowpoly.checked == false) then
			(					
				messageBox ("Error 5: You turned off Remember Low Poly"); select LP[1]
			)
			
			-------- uvw template methods----------
			if ckb_UVW.state == true then
			(
				print("No Projection Mod Found, render UVs only")
				RenderUVW selection[1] texsizeX texsizeY edt_Output.text
			)
		)
		on btn_OpenOutput pressed do
		(
			--print edt_Output.text
			shellLaunch "explorer.exe" edt_Output.text
		)
		on edt_Output entered txt do
		(
			if txt != "" then ( edt_Output.text = txt + "\\" )
			rdo_folder.state = 2
		)
		on rdo_folder changed state do
		(
			--default folder
			if rdo_folder.state == 1 then
			(
				edt_Output.text = ro_BakeTool.GetRenderPath()
				
				if ( hasINISetting iniFile "Settings" "CustomFolder" ) then
				(
					delIniSetting iniFile "Settings" "CustomFolder"
				)
			)
			
			--custom folder
			if rdo_folder.state == 2 then
			(
				savepath = getSavePath caption:"Select folder to save textures" initialDir: "C:\\Projects\\Cow2\\Assets\\"
				if savepath != undefined then
				(
					edt_Output.text = savepath + "\\"
				)
				else( rdo_folder.state=1 )
			)
		)
		on btn_SelectLowPoly pressed do
		(
			if LP.count !=0 then ( select(LP[1]) )
		)
		on btn_clear pressed do
		(
			LP = #()
			lbl_lowPoly.caption = "  "
			chk_rmblowpoly.checked = false
		)
		on btn_markLP pressed do
		(
			if selection.count == 1 then
			(
				LP = #()
				append LP selection[1]
				lbl_lowPoly.caption = LP[1].name
				chk_rmblowpoly.checked = true
			)		
		)
		
		on spn_xsize changed val do
		(
			if chk_fixratio.checked == true then
			(
				spn_ysize.value = spn_xsize.value
			)
		)
		
		on spn_ysize changed val do
		(
			if chk_fixratio.checked == true then
			(
				spn_xsize.value = spn_ysize.value
			)
		)
		
		on chk_customsize changed state do
		(
			if chk_customsize.checked == false and chk_fixratio.checked == false then
			(
				chk_customsize.checked = true
				chk_fixratio.checked = true
			)
		)
		
	)
	
createDialog ro_BakeTool
	
) --end script block




