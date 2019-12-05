
bottom_layers = 10;
wall_lines = 6;
num_tiles=19;

include <mansions_tile_sizes.scad>;

$fn=50;

fire_tile_v = concat(sq_tile_vec, [tile_thickness*19+height_slop]);
darkness_tile_v = concat(sq_tile_vec, [tile_thickness*19+height_slop]);
circle_tile_v = [circle_tile_d, circle_tile_d, box_height];

hsq = square_tile/2+wall_thickness;

tile_translations = [
                      [[0,0], "circle", circle_tile_d],
                      [[circle_tile_d+wall_thickness,0],"circle",circle_tile_d],
                      [[3*circle_tile_r+square_tile/2+2*wall_thickness,0],"square", square_tile]
                      //[[2*sq_tile_vec.x+2*wall_thickness,0],_tile_v],
                      //[[3*sq_tile_vec.x+3*wall_thickness,0],circle_tile_v],
                     //[[0,0],sq_tile_vec],
                     //[[sq_tile+wall_thickness,0],rec_tile_vec],
                     //[[sq_tile+2*wall_thickness+rec_tile_w,0],sq_tile_vec],
                     //[[row_offset+0,sq_tile+wall_thickness],rec_tile_vec],
                     //[[row_offset+rec_tile_w+wall_thickness,rec_tile_h+wall_thickness],sq_tile_vec],
                     //[[row_offset+rec_tile_w+2*wall_thickness+sq_tile,sq_tile+wall_thickness],rec_tile_vec]
                    ];

/////// ---- Holes ---- ///////

// [[w, h], is_vert, diameter]
hole_locations=[ //[[left_vx,row1_vy],true,hsq],
               ];
/////// ---- Holes ---- ///////

lid_text = "EXPLORE";

include <mansions_tile_features_tray_holes.scad>;
use <mansions_tiles.scad>;
//include <mansions_tile_magnets.scad>;

module build_base(range, wall_height) {
    resize([wall_thickness*4+2*circle_tile_d+square_tile, wall_thickness*2+square_tile+wall_height*cos(75)])square(1);

/*
    for(a = range) {
        i = tile_translations[a];
        echo(i=i);
        echo(i[1]);
        translate([i[0].x, i[0].y]) {
            if(i[1] == "circle")
                square(square_tile+2*wall_thickness,center=true);
            else if(i[1] == "square")
                square(i[2]+2*wall_thickness,center=true);
            else
                assert(false,"tile type unknown");
        }
    }
    */
}

module create_base(wall_height) {
    difference() {
        //build the walls and base
        group() {
            linear_extrude(wall_height) {
                hull() {
                    build_base([0:1], wall_height);
                }
            }
            linear_extrude(wall_height) {
                build_base([2], wall_height);
            }
        }

        //cut spaces for the tiles
        group() {
            translate([0,wall_height*cos(75)/2,square_tile*cos(75)]) {
                rotate([-15,0]) {
                    translate([circle_tile_r+wall_thickness,wall_height*cos(75),bottom_thickness]) {
                        linear_extrude(box_height) {
                            for(i=tile_translations) {
                                translate(i[0]) {
                                    if(i[1] == "circle")
                                        circle(d=i[2]);
                                    else if(i[1] == "square")
                                        square(i[2],center=true);
                                    else
                                        assert(false,"tile type unknown");
                                }
                            }
                        }
                    }
                    translate([-1,-square_tile+wall_thickness,bottom_thickness])
                        cube([wall_thickness*4+2*circle_tile_d+square_tile+2, (wall_thickness+2*square_tile+wall_height*cos(75))/2, wall_height]);
                }
            }
        }
    }
}



create_base(box_height);



