/*
fn exportSelectedDAE =
(
	local filename = getFilenameFile maxFileName
	local fileext = ".dae"
	local fileExportName =  final_path + filename + fileext
	if (selection.count != 0) then
	(
		if (not (doesFileExist fileExportName) ) or
		querybox ("Filename: " + fileExportName + "\nexists. Overwrite?") then
		(
			exportFile (fileExportName) selectedOnly:true using:ColladaExporter 
		)
		else(false)
	) else (messageBox "Select Something!")
)

*/


fn exportSelectedDAE =
(
	local filename = getFilenameFile maxFileName
	local fileext = ".dae"
	local fileExportName =  final_path + filename + fileext
	if (selection.count != 0) then
	(
		exportFile (fileExportName) selectedOnly:true using:ColladaExporter 
	) else (messageBox "Select Something!")
)

--theClasses =exporterPlugin.classes
--ShellLaunch "K:\Downloads\ScreenMarker.exe" ""
--#noPrompt