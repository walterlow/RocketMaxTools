Rollout dial_doorHelper "Door Helper" width:200
(
	local w = 40
	group ""
	(
		button btn_selectsimilar "Select Similar" tooltip:"Select Similar elements"  width:100 height: 25 across:1
	)
	
	group "Exit_Breakable" (
	button btn_break "Breakables"  across:2 width:90 height: 25
	button btn_btoggle "Show/Hide" width:60 height: 25
	button btn_b0 "0" across:4 width:w
	button btn_b1 "1"  width:w
	button btn_b2 "2" width:w
	button btn_b3 "3" width:w
	button btn_b4 "4" across:4 width:w
	button btn_b5 "5"  width:w
	button btn_b6 "6" width: w
	button btn_b7 "7" width: w
	)
	
	group "Exit_Frame" (
	button btn_frame "Frames"  across:2 width:90 height: 25
	button btn_ftoggle "Show/Hide" width:60 height: 25
	button btn_f0 "0" across:4 width: w
	button btn_f1 "1"  width:w
	button btn_f2 "2"  width:w
	button btn_f3 "3" width:w
	button btn_f4 "4" across:4 width:w
	button btn_f5 "5" width:w
	button btn_f6 "6" width:w
	button btn_f7 "7" width:w
	)
	
	group "Exit_Hole" (
	button btn_hole "Holes"  across:2 width:90 height: 25
	button btn_htoggle "Show/Hide" width:60 height: 25
	button btn_h0 "0" across:4 width:w
	button btn_h1 "1" width:w
	button btn_h2 "2" width:w
	button btn_h3 "3" width:w
	button btn_h4 "4" across:4 width:w
	button btn_h5 "5" width:w
	button btn_h6 "6" width:w
	button btn_h7 "7" width:w
	)
	
	group "Exit_Wall" (
	button btn_wall "Walls"  across:2 width:90 height: 25
	button btn_wtoggle "Show/Hide" width:60 height: 25
	button btn_w0 "0" across:4 width:w
	button btn_w1 "1"  width:w
	button btn_w2 "2"  width:w
	button btn_w3 "3" width:w
	button btn_w4 "4" across:4 width:w
	button btn_w5 "5" width:w
	button btn_w6 "6" width:w
	button btn_w7 "7" width:w
	)
	
	on btn_selectsimilar pressed do	(selectsimilar()) --door helper
	on btn_break pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Breakable"; sendtoLayer (select($_Breakable*)) "Exit_Breakable"; HideLayer "Exit_Breakable";  select prevobj;) )
	on btn_frame pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Frame"; sendtoLayer (select($_Frame*)) "Exit_Frame"; HideLayer "Exit_Frame"; select prevobj;) )
	on btn_hole pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Hole"; sendtoLayer (select($_Hole*)) "Exit_Hole"; HideLayer "Exit_Hole"; select prevobj;) )
	on btn_wall pressed do( if selection.count != 0 then (prevobj= $; DetachFace thename:"_Wall"; sendtoLayer (select($_Wall*)) "Exit_Wall"; HideLayer "Exit_Wall"; select prevobj;) )
	
		
	on btn_btoggle pressed do ( ToggleLayer "Exit_Breakable" )
	on btn_b0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
	on btn_b7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Breakable"; sendtoLayer $ "Exit_Breakable") else selSomething() )
		
	on btn_ftoggle pressed do ( ToggleLayer "Exit_Frame" )
	on btn_f0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	on btn_f7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Frame"; sendtoLayer $ "Exit_Frame") else selSomething() )
	
	on btn_htoggle pressed do ( ToggleLayer "Exit_Hole" )
	on btn_h0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	on btn_h7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Hole"; sendtoLayer $ "Exit_Hole") else selSomething() )
	
	on btn_wtoggle pressed do ( ToggleLayer "Exit_Wall" )
	on btn_w0 pressed do( if selection.count != 0 then (DetachFace thename:"Exit0_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w1 pressed do( if selection.count != 0 then (DetachFace thename:"Exit1_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w2 pressed do( if selection.count != 0 then (DetachFace thename:"Exit2_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w3 pressed do( if selection.count != 0 then (DetachFace thename:"Exit3_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w4 pressed do( if selection.count != 0 then (DetachFace thename:"Exit4_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w5 pressed do( if selection.count != 0 then (DetachFace thename:"Exit5_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w6 pressed do( if selection.count != 0 then (DetachFace thename:"Exit6_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	on btn_w7 pressed do( if selection.count != 0 then (DetachFace thename:"Exit7_Wall"; sendtoLayer $ "Exit_Wall") else selSomething() )
	)