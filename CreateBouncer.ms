fn CreateBouncer =
(
	b
	themat
	if sceneMaterials["bouncer"] == undefined then
	(
		themat = StandardMaterial name:"bouncer" specularLevel:30 glossiness:10 diffusecolor: (color 50 50 50)
	)

	if ($Bouncer == undefined) then
	(
		b = Plane length:15 width:30 pos:[0,0,0] isSelected:on lengthsegs:1 widthsegs:1
		rotate b (angleaxis -90 [1,0,0])
		convertToPoly b
		b.name = "Bouncer"
		b.boxmode = on
		b.castShadows = off
		b.receiveshadows = off
		b.ApplyAtmospherics = off
		b.inheritVisibility = off
		b.primaryVisibility = off
		b.secondaryVisibility = off
		b.material = themat
		sendtoLayer b "Bouncer"
	)
	else
	(
		Messagebox("Bouncer exists!")
		select $Bouncer
		sendtoLayer $ "Bouncer"
	)

)