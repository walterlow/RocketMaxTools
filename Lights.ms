fn createMRSkyPortal =
(
rgbmul = 255
	
mrsp = mr_Sky_Portal light_Width:1.85 light_length:1.054 on:on pos:[0,0,0] isSelected:on
mrsp.rgbFilter = color (0.996*rgbmul) (1*rgbmul) (0.8*rgbmul)
mrsp.multiplier = 10
mrsp.castShadows = on
mrsp.shadow_samples = 4
mrsp.mode = 1
rotate $ (angleaxis 90 [0,0,1])
)

fn createMROmni =
(
	mrom = MiAreaLightomni pos:[0,0,0] isSelected:on
	mrom.castShadows = on 
	mrom.multiplier = 1
	mrom.rgb = color 254 255 204
	mrom.mr_EnableLightShader
	mrom.attenDecay = 3 	-- 3 = inverse square
	
	mrom.useNearAtten = true
	mrom.nearAttenStart = 0.08
	mrom.nearAttenEnd = 0.2
	
	mrom.useFarAtten = true
	mrom.farAttenStart = 0.33
	mrom.farAttenEnd = 4.396
)