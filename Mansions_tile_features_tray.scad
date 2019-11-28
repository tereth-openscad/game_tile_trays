
include <mansions_tile_sizes.scad>;

$fn=50;

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;

box_height = bottom_thickness + num_tiles*tile_thickness + height_slop;

sq_tile_vec = [sq_tile, sq_tile];
rec_tile_vec = [rectangle_tile_width, rectangle_tile_height];

tile_translations = [
                     [[0,0],sq_tile_vec],
                     [[sq_tile+wall_thickness,0],rec_tile_vec],
                     [[sq_tile+2*wall_thickness+rec_tile_w,0],sq_tile_vec],
                     [[row_offset+0,sq_tile+wall_thickness],rec_tile_vec],
                     [[row_offset+rec_tile_w+wall_thickness,rec_tile_h+wall_thickness],sq_tile_vec],
                     [[row_offset+rec_tile_w+2*wall_thickness+sq_tile,sq_tile+wall_thickness],rec_tile_vec]
                    ];

sq_rec_diff = (sq_tile-(rec_tile_w+2*wall_thickness))/2;

lid_text = "TILES";

include <mansions_tile_features_tray_holes.scad>;
use <mansions_tiles.scad>;
include <mansions_tile_magnets.scad>;

module create_base(wall_height, fill_percentage=1) {
    for(tile=tile_translations) {
        translate(tile[0]) {
            create_tile(tile[1], bottom_thickness, fill_percentage);
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
                        create_holes();
                    }
                    create_hole_borders();
                }
                create_base(box_height, 1);
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
                }
                cut_magnet_holes(bottom_thickness);


            }

            linear_extrude(.2+.1)
                translate([(row_1_w+2*wall_thickness)/2, (sq_tile + rec_tile_h+1*wall_thickness)/2,-0.1])
                    rotate(a=[0,180,0])
                        text(lid_text,valign="center", halign="center");
        }
    }

}

build_tile_feature_bottom();
build_tile_feature_lid();


