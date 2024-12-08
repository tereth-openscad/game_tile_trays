
__version__ = 7;

build_box = false;
build_lid = true;
big_box = true;
do_fillets = 0;

bottom_layers = 10;
wall_lines = 5;
num_tiles=7;

include <mansions_tile_sizes.scad>;
use <../helpers/fillets/fillets2d.scad>;
use <../helpers/fillets/fillets3d.scad>;
use <../helpers/openscad_manual/list.scad>;

use <../scad-utils/morphology.scad>

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;

sq_rec_diff = (sq_tile-(rec_tile_w+2*wall_thickness))/2;

include <mansions_tile_features_tray_holes.scad>;
include <mansions_tile_magnets.scad>;
use <mansions_tiles.scad>;

tolerance=.2;

$fn=100;

keys=4;
fire_tokens=big_box ? 38 : 30;
restraint_tokens=20;
rift_tokens=43;
search_tokens=16;
explore_tokens=16;

big_token_list = [fire_tokens, restraint_tokens, rift_tokens, search_tokens, explore_tokens];
small_token_list = [fire_tokens, search_tokens, explore_tokens];
token_list = big_box ? big_token_list : small_token_list;

tiles_per_column=max(token_list)+1;

function calculate_tile_depth(tiles) = tiles * tile_thickness + height_slop;

big_box_columns = [ 
            [sq_tile, tiles_per_column, wall_thickness + sq_tile / 2, "square"], //fire
            [sq_tile, tiles_per_column, wall_thickness*2+sq_tile*3/2, "square"],//rift
            [sq_tile, restraint_tokens, wall_thickness*3+sq_tile*5/2, "square"],//restraint
            [circle_tile_d,search_tokens, wall_thickness*4+sq_tile*3+circle_tile_r, "circle"], //search
            [circle_tile_d,explore_tokens, wall_thickness*5+sq_tile*3+circle_tile_r*3, "circle"], //explore
          ];

small_box_columns = [ 
            [sq_tile, tiles_per_column, wall_thickness + sq_tile / 2, "square"], //fire
            //[sq_tile, tiles_per_column, wall_thickness*2+sq_tile*3/2, "square"],//rift
            //[sq_tile, restraint_tokens, wall_thickness*3+sq_tile*5/2, "square"],//restraint
            [circle_tile_d,search_tokens, wall_thickness*2+sq_tile*1+circle_tile_r, "circle"], //search
            [circle_tile_d,explore_tokens, wall_thickness*3+sq_tile*1+circle_tile_r*3, "circle"], //explore
          ];

columns = big_box ? big_box_columns : small_box_columns;

num_columns=len(columns);
box_width = add([for(i=columns) i[0]]);
min_column_depth = calculate_tile_depth(big_box ? restraint_tokens : search_tokens);

box_size = [
            (wall_thickness * (2 + (num_columns - 1))) + box_width,
            calculate_tile_depth(tiles_per_column) + (wall_thickness * 2),
            square_tile + bottom_thickness + .4
           ];

if(build_box) {
    build_explore_bottom();
}

if(build_lid) {
    translate([box_size.x + 10,0,0])
        build_explore_lid();
}

module base_box(size) {
    linear_extrude(size.z)
        rounding2d(2)
            fillet2d(2)
                group() {
                    square([size.x, size.y]);

                    //magnet posts
                    translate([0,0]+[-mag_trans,-mag_trans])
                        circle(r=magnet_radius+1);
                    translate([size.x,0] + [mag_trans,-mag_trans])
                        circle(r=magnet_radius+1);
                    translate([size.x,size.y] + [mag_trans,mag_trans])
                        circle(r=magnet_radius+1);
                    translate([0,size.y] + [-mag_trans,mag_trans])
                        circle(r=magnet_radius+1);
                }
}

use <../helpers/bases.scad>

remaining_box_trans = [ big_box ? 2 * sq_tile + 3 * wall_thickness : sq_tile + 2*wall_thickness, 
                        min_column_depth + wall_thickness*2, 
                        bottom_thickness];
remaining_box = [
                  box_size.x-(remaining_box_trans.x+wall_thickness),
                  box_size.y-(remaining_box_trans.y+wall_thickness),
                  sq_tile+1
                ];


