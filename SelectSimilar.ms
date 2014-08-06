fn SelectSimilar =
(
	if selection.count !=0 then (
	
	FindBySimilarSize = true
	FindBySimilarRatio = true
	SimilarityTolerance = 0.005 -- higher tolerance selects more objects which are not quite so similar. must be less than 1.
	FindByMatchingFaceCount = true
	FindByInstances = true
	FindByMaxSelectSimilar = false -- false by defualt because this gets lots of stuff which isnt necessarily similar.
	FindByWireColor = false -- false by default since this may find lots of stuff
	DoNotSelectHidden = true

	(
	 obj = selection[1]
	 if subobjectlevel == 4 or subobjectlevel == 5 then
	 (
	  print "select matching elements"
	  selectedfaces = polyop.getFaceSelection obj
	  facecount = selectedfaces.numberset
	  allfaces = obj.faces
	  newselection = polyop.getFaceSelection obj
	  discardedfaces = #{}
	  
	  for face in allfaces do (
	   if (newselection[face.index] == false and discardedfaces[face.index] == false) then 
	   (
		-- we havent seen this face before.
		thiselement = polyop.getElementsUsingFace obj face
		if thiselement.numberset == facecount then (
		 --print "found a matching element"
		 join newselection thiselement
		) else (
		 join discardedfaces thiselement
		)
	   )
	  )
	  
	  polyop.setfaceselection obj newselection
	  redrawviews()
	 )
	 else
	 (
	  matchingobjs = #()
	  append matchingobjs obj
	  print "select matching objects"
	  if superclassof(obj) == GeometryClass and classof(obj) != Biped_Object then
	  (
	   --find geometry with matching bounding size OR face count
	   
	   if FindBySimilarSize or FindBySimilarRatio then (
		 originalrotation = obj.rotation
		 originalposition = obj.position
		 obj.rotation = (quat 0 0 0 0)

		XDimension = (obj.max.x - obj.min.x)
		YDimension = (obj.max.y - obj.min.y)
		ZDimension = (obj.max.z - obj.min.z)
		
		XZRatio = XDimension / ZDimension
		YZRatio = YDimension / ZDimension
		
		obj.rotation = originalrotation
		obj.position = originalposition
		
		max modify mode
		
		for checkobj in geometry do (
		 originalrotation = checkobj.rotation
		 originalposition = checkobj.position
		 checkobj.rotation = (quat 0 0 0 0)
		 
		 if FindBySimilarSize then
		 (
		  if XDimension > ((checkobj.max.x - checkobj.min.x) * (1.0 - SimilarityTolerance)) and XDimension < ((checkobj.max.x - checkobj.min.x) * (1 / (1.0 - SimilarityTolerance))) and
		   YDimension > ((checkobj.max.y - checkobj.min.y) * (1.0 - SimilarityTolerance)) and YDimension < ((checkobj.max.y - checkobj.min.y) * (1 / (1.0 - SimilarityTolerance))) and
		   ZDimension > ((checkobj.max.z - checkobj.min.z) * (1.0 - SimilarityTolerance)) and ZDimension < ((checkobj.max.z - checkobj.min.z) * (1 / (1.0 - SimilarityTolerance)))  then
		  ( 
		   print (checkobj.name + " is a similarsize match")
		   appendIfUnique matchingobjs checkobj
		  )
		 )
		 
		 if FindBySimilarRatio then 
		 (
		  checkXZRatio = (checkobj.max.x - checkobj.min.x) / (checkobj.max.z - checkobj.min.z)
		  checkYZRatio = (checkobj.max.y - checkobj.min.y) / (checkobj.max.z - checkobj.min.z)
		  
		  if XZRatio > (checkXZRatio * (1.0 - SimilarityTolerance)) and XZRatio < (checkXZRatio * (1 / (1.0 - SimilarityTolerance))) and
		   YZRatio > (checkYZRatio * (1.0 - SimilarityTolerance)) and YZRatio < (checkYZRatio * (1 / (1.0 - SimilarityTolerance))) then
		  ( 
		   print (checkobj.name + " is a similarratio match")
		   appendIfUnique matchingobjs checkobj
		  )
		 )
		 
		 
		 checkobj.rotation = originalrotation
		 checkobj.position = originalposition
		)
	   )
	   

	   if FindByMatchingFaceCount and ((classof obj) == editable_poly or (classof obj) == editable_mesh) then
	   (
		for eachobj in geometry do
		(
		 if classof eachobj == editable_poly or classof eachobj == editable_mesh then
		 (
		  if obj.faces.count == eachobj.faces.count then
		  (
			appendIfUnique matchingobjs eachobj
		  )
		 )
		)
	   )
	   
	   if FindByWireColor then
	   (
		for eachobj in geometry do
		(
		 if eachobj.wirecolor == obj.wirecolor then
		 (
		  appendIfUnique matchingobjs eachobj
		 )
		)
	   )
	   
	  )
	  else
	  (
	   --select all objects matching class
	   for eachobj in $* do 
	   (
		if classof eachobj == classof(obj) then
		(
		 appendIfUnique matchingobjs eachobj
		)
	   )
	  )
	  
	  clearselection()
	  
	  if FindByMaxSelectSimilar then
	  (
	   actionMan.executeAction 0 "40099"  -- Selection: Select Similar
	  )

	  if FindByInstances then
	  (
	   InstanceMgr.GetInstances obj &instances
	   selectmore instances
	  )
	  
	  selectmore matchingobjs
	  
	  
	  if DoNotSelectHidden == true then
	  (
	   currentselection = getcurrentselection()
	   clearselection()
	   for eachobj in currentselection do
	   (
		if eachobj.ishidden == false then (selectmore eachobj)
	   )
	  )
	  
	 )
	)
	
)
) --end fn selectsimilar