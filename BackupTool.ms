fn Backup =
(
	
	raw_mfn = maxfilename 
	mfn = getfilenamefile maxfilename

	working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 

	fList = getfiles( working_path + mfn + "\\" + "*_Backup_*.max" )
	fCount = 0

		
	if fList.count == 0 then
	(
		fCount += 1
		fVer = formattedprint fCount format: ".3d"
		fOut = working_path + mfn + "\\" + mfn + "_Backup_" + fVer+ ".max"
		savemaxfile fOut usenewfile:false
		print ("Saved: " + fOut)
	)
	else
	(
		-- print fList
		a = #()
			
		for i=1 to fList.count do
		(
			fFilter = filterstring fList[i] "_"
			ver = substring fFilter[3] (fFilter[3].count-6) 3
			append a ver
		)
		
		sort a
		fCount = a[a.count] as integer
		
		fCount += 1
		fVer = formattedprint fCount format: ".3d"
		
		fOut = working_path + mfn + "\\" + mfn + "_Backup_" + fVer+ ".max"
		savemaxfile fOut usenewfile: false
		print ("Saved: " + fOut)
	)

)