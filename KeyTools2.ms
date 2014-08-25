try(destroyDialog ro_animHelper) catch();

rollout ro_animHelper "Anim Helper"
(
	group ""
	(
	button btn_assignPC "Assign Path Constraint"
	spinner spn_copies "Copies: " range:[1,99,1] type:#integer 
	button btn_offSet "Offset Animation!"
	button btn_reset "undo"
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

createDialog ro_animHelper