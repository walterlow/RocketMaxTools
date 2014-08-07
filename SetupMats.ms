-- global working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 
-- global final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
-- global shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
-- global ext = ".png"

--maxFileName
--getFilenameFile maxFileName 
global baseTexName

global diffuseTex
global speclevelTex 
global bumpnormalTex

global alphaTex
global bumpTex 
global bump2Tex 
global lightmapTex 
global silhouetteTex
global decalTex


fn existFile fname = (getfiles fname).count != 0

--if (existFile (final_path+diffuseTex)) do (print "File exist!") 
	
-- fn SetBitmap fx slot fname =
-- (
-- 	
-- 	if (getfiles fname).count != 0 then
-- 	(
-- 		fx.&slot = openBitmap (fname)
-- 	)
-- 	else
-- 	(
-- 		print fname + " does not exist!"
-- 	)
-- )

fn setupDX9Mats = 
(
	--getProperty() that access parameter block can be handy if your material is a C++ plugin or a scripted material that extends DirectX 9 Shader material.
	--getPropNames Node
	--getProperty  meditmaterials[1]  #opacity
-- 	local shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
	--macros.run "Medit Tools" "clear_medit_slots"
	
	baseTexName = getFilenameFile maxFileName
	diffuseTex = final_path + baseTexName + "-A" + ext
	speclevelTex = final_path + baseTexName + "-A" + "_S" + ext
	bumpnormalTex = final_path + baseTexName + "-A" +"_N" + ext

	alphaTex = final_path + baseTexName + "-B" + ext
	bumpTex = final_path + baseTexName + "-C" + ext
	bump2Tex = final_path + baseTexName + "-D" + ext
	lightmapTex = final_path + baseTexName + "-E" + ext
	silhouetteTex = final_path + baseTexName + "-F" + ext
	decalTex = final_path + baseTexName + "-G" + ext
	
	if sceneMaterials["Main_2UV"] == undefined then
	(
		main2uv = meditMaterials[7] = DirectX_9_Shader ()
		main2uv.name = "Main_2UV"  --eg, Simple_2UV
		main2uv.effectfile = shader_path + "simple-2uv.fx"
		main2uv.technique = 0
		main2uv.renderMaterial = StandardMaterial name:"simple-2uv_renderstyle"
		main2uv.Shininess = 30
		main2uv.BloodWallDepth = 2.5
		main2uv.BloodBlend = 1.75
		main2uv.ShadowFactor = 0.25
		main2uv.HighlightMultiplier = 0.1
		if (existFile (diffuseTex)) do (main2uv.TexDiffuse = openBitMap (diffuseTex) ) 
		if (existFile (bumpTex)) do (main2uv.TexBump = openBitMap (bumpTex) ) 
		if (existFile (lightmapTex)) do (main2uv.TexLightMap = openBitMap (lightmapTex) ) 
	)
	else ( meditMaterials[7] =  sceneMaterials["Main_2UV"] )
		
	if sceneMaterials["Simple"] == undefined then
	(
	simple = meditMaterials[8] = DirectX_9_Shader ()
	simple.name = "Simple"  --eg, Simple_2UV
	simple.effectfile = shader_path + "simple.fx"
	simple.technique = 0
	simple.renderMaterial = StandardMaterial name:"simple_renderstyle"
	--simple.TexDiffuse = openBitMap (diffuseTex)
	if (existFile (diffuseTex)) do (simple.TexDiffuse = openBitMap (diffuseTex) ) 
	)
	else ( meditMaterials[8] =  sceneMaterials["Simple"] )
		
	
	if sceneMaterials["SimpleCastShadow_2UV"] == undefined then
	(
	simple2uvcs = meditMaterials[14] = DirectX_9_Shader ()
	simple2uvcs.name = "SimpleCastShadow_2UV"  --eg, Simple_2UV
	simple2uvcs.effectfile = shader_path + "simple-2uv-castshadow.fx"
	simple2uvcs.technique = 0
	simple2uvcs.renderMaterial = StandardMaterial name:"simple_renderstyle"
	simple2uvcs.Shininess = 30
	simple2uvcs.BloodWallDepth = 2.5
	simple2uvcs.BloodBlend = 1.75
	simple2uvcs.ShadowFactor = 0.25
	simple2uvcs.HighlightMultiplier = 0.1
	if (existFile (diffuseTex)) do (simple2uvcs.TexDiffuse = openBitMap (diffuseTex) ) 
	if (existFile (bumpTex)) do (simple2uvcs.TexBump = openBitMap (bumpTex) ) 
	if (existFile (lightmapTex)) do (simple2uvcs.TexLightMap = openBitMap (lightmapTex) ) 
	)
	 else ( meditMaterials[14] =  sceneMaterials["SimpleCastShadow_2UV"] )
	
	if sceneMaterials["Silhouette"] == undefined then
	(
	silhouette = meditMaterials[9] = DirectX_9_Shader ()
	silhouette.name = "Silhouette"  --eg, Simple_2UV
	silhouette.effectfile = shader_path + "silhouette.fx"
	silhouette.technique = 0
	silhouette.renderMaterial = StandardMaterial name:"silhouette_renderstyle"
	if (existFile (silhouetteTex)) do (silhouette.TexDiffuse = openBitMap (silhouetteTex) ) 
	)
	 else ( meditMaterials[9] =  sceneMaterials["Silhouette"] )
		
	if sceneMaterials["Black"] == undefined then
	(
	blackfx = meditMaterials[10] = DirectX_9_Shader ()
	blackfx.name = "Black"  --eg, Simple_2UV
	blackfx.effectfile = shader_path + "black.fx"
	blackfx.technique = 0
	blackfx.renderMaterial = StandardMaterial name:"black_renderstyle"
	)
	 else ( meditMaterials[10] =  sceneMaterials["Black"] )
		
	if sceneMaterials["Alpha"] == undefined then
	(
	alphafx = meditMaterials[11] = DirectX_9_Shader ()
	alphafx.name = "Alpha"  --eg, Simple_2UV
	alphafx.effectfile = shader_path + "simple-alpha.fx"
	alphafx.technique = 0
	alphafx.renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
	if (existFile (decalTex)) do (alphafx.TexDiffuse = openBitMap (decalTex) ) 
	alphafx.Blend = 0.7
	alphafx.Show_Transparency = 0.5
	)
	 else ( meditMaterials[11] =  sceneMaterials["Alpha"] )

	if sceneMaterials["Alpha_2UV"] == undefined then
	(
	alpha2uv = meditMaterials[12] = DirectX_9_Shader ()
	alpha2uv.name = "Alpha_2UV"  --eg, Simple_2UV
	alpha2uv.effectfile = shader_path + "simple-alpha-2uv.fx"
	alpha2uv.technique = 0
	alpha2uv.renderMaterial = StandardMaterial name:"simple-alpha-2uv_renderstyle"
	if (existFile (alphaTex)) do (alpha2uv.TexDiffuse = openBitMap (alphaTex) ) 
	if (existFile (bumpTex)) do (alpha2uv.TexBump = openBitMap (bumpTex) ) 
	if (existFile (lightmapTex)) do (alpha2uv.TexLightMap = openBitMap (lightmapTex) ) 
	alpha2uv.Shininess = 30
	alpha2uv.BloodWallDepth = 2.5
	alpha2uv.BloodBlend = 1.75
	alpha2uv.ShadowFactor = 0.25
	alpha2uv.HighlightMultiplier = 0.1
	)
	 else ( meditMaterials[12] =  sceneMaterials["Alpha_2UV"] )
		
	if sceneMaterials["Multiply"] == undefined then
	(
	multiply = meditMaterials[13] = DirectX_9_Shader ()
	multiply.name = "Multiply"  --eg, Simple_2UV
	multiply.effectfile = shader_path + "simple-multiply.fx"
	multiply.technique = 0
	multiply.renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
	if (existFile (decalTex)) do (multiply.TexDiffuse = openBitMap (decalTex) ) 
	multiply.Blend = 1
	)
	 else ( meditMaterials[13] =  sceneMaterials["Multiply"] )
	
	
	if sceneMaterials["BreakableAlpha"] == undefined then
	(
	breakableAlpha = meditMaterials[15] = DirectX_9_Shader ()
	breakableAlpha.name = "BreakableAlpha"  --eg, Simple_2UV
	breakableAlpha.effectfile = shader_path + "simple-multiply.fx"
	breakableAlpha.technique = 0
	breakableAlpha.renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
	if (existFile (diffuseTex)) do (breakableAlpha.TexDiffuse = openBitMap (diffuseTex) ) 
	breakableAlpha.Blend = 1
	)
	 else ( meditMaterials[15] =  sceneMaterials["BreakableAlpha"] )
	
	if sceneMaterials["Chicken"] == undefined then
	(
	chicken = meditMaterials[16] = DirectX_9_Shader ()
	chicken.name = "Chicken"
	chicken.effectfile = shader_path + "object-dynamic.fx"
	chicken.technique = 0
	chicken.renderMaterial = StandardMaterial name:"object-dynamic_renderstyle"
	if (existFile (diffuseTex)) do (chicken.TexDiffuse = openBitMap (diffuseTex) ) 
	if (existFile (bumpTex)) do (chicken.TexBump = openBitMap (bumpTex) ) 
	chicken.Shininess = 30
	)
	 else ( meditMaterials[16] =  sceneMaterials["Chicken"] )
)

