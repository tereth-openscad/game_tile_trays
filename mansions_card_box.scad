
__version__ = 5;
//V5 - Add lid and seal

build_dividers=false;
build_box=false;
build_lid=true;
build_lid_seal=false;
build_demo=false;

test = false;
wall_lines = 6;//should be even
bottom_layers=test?3:10;
num_tiles=0;

include <mansions_tile_sizes.scad>
include <mansions_tiles.scad>
use <helpers/openscad_manual/list.scad>


slide_cut = min(3*line_width, wall_lines * line_width / 2);

slide_thickness = 2;
card_extension = test ? 60 : 20;
division_offset = 5+slide_thickness;

tolerance = .2;
circle_tolerance = .3;
chamfer_size = .4;

assert(tolerance*2 < slide_cut, "Slide cut doesn't allow for appropriate tolerances");
echo(2*slide_cut-tolerance*2);

damage_thickness = 45;
sanity_thickness = 45;
cond_thickness = 30;
insane_thickness = 20;

c_item_thickness = 50;
u_item_thickness = 30;
spells_thickness = 45;
elixir_thickness = 5;

function calc_bay_usage(v, thickness) = add2(v) + len(v)*slide_thickness;
function calc_bay_size(size, last=1) = last*division_offset < size ? calc_bay_size(size,last+1) : last;

//everything one box
everything_bays = [
    calc_bay_usage([damage_thickness,sanity_thickness], slide_thickness),
    calc_bay_usage([c_item_thickness,u_item_thickness], slide_thickness),
    calc_bay_usage([spells_thickness,cond_thickness,insane_thickness], slide_thickness)
];

//damage, sanity, condition cards box
//box_size ~= [45,75,48]
split_bays = [
    calc_bay_usage([damage_thickness], slide_thickness),
    calc_bay_usage([sanity_thickness], slide_thickness),
    calc_bay_usage([cond_thickness, insane_thickness], slide_thickness)
];

/*
//items/spells
//this is just here for reference
//box_size ~= [45,75,48]
items_bays = [
    calc_bay_usage([c_item_thickness], slide_thickness),
    calc_bay_usage([u_item_thickness, elixir_thickness], slide_thickness),
    calc_bay_usage([spells_thickness], slide_thickness)
];
*/

bays=split_bays;

num_bays=len(bays);

echo(bays=bays);
echo(max_usage=max(bays));

num_divisions = test ? 3 : calc_bay_size(max(bays)) + 3;

card_size = [test ? 20 : 45, 68, 1];
card_size_v = [card_size.x, card_size.z, card_size.y];
divider_size = [card_size.x+2*slide_cut, card_size.y-card_extension, slide_thickness];
divider_size_v = [divider_size.x, divider_size.z, divider_size.y];

lid_overlap = 10;

box_size = [card_size.x, num_divisions*division_offset-slide_thickness, card_size.y-card_extension];
box_size_with_inner_walls = [((box_size.x + 2 *wall_thickness) * num_bays), box_size.y+2*wall_thickness, box_size.z];
box_size_with_outer_walls = [2 * wall_thickness + box_size_with_inner_walls.x, box_size_with_inner_walls.y+2*wall_thickness, box_size_with_inner_walls.z-lid_overlap];

echo(box_size=box_size);
echo(box_size_with_outer_walls=box_size_with_outer_walls);

module make_card(size, block_size) {
    cube(card_size_v);
}

module make_divider(size) {
    cube(divider_size_v);
}

module make_flat_pyramid(size, chamfer) {
    points=[
        [chamfer, chamfer, 0],  //0
        [size.x-chamfer, chamfer,0],//1
        [size.x-chamfer, size.y-chamfer,0],//2
        [chamfer, size.y-chamfer,0],//3
        [0,0,size.z],//4
        [size.x,0,size.z],//5
        [size.x,size.y,size.z],//6
        [0,size.y,size.z]//7
    ];

    faces=[
        [0,1,2,3],
        [4,5,1,0],
        [7,6,5,4],
        [5,6,2,1],
        [6,7,3,2],
        [7,4,0,3],
    ];

    polyhedron(points,faces);
}

module make_chamfered_box(size, chamfer) {
    cube_height = size.z-2*chamfer;

    make_flat_pyramid([size.x, size.y, chamfer],chamfer);
    translate([0,0,chamfer]) cube([size.x, size.y, cube_height]);
    translate([size.x,0,size.z]) rotate([0,180,0])make_flat_pyramid([size.x, size.y, chamfer],chamfer);
}


module make_box() {
    intersection() {
        for(i=[1:1:num_bays]) {
            translate([(i-1)*(box_size.x+2*wall_thickness),0]) {
                difference() {
                    group() {
                        //difference() {
                        //    translate([-wall_thickness, -wall_thickness,0])
                        //        make_chamfered_box([box_size.x+2*wall_thickness, box_size.y+2*wall_thickness, box_size.z], .4);
                        //        translate([0,0,bottom_thickness])
                        //            cube([box_size.x, box_size.y, box_size.z+2]);
                        //}
                        create_tile(box_size, bottom_thickness);
                        create_wall(box_size, box_size.z, wall_thickness);
                        //create_wall([box_size.x, box_size.y], box_size.z-lid_over_lap, wall_thickness+wall_thickness);
                    }

                    for(i = [division_offset-slide_thickness:division_offset:box_size.y-slide_thickness])
                        translate([-slide_cut,i,bottom_thickness])
                            make_divider(divider_size);
                }
            }
        }
        translate([-wall_thickness, -wall_thickness, 0])
            make_chamfered_box(box_size_with_inner_walls, chamfer_size);
    }

