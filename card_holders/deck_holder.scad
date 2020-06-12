
include <../hexgrid.scad>
include <../BOSL/constants.scad>
use <../BOSL/math.scad>
use <../BOSL/transforms.scad>
use <../BOSL/shapes.scad>
use <../BOSL/masks.scad>

$fn=75;

sleeve_size = [66, 91];
sleeve_size_w_tol = [66, 91] + [1, 1];
deck_height = 80;
base = [sleeve_size_w_tol.x, sleeve_size_w_tol.y, 2];
corner_width = 15;
interior_fillet_r=20;

difference() {
    build_box();

    //fillet the outside corners
    grid2d([2*(sleeve_size_w_tol.x+4), 2*(sleeve_size_w_tol.y+4)], cols=2, rows=2)
        fillet_mask_z(l=deck_height + 2, r=1, align=V_UP);
    grid2d([0, 2*(sleeve_size_w_tol.y+4)], cols=1,rows=2)
        fillet_mask_x(l=sleeve_size_w_tol.x, r=1);
    grid2d([2*(sleeve_size_w_tol.x+4), 0], cols=2,rows=1)
        fillet_mask_y(l=sleeve_size_w_tol.y, r=1);
    grid2d([2*(sleeve_size_w_tol.x+1.6), 2*(sleeve_size_w_tol.y+1.6)], cols=2, rows=2)
        fillet_mask_z(l=2, r=1, align=V_UP);

    down(deck_height) 
        build_box(tolerance=.4);
    down(1.5)
        grid2d(spacing=[9,5], cols=7, rows=17, stagger=true) cylinder(d=10, h=4, $fn=6);
}

translate([0, -(sleeve_size_w_tol.y - (corner_width + 1))/2, 2])
    grid2d(spacing=[(sleeve_size_w_tol.x+2), 0], cols=2, rows=1)
        interior_fillet(l=2, r=interior_fillet_r);

translate([0, (sleeve_size_w_tol.y-(corner_width + 1))/2, 2])
    grid2d(spacing=[(sleeve_size_w_tol.x+2), 0], cols=2, rows=1)
        interior_fillet(l=2, r=interior_fillet_r, orient=ORIENT_XNEG);

translate([(sleeve_size_w_tol.x-(corner_width + 1))/2, 0, 2])
    grid2d(spacing=[0, (sleeve_size_w_tol.y+2)], cols=1, rows=2)
        interior_fillet(l=2, r=interior_fillet_r, orient=ORIENT_Y);

translate([-(sleeve_size_w_tol.x-(corner_width + 1))/2, 0, 2])
    grid2d(spacing=[0, (sleeve_size_w_tol.y+2)], cols=1, rows=2)
        interior_fillet(l=2, r=interior_fillet_r, orient=ORIENT_YNEG);

module build_box(tolerance=0) {
    difference() {
        tol=tolerance;
        wall_thickness=[4,4,0];
        support_thickness=[2,2,0];
        //make the outside a bit bigger to remove any extra wierdness
        linear_extrude(deck_height + 2)
            square(sleeve_size_w_tol + wall_thickness + [tol, tol, 0], center=true);
        //make the inside a bit smaller to add a tolerance in the mating parts
        up(deck_height) linear_extrude(deck_height + 2)
            square(sleeve_size_w_tol + support_thickness - [tol, tol, 0], center=true);
        //cut out the center
        up(2) linear_extrude(deck_height + 2)
            square(sleeve_size_w_tol, center=true);
        //cut out one set of sides
        up(2) linear_extrude(deck_height + 2)
            square([sleeve_size.x - corner_width, sleeve_size.y + 10] - [tol, 0], center=true);
        //cut out the other set of sides
        up(2) linear_extrude(deck_height + 2)
            square([sleeve_size.x + 10, sleeve_size.y - corner_width] - [0, tol], center=true);
    }
}

