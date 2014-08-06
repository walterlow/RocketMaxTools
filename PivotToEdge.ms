selected_edge = polyop.getEdgeSelection $
selected_edge_verts = (polyop.getVertsUsingEdge $ selected_edge ) as array
selected_edge_center = ( (polyop.getVert $ selected_edge_verts[1]) + (polyop.getVert $ selected_edge_verts[2]) ) / 2
$.pivot = selected_edge_center
