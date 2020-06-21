
include <../hexgrid.scad>
include <../BOSL/constants.scad>
use <../BOSL/math.scad>
use <../BOSL/transforms.scad>
use <../BOSL/shapes.scad>
use <../BOSL/masks.scad>

/* [Sleeve/card size] */
//Sleeve/Card size
sleeve_size = [66, 91]; 

//Deck Height/thickness
deck_height = 32;

/* [General] */
//Lid or Box
lid_or_box="B"; //[B:Box, L:Lid, BL:Box and Lid]

//Card storage direction (horizonal is like a stack of cards)
horiz_or_vert="V";// [H:Horizontal, V:Vertical]

is_horiz = horiz_or_vert == "H" ? true : false;

//If the boxes should be stackable (cut the buttom so another box will sit on top)
is_stackable = false;

/* [Lid] */
lid_type="T"; //[T:Top insert, FS:Front Slide, RS:Rear Slide]
lid_text="Fighter";
font="Book Antiqua";
text_size=12;
lid_overlap=1;
lid_thickness=4;//[4:.1:10]
//Lid tolerance
lid_tol=.4;

/* [Side Patterns] */
bottom_pattern="H"; //[H:Hex, S:Solid]
//*not implemented*
bottom_front_thumb_slot=false; 
//*not implemented*
bottom_back_thumb_slot=false;
//*not implemented*
bottom_left_thumb_slot=false;
//*not implemented*
bottom_right_thumb_slot=false;
left_pattern="H"; //[H:Hex, S:Solid, O:Open]
left_thumb_slot=false;
right_pattern="H"; //[H:Hex, S:Solid, O:Open]
right_thumb_slot=false;
front_pattern="O"; //[H:Hex, S:Solid, O:Open]
front_thumb_slot=false;
back_pattern="H"; //[H:Hex, S:Solid, O:Open]
back_thumb_slot=false;

/* [Spacer] */
//Number of spacers
number_of_spacers=1;
//How far down the spacer is from the top (mm)
spacer_inset=15;
//Pattern on the spacer
spacer_pattern="H"; //[H:Hex, S:Solid, O:Open]
//thumb slot
spacer_thumb_slot=true;
//spacer thickness
spacer_thickness=2;

/* [Pattern Details] */
//Size of Hex Cut Outs (for sides/bottom/spacer)
hex_size=15;
//Thickness of lines between hex cutouts
hex_line_thickness=3;
//Hex border (solid border thickness around the hex patter)
hex_border = 4;
//How much of the card should be covered by the front
corner_width = 15;
//How much of the fillet should there be in the front bottom
interior_fillet_r=20;

/* [Extra tweakable items] */
//card tolerance
card_tol=1;
//Thickness of the base
base_thickness=2;
//Wall thickness - Minimum recommended: 2
wall_thickness=3;
//Extra height for vertical orientation
extra_height_for_vert=1;

//thumb slot diameter
thumb_d = 20;

/* [Speed/Render Quality] */
//Remove some fillets to make render faster
no_fillets=true;
//Make curves more curvier
$fn=25;
//is test
is_test=true;

/* [Hidden] */
sleeve_size_w_tol = sleeve_size + [card_tol, card_tol];

horiz_box = concat(sleeve_size_w_tol, deck_height);
vert_box = [sleeve_size_w_tol.x, deck_height, sleeve_size_w_tol.y + (is_horiz ? 0 : extra_height_for_vert)];
box_size = is_horiz ? horiz_box : vert_box;

spacer_size=[box_size.x+2*wall_thickness, spacer_thickness, box_size.z-spacer_inset];

base_dim = [box_size.x, box_size.y];
base = [box_size.x, box_size.y, base_thickness];

function rows_for_size_sq(sq_size, fill_size) = ceil(fill_size/sq_size);
function rows_for_size_hex(hex_diam, fill_size) = ceil(fill_size/hex_diam);
function hex_flat_len(diam) = diam*sin(60);

if((left_pattern == "O" || right_pattern == "O") && (lid_type == "FS" || lid_type == "BS")) {
    echo("WARNING! Slide tops are not recommended with open sides patterns!");
}

