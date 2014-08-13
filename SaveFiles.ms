
fn saveCurrentFinal =
(
	--checkForSave()
	--getFilenameType maxFileName 

	
		if querybox "Save current working file AND a copy in \Assets\Screens. Proceed?" beep:true then
		(
			
			
		--	if (not (doesfileExist working_path) )then(
				--MAKEDir working_path
			--)
			--"C:\Projects\Cow2\Assets\Screens\working\\" 
			work_path = ( working_path + (getFilenameFile maxFileName) + "\\" + maxFileName  ) --current
			screens_path = ( final_path + maxFileName ) --final
			savemaxFile screens_path useNewFile:false
			savemaxFile work_path 
		)
	
	
	
)