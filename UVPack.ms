fn UVPack =
(
	if (selection.count == 1) then
	(
		if querybox "This will pack and overide UV Chn2. Continue?" beep:true then
		(
			modPanel.addModToSelection (UV_Packer ()) ui:on
			$.modifiers[#UV_Packer].channel = 2
			$.modifiers[#UV_Packer].padding = 8
			$.modifiers[#UV_Packer].width = 2048
			$.modifiers[#UV_Packer].height = 2048
			$.modifiers[#UV_Packer].aspect = 1
			$.modifiers[#UV_Packer].pack()
		)
		else
		(
			Messagebox ("Packing cancelled")
		)
	) else
	(
		Messagebox ("Select 1 object only.")
	)

)