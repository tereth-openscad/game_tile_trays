
magnet_diameter=5;
magnet_radius=magnet_diameter/2;
magnet_thickness=1;

bottom_left_magnet=true;

module magnet_hole(size, depth) {
    translate([0,0,-depth])
        linear_extrude(depth+.1) 
            circle(d=size);
}

magnet_circle_size = magnet_diameter + row_offset/2;
magnet_square_size = [thickness+sq_rec_diff, magnet_diameter+1];
magnet_bases_holes = [
                        [[-thickness, sq_tile+thickness], [row_offset-magnet_radius,sq_tile+magnet_radius+1]],
                        [[row_offset+row_2_w+3*thickness,sq_tile+thickness], [row_offset+row_2_w+3*thickness,sq_tile+magnet_radius+1]],
                        [[], [-magnet_radius, -magnet_radius]]
                     ];

module build_magnet_base(translations, square_size, circle_size) {
    intersection() {
        if(len(translations[0]) > 0) {
            translate(translations[0])
                linear_extrude(box_height)
                    resize(magnet_square_size)square(1);
        }

        translate(translations[1])
            linear_extrude(box_height)
                circle(d=magnet_circle_size);
    }
}

module build_magnet_bases() {
    build_magnet_base(magnet_bases_holes[0], magnet_square_size, magnet_circle_size);
    build_magnet_base(magnet_bases_holes[1], magnet_square_size, magnet_circle_size);

    //create the border for the bottom left magnet cutout
    if(bottom_left_magnet) {
        build_magnet_base(magnet_bases_holes[2], 0, magnet_diameter+2);
    }
}

module cut_magnet_hole(trans) {

}

magnet_holes = [
                [row_offset-magnet_radius,sq_tile+magnet_radius+1,box_height],
                [row_offset+row_2_w+thickness*2+magnet_radius,sq_tile+magnet_radius+1,box_height],
                [-magnet_radius,-magnet_radius,box_height]
               ];


module cut_magnet_holes() {
    //middle left
    translate([row_offset-magnet_radius,sq_tile+magnet_radius+1,box_height])
        magnet_hole(magnet_diameter,magnet_thickness);

    //middle right
    translate([row_offset+row_2_w+thickness*2+magnet_radius,sq_tile+magnet_radius+1,box_height])
        magnet_hole(magnet_diameter,magnet_thickness);

    //bottom left
    if(bottom_left_magnet) {
        translate([-magnet_radius,-magnet_radius,box_height])
            magnet_hole(magnet_diameter,magnet_thickness);
    }
}

