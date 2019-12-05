
module gridify(width, height, percentage, line_width) {
    for(a = [0:1.75/percentage*line_width:width-line_width])
        translate([a,0])resize([line_width, height]) square(1);
    translate([width-line_width,0])resize([line_width,height]) square(1);

    for(a = [0:1.75/percentage*line_width:height-line_width])
        translate([0,a])resize([width, line_width]) square(1);
    translate([0,height-line_width])resize([width,line_width]) square(1);
}

// module create_tile(w_h, base_thickness, fill_percentage=1, g_line_width)
// w_h - vector of [width, height]
// base_thickness - how thick the base should be
// fill_percentage - fill percentage of the base grid (1 for no grid)
module create_tile(w_h, base_thickness, fill_percentage=1, g_line_width=1) {
    width = w_h[0];
    height = w_h[1];
    intersection() {
        linear_extrude(base_thickness) {
            resize([width, height])square(10);
        }
        if(fill_percentage < 1) {
            linear_extrude(base_thickness+1) {
                gridify(width, height, fill_percentage, g_line_width);
            }
        }
    }
}

// module create_wall(w_h, wall_height, w_thickness)
// w_h - vector of [width, height]
// wall_height - how tall the walls should be
// w_thickness - thickness of the walls
module create_wall(w_h, wall_height, w_thickness) {
    width = w_h[0];
    height = w_h[1];
    linear_extrude(wall_height) {
        difference() {
            translate([-w_thickness,-w_thickness])resize([width+w_thickness*2, height+w_thickness*2])square(1);
            resize([width, height])square(1);
        }
    }
}

