fn AutoDoors =
(
	p5 = "E*_Breakable"
	p6 = "E*_Frame"
	p7 = "E*_Hole"
	p8 = "E*_Wall"
	
	p1 = "*_Breakable???*"
	p2 = "*_Frame???*"
	p3 = "*_Hole???*"
	p4 = "*_Wall???*"
	
	
	with redraw off(
		for obj in objects do 
		(
			if (matchPattern obj.name pattern: p1 or matchPattern obj.name pattern: p5) do
			(
				format "Matched Pattern: % or % --> % \n" p1 p5 obj.name 
				select obj
				sendtoLayer obj "Exit_Breakable"
			)
			
			if (matchPattern obj.name pattern: p2 or matchPattern obj.name pattern: p6) do
			(
				format "Matched Pattern: % or % --> % \n" p2 p6 obj.name 
				select obj
				sendtoLayer obj "Exit_Frame"
			)
			
			if (matchPattern obj.name pattern: p3 or matchPattern obj.name pattern: p7) do
			(
				format "Matched Pattern: % or % --> % \n" p3 p7 obj.name 
				select obj
				sendtoLayer obj "Exit_Hole"
			)
			
			if (matchPattern obj.name pattern: p4 or matchPattern obj.name pattern: p8) do
			(
				format "Matched Pattern: % or % --> % \n" p4 p8 obj.name 
				select obj
				sendtoLayer obj "Exit_Wall"
			)
			
		)
	)
)