    difference() {
        translate([-2*wall_thickness, -2*wall_thickness,0])
            make_chamfered_box(box_size_with_outer_walls, chamfer_size);
        translate([-wall_thickness, -wall_thickness,bottom_thickness])
            cube(box_size_with_inner_walls);
    }

    //translate([(box_size.x+wall_thickness)*num_bays+10,0])
        //make_chamfered_box([divider_size.x-2*tolerance,divider_size.y,divider_size.z-2*tolerance],.4);
    
}

module make_lid() {
    
    //card_extension
    //lid_overlap
    //card_size_v

    topBottomFillet(b=0,t=lid_overlap+card_extension+bottom_thickness, r=chamfer_size, s=chamfer_size/layer_thickness) {
        difference() {
            difference() {
                linear_extrude(lid_overlap+card_extension+bottom_thickness)
                    rounding2d(chamfer_size)fillet2d(chamfer_size)
                        resize([box_size_with_outer_walls.x, box_size_with_outer_walls.y])square(1);
                group() {
                    translate([wall_thickness+tolerance/2, wall_thickness+tolerance/2,-1])cube([box_size_with_inner_walls.x+tolerance, box_size_with_inner_walls.y+tolerance, lid_overlap+card_extension+1]);
                }
            }

            translate([box_size_with_outer_walls.x/2,box_size_with_outer_walls.y/2,lid_overlap+card_extension+bottom_thickness/2]) {
                linear_extrude(5)
                    circle(seal_diameter+circle_tolerance);
            }
        }
    }

    //translate([box_size_with_outer_walls.x/2,box_size_with_outer_walls.y/2,lid_overlap+card_extension+bottom_thickness/2])
        //make_lid_seal();
}

seal_diameter=30;
seal_thickness = 7 * layer_thickness;

use <helpers/fillets/fillets2d.scad>;
use <helpers/fillets/fillets3d.scad>;

module make_lid_seal() {
    topBottomFillet(b=0,t=seal_thickness, r=chamfer_size, s=chamfer_size/layer_thickness) {
        difference() {
            linear_extrude(height = seal_thickness)
                circle(seal_diameter);
            translate([0,0,3*layer_thickness])
                linear_extrude(height = seal_thickness+.1)
                    circle(seal_diameter-wall_thickness);
        }
    }
    linear_extrude(height = bottom_thickness/2+2*layer_thickness)
        scale([.4,.4])
            import("cthulhu_logo_2.svg", center=true);
}


$fn=100;
use <scad-utils/morphology.scad>

divider_w_tol_v2 = [divider_size.x-2*tolerance, divider_size.y];
divider_with_tolerances_v3 = concat(divider_w_tol_v2, [divider_size.z-2*tolerance]);

divider_right_tab_points = [
                            [0,0],
                            [divider_w_tol_v2.x,0],
                            [divider_w_tol_v2.x,divider_w_tol_v2.y+5],
                            [divider_w_tol_v2.x/2, divider_w_tol_v2.y+5],
                            [divider_w_tol_v2.x/2-1,divider_w_tol_v2.y],
                            [0,divider_w_tol_v2.y]
                           ];

divider_center_tab_points = [
                             [0,0],
                             [divider_w_tol_v2.x,0],
                             [divider_w_tol_v2.x, divider_w_tol_v2.y],
                             [divider_w_tol_v2.x*2/3+2, divider_w_tol_v2.y],
                             [divider_w_tol_v2.x*2/3, divider_w_tol_v2.y+5],
                             [divider_w_tol_v2.x/3, divider_w_tol_v2.y+5],
                             [divider_w_tol_v2.x/3-2,divider_w_tol_v2.y],
                             [0,divider_w_tol_v2.y]
                            ];


module make_divider_shape() {
    polygon(divider_center_tab_points);
}

module make_divider_square() {
    resize([divider_size.x-2*tolerance, divider_size.y]) square(1); 
}

module make_divider_insert() {
    height = divider_with_tolerances_v3.z;
    for(i=[0:layer_thickness:height]) {
        translate([0,0,i]) {
            if(i < chamfer_size) {
                linear_extrude(layer_thickness)
                    rounding(r=.3) inset(d=chamfer_size-i) make_divider_shape();
            }
            else if (i > height-chamfer_size) {
                inset_d = chamfer_size-(height-i);
                linear_extrude(layer_thickness)
                    rounding(r=.3)inset(d=inset_d) make_divider_shape();
            } else {
                linear_extrude(layer_thickness)
                    rounding(r=.3) fillet(r=.3) make_divider_shape();
            }
        }
    }
}

if(build_box) {
    make_box();
}

if(build_dividers) {
    make_divider_insert();
}

if(build_lid) {
    translate(build_box ? [-2*wall_thickness, -2*wall_thickness, box_size_with_outer_walls.z]: [0,0,0]) {
        make_lid();
        if(build_lid_seal)
            translate([box_size_with_outer_walls.x/2,box_size_with_outer_walls.y/2,lid_overlap+card_extension+bottom_thickness/2])
                make_lid_seal();
    }
}

if(build_lid_seal && !build_lid) {
    make_lid_seal();
}

