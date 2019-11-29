
bottom_layers = 8;
wall_lines = 6;
num_tiles=7;

include <mansions_tile_sizes.scad>;

$fn=50;

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;

tile_translations = [
                     [[0,0],sq_tile_vec],
                     [[sq_tile+wall_thickness,0],rec_tile_vec],
                     [[sq_tile+2*wall_thickness+rec_tile_w,0],sq_tile_vec],
                     [[row_offset+0,sq_tile+wall_thickness],rec_tile_vec],
                     [[row_offset+rec_tile_w+wall_thickness,rec_tile_h+wall_thickness],sq_tile_vec],
                     [[row_offset+rec_tile_w+2*wall_thickness+sq_tile,sq_tile+wall_thickness],rec_tile_vec]
                    ];

sq_rec_diff = (sq_tile-(rec_tile_w+2*wall_thickness))/2;

box_center = [(row_1_w+2*wall_thickness)/2, (sq_tile + rec_tile_h+1*wall_thickness)/2];

/////// ---- Holes ---- ///////
//  [0  1  2]
//  [3  4  5]
column0_hx = hsq;
column1_hx = sq_tile+wall_thickness+hrw;
column2_hx = 3*hsq + rec_tile_w + 2*wall_thickness;

row0_vy = rec_tile_h+hsq+wall_thickness;
row1_vy = hsq;

top_hy = sq_tile+wall_thickness+rec_tile_h+ht;
bottom_hy = -ht;
left_vx = -ht;
row1_right_vx = sq_tile*2 + rec_tile_w + 2*wall_thickness + ht;

// [[w, h], is_vert, diameter]
hole_locations=[ [[left_vx,row1_vy],true,hsq],
                 [[column0_hx,bottom_hy],false,hsq],
                 [[sq_tile+ht,row1_vy],true,hsq],
                 [[column0_hx,sq_tile+ht],false,hrw],
                 [[column1_hx,bottom_hy],false,hrw],
                 [[column1_hx,rec_tile_h+ht],false,hrw],
                 [[column0_hx,top_hy],false,hrw],
                 [[column2_hx,top_hy],false,hrw],
                 [[row1_right_vx,row1_vy],true,hrw],
                 [[column2_hx, bottom_hy],false,hsq],
                 [[column2_hx, sq_tile+ht], false,hrw],
                 //right of 4
                 [[sq_tile+wall_thickness+rec_tile_w+ht, row1_vy],true,hsq],
                 //top of 1
                 [[column1_hx,top_hy], false,hsq],
                 //left of 0
                 [[left_vx+row_offset,row0_vy],true,hsq],
                 //right of 0 && left of 1
                 [[row_offset+rec_tile_w+ht, row0_vy],true,hsq],
                 //right of 1 && left of 2
                 [[row_offset+rec_tile_w+wall_thickness+sq_tile+ht, row0_vy],true,hsq],
                 //right of 2
                 [[row_offset+2*rec_tile_w+2*wall_thickness+sq_tile+ht, row0_vy],true,hsq],
               ];
/////// ---- Holes ---- ///////

lid_text = "TILES";

include <mansions_tile_features_tray_holes.scad>;
use <mansions_tiles.scad>;
include <mansions_tile_magnets.scad>;

module create_base(wall_height, fill_percentage=1) {
    for(tile=tile_translations) {
        translate(tile[0]) {
            create_tile(tile[1], bottom_thickness, fill_percentage, grid_line_width);
            create_wall(tile[1], wall_height, wall_thickness);
        }
    }
}

module build_tile_feature_bottom() {
    difference() {
        group() {
            build_magnet_bases(box_height);

            //this intersection is there to clean the outside of the box of any outlying features
            intersection() {
                group() {
                    difference() {
                        translate([0,0,.01])create_base(box_height, base_fill_percentage);
                        group() {
                            if(!hole_border) {
                                create_holes(hole_locations, box_height+1, wall_thickness);
                            } else {
                                translate([0,0,bottom_thickness])create_holes(hole_locations, box_height+1, wall_thickness);
                                create_holes(hole_locations, bottom_thickness, wall_thickness, 2);
                            }
                        }
                    }
                }
                //create_base(box_height, 1);
            }
        }

        cut_magnet_holes(box_height);
    }
}


module build_tile_feature_lid() {
    translate([100,0]) {
        difference() {
            difference() {
                group() {
                    build_magnet_bases(bottom_thickness);
                    create_base(bottom_thickness, 1);
                    linear_extrude(bottom_thickness)
                        translate(box_center) square(50,center=true);
                }
                cut_magnet_holes(bottom_thickness);
            }

            linear_extrude(.2+.1)
                translate(concat(box_center,[-0.1]))
                    rotate(a=[0,180,0])
                        text(lid_text,valign="center", halign="center");
        }
    }

}

build_tile_feature_bottom();
build_tile_feature_lid();

