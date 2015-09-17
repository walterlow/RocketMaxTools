
scriptPath = GetDir #userScripts + "\\RocketMaxTools\\"

macroScript StereoCam category:"RocketBirds"
tooltip:"StereoCam"
(
	fileIn( scriptPath + "StereoCam.ms" )
)

macroScript RocketMaxTools category:"RocketBirds"
tooltip:"RocketMaxTools"
(
	fileIn( scriptPath + "RMT.ms" )
)

macroScript BakeTool category:"RocketBirds"
tooltip:"Bake Props Tool"
(
	fileIn( scriptPath + "BakeTool.ms" )
)