fn setupMaxMats = 
(
	mainMat = meditMaterials[1] = StandardMaterial name:"Main" showInViewport:true
	mainMat.diffuseMapEnable = on
	mainMat.diffuseMap = Bitmaptexture fileName:  (diffuseTex)
	--meditMaterials[1][#Maps][#Diffuse_Color__Map__0__BARK5_jpg].alphaSource = 2
	
	mainMat.specularLevelMapEnable = on
	mainMat.specularLevelMap = Bitmaptexture fileName: (speclevelTex)
	
	mainMat.bumpMapEnable = on
	mainMat.bumpMap = Normal_Bump () --Normal_Bump name:"FFF"
	mainMat.bumpMap.normal_map = Bitmaptexture fileName: (bumpnormalTex) --change bitmaptexure name?
	mainMat.bumpMapAmount = 100
	--meditMaterials[1][#Maps][#Bump__Map__1____Normal_Bump].normal_map = Bitmaptexture fileName:"C:\Users\walter\Documents\3dsMax\sceneassets\images\BWom0001-M3-Body-N.jpg"
	
	------
	
	glassMat = meditMaterials[3] = StandardMaterial name:"Glass" showInViewport:true
	glassMat.diffuseMapEnable = on
	glassMat.diffuseMap = Bitmaptexture fileName:  (alphaTex)
	
	glassMat.specularLevelMapEnable = on
	glassMat.specularLevelMap = Bitmaptexture fileName: (speclevelTex)
	
	--glassMat.bumpMapEnable = on
	--glassMat.bumpMap = Normal_Bump () --Normal_Bump name:"FFF"
	--glassMat.bumpMap.normal_map = Bitmaptexture fileName: (final_path + bumpnormalTex) --change bitmaptexure name?
	glassMat.bumpMapAmount = 100
	
)

fn SetupMats =
(
	if(getFilenameFile maxFileName != "") then
	(
	setupMaxMats()
	setupDX9Mats()
	)
	else
	(messagebox("Please save and name your file first."))
)

fn CleanMats =
(
	undo on (
		obj = getCurrentSelection()
		
		if obj.count == 0 then
		(
			if querybox "Do you want to clear all object materials in the scene?" beep:true do
			$*.material = undefined
			macros.run "Medit Tools" "clear_medit_slots"
		)
		else
		(
			for o in obj do
			(
				o.material = undefined
			)
			select obj
		)
	)
)
