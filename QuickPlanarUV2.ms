fn QuickPlanarUV2 =
(
	if (selection.count == 1) then
	(
	modPanel.addModToSelection (Unwrap_UVW ()) ui:on
	$.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
	--$.modifiers[#unwrap_uvw].unwrap.edit ()
	--do not reset uv2 for our workflow.	
	polyCount = polyop.getNumFaces $;
	$.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..polyCount} $
	$.modifiers[#unwrap_uvw].unwrap5.quickPlanarMap ()
	ConvertToPoly $
	Messagebox($.name + " Planar mapped!")
	) else (Messagebox "Select 1 object")
)

fn ApplyUV2 = 
(
	if(selection.count != 0) then (
	modPanel.addModToSelection (Unwrap_UVW ()) ui:on
	for obj in selection do
	(
		obj.modifiers[#unwrap_uvw].unwrap.setMapChannel 2
		ConvertToPoly obj
	)
	Messagebox("Selected objects UV2 applied")
	)
	else(
		Messagebox("Select something!")
	)
)

