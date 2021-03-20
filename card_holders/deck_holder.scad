
include <../BOSL/constants.scad>
use <../BOSL/math.scad>
use <../BOSL/transforms.scad>
use <../BOSL/shapes.scad>
use <../BOSL/masks.scad>

//V6 - Added custom spacer spacing
//   - Added multi-line text for lids
//   - Fixed top fillet of spacers to based on spacer thickness

_version_=str("7"); //this is wierd to hide it from the customizer
echo(str("Building Version ",_version_," box..."));

/* [Sleeve/card size] */
//Sleeve/Card size
sleeve_size = [66, 91]; 

//Deck Height/thickness
deck_height = 32;

//If using custom spacer spacing this will auto-calculate the box thickness overriding the above setting
auto_calc_deck_thickness=false;

/* [General] */
//Lid or Box
lid_or_box="B"; //[B:Box, L:Lid, BL:Box and Lid]

//Card storage direction (horizonal is like a stack of cards)
horiz_or_vert="V";// [H:Horizontal, V:Vertical]

is_horiz = horiz_or_vert == "H" ? true : false;

//If the boxes should be stackable (cut the buttom so another box will sit on top)
is_stackable = false;

/* [Lid] */
lid_type="FS"; //[T:Top insert, FS:Front Slide, BS:Back Slide, LS:Left Slide, RS:Right Slide]
lid_text=[];
line_spacing=3;
font="Book Antiqua";
text_size=12;
lid_overlap=1;
lid_thickness=4;//[4:.1:10]
//Lid tolerance
lid_tol=.1; //[0:.01:1]
emboss_tolerance=false;

/* [Side Patterns] */
bottom_pattern="S"; //[H:Hex, S:Solid]
bottom_front_thumb_slot=false; 
bottom_back_thumb_slot=false;
//*not implemented*
bottom_left_thumb_slot=false;
//*not implemented*
bottom_right_thumb_slot=false;
left_pattern="S"; //[H:Hex, S:Solid, O:Open]
left_thumb_slot=false;
right_pattern="S"; //[H:Hex, S:Solid, O:Open]
right_thumb_slot=false;
front_pattern="O"; //[H:Hex, S:Solid, O:Open]
front_thumb_slot=false;
back_pattern="S"; //[H:Hex, S:Solid, O:Open]
back_thumb_slot=false;

/* [Spacer] */
//Number of spacers
number_of_spacers=1;
//How far down the spacer is from the top (mm)
spacer_inset=10;
//Pattern on the spacer
spacer_pattern="O"; //[H:Hex, S:Solid, O:Open]
//thumb slot
spacer_thumb_slot=true;
//spacer thickness
spacer_thickness=2;
// If this is true the number of spacers variable is disregarded and the number of spacers is based on the spacing vector
use_custom_spacer_spacing=true;
// When using custom spacing this is the slot spacing starting from the back of the box to the front
spacer_spacing=[];

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
wall_thickness=3; //[2:.1:10]
//Extra height for vertical orientation
extra_height_for_vert=1;

//thumb slot diameter
thumb_d = 20;

/* [Speed/Render Quality] */
//Remove some fillets to make render faster
no_fillets=true;
//Make curves more curvier
$fn=50;
//is test
is_test=false;

/* [Hidden] */
sleeve_size_w_tol = sleeve_size + [card_tol, card_tol];

auto_deck_height = auto_calc_deck_thickness ? (add(spacer_spacing) + ((len(spacer_spacing)-1)*spacer_thickness)) : deck_height;
if(auto_calc_deck_thickness) {
    echo(str("Building box with thickness ", auto_deck_height));
}

horiz_box = concat(sleeve_size_w_tol, auto_deck_height);
vert_box = [sleeve_size_w_tol.x, auto_deck_height, sleeve_size_w_tol.y + (is_horiz ? 0 : extra_height_for_vert)];
box_size = (is_horiz ? horiz_box : vert_box) + [0,0,lid_overlap];

spacer_size=[box_size.x+2*wall_thickness, spacer_thickness, box_size.z-spacer_inset];

base_dim = [box_size.x, box_size.y];
base = [box_size.x, box_size.y, base_thickness];

function add(v, i = 0, r = 0) = i < len(v) ? add(v, i + 1, r + v[i]) : r;
function rows_for_size_sq(sq_size, fill_size) = ceil(fill_size/sq_size);
function rows_for_size_hex(hex_diam, fill_size) = ceil(fill_size/hex_diam);
function hex_flat_len(diam) = diam*sin(60);

//check to make sure the spacer spacing matches the deck height 
assert(!(use_custom_spacer_spacing && ((add(spacer_spacing) + (len(spacer_spacing) - 1) * spacer_thickness) != auto_deck_height)), 
        "Spacer spacing calculation doesn't match deck height");

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

