
include <../BOSL/constants.scad>
use <../BOSL/shapes.scad>
use <../BOSL/beziers.scad>

$fn = 50;

module heart(radius) {
    square([radius*2,radius*2],center=true);
    translate([0,radius,0])
        circle(r=radius);
    translate([radius,0,0])
        circle(r=radius);
}


module build_teardrop() {
linear_extrude(10)
    translate([0,30,0])
        rotate([0,0,155])
            difference() {
                offset(r=3)
                offset(delta=-3)
                    teardrop2d(r=28,ang=25);
                offset(r=-3)
                    teardrop2d(r=28,ang=25);
            }
}



module build_heart_box() {
    linear_extrude(2)
        offset(r=3)
        offset(delta=-3)
            heart(30);

    linear_extrude(10)
        difference() {
            offset(r=3)
            offset(delta=-3)
                heart(30);
            offset(r=-3)
                heart(30);
        }
}


module build_teardrop() {
    bez1 = [
        [0,   0],  [10,  0],
        [40,  -10], [60,  0], [55, -20],  
        [20,  -60],[0,   -60]  
    ];
    closed=bezier_close_to_axis(bez1,axis="Y");
    c2=bezier_offset(5,closed);
    trace_bezier(c2, N=3, size=0.5);
    //linear_extrude_bezier(c2,5);


    linear_extrude(5)
        translate([0,-30])
        difference() {
            circle(r=30);
            translate([0,-30])
                square([60,60]);
        }
}


!build_teardrop();
mirror([0,1,0])
    build_teardrop();
