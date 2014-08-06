selected_vert = polyop.getVertSelection $ as array
selected_vert_pos = polyop.getVert $ selected_vert[1]
$.pivot = selected_vert_pos
