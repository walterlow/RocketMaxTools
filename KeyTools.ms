showproperties $.position.controller


$.position.controller.x_position.keys


$.position.controller

--addNewKey $.position.controller 260f

total = numKeys $.position.controller

selkeys = selectKeys $.controller
moveKeys $.controller -62f #selection





/* for obj in selection do
(
	selkeys = selectKeys obj.controller
	moveKeys obj.controller -62f #selection
)
 */

$.position.controller = Path_Constraint()


selkeys = selectKeys $.controller
moveKeys $.controller -20 #selection

