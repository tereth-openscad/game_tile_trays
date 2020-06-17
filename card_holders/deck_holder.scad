
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

/* [Orientation] */
//Card storage direction (horizonal is like a stack of cards)
horiz_or_vert="V";// [H:Horizontal, V:Vertical]

//Lid or Box
lid_or_box="B"; //[B:Box, L:Lid]

is_horiz = horiz_or_vert == "H" ? true : false;

//If the boxes should be stackable (cut the buttom so another box will sit on top)
is_stackable = false;

/* [Lid type] */
lid_type="T"; //[T:Top insert, FS:Front Slide, RS:Rear Slide]

/* [Lid Text] */
lid_text="Fighter";
font="Book Antiqua";
text_size=12;

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
//Add a spacer to the box (only really useful for a vertical box)
add_spacer=true; //only set this if is_horiz is false
//Spacer position (ratio of front:back pocket size)
spacing=.5; 
//How far down the spacer is from the top (mm)
spacer_inset=15;
//Pattern on the spacer
spacer_pattern="H"; //[H:Hex, S:Solid, O:Open]
//thumb slot
spacer_thumb_slot=true;

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
//Lid tolerance
lid_tol=.4;
//card tolerance
card_tol=1;
//Thickness of the base
base_thickness=2;
//Wall thickness
wall_thickness=2;
//Extra height for vertical orientation
extra_height_for_vert=1;

//thumb slot diameter
thumb_d = 20;

/* [Speed/Render Quality] */
//Remove some fillets to make render faster
no_fillets=true;
//Make curves more curvier
$fn=25;

/* [Hidden] */
sleeve_size_w_tol = sleeve_size + [card_tol, card_tol];

horiz_box = concat(sleeve_size_w_tol, deck_height);
vert_box = [sleeve_size_w_tol.x, deck_height, sleeve_size_w_tol.y + (is_horiz ? 0 : extra_height_for_vert)];
box_size = is_horiz ? horiz_box : vert_box;

spacer_size=[box_size.x+2*wall_thickness, wall_thickness, box_size.z-spacer_inset];

base_dim = [box_size.x, box_size.y];
base = [box_size.x, box_size.y, base_thickness];

function rows_for_size_sq(sq_size, fill_size) = ceil(fill_size/sq_size);
function rows_for_size_hex(hex_diam, fill_size) = ceil(fill_size/hex_diam);
function hex_flat_len(diam) = diam*sin(60);

if(lid_or_box == "B") {
    build_bottom();
} else {
    build_lid();
}

module build_bottom() {
    difference() {
        build_box();

        //fillet the outside corners
        if(!no_fillets) {
            grid2d([2*(box_size.x+wall_thickness*2), 2*(box_size.y+wall_thickness*2)], cols=2, rows=2)
                fillet_mask_z(l=box_size.z + base_thickness + wall_thickness, r=1, align=V_UP);
            grid2d([0, 2*(box_size.y+4)], cols=1,rows=2)
                fillet_mask_x(l=box_size.x+4, r=1);
            grid2d([2*(box_size.x+4), 0], cols=2,rows=1)
                fillet_mask_y(l=box_size.y+4, r=1);
        }

        if(is_stackable) {
            //cut the groves in the bottom
            down(box_size.z+base_thickness) 
                build_simple_box(tolerance=lid_tol);
            //round the cut corner
            if(!no_fillets) {
                grid2d([2*(box_size.x+1.6), 2*(box_size.y+1.6)], cols=2, rows=2)
                    fillet_mask_z(l=2, r=1, align=V_UP);
            }
        } else {
            if(!no_fillets) {
            //round the corners
                grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
                    fillet_corner_mask(r=1);
            }
        }
    }
}

module build_lid()
{
    difference() {
        cuboid([box_size.x+4, box_size.y+4, 4], align=V_UP);

        if(!no_fillets) {
            //fillet the outside corners
            grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
                fillet_mask_z(l=box_size.z + 2, r=1, align=V_UP);
            grid2d([0, 2*(box_size.y+4)], cols=1,rows=2)
                fillet_mask_x(l=box_size.x+4, r=1);
            grid2d([2*(box_size.x+4), 0], cols=2,rows=1)
                fillet_mask_y(l=box_size.y+4, r=1);
        }

        //cut the groves in the bottom
        down(box_size.z) 
            build_simple_box(tolerance=lid_tol);

        if(!no_fillets) {
            //round the cut corner
            grid2d([2*(box_size.x+1.6), 2*(box_size.y+1.6)], cols=2, rows=2)
                fillet_mask_z(l=2, r=1, align=V_UP);
        }

        
        up(2) linear_extrude(2.1)
            text(lid_text, font=font, size=text_size, halign="center", valign="center");
    }
}

module build_simple_box(tolerance=0) {
    tol=tolerance;
    wall_t=[wall_thickness,wall_thickness,0]*2;
    support_thickness=[wall_thickness,wall_thickness,0];
    difference() {
        //make the outside a bit bigger to remove any extra wierdness
        linear_extrude(box_size.z + base_thickness + wall_thickness)
            square(base_dim + wall_t + [tol, tol, 0], center=true);
        //make the inside a bit smaller to add a tolerance in the mating parts
        up(box_size.z + base_thickness) linear_extrude(box_size.z + base_thickness)
            square(base_dim + support_thickness - [tol, tol, 0], center=true);
        //cut out the center
        up(base_thickness) linear_extrude(box_size.z + base_thickness)
            square(base_dim, center=true);

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

    build_thumb_rings();

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
        thumb_hole_mask([0,box_size.y/2, box_size.z+base_thickness], [90,0,0]);
    }
    
    if(front_thumb_slot && front_pattern != "O") {
        thumb_hole_mask([0,-box_size.y/2, box_size.z+base_thickness], [90,0,0]);
    }

    if(left_thumb_slot && left_pattern != "O") {
        thumb_hole_mask([-box_size.x/2,0, box_size.z+base_thickness], [90,0,90]);
    }

    if(right_thumb_slot && right_pattern != "O") {
        thumb_hole_mask([box_size.x/2,0, box_size.z+base_thickness], [90,0,90]);
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
    if(add_spacer) {
        fwd(box_size.y/2-box_size.y*spacing) {
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

        if(spacer_pattern == "O") {
            build_opposite_fillet_pair([0,0,0], distance=(box_size.x-corner_width)/2, rot=0);
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

module build_opposite_fillet_pair(trans, distance, rot) {
    translate(trans) zrot(rot)
        zrot_copies(n=2, r=distance)
            zrot(90) interior_fillet(l=2, r=interior_fillet_r);
}

module build_fillet_pair(trans, spacing, cols, rows, orient) {
    translate(trans)
        grid2d(spacing=spacing, cols=cols, rows=rows)
            interior_fillet(l=2, r=interior_fillet_r, orient=orient);
}

module thumb_hole_mask(trans, rot, thickness=5)
{
    translate(trans) rot(rot)
    group() {
        back(thumb_d/2)
            cuboid([thumb_d,thumb_d,thickness]);
        cylinder(d=thumb_d, h=thickness, center=true);
    }
}

module thumb_ring(trans, rot)
{
    //add the thumb ring
    translate(trans) rot(rot) {
        difference() {
            outer_d = thumb_d + hex_line_thickness*2;
            cylinder(d=outer_d, h=spacer_size.y, center=true);
            cylinder(d=thumb_d, h=5, center=true);
            back(outer_d/2)
                cuboid([outer_d,outer_d,5],center=true);
        }
    }
}
