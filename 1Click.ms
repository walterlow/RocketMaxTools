global userscriptPath =  (GetDir #userscripts) 

global working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 
global final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
global shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
global ext = ".png"

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
	
importedFile = getOpenFileName "Import RocketEd dae" filename:"C:\\Projects\\Cow2\\Assets\\Screens\\" types: "OpenCollada(*.dae)|*.dae|"

if importedFile != undefined then
(

tokens = filterString importedFile "\\"
fileTitle = substring tokens[6] 1 (tokens[6].count-4) -- start from int 1 to tokenlength-4

suspendEditing which:#modify

	
if (not (doesFileExist ("C:\\Projects\\Cow2\\Assets\\Screens\\" + "working\\" + fileTitle))) do
(
	makeDir  ("C:\\Projects\\Cow2\\Assets\\Screens\\" + "working\\" + fileTitle)
)
	
savemaxFile ("C:\\Projects\\Cow2\\Assets\\Screens\\" + "working\\" + fileTitle + "\\"+ fileTitle + ".max")
	
importFile importedFile #noPrompt using:DAEIMP

format " ** Imported File: % **\n" fileTitle

--importerPlugin.classes
--exporterPlugin.classes

select $*
ResetXFPoly()
AutoDoors()
assignDoorMatID()
SetupMats()
$*.material = meditmaterials[1]
createBouncer()
sendtoLayer $Bouncer "Bouncer"
clearSelection()

--save file, 
--set up materials


for o in objects do
(
	if matchpattern o.name pattern: "*Silhouette*" then
	(
		--o.material = sceneMaterials["Silhouette"]
		o.material = meditmaterials[9]
		sendtoLayerByName o.name "Silhouette"
		format "found: %" o.name
	)
	
)

for o in objects where (classof o.baseobject == Editable_Poly) do
(
	ChannelInfo.CopyChannel o 3 1
	ChannelInfo.PasteChannel o 3 2
	collapseStack o
)

for o in objects do 
(
	
)


resumeEditing which:#modify

)



