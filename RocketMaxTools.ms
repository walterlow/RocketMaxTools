--%localappdata%\Autodesk\3dsMax\2011 - 64bit\ENU\scripts

-- try(cui.UnRegisterDialogBar MainFloater; closeRolloutFloater MainFloater) catch()
try(closeRolloutFloater MainFloater) catch()
try(destroyDialog ro_TransferUV) catch()
try(destroyDialog dial_doorHelper) catch()
-----------------------------------------------
--UI GLOBALS

global buttonWidth = 150
global buttonHeight = 20
global spacing = 8
global promptText = ""
-----------------------------------------------
--PROJECT PATH GLOBALS

global working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 
global final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
global shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
global ext = ".png"

global userscriptPath =  (GetDir #userscripts) 

global mr = renderers.current = mental_ray_renderer()
mr.DistributedEnable = false

-------------------------------------------------------------------

::fileIn( userscriptPath + "\\RocketMaxTools\SaveFiles.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\exportSelectedDAE.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\Bake.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\SelectSimilar.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\SetupMR.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\SetupMats.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\Lights.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\SendtoLayer.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\WeldVertices.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\ResetXFPoly.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\OneObject.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\CenterPivot.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\DetachFace.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\BuildRun.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\CreateBouncer.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\QuickPlanarUV2.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\UVPack.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\Autodoors.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\EditNormalFix.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\DeleteEmptyObjects.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\CreateFX.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\TransferUV.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\AutoDetachSetup.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\BackupTool.ms")


fn selSomething =
(
	messageBox("Select Something!")
)


Rollout Menu01 "Layering Tools"
(
	--button CreateLayers "Create Layers from Selection" width:buttonWidth
	button btn_lightLayers "Lights"  pos:[8,8] width: 50
	button btn_Black "Black"  tooltip:"Black" pos:[58,8] width: 50
	button btn_fullBright "FB" tooltip:"Full Bright" pos:[108,8] width: 50
	button btn_silhouette "Silhouette"  pos:[158,8] width: 50
		
	button btn_blocker "Blocker" pos:[8,30] width: 50
	button btn_fx "FX" pos:[58,30] width: 50
	button btn_main "Main" pos:[108,30] width: 50
	button btn_ladder "Ladders" pos:[158,30] width:50
	
	local files = #( "Chicken", "FX", "Grates", "Lines", "Abattoir Lines")

	group ""(
	button btn_bouncer "Bouncer" pos:[8,70] width: 50
	colorpicker theColor "" color:[50,50,50] pos:[58,70]
	--button btn_importFX "Import FX" pos:[108, 70]
	--button btn_importChicken "Chicken" pos:[178, 70]
		
	dropdownlist ddl_import "" items: files across: 2 width: 80 pos:[108, 70]
	button btn_import "Import" pos:[190, 70]
	)
	
	button btn_delEmptyLayers "Del Empty Layers"  across:2
	button btn_delemptyobjects "Del Empty Objects" items:files
	
	on theColor changed new_col do (if sceneMaterials["bouncer"] != undefined then sceneMaterials["bouncer"].diffusecolor = new_col)
	on btn_bouncer pressed do (CreateBouncer())
	--on btn_importFX pressed do (importFX())
	--on btn_importChicken pressed do ( mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\Chicken\\RiggedChicken.max") #select #useSceneMtlDups )
	
	on btn_import pressed do
	(
		case ddl_import.selected of
		(
			"Chicken": mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\Chicken\\RiggedChicken.max") #select #useSceneMtlDups
			"FX": importFX()
			"Grates": mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\Grates\\Grates.max") #select #useSceneMtlDups
			"Lines": mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\Lines\\Lines.max") #select #useSceneMtlDups
			"Abattoir Lines": mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\Lines\\AbattoirLines.max") #select #useSceneMtlDups

		)
	)
	
	--Create Layers Script-- 
	on CreateLayers pressed do
	(
		if selection.count != 0 then
		(
			for o in selection do 
			(
				objName = o.name
				
				if (objLayer = LayerManager.getLayerfromName objName) == undefined then
				(
					objLayer = LayerManager.newLayerfromName objName
					objLayer.addNode o
					PromptBox "Layers Created."
				)
				else
				(
					objLayer.addNode o
					PromptBox "Layers Created."
				)
			)--endfor
		) --endif
		else 
		(
			--createDialog PromptDialog
			PromptBox "Please select something!"
		)
	)
	
	--Delete Empty Layers Script-- 
	on btn_delEmptyLayers pressed do
	(
		if querybox "Do you want to delete all empty layers?" beep:true do
		DeleteEmptyLayers()
	)
	
	on btn_delemptyobjects pressed do (DeleteEmptyObjects())
	on btn_lightLayers pressed do (sendtoLayer (select lights)  "Lights")
	on btn_Black pressed do (sendtoLayer selection "Black")
	on btn_fullBright pressed do (sendtoLayer selection "FullBright")	
	on btn_silhouette pressed do (sendtoLayer selection "Silhouette")
	on btn_blocker pressed do (sendtoLayer selection "Blocker")
	on btn_fx pressed do (sendtoLayer selection "FX")
	on btn_main pressed do (sendtoLayer selection "Main")
	on btn_ladder pressed do (sendtoLayer selection "Ladders")
	
) --endRollout

Rollout Menu02 "Geometry Tools"
(
	--button btn_mirrorflip "Mirror and Flip Normals" width: buttonWidth
	button btn_xform "Reset XForms" pos:[8,8] width:100 tooltip: "Convert to Editable Poly and Resets XForm" across:2
	button btn_weldVertices "Weld Vertices" pos:[108,8] width:100 tooltip: "Weld ALL vertices of selected objects at 0.001" align:#right
	button btn_centerPivot "Center Pivot"  pos:[8,30] width: 100 tooltip: "Set pivot to center, selected vertex or edge" across:2
	button btn_oneobject "One Object" pos:[108,30] width: 100 tooltip: "Attach all objects in selection" 
	button btn_normalfix "FIX" pos:[208,8] width:38 height: 43
	
	group "Door Helper" (
	button btn_selectsimilar "Select Similar" tooltip:"Select Similar elements" pos:[8,80] width:100 
	button btn_detachFaces "Quick Detach" tooltip:"Detach selected faces as object" pos:[108,80] width:100
	button btn_autoDoors "Auto Doors"  pos:[8,102] width: 100
	button btn_doorHelper "Door Helper" tooltip:"Launch door helper tool"  pos:[108,102]  width: 100
	button btn_doorHelper2 "D++" pos:[208,80] width:34 height: 43 
	)
	

	
	-------------------------------------------------------------------------------------------------------------------------
Rollout dial_doorHelper "Door Helper" width:200
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
	
	on btn_selectsimilar pressed do	(selectsimilar()) --door helper
	on btn_break pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Breakable"; sendtoLayer (select($_Breakable*)) "Exit_Breakable"; HideLayer "Exit_Breakable";  select prevobj;) )
	on btn_frame pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Frame"; sendtoLayer (select($_Frame*)) "Exit_Frame"; HideLayer "Exit_Frame"; select prevobj;) )
	on btn_hole pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Hole"; sendtoLayer (select($_Hole*)) "Exit_Hole"; HideLayer "Exit_Hole"; select prevobj;) )
	on btn_wall pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Wall"; sendtoLayer (select($_Wall*)) "Exit_Wall"; HideLayer "Exit_Wall"; select prevobj;) )
	
		
	on btn_btoggle pressed do ( ToggleLayer "Exit_Breakable" )
	on btn_b0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
		
	on btn_ftoggle pressed do ( ToggleLayer "Exit_Frame" )
	on btn_f0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	
	on btn_htoggle pressed do ( ToggleLayer "Exit_Hole" )
	on btn_h0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	
	on btn_wtoggle pressed do ( ToggleLayer "Exit_Wall" )
	on btn_w0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	)

	on btn_doorHelper pressed do ( try(destroyDialog dial_doorHelper)catch(); createDialog dial_doorHelper)
	
	on btn_doorHelper2 pressed do ( try(destroyDialog ro_doorHelper2)catch(); createDialog ro_doorHelper2)
	
	on btn_autoDoors pressed do (AutoDoors())
	
	on btn_xform pressed do (ResetXFPoly())
	
	on btn_oneobject pressed do(OneObject())
		
	on btn_normalfix pressed do (EditNormalFix())
	
	on btn_centerPivot pressed do (CenPivot())
	
	on btn_selectsimilar pressed do	(selectsimilar())
	
	on btn_weldVertices pressed do (WeldVertices())
	
	on btn_detachFaces pressed do (DetachFace())
)	--endrollout

Rollout Menu03 "Bake Tools"
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
	checkbox chkbox_NR "Net Render" checked:false tooltip:"Enable Distributed Rendering. \n-ALPHA feature-\n Please check ip address of Hansen's com"
	)
	
	
	
	on btn_bakeSelected pressed do( BakeTextures $ (ddl_bakeSize.selected as integer))
	on chkbox_NR changed theState do ( mr.DistributedEnable = theState )
	on btn_setupFG pressed do (SetupMR())
	on btn_SetupMats pressed do (SetupMats())
	on btn_CleanMats pressed do (CleanMats())
	on btn_MRSP pressed do (createMRSkyPortal())
	on btn_MROM pressed do (createMROmni())
	on btn_ApplyUV2 pressed do (ApplyUV2())	
	on btn_QPUV2 pressed do(QuickPlanarUV2())
	on btn_UVPacker pressed do (UVPack())
	on btn_TransferUV pressed do ( try(destroyDialog ro_TransferUV)catch(); createDialog ro_TransferUV)
)

