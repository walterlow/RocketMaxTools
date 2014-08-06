fn DeleteEmptyObjects =
(
--delete (for obj in Geometry where classof obj == Editable_Poly and (getPolygonCount obj)[1] == 0 collect obj)
delete (for obj in Geometry where classof obj == Editable_Poly and polyop.getNumFaces obj == 0 collect obj)
)

