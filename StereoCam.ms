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
		if $Cam_Main != undefined then
		(
			if queryBox "Stereo Cameras exists in the current scene!\n Do you want to replace them?"  title:"Warning!" then 
			(
				try(
					delete $Cam_StereoLeft
					delete $Cam_StereoRight
					delete $Cam_Main
				) catch()
				
				
				local targetDist = 10
		
				mainCam = Freecamera name:"Cam_Main" wirecolor: white
				mainCam.orthoProjection = true
				mainCam.rotation = (angleaxis 90 [1,0,0])
				mainCam.position = [0, -targetDist, 5]
				mainCam.baseObject.targetDistance = targetDist
				mainCam.fov = GetFOVFromLens 35

				--Create 2 cameras with offset from main cam
				::CreateLeftRightCams mainCam

				roStereoCam.UpdateSpinners()
			)
		)
		
		
	)
	

	fn CreateLeftRightCams mainCam =
	(
		camDist = roStereoCam.spn_camDist.value
		
		--local axis
		camLeft = instance mainCam name:"Cam_StereoLeft" wirecolor: red
		in coordsys local (camLeft.position.x -= camDist)
		camRight = instance mainCam name:"Cam_StereoRight" wirecolor: blue
		in coordsys local (camRight.position.x += camDist)
		
		::LinkChildToParent camLeft mainCam
		::LinkChildToParent camRight mainCam
		
	)
	
	fn LinkChildToParent child parent =
	(
		child.parent = parent
	)
	
	fn createVideoFromSequence =
	(
		QTPathOut = fPath + roStereoCam.edt_shotname.text + ".avi"
		entstring = "-y -i " + fPath + roStereoCam.edt_shotname.text + "-%4d" + roStereoCam.ddl_ext.selected + " -vcodec huffyuv -r 30 " + QTPathOut

		shellLaunch ffmpeg entstring
	)
	
	fn CreateFolder fPath =
	(
		if (not (doesfileExist fPath) ) then ( MAKEDir fPath)
		return fPath
	)
	

	rollout roStereoCam "Stereo Cam Tool" width:236 height:450
	(
		--local vars
		
		
		GroupBox grp1 "Setup Cam" pos:[4,0] width:224 height:100		
		
		spinner spn_frameWidth "Frame Width:" pos:[28,52] width:139 height:16 range:[640, 7680 , 1280] type:#integer
		spinner spn_frameHeight "Frame Height:" pos:[28,72] width:139 height:16 range:[360 , 4320, 720] type:#integer
		
		button btn_createCam "Create Cameras" pos:[16,20] width:91 height:24


		GroupBox grp2 "Cam Controls" pos:[4,112] width:224 height:160
		spinner spn_camDist "Cam Distance:" pos:[32,136] width:100 height:16 range:[0.01,10,0.1] fieldwidth:40
		checkBox chkbox_ortho "Ortho" pos:[150,136]
		
		edittext edt_shotname "Shot Name:" pos:[12,280] width:148 height:17
		dropdownlist ddl_ext pos:[170,278] width:50 items:#(".jpg", ".bmp", ".png") selection:3
		
		
		radiobuttons rad_frame "Time output:" labels:#("Single", "Range") pos:[12,298] columns:2
		spinner spn_rendStart "Start" pos:[12,334] fieldWidth: 40 type:#integer range:[0,99999,animationRange.start]
		spinner spn_rendEnd "End" pos:[100,334] fieldWidth: 40  type:#integer range:[0,99999,animationRange.end]
		
		
		checkbox chkbox_NR "Net Render" pos:[12,354] checked:false toolTip:"Enable Distributed Rendering."
		button btn_editHost "Edit Hosts" pos:[95, 354] height:20
		
		button btn_render "Render" pos:[15,378] width:72 height:32
		button btn_output "Output Folder" pos:[95,378] width:78 height:32
		
		progressBar progBar "" pos:[15,414] width:200 height:16 

		button btn_selectMainCam "Select MainCam" pos:[10,160] width:85 height:21
		button btn_setupViews "Setup Views" pos:[100,160] width:76 height:21
		button btn_resetViews "Reset" pos:[180,160] width:40 height:21
		
		spinner spn_FOV "FOV:" pos:[44,190] width:96 height:16 range:[1,1000, GetFOVFromLens 35]
		spinner spn_horizontalAxis "Horizontal:" pos:[34,212] width:139 height:16 range:[-1000,1000,0]
		spinner spn_verticalAxis "Vertical:" pos:[34,232] width:139 height:16 range:[-1000,1000,0]
		spinner spn_pan "Pan:" pos:[34,252] width:139 height:16 range:[-1000,1000,0]

		fn UpdateSpinners =
		(
				spn_FOV.value 							= $Cam_Main.fov
				spn_horizontalAxis.controller 	= $Cam_Main.position.controller.X_Position.controller
				spn_verticalAxis.controller 		= $Cam_Main.position.controller.Z_Position.controller
				spn_pan.controller 					= $Cam_Main.rotation.controller.Z_Rotation.controller
		)
		

		on roStereoCam open do 
		(
			try
			(
				UpdateSpinners()
				chkbox_NR.state = renderers.current.DistributedEnable
				
			) catch()
			
			edt_shotname.text = getFilenameFile maxfilename
			chkbox_ortho.state = $Cam_Main.orthoProjection
			
			rad_frame.state = 2
			
			print mainCam
		)
		
		on btn_createCam pressed do
		(
			createMainCam()
		)

		on spn_camDist changed value do
		(
			$Cam_StereoLeft.pos.x = $Cam_Main.pos.x - spn_camDist.value
			$Cam_StereoRight.pos.x = $Cam_Main.pos.x + spn_camDist.value
		)
		
		on spn_FOV changed value do
		(

			$Cam_Main.fov = spn_FOV.value
			$cam_StereoLeft.fov = spn_FOV.value
			$cam_StereoRight.fov = spn_FOV.value
			
		)
		
		on rad_frame changed state do
		(
			if state == 1 then
			(
				spn_rendStart.enabled = false
				spn_rendEnd.enabled = false
			)
			else
			(
				spn_rendStart.enabled = true
				spn_rendEnd.enabled = true
			)
		)
		
		on spn_rendStart changed value do 
		(
			animationRange.start = value
			
		)
		
		
		on spn_rendEnd changed value do 
		(
			animationRange.end = value
			
		)

		
		on btn_setupViews pressed do 
		(
			viewport.SetLayout #layout_3ht
			
			viewport.activeViewport = 1
			viewport.setCamera $Cam_StereoLeft
			viewport.SetRenderLevel #smoothhighlights 

			viewport.activeViewport = 2
			viewport.setCamera $Cam_StereoRight
			viewport.SetRenderLevel #smoothhighlights 
			
			viewport.activeViewport = 3
			viewport.setType #view_persp_user
			viewport.SetRenderLevel #smoothhighlights 
			
			redrawViews()
		)
		
		on btn_resetViews pressed do 
		(
			viewport.ResetAllViews() 
		)
		
		on btn_render pressed do
		(
			totalStart = timeStamp()
			fPath = maxFilePath + "render\\"
			camLeft = $Cam_StereoLeft
			camRight = $Cam_StereoRight 
			bCancelled = false
			
			CreateFolder fPath
			
			if rad_frame.state == 2 then
			(

				count = spn_rendStart.value	
				slidertime = spn_rendStart.value	
				fstart = spn_rendStart.value				
				fend = spn_rendEnd.value
				
				for i = fstart to fend do 
				(
					
					if (not bCancelled) do
					(
						progBar.value = 100.0 * i/fend
						progBar.color = green
						
						fCount = formattedprint (count as integer) format: ".4d"
						fName = fPath + edt_shotname.text  + "-Left-"  + fCount + ddl_ext.selected
						leftbitmap = bitmap spn_frameWidth.value spn_frameHeight.value filename:fName
						start = timeStamp()
						render camera:CamLeft outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:leftbitmap cancelled: &bCancelled progressbar:true
						end = timeStamp()
						format "Last rendered frame took % seconds\n" ((end - start) / 1000.0)
						save leftbitmap
						
						fName = fPath + edt_shotname.text  + "-Right-" + fCount + ddl_ext.selected
						rightbitmap = bitmap spn_frameWidth.value spn_frameHeight.value filename:fName
						start = timeStamp()
						render camera:CamRight outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:rightbitmap  cancelled: &bCancelled progressbar:true
						end = timeStamp()
						format "Last rendered frame took % seconds\n" ((end - start) / 1000.0)
						save rightbitmap
						
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
				

			)
			else
			(
				count = sliderTime

				
				fCount = formattedprint (count.frame as integer) format: ".4d"
				fName = fPath + edt_shotname.text  + "-Left-"  + fCount + ddl_ext.selected
				leftbitmap = bitmap spn_frameWidth.value spn_frameHeight.value filename:fName
				start = timeStamp()
				render camera:CamLeft outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:leftbitmap cancelled: &bCancelled progressbar:true
				end = timeStamp()
				format "Last rendered frame took % seconds\n" ((end - start) / 1000.0)
				save leftbitmap
				
				fName = fPath + edt_shotname.text  + "-Right-" + fCount + ddl_ext.selected
				rightbitmap = bitmap spn_frameWidth.value spn_frameHeight.value filename:fName
				start = timeStamp()
				render camera:CamRight outputwidth:spn_frameWidth.value outputheight:spn_frameHeight.value  vfb:false to:rightbitmap  cancelled: &bCancelled progressbar:true
				end = timeStamp()
				format "Last rendered frame took % seconds\n" ((end - start) / 1000.0)
				save rightbitmap
				
				--Combine images here
				finalbitmap = bitmap (spn_frameWidth.value * 2) spn_frameHeight.value filename: (fPath + edt_shotname.text + "-" + fCount + ddl_ext.selected)
				pasteBitmap leftbitmap finalbitmap [0, 0] [0,0]
				
				--SBS side by side
				pasteBitmap rightbitmap finalbitmap [0, 0] [spn_frameWidth.value,0]
				
				--TAB top and bottom
	-- 			pasteBitmap rightbitmap finalbitmap [0, 0] [0, spn_frameHeight.value]
	
				save finalbitmap
				
			)


			
			gc light:true
			
			if (not bCancelled) do
			(
				--createVideoFromSequence()
			)
			
			bCancelled = false
			progBar.value = 0
			totalEnd = timeStamp()
			
			format "Total Render Process took: % mins\n" ((totalEnd-totalStart)/1000/60)
		)
		
		on btn_output pressed do
		(
			fPath = maxFilePath + "render\\"
			ShellLaunch "explorer.exe" (CreateFolder fPath)
		)
		on btn_selectCtrl pressed do
		(
			select $CamController
		)
		on btn_selectMainCam pressed do 
		(
			select $Cam_Main
		)
		
		on chkbox_NR changed state do
		(
			if classof renderers.current != mental_ray_renderer do 
			(
				renderers.current = mental_ray_renderer()
			)
			
			renderers.current.DistributedEnable = state;
			format "Net Render %\n" state
		)
		
		on chkbox_ortho changed state do 
		(
			SuspendEditing which:#modify
			 $Cam_main.orthoprojection = state
			resumeEditing which:#modify
		)
		
		on btn_editHost pressed do 
		(
			HiddenDOSCommand "notepad C:\Program Files\Autodesk\3ds Max 2011\mentalimages\max.rayhosts" 
		)
		
		on spn_horizontalAxis changed value do
		(
			$Cam_Main.position.controller.X_position = spn_horizontalAxis.value
		)
		on spn_verticalAxis changed value do
		(
			
			$Cam_Main.position.controller.Z_position = spn_verticalAxis.value
		)
		on spn_pan changed value do 
		(
			
			$Cam_Main.rotation.controller.Z_Rotation = spn_pan.value
			
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

