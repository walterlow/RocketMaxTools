(
	global GW_displayText
	unregisterRedrawViewsCallback GW_displayText
	callbacks.removeScripts id:#ViewSwtcd
	fn GW_displayText =
	(
		--wPos = 40 -- horizontal position max = gw.getWinSizeX() 0 is left
		--hPos = 40 -- vertical position max = gw.getWinSizeY() . 0 is lower left
		--gw.htext [wPos,hPos,0] "Potatoes" color:green
		--gw.updateScreen() 
		
		if selection.count == 1 do
		(
				gw.text [selection[1].pivot.x, selection[1].pivot.y, selection[1].pivot.z] (selection[1].material as string) color:green
		)
	
		if selection.count > 1 do
		(
			for obj in selection where superclassof obj == GeometryClass do
			(
				gw.text [obj.pivot.x, obj.pivot.y, obj.pivot.z] (obj.material as string) color:green
			)
		)
		
/* 		if selection.count == 0 do
		(
			for obj in geometry do
			(
				gw.text [obj.pivot.x,obj.pivot.y,obj.pivot.z] (obj.material as string) color:green
			)
		) */

		gw.updateScreen() 
	)
	registerRedrawViewsCallback GW_displayText
	
	global before_av= viewport.activeViewport
	global viewport_switch_trigger
	fn viewport_switch_trigger= 
	(
		current_av=viewport.activeViewport
		if before_av != current_av then 
			unregisterRedrawViewsCallback GW_displayText
		else
			registerRedrawViewsCallback GW_displayText
	)

	callbacks.addScript #viewportChange "viewport_switch_trigger()" id:#ViewSwtcd
)

-- callbacks.show()

