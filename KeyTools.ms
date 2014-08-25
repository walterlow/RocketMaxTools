-- try(destroyDialog ro_animHelper) catch();

global originalEndRange

rollout ro_animHelper "Anim Helper"
(
	
	group ""
	(
		button btn_assignPC "Assign Path Constraint"
	)
	
	group ""
	(
		spinner spn_copies "Copies: " range:[1,99,1] type:#integer align:#left
		button btn_offSet "Offset Animation!" align:#left
		button btn_reset "Undo" align:#left width:120
		edittext edt_fend "End Frame:" text: "500" align:#left width:120
		button btn_go "Set" width:120 align:#left
		
		on btn_go pressed do
		(
			animationrange = interval 0 (edt_fend.text as integer)
			originalEndRange = (edt_fend.text as integer)
		)
	)
	
	group ""
	(
		button btn_deleteKeys "Delete All Keys"
		
		on btn_deleteKeys pressed do
		(
			undo on
			(
			sliderTime = 0f
			userSel = getCurrentSelection ()
			deleteKeys userSel #allKeys
			)
		)
	)
	
	fn createCopies =
	(
		fstart = animationrange.start
		fend = animationrange.end
		originalEndRange = fend
		copies = spn_copies.value
		
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
	) --end fn block
	
	on btn_assignPC pressed do
	(
		pc = Path_Constraint()
		$.position.controller = pc
		max motion mode
	)

	on spn_copies.value changed do (
		copies = spn_copies.value
	)
	on btn_offSet pressed do ( createCopies() )
	on btn_reset pressed do
	( 
		max undo
		animationRange = interval 0 (originalEndRange)
	)
	
)--rollout

-- createDialog ro_animHelper