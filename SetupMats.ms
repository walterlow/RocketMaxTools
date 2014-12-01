-- global working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 
-- global final_path =  "C:\\Projects\\Cow2\\Assets\\Screens\\"
-- global ::shader_path = "C:\\Projects\\Cow2\\Assets\\Shaders\\"
-- global ext = ".png"

global baseTexName

global diffuseTex
global speclevelTex 
global bumpnormalTex
global glassSpeclevelTex

global alphaTex
global bumpTex 
global bump2Tex 
global lightmapTex 
global silhouetteTex
global decalTex


fn existFile fname = (getfiles fname).count != 0

fn setupDX9Mats = 
(
	
	if sceneMaterials["Main_2UV"] == undefined then
	(
		meditMaterials[7] = DirectX_9_Shader ()
		meditMaterials[7].name = "Main_2UV"  --eg, Simple_2UV
		meditMaterials[7].effectfile = ::shader_path + "simple-2uv.fx"
		meditMaterials[7].technique = 0
		meditMaterials[7].renderMaterial = StandardMaterial name:"simple-2uv_renderstyle"
		meditMaterials[7].Shininess = 30
		meditMaterials[7].BloodWallDepth = 2.5
		meditMaterials[7].BloodBlend = 1.75
		meditMaterials[7].ShadowFactor = 0.25
		meditMaterials[7].HighlightMultiplier = 0.1
		if (existFile (diffuseTex)) do (meditMaterials[7].TexDiffuse = openBitMap (diffuseTex) ) 
		if (existFile (bumpTex)) do (meditMaterials[7].TexBump = openBitMap (bumpTex) ) 
		if (existFile (lightmapTex)) do (meditMaterials[7].TexLightMap = openBitMap (lightmapTex) ) 
	)
	else ( meditMaterials[7] =  sceneMaterials["Main_2UV"] )
		
	if sceneMaterials["Simple"] == undefined then
	(
	meditMaterials[8] = DirectX_9_Shader ()
	meditMaterials[8].name = "Simple"  --eg, Simple_2UV
	meditMaterials[8].effectfile = ::shader_path + "simple.fx"
	meditMaterials[8].technique = 0
	meditMaterials[8].renderMaterial = StandardMaterial name:"simple_renderstyle"
	if (existFile (diffuseTex)) do (meditMaterials[8].TexDiffuse = openBitMap (diffuseTex) ) 
	)
	else ( meditMaterials[8] =  sceneMaterials["Simple"] )
		
	
	if sceneMaterials["SimpleCastShadow_2UV"] == undefined then
	(
	meditMaterials[14] = DirectX_9_Shader ()
	meditMaterials[14].name = "SimpleCastShadow_2UV"  --eg, Simple_2UV
	meditMaterials[14].effectfile = ::shader_path + "simple-2uv-castshadow.fx"
	meditMaterials[14].technique = 0
	meditMaterials[14].renderMaterial = StandardMaterial name:"simple_renderstyle"
	meditMaterials[14].Shininess = 30
	meditMaterials[14].BloodWallDepth = 2.5
	meditMaterials[14].BloodBlend = 1.75
	meditMaterials[14].ShadowFactor = 0.25
	meditMaterials[14].HighlightMultiplier = 0.1
	if (existFile (diffuseTex)) do (meditMaterials[14].TexDiffuse = openBitMap (diffuseTex) ) 
	if (existFile (bumpTex)) do (meditMaterials[14].TexBump = openBitMap (bumpTex) ) 
	if (existFile (lightmapTex)) do (meditMaterials[14].TexLightMap = openBitMap (lightmapTex) ) 
	)
	 else ( meditMaterials[14] =  sceneMaterials["SimpleCastShadow_2UV"] )
	
	if sceneMaterials["Silhouette"] == undefined then
	(
	meditMaterials[9] = meditMaterials[9] = DirectX_9_Shader ()
	meditMaterials[9].name = "Silhouette"  --eg, Simple_2UV
	meditMaterials[9].effectfile = ::shader_path + "silhouette.fx"
	meditMaterials[9].technique = 0
	meditMaterials[9].renderMaterial = StandardMaterial name:"silhouette_renderstyle"
	if (existFile (silhouetteTex)) do (meditMaterials[9].TexDiffuse = openBitMap (silhouetteTex) ) 
	)
	 else ( meditMaterials[9] =  sceneMaterials["Silhouette"] )
		
	if sceneMaterials["Black"] == undefined then
	(
	meditMaterials[10] = DirectX_9_Shader ()
	meditMaterials[10].name = "Black"  --eg, Simple_2UV
	meditMaterials[10].effectfile = ::shader_path + "black.fx"
	meditMaterials[10].technique = 0
	meditMaterials[10].renderMaterial = StandardMaterial name:"black_renderstyle"
	)
	 else ( meditMaterials[10] =  sceneMaterials["Black"] )
		
	if sceneMaterials["Alpha"] == undefined then
	(
	meditMaterials[11] = meditMaterials[11] = DirectX_9_Shader ()
	meditMaterials[11].name = "Alpha"  --eg, Simple_2UV
	meditMaterials[11].effectfile = ::shader_path + "simple-alpha.fx"
	meditMaterials[11].technique = 0
	meditMaterials[11].renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
	if (existFile (decalTex)) do (meditMaterials[11].TexDiffuse = openBitMap (decalTex) ) 
	meditMaterials[11].Blend = 0.7
	meditMaterials[11].Show_Transparency = 0.5
	)
	 else ( meditMaterials[11] =  sceneMaterials["Alpha"] )

	if sceneMaterials["Alpha_2UV"] == undefined then
	(
	meditMaterials[12] = DirectX_9_Shader ()
	meditMaterials[12].name = "Alpha_2UV"  --eg, Simple_2UV
	meditMaterials[12].effectfile = ::shader_path + "simple-alpha-2uv.fx"
	meditMaterials[12].technique = 0
	meditMaterials[12].renderMaterial = StandardMaterial name:"simple-alpha-2uv_renderstyle"
	if (existFile (alphaTex)) do (meditMaterials[12].TexDiffuse = openBitMap (alphaTex) ) 
	if (existFile (bump2Tex)) do (meditMaterials[12].TexBump = openBitMap (bump2Tex) ) 
	if (existFile (lightmapTex)) do (meditMaterials[12].TexLightMap = openBitMap (lightmapTex) ) 
	meditMaterials[12].Shininess = 30
	meditMaterials[12].BloodWallDepth = 2.5
	meditMaterials[12].BloodBlend = 1.75
	meditMaterials[12].ShadowFactor = 0.25
	meditMaterials[12].HighlightMultiplier = 0.1
	)
	 else ( meditMaterials[12] =  sceneMaterials["Alpha_2UV"] )
		
	if sceneMaterials["Multiply"] == undefined then
	(
	meditMaterials[13] = DirectX_9_Shader ()
	meditMaterials[13].name = "Multiply"  --eg, Simple_2UV
	meditMaterials[13].effectfile = ::shader_path + "simple-multiply.fx"
	meditMaterials[13].technique = 0
	meditMaterials[13].renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
	if (existFile (decalTex)) do (meditMaterials[13].TexDiffuse = openBitMap (decalTex) ) 
	meditMaterials[13].Blend = 1
	)
	 else ( meditMaterials[13] =  sceneMaterials["Multiply"] )
	
	
	if sceneMaterials["BreakableAlpha"] == undefined then
	(
	meditMaterials[15] = DirectX_9_Shader ()
	meditMaterials[15].name = "BreakableAlpha"  --eg, Simple_2UV
	meditMaterials[15].effectfile = ::shader_path + "simple-multiply.fx"
	meditMaterials[15].technique = 0
	meditMaterials[15].renderMaterial = StandardMaterial name:"simple-multiply_renderstyle"
	if (existFile (diffuseTex)) do (meditMaterials[15].TexDiffuse = openBitMap (diffuseTex) ) 
	meditMaterials[15].Blend = 1
	)
	 else ( meditMaterials[15] =  sceneMaterials["BreakableAlpha"] )
	
	if sceneMaterials["Chicken"] == undefined then
	(
	meditMaterials[16] = DirectX_9_Shader ()
	meditMaterials[16].name = "Chicken"
	meditMaterials[16].effectfile = ::shader_path + "character-background.fx"
	meditMaterials[16].technique = 0
	meditMaterials[16].renderMaterial = StandardMaterial name:"character-background_renderstyle"
	if (existFile (diffuseTex)) do (meditMaterials[16].TexDiffuse = openBitMap (diffuseTex) ) 
	if (existFile (bumpTex)) do (meditMaterials[16].TexBump = openBitMap (bumpTex) ) 
	meditMaterials[16].Shininess = 30
	)
	 else ( meditMaterials[16] =  sceneMaterials["Chicken"] )
	
	if sceneMaterials["Stars"] == undefined then
	(
	meditMaterials[17] = DirectX_9_Shader ()
	meditMaterials[17].name = "Stars"  --eg, Simple_2UV
	meditMaterials[17].effectfile = ::shader_path + "simple-alpha.fx"
	meditMaterials[17].technique = 0
	meditMaterials[17].renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
	if (existFile (alphaTex)) do (meditMaterials[17].TexDiffuse = openBitMap (alphaTex) ) 
	meditMaterials[17].Blend = 1
	meditMaterials[17].Show_Transparency = 1
	)
	 else ( meditMaterials[17] =  sceneMaterials["Stars"] )
	
	
	if sceneMaterials["Terminator"] == undefined then
	(
	meditMaterials[18] = meditMaterials[11] = DirectX_9_Shader ()
	meditMaterials[18].name = "Terminator"  --eg, Simple_2UV
	meditMaterials[18].effectfile = ::shader_path + "simple-alpha.fx"
	meditMaterials[18].technique = 0
	meditMaterials[18].renderMaterial = StandardMaterial name:"simple-alpha_renderstyle"
	if (existFile (alphaTex)) do (meditMaterials[11].TexDiffuse = openBitMap (alphaTex) ) 
	meditMaterials[18].Blend = 1
	meditMaterials[18].Show_Transparency = 1
	)
	 else ( meditMaterials[11] =  sceneMaterials["Terminator"] )
	
)

