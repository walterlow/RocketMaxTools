-- fn existFile fname = (getfiles fname).count != 0

-- if (existFile diffuseTex) do (print "File exist!") 

-- alphafx.TexDiffuse = openBitmap (final_path + decalTex)

fn SetBitmap fx texslot fname =
(
	if (getfiles fname).count != 0 then
	(
		fx .texslot = openBitmap (fname)
	)
	else
	(
		print fname + " does not exist!"
	)
)

SetBitmap alphafx final_path+decalTex