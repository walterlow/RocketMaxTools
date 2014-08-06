--$.weldThreshold = 0.001
--$.EditablePoly.weldFlaggedVertices ()

fn WeldVertices =
(
	for obj in selection do
	( 
			
			if (subobjectlevel == 0) then
			(
				undo on
				(
					obj.weldThreshold = 0.001 -- set weld threshold value
					allVerts = #{1..(polyop.getNumVerts obj)} -- get all verts list
					--print	("verts: " + allVerts.count as string)
					if (allVerts.count != 0) then
					(
						print ("Welded: " + allVerts.count as string  + " verts.")
						polyop.weldVertsByThreshold obj allVerts -- Weld
					)
				)
			)
			
			if (subobjectlevel == 1) then
			(
				undo on
				(
					$.weldThreshold = 0.001 -- set weld threshold value
					selVerts = $.selectedverts
					--print	("verts: " + selVerts.count as string)
					if (selVerts.count !=0 ) then
					(
					print ("Welded: " + selVerts.count as string + " verts.")
					$.EditablePoly.weldFlaggedVertices ()
					)
					else (messagebox("Select verts to weld!"))
				)
			) 
			
	)

)