module build_explore_bottom() {
    group () {
        difference() {
            difference() {
                bottomFillet(b=0, r=.2,s=1,e=do_fillets) {
                    base_box(box_size);
                }
                translate([wall_thickness, wall_thickness,-.1])
                    linear_extrude(box_size.z)
                        triangle_base_cut([square_tile, box_size.y-2*wall_thickness], 1, 4, wall_thickness);
                if(big_box) {
                    translate([wall_thickness*2 + square_tile, wall_thickness,-.1])
                        linear_extrude(box_size.z)
                            triangle_base_cut([square_tile, box_size.y-2*wall_thickness], 1, 4, wall_thickness);

                    translate([columns[2][2], calculate_tile_depth(columns[2][1])/2+wall_thickness,-.1])
                        linear_extrude(box_size.z)
                            triangle_base_cut([square_tile, calculate_tile_depth(columns[2][1])], 1, 2, wall_thickness, center=true);

                    translate([wall_thickness, wall_thickness, box_size.z*3/4])
                        cube([columns[0][0]+columns[1][0], box_size.y-2*wall_thickness, box_size.z]);

                    translate([columns[0][0]+columns[1][0]+2*wall_thickness, wall_thickness, box_size.z*3/4])
                        cube([columns[2][0]+columns[3][0]+columns[4][0]+3*wall_thickness, calculate_tile_depth(columns[2][1]), box_size.z]);
                }
                        
                translate([0,0,box_size.z-magnet_thickness]) {
                    translate([0,0]+[-mag_trans,-mag_trans])
                        cylinder(r=magnet_radius, h=magnet_thickness+1);
                    translate([box_size.x,0] + [mag_trans,-mag_trans])
                        cylinder(r=magnet_radius, h=magnet_thickness+1);
                    translate([box_size.x,box_size.y] + [mag_trans,mag_trans])
                        cylinder(r=magnet_radius, h=magnet_thickness+1);
                    translate([0,box_size.y] + [-mag_trans,mag_trans])
                        cylinder(r=magnet_radius, h=magnet_thickness+1);
                }
            }

            for(item=columns) {
                depth=calculate_tile_depth(item[1]);
                translate([item[2], wall_thickness+depth/2, box_size.z-item[0]/2])
                    build_tile_cut(shape=item[3], size=[item[0], depth, item[0]]);

                translate([item[2], wall_thickness/2, box_size.z])
                    rotate([90,0,0])
                        linear_extrude(wall_thickness+1, center=true)
                            circle(r=item[0]/2-2);
            }

            translate(remaining_box_trans+(remaining_box/2)) {
                rounded_bottom(circle_tile_r, remaining_box);
            }

        }
    }
}

mag_trans = sqrt(2)/2*(magnet_radius+wall_thickness/2-sqrt(2)*wall_thickness);

lid_text="EXPLORE";
module build_explore_lid() {
    difference() {
        group () {
            bottomFillet(b=0,r=.2,s=1,e=do_fillets) {
                base_box([box_size.x, box_size.y, bottom_thickness]);
            }
            //small remaining box inset
            topFillet(t=bottom_thickness+2, r=.6,s=3,e=do_fillets)
                translate([wall_thickness+.2, box_size.y-(remaining_box.y-.2+wall_thickness),bottom_thickness])
                    linear_extrude(2)
                        rounding2d(2)
                            fillet2d(2)
                                square([remaining_box.x-.4, remaining_box.y-.4]);
        }

        //cut out magnet holes
        translate([0,0,bottom_thickness-magnet_thickness]) {
            translate([0,0]+[-mag_trans,-mag_trans])
                cylinder(r=magnet_radius, h=magnet_thickness+1);
            translate([box_size.x,0] + [mag_trans,-mag_trans])
                cylinder(r=magnet_radius, h=magnet_thickness+1);
            translate([box_size.x,box_size.y] + [mag_trans,mag_trans])
                cylinder(r=magnet_radius, h=magnet_thickness+1);
            translate([0,box_size.y] + [-mag_trans,mag_trans])
                cylinder(r=magnet_radius, h=magnet_thickness+1);
        }

        translate([0,0,-.1])
            linear_extrude(.2+.1)
                translate([box_size.x/2,box_size.y/2])
                    rotate(a=[0,180,-10])
                        text(lid_text,font="Elric",valign="center", halign="center");
                        
    }
}

module rounded_bottom(rbottom, size) {
    assert(size.z >= rbottom, "z size must be 2x rbottom")
    rotate([90,0,0])
        linear_extrude(size.y,center=true)
            hull() {
                square_size = 1;
                x_dist_c = (size.x - (rbottom*2))/2;
                z_dist_c = (size.z - (rbottom*2))/2;
                x_dist_s = (size.x - square_size)/2;
                z_dist_s = (size.z - square_size)/2;
                translate([-x_dist_c,-z_dist_c,0])
                    difference() {
                        circle(r=rbottom);
                        translate([0,rbottom/2])
                            resize([2*rbottom, rbottom])square(1,center=true);
                    }
                translate([x_dist_s,z_dist_s,0])
                    square(square_size,center=true);
                translate([x_dist_c,-z_dist_c,0])
                    difference() {
                        circle(r=rbottom);
                        translate([0,rbottom/2])
                            resize([2*rbottom, rbottom])square(1,center=true);
                    }
                translate([-x_dist_s,z_dist_s,0])
                    square(square_size,center=true);
            }
}

module build_tile_cut(shape="square", size) {
    if(shape=="square") {
        cube([size.x,size.y,size.z+1], center=true);
    } else if(shape=="circle") {
        rotate([90,0,0]) {
            cylinder(h=size.y, d=size.x, center=true);
        }
        translate([0,0,size.x/2])
            cube([size.x,size.y,size.x],center=true);

    } else {
        assert("Unknown shape");
    }
}

