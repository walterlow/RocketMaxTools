fn DetachFace thename: (uniquename "detached") =
(
	if(subobjectlevel == 0 ) then ()
		else
		(
			selectedFaces = polyop.getFaceSelection $
			if (selectedFaces.isEmpty)then(messagebox("Please select some faces!"))
			else
			(	
				selectedFaces = polyop.getFaceSelection $
				polyop.detachFaces $ selectedFaces asNode:true name:thename
				--could also use #selection instead of selectedFaces
			)
		)
)