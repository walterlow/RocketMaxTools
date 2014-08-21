(
	
raw_mfn = maxfilename 
mfn = getfilenamefile maxfilename

working_path = "C:\\Projects\\Cow2\\Assets\\Screens\\working\\" 

filelist = getfiles( working_path + mfn + "\\" + "*_Backup_*.max" )

	
if filelist.count == 0 then
(
	--save first backup version
	print "save first backup version"
	filename = working_path + mfn + "\\" + mfn + "_Backup_" + "001"+ ".max"
	savemaxfile filename usenewfile: false
)
else
(
	print "proceed to backup version incrementally"
)

-- print filelist
versions = #()
	
for i=1 to filelist.count do
(
	filefilter = filterstring filelist[i] "_"
	ver = substring filefilter[3] (filefilter[3].count-6) 3
	append versions ver
)

sort versions
print "Latest version: " +  versions[versions.count]




-- filefilter = filterstring file "_"
-- ver = filefilter[2]
-- append filelist ver

-- append filelist ""
-- append filelist "006"
-- append filelist "003"

-- sort filelist

-- filelist[filelist.count]

)