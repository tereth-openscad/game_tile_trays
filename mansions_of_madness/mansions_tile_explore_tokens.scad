
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

use <helpers/fillets/fillets2d.scad>
use <helpers/fillets/fillets3d.scad>
module build_base(wall_height) {

    rounding2d(1)
        fillet2d(1)
            resize([wall_thickness*4 + 2*circle_tile_d + square_tile, 
                    wall_thickness*2+square_tile+wall_height*sin(15)])
                square(1);

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

module trans_and_rotate(trans, rot) {
    translate(trans)
        rotate(rot)
            children();
}

module tile_cut(wall_height, extra_height=2) {
    trans_and_rotate([0,square_tile/2+wall_thickness,tan(15)*hsq+bottom_thickness], [-15,0])
    {
        translate([circle_tile_r+wall_thickness,0]) 
        {
            linear_extrude(wall_height-bottom_thickness+extra_height) {
                for(i=tile_translations) {
                    translate(i[0]) 
                    {
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
    }
}


cube_cut_size = [wall_thickness*4+2*circle_tile_d+square_tile+2, 
                 (wall_thickness+2*square_tile+box_height*cos(75))/2, 
                 box_height-bottom_thickness+5];
module create_base(wall_height, do_fillets=1) {
    echo(wall_height=wall_height);
    echo(bottom_thickness=bottom_thickness);
    difference() {
        //build the walls and base
        group() {
            bottomFillet(b = 0, r = .4, s = 2, e = do_fillets) {
                linear_extrude(wall_height) {
                    build_base(wall_height);
                }
            }

            trans_and_rotate([0,square_tile/2+wall_thickness,tan(15)*hsq+bottom_thickness], [-15,0])
            {
                //put some extra on the top
                translate([-1+cube_cut_size.x/2,-2,wall_height-bottom_thickness-2.5])
                    cube([cube_cut_size.x-2,cube_cut_size.y, 5],center=true);
            }
        }

        //cut spaces for the tiles
        group() {
            tile_cut(wall_height);

            trans_and_rotate([0,square_tile/2+wall_thickness,tan(15)*hsq+bottom_thickness], [-15,0]) {
                translate([-1,-cube_cut_size.y,0])
                    cube(cube_cut_size);

                translate([-1+cube_cut_size.x/2,0,wall_height-bottom_thickness+2.5])
                    cube([cube_cut_size.x,cube_cut_size.y, 5],center=true);
            }
        }
    }
}

module create_lid(wall_height) {

    difference() {
        linear_extrude(wall_height+bottom_thickness+10)
            rounding2d(1)
                fillet2d(1)
                    resize([wall_thickness*4 + 2*circle_tile_d + square_tile, 
                            wall_thickness*2+square_tile+wall_height*sin(15)])
                        square(1);
        group() {
            tile_cut(wall_height,extra_height=0);
            create_base(wall_height, do_fillets=0);
        }
    }
}


create_base(box_height);

//create_lid(box_height);

