fn CenPivot = 
(
	
	if (selection.count != 0) then (
	
		for obj in selection do
		if obj.pivot != obj.center then (
		 obj.pivot = obj.center
		) 
		--else (
		 --obj.pivot = obj.center
		-- obj.pivot.z = obj.min.z
		--)

		if (subobjectlevel == 1) then
		(
			selected_vert = polyop.getVertSelection $ as array
				if (selected_vert.count == 1) then
				(
					selected_vert_pos = polyop.getVert $ selected_vert[1]
					$.pivot = selected_vert_pos
					subobjectlevel = 0
				) else (Messagebox "Select a vertex!")
		)
		if (subobjectlevel == 2) then
		(
			selected_edge = polyop.getEdgeSelection $
			selected_edge_verts = (polyop.getVertsUsingEdge $ selected_edge ) as array
			if (selected_edge_verts.count == 2) then
			(
				selected_edge_center = ( (polyop.getVert $ selected_edge_verts[1]) + (polyop.getVert $ selected_edge_verts[2]) ) / 2
				$.pivot = selected_edge_center
				subobjectlevel = 0
			) else (Messagebox "Select an edge!")
		)
		
	)
	redrawviews()
)