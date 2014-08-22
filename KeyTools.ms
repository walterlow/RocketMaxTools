showproperties $.position.controller


$.position.controller.x_position.keys


$.position.controller

--addNewKey $.position.controller 260f

total = numKeys $.position.controller

selkeys = selectKeys $.controller
moveKeys $.controller -62f #selection


maxOps.cloneNodes $ cloneType:#copy newNodes:&nnl
select nnl
for i = 1 to nnl.count do
(
	selkeys = selectKeys nnl[i].controller
	moveKeys nnl[i].controller -62.5 #selection
	--deselectKeys nnl[i].controller
)

-- for obj in selection do
-- (
-- 	selkeys = selectKeys obj.controller
-- 	moveKeys obj.controller -62f #selection
-- )