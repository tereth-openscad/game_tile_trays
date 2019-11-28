
module gridify(width, height, percentage, line_width) {
    for(a = [0:1.75/percentage*line_width:width-line_width])
        translate([a,0])resize([line_width, height]) square(1);
    translate([width-line_width,0])resize([line_width,height]) square(1);

    for(a = [0:1.75/percentage*line_width:height-line_width])
        translate([0,a])resize([width, line_width]) square(1);
    translate([0,height-line_width])resize([width,line_width]) square(1);
}

module create_tile(w_h, base_thickness, fill_percentage=1) {
    width = w_h[0];
    height = w_h[1];
    intersection() {
        linear_extrude(base_thickness) {
            resize([width, height])square(10);
        }
        if(fill_percentage < 1) {
            linear_extrude(base_thickness+1) {
                gridify(width, height, fill_percentage, grid_line_width);
            }
        }
    }
}

module create_wall(w_h, wall_height, wall_thickness) {
    width = w_h[0];
    height = w_h[1];
    linear_extrude(wall_height) {
        difference() {
            translate([-wall_thickness,-wall_thickness])resize([width+wall_thickness*2, height+wall_thickness*2])square(1);
            resize([width, height])square(1);
        }
    }
}