fn setupMaxMats = 
(
	meditMaterials[1] = StandardMaterial name:"Main" showInViewport:true
	meditMaterials[1].diffuseMapEnable = on
	meditMaterials[1].twoSided = on
	meditMaterials[1].diffuseMap = Bitmaptexture fileName:  (diffuseTex)
	
	
	meditMaterials[1].specularLevelMapEnable = on
	meditMaterials[1].specularLevelMap = Bitmaptexture fileName: (speclevelTex)
	
	meditMaterials[1].bumpMapEnable = on
	meditMaterials[1].bumpMap = Normal_Bump () --Normal_Bump name:"FFF"
	meditMaterials[1].bumpMap.normal_map = Bitmaptexture fileName: (bumpnormalTex) --change bitmaptexure name?
	meditMaterials[1].bumpMapAmount = 100
	
	------
	
	meditMaterials[3] = StandardMaterial name:"Glass" showInViewport:true
	meditMaterials[3].diffuseMapEnable = on
	meditMaterials[3].twoSided = on
	meditMaterials[3].diffuseMap = Bitmaptexture fileName:  (alphaTex)
	
	meditMaterials[3].specularLevelMapEnable = on
	meditMaterials[3].specularLevelMap = Bitmaptexture fileName: (glassSpeclevelTex)
	
	meditMaterials[3].bumpMapAmount = 100
	
)

fn SetupMats =
(
	$*.material = undefined
	macros.run "Medit Tools" "clear_medit_slots"
	if(getFilenameFile maxFileName != "") then
	(
		baseTexName = getFilenameFile maxFileName
		diffuseTex = final_path + baseTexName + "-A" + ext
		speclevelTex = final_path + baseTexName + "-A" + "_S" + ext
		glassSpeclevelTex = final_path + baseTexName + "-B" + "_S" + ext
		bumpnormalTex = final_path + baseTexName + "-A" +"_N" + ext

		alphaTex = final_path + baseTexName + "-B" + ext
		bumpTex = final_path + baseTexName + "-C" + ext
		bump2Tex = final_path + baseTexName + "-D" + ext
		lightmapTex = final_path + baseTexName + "-E" + ext
		silhouetteTex = final_path + baseTexName + "-F" + ext
		decalTex = final_path + baseTexName + "-G" + ext
		
		setupDX9Mats()
		setupMaxMats()
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
