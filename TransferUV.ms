rollout ro_TransferUV "Transfer UV"
(
	
	local target
	local source
	
	fn chickenFilter obj = classof obj.baseObject == Editable_Poly
		
	fn TransferUV = 
	(
	ChannelInfo.CopyChannel source 3 1
	--modPanel.setCurrentObject target.baseObject ui:false
	ChannelInfo.PasteChannel target 3 1
	)
	
	pickbutton btn_source "Source" width:140 filter:chickenFilter
	pickbutton btn_target "Target" width:140 filter:chickenFilter
	button btn_Transfer "Transfer!" tooltip: "Transfer UVW Channel 1 only."
	
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