macroScript StereoCam category:"RocketBirds"
tooltip:"StereoCam"
(
	::fileIn(GetDir #userScripts + "\RocketMaxTools" + "\StereoCam.ms")
)

try(DestroyDialog roStereoCam)catch();
(
	global roStereoCam
	
	fPath = maxFilePath + "render\\"
	ffmpeg = @"C:\Projects\Cow2\Tools\ffmpeg.exe"
	
-- 	Lens = 0.5 * (GetRendApertureWidth() / tan(FOV/2.0))

	fn camFilter obj = (classof obj == Freecamera) or (classof obj == Targetcamera)
	
	fn GetFOVFromLens lensVal =
	(
		local FOV = 2.0* atan(GetRendApertureWidth()/lensVal*0.5)
	)
	
	fn createMainCam = 
	(
		local targetDist = 10
		local MainCam = Freecamera name:"Cam_Main" wirecolor: white
		MainCam.orthoProjection = true
		MainCam.rotation = (angleaxis 90 [1,0,0])
		MainCam.position = [0, -targetDist, 5]
		MainCam.baseObject.targetDistance = targetDist
		MainCam.fov = GetFOVFromLens 35
	)
	
	fn SetupCameraController =
	(
		local CamControl = Dummy name:"CamController" boxsize: [2,2,2]
		CamControl.transform = $Cam_Main.transform
		
		for c in cameras do 
		(
			c.parent = CamControl
		)
	)
	
	fn createVideoFromSequence =
	(
		QTPathOut = fPath + roStereoCam.edt_shotname.text + ".avi"
		entstring = "-y -i " + fPath + roStereoCam.edt_shotname.text + "-%4d" + roStereoCam.ddl_ext.selected + " -vcodec huffyuv -r 30 " + QTPathOut
		

		shellLaunch ffmpeg entstring
	)

	
	rollout roStereoCam "Stereo Cam Tool" width:236 height:376
	(
		GroupBox grp1 "Setup Cam" pos:[4,0] width:224 height:100		
		
		spinner spn_frameWidth "Frame Width:" pos:[28,52] width:139 height:16 range:[640, 7680 , 1280] type:#integer
		spinner spn_frameHeight "Frame Height:" pos:[28,72] width:139 height:16 range:[360 , 4320, 720] type:#integer
		
		button btn_createCam "Create Cameras" pos:[16,20] width:91 height:24

		GroupBox grp2 "Cam Controls" pos:[4,112] width:224 height:160
		spinner spn_camDist "Cam Distance:" pos:[24,136] width:139 height:16 range:[0.01,1,0.1]

		edittext edt_shotname "Shot Name:" pos:[19,280] width:148 height:17
		dropdownlist ddl_ext pos:[170,278] width:50 items:#(".jpg", ".bmp", ".png")
		button btn_render "Render" pos:[15,304] width:72 height:32
		button btn_output "Output Folder" pos:[95,304] width:78 height:32
		progressBar progBar "" pos:[15,344] width:200 height:16 
 
		button btn_selectCtrl "Select CamCtrl" pos:[12,160] width:85 height:21
		button btn_selectMainCam "Select MainCam" pos:[100,160] width:85 height:21
		spinner spn_FOV "FOV:" pos:[44,190] width:96 height:16 range:[1,1000, GetFOVFromLens 35]
		spinner spn_horizontalAxis "Horizontal:" pos:[34,212] width:139 height:16 range:[-1000,1000,0]
		spinner spn_verticalAxis "Vertical:" pos:[34,232] width:139 height:16 range:[-1000,1000,0]
		spinner spn_pan "Pan:" pos:[34,252] width:139 height:16 range:[-1000,1000,0]
		
		fn UpdateSpinners =
		(
				spn_FOV.controller =  $Cam_Main.fov.controller
				spn_horizontalAxis.controller = $CamController.position.controller.X_position.controller
				spn_verticalAxis.controller = $CamController.position.controller.Z_position.controller
				spn_pan.controller = $CamController.rotation.controller.Z_Rotation.controller
		)
		
		
		on roStereoCam open do 
		(
			try
			(
				UpdateSpinners()
	
			) catch()
		)
		
		on btn_createCam pressed do
		(
			try
			(
				delete $Cam_StereoLeft
				delete $Cam_StereoRight
				delete $Cam_Main
				delete $CamController
			) catch();
			
			createMainCam()
		
			MyCamera = $Cam_Main
			camDist = spn_camDist.value
		
			--local axis
			CamLeft = instance MyCamera name:"Cam_StereoLeft" wirecolor: red
			in coordsys local (CamLeft.position.x -= camDist)
			CamRight = instance MyCamera name:"Cam_StereoRight" wirecolor: blue
			in coordsys local (CamRight.position.x += camDist)
			
			SetupCameraController()
			UpdateSpinners()
		)
		on spn_camDist changed value do
		(
			$Cam_StereoLeft.pos.x = $Cam_Main.pos.x - spn_camDist.value
			$Cam_StereoRight.pos.x = $Cam_Main.pos.x + spn_camDist.value
		)
		on spn_FOV changed value do
		(
-- 			FOV = GetFOVFromLens spn_Lens.value
			$Cam_Main.fov = spn_FOV.value
			$cam_StereoLeft.fov = spn_FOV.value
			$cam_StereoRight.fov = spn_FOV.value
			
		)
		on btn_render pressed do
		(
			fPath = maxFilePath + "render\\"
			camLeft = $Cam_StereoLeft
			camRight = $Cam_StereoRight 
			bCancelled = false
			
			count = 0
			slidertime = animationrange.start
			fstart = animationrange.start
			fend = animationrange.end
			
			if (not (doesfileExist fPath) ) then ( MAKEDir fPath)
			
			
			for i = fstart to fend do 
			(
				if (not bCancelled) do
				(
					
					progBar.value = 100.0 * i/fend
					progBar.color = green
					
					fCount = formattedprint count format: ".4d"
					fName = fPath + edt_shotname.text  + "-" + fCount + "-" + "Left" + ddl_ext.selected
					leftbitmap = bitmap spn_frameWidth.value spn_frameHeight.value
					render camera:CamLeft outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:leftbitmap cancelled: &bCancelled
						
					windows.processPostedMessages()
					fName = fPath + edt_shotname.text  + "-" + fCount + "-" + "Right" + ddl_ext.selected
					rightbitmap = bitmap spn_frameWidth.value spn_frameHeight.value
					render camera:CamRight outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:rightbitmap  cancelled: &bCancelled 
					windows.processPostedMessages()
					
					--Combine images here
					finalbitmap = bitmap (spn_frameWidth.value * 2) spn_frameHeight.value filename: (fPath + edt_shotname.text + "-" + fCount + ddl_ext.selected)
					pasteBitmap leftbitmap finalbitmap [0, 0] [0,0]
					
					--SBS side by side
					pasteBitmap rightbitmap finalbitmap [0, 0] [spn_frameWidth.value,0]
					
					--TAB top and bottom
		-- 			pasteBitmap rightbitmap finalbitmap [0, 0] [0, spn_frameHeight.value]
		
					save finalbitmap
					
					count += 1
					slidertime +=1
					
				)
			)
			
			gc light:true
			
			if (not bCancelled) do
			(
				createVideoFromSequence()
			)
			
			count = 0
			bCancelled = false
			progBar.value = 0
		)
		on btn_output pressed do
		(
			ShellLaunch "explorer.exe" fPath
		)
		on btn_selectCtrl pressed do
		(
			select $CamController
		)
		on btn_selectMainCam pressed do 
		(
			select $Cam_Main
		)
		on spn_horizontalAxis changed value do
		(
			$CamController.position.controller.X_position = spn_horizontalAxis.value
		)
		on spn_verticalAxis changed value do
		(
			
			$CamController.position.controller.Z_position = spn_verticalAxis.value
		)
		on spn_pan changed value do 
		(
			$CamController.rotation.controller.Z_Rotation = spn_pan.value
		)
		on spn_frameWidth changed value do
		(
			renderWidth  = spn_frameWidth.value
			renderHeight  = ( spn_frameWidth.value * 9 / 16 )
			spn_frameHeight.value = renderHeight
		)
		
		on spn_frameHeight changed value do
		(
			renderHeight  = spn_frameHeight.value
			renderWidth  = ( spn_frameHeight.value * 16 / 9 )
			spn_frameWidth.value = renderWidth
		)
	)
	
	CreateDialog roStereoCam
)

