
__version__ = 14;
//V14 - Fixed the bottom right hole being too small - added build flags for parts
//V13 - Increased bottom layers and wall lines. - adjusted magnet holes accordingly
//V12 - Increased magnet hole size tolerance


bottom_layers = 10;
wall_lines = 8;
num_tiles=7;

include <mansions_tile_sizes.scad>;
use <helpers/fillets/fillets2d.scad>;
use <helpers/fillets/fillets3d.scad>;

$fn=50;

build_box = false;
build_lid = true;
do_fillets = 1;

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;

tile_translations = [
                     [[0,0],sq_tile_vec], //bottom left
                     [[sq_tile+wall_thickness,0],rec_tile_vec],
                     [[sq_tile+2*wall_thickness+rec_tile_w,0],sq_tile_vec],
                     [[row_offset+0,sq_tile+wall_thickness],rec_tile_vec],
                     [[row_offset+rec_tile_w+wall_thickness,rec_tile_h+wall_thickness],sq_tile_vec],
                     [[row_offset+rec_tile_w+2*wall_thickness+sq_tile,sq_tile+wall_thickness],rec_tile_vec]
                    ];

sq_rec_diff = (sq_tile-(rec_tile_w+2*wall_thickness))/2;

box_center = [(row_1_w+2*wall_thickness)/2, (sq_tile + rec_tile_h+1*wall_thickness)/2];

/////// ---- Holes ---- ///////
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
//top-left (0) to bottom right (16)
hole_locations=[ 
                 [[column0_hx,top_hy],false,hrw], //0
                 [[column1_hx,top_hy], false,hsq], //1
                 [[column2_hx,top_hy],false,hrw], //2
                 [[left_vx+row_offset,row0_vy],true,hsq],// 3
                 [[row_offset+rec_tile_w+ht, row0_vy],true,hsq],// 4
                 [[row_offset+rec_tile_w+wall_thickness+sq_tile+ht, row0_vy],true,hsq], // 5
                 [[row_offset+2*rec_tile_w+2*wall_thickness+sq_tile+ht, row0_vy],true,hsq], // 6
                 [[column0_hx,sq_tile+ht],false,hrw],// 7
                 [[column2_hx, sq_tile+ht], false,hrw],// 8
                 [[column1_hx,rec_tile_h+ht],false,hrw],// 9
                 [[left_vx,row1_vy],true,hsq], // 10
                 [[sq_tile+ht,row1_vy],true,hsq], // 11
                 [[sq_tile+wall_thickness+rec_tile_w+ht, row1_vy],true,hsq],// 12
                 [[row1_right_vx,row1_vy],true,hsq], // 13
                 [[column0_hx,bottom_hy],false,hsq], //14
                 [[column1_hx,bottom_hy],false,hrw], //15
                 [[column2_hx, bottom_hy],false,hsq], //16
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


use <scad-utils/morphology.scad>

tolerance=.2;

lid_pop_in = (num_tiles-2) < 4 ? 1 : 2;

module create_lid_walls() {
    topFillet(t = box_height-1, r = .4, s = 2, e = do_fillets)
        linear_extrude(box_height-1)
            translate(hole_locations[1][0])
                resize([hole_locations[1][2]-1, wall_thickness]) 
                    square(1,center=true);

    topFillet(t = box_height-1, r = .4, s = 2, e = do_fillets)
        linear_extrude(box_height-1)
            translate(hole_locations[15][0])
                resize([hole_locations[15][2]-1, wall_thickness]) 
                    square(1,center=true);

    for(i=[0,2,4]) {
        tile = tile_translations[i];
        topFillet(t = bottom_thickness+lid_pop_in*tile_thickness, r = .4, s = 2, e = do_fillets)
            translate([tile[0].x+tile[1].x/2, tile[0].y+tile[1].y/2]) {
                create_tile([tile[1].x-tolerance, tile[1].y-tolerance], bottom_thickness+lid_pop_in*tile_thickness,center=true);
        }
    }
}

module build_tile_feature_lid() {
    translate([100,0]) {
        difference() {
            difference() {
                bottomFillet(b=0,r=.4,s=2,e=0)// this fillet is broken because of how the base is assembled...
                group() {
                    build_magnet_bases(bottom_thickness);
                    create_base(bottom_thickness, 1);
                    linear_extrude(bottom_thickness)
                        translate(box_center) square(50,center=true);
                    create_lid_walls();
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

if(build_box) {
    build_tile_feature_bottom();
}

if(build_lid) {
    build_tile_feature_lid();
}

