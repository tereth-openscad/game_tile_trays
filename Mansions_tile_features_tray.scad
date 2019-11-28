
include <mansions_tile_sizes.scad>;

$fn=50;

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;

box_height = bottom_thickness + num_tiles*tile_thickness + height_slop;

sq_tile_vec = [sq_tile, sq_tile];
rec_tile_vec = [rectangle_tile_width, rectangle_tile_height];

tile_translations = [[[0,0],sq_tile_vec],
                     [[sq_tile+thickness,0],rec_tile_vec],
                     [[sq_tile+2*thickness+rec_tile_w,0],sq_tile_vec],
                     [[row_offset+0,sq_tile+thickness],rec_tile_vec],
                     [[row_offset+rec_tile_w+thickness,rec_tile_h+thickness],sq_tile_vec],
                     [[row_offset+rec_tile_w+2*thickness+sq_tile,sq_tile+thickness],rec_tile_vec]
                    ];

sq_rec_diff = (sq_tile-(rec_tile_w+2*thickness))/2;

include <mansions_tile_features_tray_holes.scad>;
use <mansions_tiles.scad>;
include <mansions_tile_magnets.scad>;

module create_base(wall_height, fill_percentage=1) {
    for(tile=tile_translations) {
        translate(tile[0]) {
            create_tile(tile[1], bottom_thickness, fill_percentage);
            create_wall(tile[1], wall_height, thickness);
        }
    }
}

module build_tile_feature_bottom() {
    difference() {
        group() {
            build_magnet_bases();

            //this intersection is there to clean the outside of the box of any outlying features
            intersection() {
                group() {
                    difference() {
                        translate([0,0,.01])create_base(box_height, base_fill_percentage);
                        create_holes();
                    }
                    create_hole_borders();
                }
                create_base(box_height, 1);
            }
        }

        //magnet cut outs
        group() {
            cut_magnet_holes();
        }
    }
}

module build_tile_feature_lid() {
    translate([100,0]) {
        create_base(bottom_thickness, 1);
    }
}

build_tile_feature_bottom();
build_tile_feature_lid();


