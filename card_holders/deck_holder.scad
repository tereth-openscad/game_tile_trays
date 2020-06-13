
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

/* [Lid Text] */
lid_text="Fighter";
font="Book Antiqua";
text_size=12;

/* [Features] */
//Add a spacer to the box (only really useful for a vertical box)
add_spacer=true; //only set this if is_horiz is false
//Spacer position (ratio of front:back pocket size)
spacing=.5; 
//How far down the spacer is from the top (mm)
spacer_inset=15;

/* [Feature sizes] */
//Size of Hex Cut Outs (for sides/bottom/spacer)
hex_size=25;
//Thickness of lines between hex cutouts
hex_line_thickness=3;

//How much of the card should be covered by the front
corner_width = 15;

//How much of the fillet should there be in the front bottom
interior_fillet_r=20;

//Lid tolerance
lid_tol=.4;
//card tolerance
card_tol=1;
//Thickness of the base
base_thickness=2;
//Extra height for vertical orientation
extra_height_for_vert=4;

/* [Speed] */
$fn=25;

/* [Hidden] */
sleeve_size_w_tol = sleeve_size + [card_tol, card_tol];

horiz_box = concat(sleeve_size_w_tol, deck_height);
vert_box = [sleeve_size_w_tol.x, deck_height, sleeve_size_w_tol.y + (is_horiz ? 0 : extra_height_for_vert)];
box_size = is_horiz ? horiz_box : vert_box;

spacer_size=[box_size.x+4, 2, box_size.z-spacer_inset];

hero_deck_thickness=11;
hero_extras_thickness=15;
base_dim = [box_size.x, box_size.y];
base = [box_size.x, box_size.y, 2];

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
        grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
            fillet_mask_z(l=box_size.z + 2, r=1, align=V_UP);
        grid2d([0, 2*(box_size.y+4)], cols=1,rows=2)
            fillet_mask_x(l=box_size.x+4, r=1);
        grid2d([2*(box_size.x+4), 0], cols=2,rows=1)
            fillet_mask_y(l=box_size.y+4, r=1);

        if(is_stackable) {
            //cut the groves in the bottom
            down(box_size.z) 
                build_simple_box(tolerance=lid_tol);
            //round the cut corner
            grid2d([2*(box_size.x+1.6), 2*(box_size.y+1.6)], cols=2, rows=2)
                fillet_mask_z(l=2, r=1, align=V_UP);
        } else {
            //round the corners
            grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
                fillet_corner_mask(r=1);
        }
    }
}

module build_lid()
{
    difference() {
        cuboid([box_size.x+4, box_size.y+4, 4], align=V_UP);

        //fillet the outside corners
        grid2d([2*(box_size.x+4), 2*(box_size.y+4)], cols=2, rows=2)
            fillet_mask_z(l=box_size.z + 2, r=1, align=V_UP);
        grid2d([0, 2*(box_size.y+4)], cols=1,rows=2)
            fillet_mask_x(l=box_size.x+4, r=1);
        grid2d([2*(box_size.x+4), 0], cols=2,rows=1)
            fillet_mask_y(l=box_size.y+4, r=1);

        //cut the groves in the bottom
        down(box_size.z) 
            build_simple_box(tolerance=lid_tol);
        //round the cut corner
        grid2d([2*(box_size.x+1.6), 2*(box_size.y+1.6)], cols=2, rows=2)
            fillet_mask_z(l=2, r=1, align=V_UP);

        
        up(2) linear_extrude(2.1)
            text(lid_text, font=font, size=text_size, halign="center", valign="center");
    }
}

module build_opposite_fillet_pair(trans, rot) {
    translate(trans) zrot(rot)
        zrot_copies(n=2, r=(box_size.x-corner_width)/2)
            zrot(90) interior_fillet(l=2, r=interior_fillet_r);
}

module build_fillet_pair(trans, spacing, cols, rows, orient) {
    translate(trans)
        grid2d(spacing=spacing, cols=cols, rows=rows)
            interior_fillet(l=2, r=interior_fillet_r, orient=orient);
}

module build_simple_box(tolerance=0) {
    tol=tolerance;
    wall_thickness=[4,4,0];
    support_thickness=[2,2,0];
    difference() {
        //make the outside a bit bigger to remove any extra wierdness
        linear_extrude(box_size.z + base_thickness)
            square(base_dim + wall_thickness + [tol, tol, 0], center=true);
        //make the inside a bit smaller to add a tolerance in the mating parts
        up(box_size.z) linear_extrude(box_size.z + base_thickness)
            square(base_dim + support_thickness - [tol, tol, 0], center=true);
        //cut out the center
        up(base_thickness) linear_extrude(box_size.z + base_thickness)
            square(base_dim, center=true);
        //cut out front 
        up(base_thickness) fwd(10) linear_extrude(box_size.z + base_thickness)
            square([box_size.x - corner_width, box_size.y + 10] - [tol, 0], center=true);
    }
}


module build_box(tolerance=0) {
    tol=tolerance;
    wall_thickness=[4,4,0];
    support_thickness=[2,2,0];
    difference() {
        build_simple_box(tol);

        //pattern the back
        up(box_size.z/2) back((box_size.y+wall_thickness.x)/2+.1) xrot(90) zrot(90)
            build_hex_mask([box_size.z, box_size.x] - [8,4], hex_size, 5);

        //pattern the sides
        up(box_size.z/2) left((box_size.x)/2+5/2-.1) yrot(90)
            build_hex_mask([box_size.z, box_size.y] - [8,4], hex_size, 5);
        up(box_size.z/2) right((box_size.x)/2-.1) yrot(90)
            build_hex_mask([box_size.z, box_size.y] - [8,4], hex_size, 5);

        //pattern the bottom
        down(.1)
            build_hex_mask(base_dim-[4,4], hex_size, 5);
    }
    if(add_spacer) {
        fwd(box_size.y/2-box_size.y*spacing)
        difference() {
            cuboid(spacer_size, align=V_UP);
            up(spacer_size.z/2) back(1.1) xrot(90) zrot(90)
                build_hex_mask([spacer_size.z, spacer_size.x] - [10,10], hex_size, 5);
        }
    }
    build_opposite_fillet_pair([0,-(box_size.y/2+1),2], 0);
}

module build_hex_mask(size, d, thickness) {
    line_t=hex_line_thickness;
    x_stagger = (hex_flat_len(d)+line_t)*sin(60);
    y_stagger = hex_flat_len(d)/2+line_t/2;
    x_rows = rows_for_size_hex(x_stagger, size.x)+1;
    y_rows = rows_for_size_hex(y_stagger, size.y)+1;
    intersection() {
        grid2d(spacing=[x_stagger,y_stagger], cols=x_rows, rows=y_rows, stagger=true) cylinder(d=d, h=thickness, $fn=6);
        cuboid([size.x, size.y, thickness]);
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

