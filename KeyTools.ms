rollout ro_animHelper "Anim Helper" width:232 height:488
(
	global originalEndRange = animationrange.end
	global pc

	groupBox grp1 "Add Path:" pos:[8,8] width:216 height:264
	button btn_assignPC "Assign Path Constraint" pos:[16,32] width:200 height:24
	button btn_delPC "Remove Path Constraint" pos:[16,64] width:200 height:24
	listBox path_list "Select Path to follow:" pos:[16,104] width:200 height:8 items: (for o in objects where superclassof o == shape collect o.name)
	button btn_assignPath "Add Path" pos:[16,240] width:56 height:24
	button btn_deletePath "Delete Path" pos:[80,240] width:64 height:24
	button btn_refresh "Refresh" pos:[152,240] width:64 height:24
	
	groupBox grp2 "Bake It:" pos:[8,280] width:216 height:88
	button btn_BakeKeys "Bake Keys" pos:[144,296] width:72 height:40
	spinner spn_step "Step:" pos:[48,304] width:80 height:16 range:[0,9999,25] type:#integer scale:1
	
	groupBox grp3 "Duplicate" pos:[8,376] width:216 height:56
	spinner spn_copies "Copies" pos:[30,400] width:64 height:16 range:[0,9999,1] type:#integer scale:1
	button btn_offSet "Offset Animation!" pos:[96,392] width:120 height:32
	button btn_reset "UNDO" pos:[8,440] width:80 height:32
	button btn_deleteKeys "Delete All Keys" pos:[96,440] width:128 height:32
	editText edt_fend "End Frame:" pos:[16,344] width:112 height:16 text: "500" 
	button btn_go "Set" pos:[144,344] width:72 height:20
	
	--functions
	
	on btn_assignPC pressed do
	(
		pc = Path_Constraint()
		if selection.count > 0 do
		(
		$.position.controller = pc
		)
		max motion mode
	)
	
	on btn_delPC pressed do
	(
		
		for o in selection do
		(
			o.pos.controller = Position_XYZ ()
		)			
	)
	
	on btn_assignPath pressed do
	(
		if  getnodebyname (path_list.selected) !=undefined then
		(
			pc.path = getnodebyname (path_list.selected)
		)
		else (messageBox "Path not found. Please refresh")
	)
	
	on btn_deletePath pressed do
	(
		pc.deleteTarget 1
	)
	
	on btn_refresh pressed do
	(
		for i = path_list.items.count to 1 by -1 do
		(
			path_list.items = deleteItem path_list.items i
		)
		
		a = for o in objects where superclassof o == shape collect o.name
		path_list.items = (for o in objects where superclassof o == shape collect o.name)
	)
---------------------------------------------------------------------------------------------
	
	on btn_BakeKeys pressed do
	(
		undo on 
		(
		TempPoint = point()
		step = spn_step.value
		for i=animationrange.start to i=animationrange.end by step do
			(
				with animate on 
				at time i
				TempPoint.transform = $.Transform
			)
			$.Transform.Controller = TempPoint.Transform.Controller
			delete TempPoint	
		)
	)
	
	on btn_go pressed do
	(
		animationrange = interval 0 (edt_fend.text as integer)
		originalEndRange = (edt_fend.text as integer)
	)

	
	fn createCopies =
	(
		fstart = animationrange.start
		fend = animationrange.end
		originalEndRange = fend
		copies = spn_copies.value
		
		max motion mode
		suspendEditing which:#motion
		
		undo "copyanim" on
		(
			for i = 1 to copies-1 do
			(
				
				maxOps.cloneNodes selection cloneType:#copy newNodes:&objs
				select objs
				for i = 1 to objs.count do
				(
					selkeys = selectKeys objs[i].controller
					moveKeys objs[i].controller -(fend/copies) #selection
					--objs[i].controller.keys.time -= (fend/copies) 
					--deselectKeys nnl[i].controller
				)
				
			)
			animationRange = interval 0 (fend/copies)
		) --end undo
		
		resumeEditing which:#motion
	) --end fn block
	


	on spn_copies.value changed do (copies = spn_copies.value)
	
	on btn_offSet pressed do (createCopies())
	
	on btn_reset pressed do
	( 
	
		max motion mode
		suspendEditing which:#motion
		max undo
		animationRange = interval 0 (originalEndRange)
		resumeEditing which:#motion
	)
	
	on btn_deleteKeys pressed do
	(
		undo on
		(
		sliderTime = 0f
		userSel = getCurrentSelection ()
		deleteKeys userSel #allKeys
		)
	)
	
) --end rollout