Rollout Menu04 "File Tools"
(
	edittext et_projName "Filename: " text: "L99-S99" fieldWidth:60 height:20 across:3
	button btn_createProj "Create" tooltip:"Makes project folder and saves file" pos:[130, 7]
	button btn_backup "Backup" toolip:"Backup a file in working folder" pos:[180, 7]
	button btn_save2copies "Save 2 Copies" tooltip:"Save current and another copy in Screens" across:3
	button btn_exportDAE "Export DAE" tooltip:"Export selected as DAE" 
	button btn_buildandrun "Build & Run" tooltip:"Build then Press any key to run"
	

	on btn_createProj pressed do
	(
		makeDir (working_path + et_projName.text )
		savemaxFile (working_path + et_projName.text + "\\" + et_projName.text + ".max")
	)
	
	on btn_backup pressed do ( Backup() )
	
	on btn_save2copies pressed do (saveCurrentFinal()) 
		
	on btn_exportDAE pressed do (exportSelectedDAE())
	
	on btn_buildandrun pressed do (BuildRun())
		
) --endrollout


Rollout Rocketbirds "Rocketbirds"
(
	local imglogo = GetDir #userScripts + "\\RocketMaxTools\\rb.bmp"
	button btn_logo "" tooltip:"Open Working Folder"align:#center width:256 height:128 images:#(imglogo,undefined,1,1,1,1,1) enabled:true
	
	on btn_logo pressed do (shellLaunch "explorer.exe" working_path)
		
) --endrollout

MainFloater = newRolloutFloater "RocketMaxTools" 260 780

addRollout Menu01 MainFloater
addRollout Menu02 MainFloater
addRollout Menu03 MainFloater
addRollout Menu04 MainFloater
addRollout Rocketbirds MainFloater

--cui.RegisterDialogBar MainFloater style: #(#cui_dock_left, #cui_dock_right, #cui_floatable, #cui_handles) 

macroScript RocketMaxTools category:"RocketBirds"
tooltip:"RocketMaxTools" --Icon:#("RocketMaxTools",1)
(
	::fileIn(GetDir #userScripts + "\\RocketMaxTools\RocketMaxTools.ms")
)