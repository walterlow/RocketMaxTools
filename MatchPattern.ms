fn AutoDoors =
(
	p1 = "Exit*_Breakable"
	p2 = "Exit*_Frame"
	p3 = "Exit*_Hole"
	p4 = "Exit*_Wall"

	for obj in objects do 
	(

		
		if matchPattern obj.name pattern: p1 do
		(
			print obj.name
			sendtoLayer obj "Exit_Breakable"
		)
		
	)
)