if(lid_or_box == "B" || lid_or_box == "BL") {
    difference() {
        build_bottom();
        if(is_test)
        {
            cuboid(box_size+[2*wall_thickness+2, 2*wall_thickness+2, -10], align=V_UP);
        }
    }
} 

if(lid_or_box == "L" || lid_or_box == "BL") {
    build_lid();
}


module build_bottom() {
    difference() {
        build_box();

        //fillet the outside corners
        if(!no_fillets) {
            grid2d([2*(box_size.x+wall_thickness*2), 2*(box_size.y+wall_thickness*2)], cols=2, rows=2)
                fillet_mask_z(l=box_size.z + base_thickness + wall_thickness, r=1, align=V_UP);
            grid2d([0, 2*(box_size.y+wall_thickness*2)], cols=1,rows=2)
                fillet_mask_x(l=box_size.x+wall_thickness*2, r=1);
            grid2d([2*(box_size.x+wall_thickness*2), 0], cols=2,rows=1)
                fillet_mask_y(l=box_size.y+wall_thickness*2, r=1);
        }

        if(is_stackable) {
            //cut the groves in the bottom
            down(box_size.z+base_thickness) 
                build_simple_box(tolerance=lid_tol);
            //round the cut corner
            if(!no_fillets) {
                grid2d([2*(box_size.x+wall_thickness-lid_tol), 2*(box_size.y+wall_thickness-lid_tol)], cols=2, rows=2)
                    fillet_mask_z(l=lid_overlap, r=1, align=V_UP);
            }
        } else {
            if(!no_fillets) {
                //round the corners
                grid2d([2*(box_size.x+2*wall_thickness), 2*(box_size.y+2*wall_thickness)], cols=2, rows=2)
                    fillet_corner_mask(r=1);
            }
        }

/*
        if(!no_fillets) {
            up(box_size.z+base_thickness+wall_thickness) 
                grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
                    fillet_corner_mask(r=1);
            up(box_size.z+base_thickness+wall_thickness) {
                grid2d([0, 2*(box_size.y+4)], cols=1,rows=2)
                    fillet_mask_x(l=box_size.x+4, r=1);
                grid2d([2*(box_size.x+4), 0], cols=2,rows=1)
                    fillet_mask_y(l=box_size.y+4, r=1);
            }
        }
*/
    }
}

module build_lid() {
    up(lid_or_box == "BL" ? box_size.z + base_thickness - lid_overlap: 0) {
        if(lid_type == "T") {
            build_top_insert_lid();
        } else {
            build_sliding_lid(tol=lid_tol, align=V_UP);
        }
    }
}

module build_top_insert_lid() {
    difference() {
        cuboid([box_size.x+wall_thickness*2, box_size.y+wall_thickness*2, lid_thickness], fillet=(no_fillets ? 0 : 1), edges=EDGES_TOP+EDGES_Z_ALL, align=V_UP);

        //cut the groves in the bottom
        down(box_size.z + base_thickness) 
            build_simple_box(tolerance=lid_tol);

        if(!no_fillets) {
            //round the cut corner
            grid2d([2*(box_size.x+wall_thickness-lid_tol), 2*(box_size.y+wall_thickness-lid_tol)], cols=2, rows=2)
                fillet_mask_z(l=lid_overlap, r=1, align=V_UP);
        }
        
        up(2) linear_extrude(2.1)
            text(lid_text, font=font, size=text_size, halign="center", valign="center");
    }
}

module build_sliding_lid(tol=0, orient=ORIENT_X, align=V_CENTER) {
    bevel_thickness=2;
    //     |\                      |\
    //     | \               2-tol | \
    //   2 |  \                    |  \
    //     |___\ <- angle          |___\ <- angle
    //      1.5                      ?
    center=lid_thickness/2-(bevel_thickness);
    angle=atan(2/1.5);
    top_bevel_x=tol/sin(angle)*2;
    bottom_bevel_x=3-(2*(tol/tan(angle))+top_bevel_x);

    //bevel_x = (bevel_thickness-tol)/tan(angle) * 2;
    echo(top_bevel_x=top_bevel_x);
    echo(bottom_bevel_x=bottom_bevel_x);

