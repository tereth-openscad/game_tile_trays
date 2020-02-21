

module create_hole_border(is_vert, size, line_width, w_thickness) {
    difference() {
        create_single_hole(is_vert, size, w_thickness);
        translate([0,0,-.1])create_single_hole(is_vert, size-line_width, w_thickness);
    }
}

module create_single_hole(is_vert, size, w_thickness) {
    rotate(is_vert ? 0 : 90) {
        translate([w_thickness/2,0]) {
            hull() {
                translate([-w_thickness,0]) {
                    circle(size/2);
                }
                circle(size/2);
            }
        }
    }
}

module create_holes(hole_vector, z, w_thickness, size_mod=0) {
    linear_extrude(z) {
        for(i = hole_vector) {
            translate(i[0]) {
                is_vert = i[1];
                create_single_hole(is_vert, i[2]-size_mod, w_thickness);
            }
        }
    }
}

module create_hole_borders(hole_vector, z, hole_border) {
    linear_extrude(z) {
        for(i = hole_vector) {
            translate(i[0]) {
                is_vert = i[1];
                create_hole_border(is_vert, i[2], hole_border);
            }
        }
    }
}

