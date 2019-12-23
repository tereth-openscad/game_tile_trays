
__version__ = 1;

bottom_layers = 10;
wall_lines = 9;
num_tiles=7;

include <mansions_tile_sizes.scad>;
use <helpers/fillets/fillets2d.scad>;
use <helpers/fillets/fillets3d.scad>;

$fn=50;

build_box = true;
build_lid = true;
do_fillets = 0;


if(build_box) {
    build_tile_feature_bottom();
}

if(build_lid) {
    build_tile_feature_lid();
}


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
include <mansions_tile_magnets.scad>;
use <mansions_tiles.scad>;
use <helpers/fillets/fillets2d.scad>
use <helpers/fillets/fillets3d.scad>

wall_thickness_v = [wall_thickness,wall_thickness];

module create_base(wall_height, fill_percentage=1) {
    for(tile=tile_translations) {
        translate(tile[0]-wall_thickness_v) {
            create_tile(tile[1]+2*wall_thickness_v, bottom_thickness);
        }
    }
}

module create_walls(wall_height) {
    for(tile=tile_translations) {
        translate(tile[0])
            create_wall(tile[1], wall_height, wall_thickness);
    }
}

module build_tile_feature_bottom() {
    difference() {
        group() {
            difference() {
                bottomFillet(b=0,r=.4,s=2,e=1)
                group() {
                    linear_extrude(bottom_thickness)
                        rounding(r=1)
                        create_base(box_height, base_fill_percentage);
                    linear_extrude(box_height) {
                        rounding(r=1)
                            create_walls(box_height);
                        build_magnet_bases(box_height);
                    }
                }
                group() {
                    if(!hole_border) {
                        topBottomFillet(b=0,t=box_height,r=.4,s=2, e=do_fillets, inverse=true)
                            create_holes(hole_locations, box_height+1, wall_thickness);
                    } else {
                        translate([0,0,bottom_thickness])
                            create_holes(hole_locations, box_height+1, wall_thickness);

                        create_holes(hole_locations, bottom_thickness, wall_thickness, 2);
                    }
                }
            }
        }

        cut_magnet_holes(box_height);
    }
}


use <scad-utils/morphology.scad>

tolerance=.2;

lid_pop_in = (num_tiles-2) < 4 ? 1 : 2;

lid_pop_in_tol = 6*tolerance;
module create_lid_pop_in() {
    for(i=[0,2,4]) {
        tile = tile_translations[i];
        topFillet(t = bottom_thickness+lid_pop_in*tile_thickness, r = .4, s = 2, e = do_fillets)
            translate([tile[0].x+tile[1].x/2, tile[0].y+tile[1].y/2]) {
                linear_extrude(bottom_thickness+lid_pop_in*tile_thickness) {
                    create_tile([tile[1].x-lid_pop_in_tol, tile[1].y-lid_pop_in_tol], bottom_thickness+lid_pop_in*tile_thickness,center=true);
                }
        }
    }
}

module build_tile_feature_lid() {
    translate([100,0]) {
        difference() {
            difference() {
                bottomFillet(b=0,r=.4,s=2,e=1)
                    group() {
                        linear_extrude(bottom_thickness) {
                            rounding(r=1)
                                create_base(bottom_thickness, 1);
                            build_magnet_bases(bottom_thickness);
                            translate(box_center) 
                                square(50,center=true);
                        }
                        create_lid_pop_in();
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

