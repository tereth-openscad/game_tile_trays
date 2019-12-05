
magnet_diameter=5+.2;
magnet_radius=magnet_diameter/2;
magnet_thickness=1;

middle_magnets=true;
bottom_left_magnet=false;

module magnet_hole(size, depth) {
    translate([0,0,-depth])
        linear_extrude(depth+1) 
            circle(d=size);
}

magnet_circle_size = max(wall_thickness*2, magnet_diameter+row_offset/2);
magnet_left_middle_cut_trans=min(row_offset-magnet_radius-.1,0);
magnet_square_size = [wall_thickness+sq_rec_diff, magnet_diameter+1];
magnet_bases_holes = [
                        [[-(row_offset+wall_thickness)/2, sq_tile+wall_thickness], [magnet_left_middle_cut_trans,sq_tile+magnet_radius+1]],
                        [[row_offset+row_2_w+3*wall_thickness,sq_tile+wall_thickness], [row_offset+row_2_w+3*wall_thickness,sq_tile+magnet_radius+1]],
                        [[], [-magnet_radius, -magnet_radius]]
                     ];

module build_magnet_base(translations, square_size, circle_size, height) {
    intersection() {
        if(len(translations[0]) > 0) {
            translate(translations[0])
                linear_extrude(height)
                    resize(magnet_square_size)square(1);
        }

        translate(translations[1])
            linear_extrude(height)
                circle(d=magnet_circle_size);
    }
}

module build_magnet_bases(height) {
    if(middle_magnets) {
        build_magnet_base(magnet_bases_holes[0], magnet_square_size, magnet_circle_size, height);
        build_magnet_base(magnet_bases_holes[1], magnet_square_size, magnet_circle_size, height);
    }

    //create the border for the bottom left magnet cutout
    if(bottom_left_magnet) {
        build_magnet_base(magnet_bases_holes[2], 0, magnet_diameter+2, box_height);
    }
}

module cut_magnet_hole(trans, height) {
    translate(concat(trans,[height]))
        magnet_hole(magnet_diameter,magnet_thickness);
}

module cut_magnet_holes(height) {
    if(middle_magnets) {
        cut_magnet_hole(magnet_bases_holes[0][1], height);
        cut_magnet_hole(magnet_bases_holes[1][1], height);
    }

    if(bottom_left_magnet) {
        cut_magnet_hole(magnet_bases_holes[2][1], height);
    }
}