    orient_and_align(size=[box_size.x+2*wall_thickness, box_size.y+2*wall_thickness, lid_thickness], orient=orient, align=align, orig_orient=ORIENT_X) {
        difference() {
            down(center) {
                group() {
                    cuboid([box_size.x+2*wall_thickness, box_size.y+2*wall_thickness, lid_thickness-bevel_thickness], fillet=1, edges=EDGES_TOP+EDGES_Z_ALL, align=V_UP);
                    up(.001) fwd(wall_thickness/2)
                        prismoid(size1=[box_size.x+bottom_bevel_x, box_size.y+wall_thickness], size2=[box_size.x-top_bevel_x, box_size.y+wall_thickness], h=bevel_thickness-tol, align=V_DOWN);
                    if(false) {
                        //slide knobs
                        fwd(box_size.y/2) up(lid_thickness-bevel_thickness) {
                            yspread(n=3,l=4)
                                cuboid([15,.6,.4], fillet=.2, edges=EDGES_TOP, align=V_UP);
                        }
                    }
                }
            }

            up(lid_thickness/2-1)
            linear_extrude(1.1)
                text(lid_text, font=font, size=text_size, halign="center", valign="center");
        }
    }
}

module build_simple_box(tolerance=0) {
    tol_v=[tolerance, tolerance];
    wall_t=[wall_thickness,wall_thickness,0]*2;
    support_thickness=[lid_overlap,lid_overlap,0];
    difference() {
        //make the outside a bit bigger to remove any extra wierdness
        linear_extrude(box_size.z + base_thickness + lid_overlap)
            square(base_dim + wall_t + tol_v, center=true);

        if(lid_type == "T") {
            //make the inside a bit smaller to add a tolerance in the mating parts
            up(box_size.z + base_thickness) linear_extrude(lid_overlap+.1)
                square(base_dim + wall_t/2 - tol_v, center=true);
        } else {
            up(box_size.z + base_thickness - lid_overlap)
                build_sliding_lid(align=V_UP);
        }


        //cut out the center
        up(base_thickness) linear_extrude(box_size.z + base_thickness + wall_thickness)
            square(base_dim, center=true);

        build_open_pattern_masks(tolerance);
    }

    build_thumb_rings();
}

module build_open_pattern_masks(tol) {
        //cut out front 
        if(front_pattern == "O") {
            up(base_thickness) fwd(10) linear_extrude(box_size.z + base_thickness+1)
                square([box_size.x - corner_width, box_size.y + 10] - [tol, 0], center=true);

            if(!no_fillets) {
                up(box_size.z+base_thickness+wall_thickness) fwd((box_size.y+wall_thickness)/2)
                    grid2d([(box_size.x-corner_width) * 2, 0], cols=2, rows=1)
                        fillet_mask_y(l=2, r=2);
            }
        }

        if(back_pattern == "O") {
            up(base_thickness) back(10) linear_extrude(box_size.z + base_thickness+1)
                square([box_size.x - corner_width, box_size.y + 10] - [tol, 0], center=true);

            if(!no_fillets) {
                up(box_size.z+base_thickness+wall_thickness) back((box_size.y+wall_thickness)/2)
                    grid2d([(box_size.x-corner_width) * 2, 0], cols=2, rows=1)
                        fillet_mask_y(l=2, r=2);
            }
        }

        if(left_pattern == "O") {
            up(base_thickness) left(10) linear_extrude(box_size.z + base_thickness+1)
                square([box_size.x + 10, box_size.y - corner_width] - [0, tol], center=true);

            if(!no_fillets) {
                up(box_size.z+base_thickness+wall_thickness) left((box_size.x+wall_thickness)/2)
                    grid2d([0, (box_size.y-corner_width) * 2], cols=1, rows=2)
                        fillet_mask_x(l=2, r=2);
            }
        }

        if(right_pattern == "O") {
            up(base_thickness) right(10) linear_extrude(box_size.z + base_thickness+1)
                square([box_size.x + 10, box_size.y - corner_width] - [0, tol], center=true);

            if(!no_fillets) {
                up(box_size.z+base_thickness+wall_thickness) right((box_size.x+wall_thickness)/2)
                    grid2d([0, (box_size.y-corner_width) * 2], cols=1, rows=2)
                        fillet_mask_x(l=2, r=2);
            }
        }
}

