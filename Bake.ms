--todo add check for uvchannel 2

fn BakeTextures obj texsize =
(
	if(classof $ == Editable_Poly and selection.count != 0)
	then
	(
	
	try (destroyDialog gTextureBakeDialog)catch()
	macros.run "Render" "BakeDialog"
	--mr = renderers.current = mental_ray_renderer()
	
	working_path = "C:\Projects\Cow2\Assets\Screens\working\\" + getFileNameFile maxFileName + "\\"
	--working_path = maxFilePath + getfilenamefile maxFileName  + "\\"
	
	--WTF IS THIS ABSTRACT CODE?  (sets the default output folder of RTT)
	
	if (not (doesfileExist working_path))then(
		MAKEDir working_path
	) else
	(
		RTT_SceneData_AppData_Index = 0x41dd73d5
		RTT_data.FileOutput_FilePath = working_path
		setAppData rootNode (RTT_SceneData_AppData_Index+4) RTT_data.FileOutput_FilePath 
	)
	
	bp = obj.INodeBakeProperties
	bp.removeAllBakeElements()
	bp.bakeEnabled = true
    bp.bakeChannel = 2
    bp.nDilations = 2


	--Lightmap
	lm = LightingMap()
	lm.outputSzX = lm.outputSzY = texsize
	--lm.filenameUnique = true
	
	--lm.fileType = working_path + $.name + lm.elementName + ".png"
	--lm.fileName = working_path + $.name + lm.elementName + ".png"
	
	lm.fileType = working_path + $.name + "_Light"  + ".png"
	lm.fileName = working_path + $.name + "_Light"  + ".png"

	lm.shadowsOn = true
	lm.directOn = true
	lm.indirectOn = false
	
	
	--Indirect Lightmap
	ilm = LightingMap()
	ilm.outputSzX = ilm.outputSzY = texsize
	--ilm.filenameUnique = true
	ilm.fileType = working_path + $.name + "_IL" + ".png"
	ilm.fileName = working_path + $.name + "_IL" + ".png"
	
	ilm.shadowsOn = false
	ilm.directOn = false
	ilm.indirectOn = true
	
	--AOmap
	ao = Ambient_Occlusion()
	ao.outputSzX = ao.outputSzY = texsize
	--ao.filenameUnique = true
	ao.fileType = working_path + $.name + "_AO" + ".png"
	ao.fileName = working_path + $.name + "_AO" + ".png"
	
	ao.samples = 512
	ao.spread = 1
	ao.maxDistance = 1
	ao.falloff = 1
	
	--Add elements
	bp.addBakeElement lm
	bp.addBakeElement ilm
	bp.addBakeElement ao
	
	--Render
	--mr = renderers.current = mental_ray_renderer()
	--mr.DistributedEnable = true
	--render rendertype:#bakeSelected outputwidth:Xsize outputheight:Ysize outputfile:(fPath+fName+fType)
	--render rendertype:#bakeSelected vfb:on progressBar:true outputSize:[2048,2048]
	render renderType:#bakeSelected frame:#current vfb:true progressBar:true outputwidth:texsize outputheight:texsize
)
else
(
	MessageBox("Select Something!")
)

)