function calc_text_spacing(i, text_size, spacing, num_lines) = num_lines==1 ? 0 : ((i-1)*(text_size+spacing) + ((num_lines%2 == 0) ? (text_size+spacing)/2:0));

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
        
        if(len(lid_text) > 0) {
            for(i=[0 : len(lid_text)-1]) {
                up(2) fwd(calc_text_spacing(i, text_size, line_spacing, len(lid_text)))
                    linear_extrude(2.1)
                        text(lid_text[i], font=font, size=text_size, halign="center", valign="center");
            }
        }
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

    orient_and_align(size=[box_size.x+2*wall_thickness, box_size.y+2*wall_thickness, lid_thickness], orient=orient, align=align, orig_orient=ORIENT_X) {
        difference() {
            down(center) {
                group() {
                    cuboid([box_size.x+2*wall_thickness, box_size.y+2*wall_thickness, lid_thickness-bevel_thickness], fillet=1, edges=EDGES_TOP+EDGES_Z_ALL, align=V_UP);
                    up(.001) fwd(wall_thickness/2)
                        prismoid(size1=[box_size.x+bottom_bevel_x, box_size.y+wall_thickness], size2=[box_size.x-top_bevel_x, box_size.y+wall_thickness], h=bevel_thickness-tol, align=V_DOWN);
                }
            }

            if(len(lid_text) > 0) {
                for(i=[0 : len(lid_text)-1]) {
                    up(lid_thickness/2-1) fwd(calc_text_spacing(i, text_size, line_spacing, len(lid_text)))
                        linear_extrude(1.1)
                            text(lid_text[i], font=font, size=text_size, halign="center", valign="center");
                }
            }
            if(emboss_tolerance) {
                down(lid_thickness/2)
                    yrot(180) linear_extrude(.7, center=true)
                        text(str("tol: ", lid_tol), size=6, halign="center", valign="center");
            }
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

    build_thumb_rings(top_only=true);
}

module build_open_pattern_masks(tol) {
    //cut out front 
    if(front_pattern == "O") {
        up(base_thickness) fwd(10) linear_extrude(box_size.z + base_thickness+1)
            square([box_size.x - corner_width, box_size.y + 10] - [tol, 0], center=true);

        if(!no_fillets) {
            up(box_size.z+base_thickness+(lid_type=="T"?lid_overlap:-lid_overlap)) fwd((box_size.y+wall_thickness)/2)
                grid2d([(box_size.x-corner_width) * 2, 0], cols=2, rows=1)
                    fillet_mask_y(l=wall_thickness, r=2);
        }
    }

    if(back_pattern == "O") {
        up(base_thickness) back(10) linear_extrude(box_size.z + base_thickness+1)
            square([box_size.x - corner_width, box_size.y + 10] - [tol, 0], center=true);

        if(!no_fillets) {
            up(box_size.z+base_thickness+(lid_type=="T"?lid_overlap:-lid_overlap)) back((box_size.y+wall_thickness)/2)
                grid2d([(box_size.x-corner_width) * 2, 0], cols=2, rows=1)
                    fillet_mask_y(l=wall_thickness, r=2);
        }
    }

    if(left_pattern == "O") {
        up(base_thickness) left(10) linear_extrude(box_size.z + base_thickness+1)
            square([box_size.x + 10, box_size.y - corner_width] - [0, tol], center=true);

        if(!no_fillets) {
            up(box_size.z+base_thickness+wall_thickness+(lid_type=="T"?lid_overlap:-lid_overlap)) left((box_size.x+wall_thickness)/2)
                grid2d([0, (box_size.y-corner_width) * 2], cols=1, rows=2)
                    fillet_mask_x(l=wall_thickness, r=2);
        }
    }

    if(right_pattern == "O") {
        up(base_thickness) right(10) linear_extrude(box_size.z + base_thickness+1)
            square([box_size.x + 10, box_size.y - corner_width] - [0, tol], center=true);

        if(!no_fillets) {
            up(box_size.z+base_thickness+wall_thickness+(lid_type=="T"?lid_overlap:-lid_overlap)) right((box_size.x+wall_thickness)/2)
                grid2d([0, (box_size.y-corner_width) * 2], cols=1, rows=2)
                    fillet_mask_x(l=wall_thickness, r=2);
        }
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

    if(bottom_front_thumb_slot && front_pattern == "O") {
        thumb_hole_mask([0,-(wall_thickness+box_size.y)/2, base_thickness/2], thickness=base_thickness, orient=ORIENT_YNEG);
    }

    if(bottom_back_thumb_slot && front_pattern == "O") {
        thumb_hole_mask([0,(wall_thickness+box_size.y)/2, base_thickness/2], thickness=base_thickness, orient=ORIENT_Y);
    }
}

module build_thumb_rings(top_only=false) {
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

    if(!top_only) {
        if(bottom_front_thumb_slot && front_pattern == "O" && bottom_pattern == "H") {
            thumb_ring([0,-(wall_thickness+box_size.y)/2, base_thickness/2], [180,0,0], thickness=base_thickness);
        }

        if(bottom_back_thumb_slot && front_pattern == "O" && bottom_pattern == "H") {
            thumb_ring([0,(wall_thickness+box_size.y)/2, base_thickness/2], [0,0,0], thickness=base_thickness);
        }
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
        build_opposite_fillet_pair(trans=[0,-((box_size.y+wall_thickness)/2),base_thickness], distance=(box_size.x-corner_width)/2, rot=0);
    }

    if(back_pattern == "O") {
        build_opposite_fillet_pair([0,((box_size.y+wall_thickness)/2),base_thickness], distance=(box_size.x-corner_width)/2, rot=0);
    }

    if(left_pattern == "O") {
        build_opposite_fillet_pair([-((box_size.x+wall_thickness)/2),0,base_thickness], distance=(box_size.y-corner_width)/2, rot=90);
    }

    if(right_pattern == "O") {
        build_opposite_fillet_pair([((box_size.x+wall_thickness)/2),0,base_thickness], distance=(box_size.y-corner_width)/2, rot=90);
    }

}

function build_spacing_array(num, dist, thickness) = [for(i = [1:num]) [0,-(i*((dist-num*thickness)/(num+1)+thickness)-thickness/2),0]];
function sumv(v,i,s=0) = (i==s ? v[i] : v[i] + sumv(v,i-1,s));

module build_spacer() {
    wall_t=[wall_thickness,wall_thickness,0]*2;

    num_spacers = use_custom_spacer_spacing ? (len(spacer_spacing) - 1) : number_of_spacers;
    spacing = use_custom_spacer_spacing ? [for(i = [0:num_spacers-1]) [0, -(sumv(spacer_spacing, i)+i*spacer_thickness+spacer_thickness/2), 0]]
                : build_spacing_array(num_spacers, box_size.y, spacer_thickness);
    if(num_spacers > 0) {
        //spacing=(box_size.y-num_spacers*spacer_thickness)/(num_spacers+1)+spacer_thickness;
        back(box_size.y/2) {
            place_copies(spacing) {
                difference() {
                    cuboid(spacer_size, align=V_UP);
                    if(spacer_pattern == "H") {
                        up(spacer_size.z/2)
                            build_hex_mask([spacer_size.z, spacer_size.x] - (side_hex_border+wall_t), hex_size, wall_thickness+1, orient=ORIENT_Z);
                    }

                    if(spacer_pattern == "O") {
                        up(base_thickness)
                            cuboid(box_size-[corner_width,-1,-1], align=V_UP);

                        if(!no_fillets) {
                            up(box_size.z-spacer_inset)
                                grid2d([(box_size.x-corner_width) * 2, 0], cols=2, rows=1)
                                    fillet_mask_y(l=spacer_thickness, r=2);
                        }
                    }

                    if((spacer_pattern != "O") && spacer_thumb_slot) {
                        thumb_hole_mask([0,0,spacer_size.z], [90,0,0]);
                    }

                }

                if((spacer_pattern == "H") && spacer_thumb_slot) {
                    thumb_ring([0,0,spacer_size.z], [90,0,0]);
                }

                if(spacer_pattern == "O") {
                    build_opposite_fillet_pair([0,0,base_thickness], distance=(box_size.x-corner_width)/2, rot=0, thickness=spacer_thickness);
                }
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
            zrot(90) interior_fillet(l=thickness, r=interior_fillet_r);
}

module build_fillet_pair(trans, spacing, cols, rows, orient) {
    translate(trans)
        grid2d(spacing=spacing, cols=cols, rows=rows)
            interior_fillet(l=2, r=interior_fillet_r, orient=orient);
}

module thumb_hole_mask(trans, thickness=wall_thickness, orient=ORIENT_Z, align=V_CENTER) {
    translate(trans) {
        orient_and_align([thumb_d, thumb_d, thickness], orient=orient, align=align, orig_orient=ORIENT_Y) {
            group () {
                back(thumb_d/2)
                    cuboid([thumb_d,thumb_d,thickness+1]);
                cylinder(d=thumb_d, h=thickness+1, center=true);

                back(thumb_d/2)
                    grid2d(spacing=[thumb_d, wall_thickness, thumb_d], cols=2,rows=2, orient=ORIENT_Y)
                        fillet_mask_y(l=thumb_d, r=1);

                up(wall_thickness/2)
                    fillet_hole_mask(d=thumb_d, fillet=1);
                down(wall_thickness/2) yrot(180)
                    fillet_hole_mask(d=thumb_d, fillet=1);
            }
        }
    }
}

module thumb_ring(trans, rot, thickness=wall_thickness)
{
    //add the thumb ring
    translate(trans) rot(rot) {
        difference() {
            outer_d = thumb_d + hex_line_thickness*2;
            cylinder(d=outer_d, h=thickness, center=true);
            cylinder(d=thumb_d, h=thickness+2, center=true);
            back(outer_d/2)
                cuboid([outer_d,outer_d,wall_thickness+2],center=true);

            if(true) {
                //this is to fillet the rounded part of the thumb ring
                if(!no_fillets) {
                    up(thickness/2)
                        fillet_hole_mask(d=thumb_d, fillet=1);
                    down(thickness/2) xrot(180)
                        fillet_hole_mask(d=thumb_d, fillet=1);
                }
            }
        }
    }
}
