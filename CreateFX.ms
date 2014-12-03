fn createFX =
(
	local p 
	p = Plane uniquename "FX" pos:[0,0,19]
	p.length = p.width = 5
	p.lengthsegs = p.widthsegs = 1
	rotate p (angleaxis 90 [1,0,0])
	convertToPoly p
	if scenematerials["Alpha"] != undefined then p.material = scenematerials["Alpha"] else (messagebox("Please setup Alpha material"))
)

fn importFX = 
(
	/*
	--files = getFiles ("C:\\Projects\\Cow2\\Assets\\Screens\\working\\FX\\FXMultiply*.FBX")
	local files = getFiles (userscriptPath + "\\RocketMaxTools\\Assets\\FX\\FX*.FBX")

	for f in files do
	(
		importFile f #noPrompt using:FBXIMP
	)
	convertTo $FX* Editable_Poly
	*/
	
	mergemaxfile (userscriptPath + "\\RocketMaxTools\\Assets\\FX\\FX.max") #select #useSceneMtlDups
	
	if scenematerials["Multiply"] != undefined then
	(
		$FXMultiply*.material = scenematerials["Multiply"] 
	) 
	else
	(
		messagebox ("Please setup Multiply material.")
	)
	
	if scenematerials["Alpha"] != undefined then
	(
		$FXAlpha*.material = scenematerials["Alpha"] 
	) 
	else
	(
		messagebox ("Please setup Alpha material.")
	)
)


--createFX()
--importFX()
--userscriptPath + "\\RocketMaxTools\\FX\\FXMultiply*.FBX" 
