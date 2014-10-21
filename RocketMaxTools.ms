--%localappdata%\Autodesk\3dsMax\2011 - 64bit\ENU\scripts

-- try(cui.UnRegisterDialogBar MainFloater; closeRolloutFloater MainFloater) catch()
-- try(closeRolloutFloater MainFloater) catch()
-- try(destroyDialog ro_TransferUV) catch()
-- try(destroyDialog dial_doorHelper) catch()

if MainFloater !=undefined then closeRolloutFloater MainFloater
if dial_doorHelper !=undefined then destroyDialog dial_doorHelper
if ro_TransferUV !=undefined then destroyDialog ro_TransferUV
if ro_doorHelper2 !=undefined then destroyDialog ro_doorHelper2
if ro_animHelper !=undefined then destroyDialog ro_animHelper

-----------------------------------------------------------------------------------------------------
--PROJECT PATH GLOBALS
global userscriptPath =  (GetDir #userscripts) 

global working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 
global final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
global shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
global ext = ".png"

global mr = renderers.current = mental_ray_renderer()
mr.DistributedEnable = false
-----------------------------------------------------------------------------------------------------

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
::fileIn( userscriptPath + "\\RocketMaxTools\DoorHelper.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\Autodoors.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\EditNormalFix.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\DeleteEmptyObjects.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\CreateFX.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\TransferUV.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\AutoDetachSetup.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\BackupTool.ms")
::fileIn( userscriptPath + "\\RocketMaxTools\KeyTools.ms")

-----------------------------------------------------------------------------------------------------

Rollout Menu01 "Layering Tools"
(
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
	
	on btn_xform pressed do (ResetXFPoly())
	on btn_weldVertices pressed do (WeldVertices())
	on btn_centerPivot pressed do (CenPivot(); if keyboard.controlPressed do centerPivotWorld() )
	on btn_oneobject pressed do(OneObject())
	on btn_normalfix pressed do (EditNormalFix())
	
	group "Door Helper" (
		button btn_selectsimilar "Select Similar" tooltip:"Select Similar elements" pos:[8,80] width:80 
		button btn_detachFaces "Quick Detach" tooltip:"Detach selected faces as object" pos:[88,80] width:80
		button btn_autoDoors "Auto Doors"  pos:[8,102] width: 80
		button btn_doorHelper "Door Helper" tooltip:"Launch door helper tool"  pos:[88,102]  width: 80
		button btn_doorHelper2 "DoorHelperV2" pos:[168,80] width:70 height: 43 
	)
	
	on btn_selectsimilar pressed do	(selectsimilar())
	on btn_detachFaces pressed do (DetachFace())
	on btn_autoDoors pressed do (AutoDoors())
	on btn_doorHelper pressed do ( try(destroyDialog dial_doorHelper)catch(); createDialog dial_doorHelper)
	on btn_doorHelper2 pressed do ( try(destroyDialog ro_doorHelper2)catch(); createDialog ro_doorHelper2)
	
	group "Anim Helper"(
		button btn_animHelper "Animation Helper" pos:[8,150] 
	)
	on btn_animHelper pressed do ( try(destroyDialog ro_animHelper) catch(); createDialog ro_animHelper)

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
		checkbox chkbox_NR "Net Render" checked:false tooltip:"Enable Distributed Rendering."
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