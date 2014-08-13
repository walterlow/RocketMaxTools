
fn SetupMR =
(
	--FG BASICS
	--mr = renderers.current = mental_ray_renderer()
	mr.FinalGatherEnable2 = true 
	mr.FinalGatherDensity = 0.3
	mr.FinalGatherAccuracy = 1100
	mr.FinalGatherBounces = 4
	
	--FG INTERPOLATION
	mr.FinalGatherUseRadiusInterpolation = true
	mr.FinalGatherView = false
	mr.UseFinalGatherRadius = true
	mr.UseFinalGatherMinRadius = true
	mr.FinalGatherRadius = 32
	mr.FinalGatherMinRadius = 3.3
	
	mr.MaximumReflections = 1
	mr.MaximumRefractions = 1
	
	MessageBox("MentalRay FG Settings Loaded")
)