module build_thumb_rings() {
    if((front_pattern == "H") && front_thumb_slot) {
        thumb_ring([0,-(box_size.y+wall_thickness)/2, box_size.z+base_thickness], [90,0,0]);
    }

    if((back_pattern == "H") && back_thumb_slot) {
        thumb_ring([0,(box_size.y+wall_thickness)/2, box_size.z+base_thickness], [90,0,0]);
    }

    if(left_thumb_slot && left_pattern == "H") {
        thumb_ring([-(box_size.x+wall_thickness)/2,0, box_size.z+base_thickness], [90,0,90]);
    }

    if(right_thumb_slot && right_pattern == "H") {
        thumb_ring([(box_size.x+wall_thickness)/2,0, box_size.z+base_thickness], [90,0,90]);
    }
}


module build_box(tolerance=0) {
    tol=tolerance;
    difference() {
        build_simple_box(tol);
        build_wall_pattern_masks();
        build_thumb_slot_masks();
    }

    build_thumb_rings();
    build_spacer();
    build_open_face_fillets();
}

module build_thumb_slot_masks() {
    if(back_thumb_slot && back_pattern != "O") {
        thumb_hole_mask([0,(box_size.y+wall_thickness)/2, box_size.z+base_thickness]);
    }
    
    if(front_thumb_slot && front_pattern != "O") {
        thumb_hole_mask([0,-(wall_thickness+box_size.y)/2, box_size.z+base_thickness]);
    }

    if(left_thumb_slot && left_pattern != "O") {
        thumb_hole_mask([-(box_size.x+wall_thickness)/2,0, box_size.z+base_thickness], orient=ORIENT_Z_90);
    }

    if(right_thumb_slot && right_pattern != "O") {
        thumb_hole_mask([(box_size.x+wall_thickness)/2,0, box_size.z+base_thickness], orient=ORIENT_Z_90);
    }
}

module build_wall_pattern_masks() {
    side_hex_border=[hex_border, hex_border];
    bottom_hex_border=[hex_border,hex_border];
    if(bottom_pattern == "H") {
        down(.1)
            build_hex_mask(base_dim-bottom_hex_border, hex_size, base_thickness+.2, align=V_UP);
    }

    if(back_pattern == "H") {
        up(box_size.z/2+base_thickness) back((box_size.y+wall_thickness)/2)
            build_hex_mask([box_size.z, box_size.x] - side_hex_border, hex_size, wall_thickness+1, orient=ORIENT_Z);
    }

    if(front_pattern == "H") {
        up(box_size.z/2+base_thickness) forward((box_size.y+wall_thickness)/2)
            build_hex_mask([box_size.z, box_size.x] - side_hex_border, hex_size, wall_thickness+1, orient=ORIENT_Z);
    }

    if(left_pattern == "H") {
        up(box_size.z/2+base_thickness) left((box_size.x+wall_thickness)/2)
            build_hex_mask([box_size.z, box_size.y] - side_hex_border, hex_size, wall_thickness+1, orient=ORIENT_Z_90);
    }

    if(right_pattern == "H") {
        up(box_size.z/2+base_thickness) right((box_size.x+wall_thickness)/2)
            build_hex_mask([box_size.z, box_size.y] - side_hex_border, hex_size, wall_thickness+1, orient=ORIENT_Z_90);
    }
}

module build_open_face_fillets() {
    if(front_pattern == "O") {
        build_opposite_fillet_pair(trans=[0,-(box_size.y/2+1),base_thickness], distance=(box_size.x-corner_width)/2, rot=0);
    }

    if(back_pattern == "O") {
        build_opposite_fillet_pair([0,(box_size.y/2+1),base_thickness], distance=(box_size.x-corner_width)/2, rot=0);
    }

    if(left_pattern == "O") {
        build_opposite_fillet_pair([-(box_size.x/2+1),0,base_thickness], distance=(box_size.y-corner_width)/2, rot=90);
    }

    if(right_pattern == "O") {
        build_opposite_fillet_pair([(box_size.x/2+1),0,base_thickness], distance=(box_size.y-corner_width)/2, rot=90);
    }

}

