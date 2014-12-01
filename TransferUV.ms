rollout ro_TransferUV "Transfer UV"
(
	
-- 	local target
-- 	local source

	fn ePoly obj = classof obj.baseObject == Editable_Poly

	pickbutton btn_source "Source" width:140 filter:ePoly
	spinner spn_sourcechn "uv chn: " range:[1,4,1] type:#integer scale:1
	
	pickbutton btn_target "Target" width:140 filter:ePoly
	spinner spn_targetchn "uv chn: " range:[1,4,1] type:#integer scale:1
	
	button btn_Transfer "Transfer!" tooltip: "Transfer UVW Channel 1 only."
	
	
	fn TransferUV = 
	(
	ChannelInfo.CopyChannel source 3 spn_sourcechn.value
	--modPanel.setCurrentObject target.baseObject ui:false
-- 	modPanel.setCurrentObject target.baseobject
	ChannelInfo.PasteChannel target 3 spn_targetchn.value
-- 	modPanel.setCurrentObject target.modifiers[#UVW_Mapping_Paste]
	--maxOps.CollapseNodeTo target 2 off
	)
	

-- 	modPanel.setCurrentObject $Terminator002.modifiers[#UVW_Mapping_Paste]
-- deleteModifier $Terminator002 1
-- maxOps.CollapseNodeTo $Terminator002 2 off

	on spn_sourcechn changed val do
	(
-- 		format "source uv chn: %\n" spn_sourcechn.value
	)
	
	
	--If the user picked an object, then
	on btn_source picked obj do
	(
		if obj != undefined do
		(
			btn_source.text = "Source: " + obj.name
			source = obj
		)
		
	)--end on
	
	on btn_target picked obj do
	(
		if obj != undefined do
		(
			btn_target.text =  "Target: " + obj.name
			target=obj
		)
	)--end on
	
	on btn_Transfer pressed do
	(
		TransferUV()
	)
	
	
	
)--end rollout
--createDialog ro_TransferUV