module build_spacer() {
    wall_t=[wall_thickness,wall_thickness,0]*2;
    num_spacers = number_of_spacers;
    if(number_of_spacers > 0) {
    spacing=(box_size.y-num_spacers*spacer_thickness)/(num_spacers+1)+spacer_thickness;
        yspread(spacing=spacing, n=number_of_spacers) {
            difference() {
                cuboid(spacer_size, align=V_UP);
                if(spacer_pattern == "H") {
                    up(spacer_size.z/2)
                        build_hex_mask([spacer_size.z, spacer_size.x] - (side_hex_border+wall_t), hex_size, wall_thickness+1, orient=ORIENT_Z);
                }

                if(spacer_pattern == "O") {
                    up(base_thickness)
                        cuboid(box_size-[corner_width,-1,-1], align=V_UP);
                }

                if((spacer_pattern != "O") && spacer_thumb_slot) {
                    thumb_hole_mask([0,0,spacer_size.z], [90,0,0]);
                }
            }

            if((spacer_pattern == "H") && spacer_thumb_slot) {
                thumb_ring([0,0,spacer_size.z], [90,0,0]);
            }
        }

        yspread(spacing=spacing, n=number_of_spacers) {
            if(spacer_pattern == "O") {
                build_opposite_fillet_pair([0,0,0], distance=(box_size.x-corner_width)/2, rot=0, thickness=spacer_thickness);
            }
        }
    }
}

module build_hex_mask(size, d, thickness, orient=ORIENT_X, align=V_CENTER) {
    line_t=hex_line_thickness;
    x_stagger = (hex_flat_len(d)+line_t)*sin(60);
    y_stagger = hex_flat_len(d)/2+line_t/2;
    x_rows = rows_for_size_hex(x_stagger, size.x)+1;
    y_rows = rows_for_size_hex(y_stagger, size.y)+1;
    orient_and_align(concat(size,thickness), orient=orient, orig_orient=ORIENT_X, align=align) {
        intersection() {
            grid2d(spacing=[x_stagger,y_stagger], cols=x_rows, rows=y_rows, stagger=true) cylinder(d=d, h=thickness, $fn=6, center=true);
            cuboid([size.x, size.y, thickness], center=true);
        }
    }
}

module build_x_mask(size, sq_size) {
    x_rows = rows_for_size_sq(sq_size, box_size.x)+1;
    y_rows = rows_for_size_sq(sq_size, box_size.y)+1;
    flat_sq_size=sq_size*1.414;
    intersection()
    {
        difference() {
            grid2d(spacing=[sq_size*.707+2,sq_size*.707+2], cols=x_rows, rows=y_rows, stagger=true) zrot(45) cuboid([sq_size,sq_size,4]);
        }
        cuboid([size.x, size.y, 4]);
    }
}

module build_opposite_fillet_pair(trans, distance, rot,thickness=wall_thickness) {
    translate(trans) zrot(rot)
        zrot_copies(n=2, r=distance)
            zrot(90) interior_fillet(l=2, r=interior_fillet_r);
}

module build_fillet_pair(trans, spacing, cols, rows, orient) {
    translate(trans)
        grid2d(spacing=spacing, cols=cols, rows=rows)
            interior_fillet(l=2, r=interior_fillet_r, orient=orient);
}

module thumb_hole_mask(trans, thickness=wall_thickness, orient=ORIENT_Z, align=V_CENTER)
{
    translate(trans)
        orient_and_align([thumb_d, thumb_d, thickness], orient=orient, align=align, orig_orient=ORIENT_Y)
            group () {
                back(thumb_d/2)
                    cuboid([thumb_d,thumb_d,thickness+1]);
                cylinder(d=thumb_d, h=thickness+1, center=true);
            }
}

module thumb_ring(trans, rot)
{
    //add the thumb ring
    translate(trans) rot(rot) {
        difference() {
            outer_d = thumb_d + hex_line_thickness*2;
            cylinder(d=outer_d, h=spacer_size.y, center=true);
            cylinder(d=thumb_d, h=wall_thickness+2, center=true);
            back(outer_d/2)
                cuboid([outer_d,outer_d,wall_thickness+2],center=true);

if(false) {
            if(!no_fillet) {
                up(spacer_size.y/2)
                    fillet_hole_mask(d=thumb_d, fillet=1);
                down(spacer_size.y/2) xrot(180)
                    fillet_hole_mask(d=thumb_d, fillet=1);
            }
}
        }
    }
}
