

include <../BOSL/constants.scad>
use <../BOSL/shapes.scad>
use <../BOSL/transforms.scad>

$fn=100;

base_d=22;
base_h=2.6;

token_size=[19, 38,.8];
token_tab=[5,base_h,.8];

magnet_d=5.3;
magnet_h=2.2;

print_top=true;
print_base=true;

if(print_top) {
    build_top();
}
if(print_base) {
    translate(print_top ? [0,-20,0] : [0,0,0])
        build_bottom();
}

module build_top() {
    cuboid(token_size, align=V_BACK+V_UP);
    build_tab(token_tab-[0,.2,0],edges=EDGES_Z_FR);
}

module build_bottom() {
    difference() {
        cyl(d1=base_d,d2=base_d-1,l=base_h,fillet2=1,align=V_UP);
        up(base_h-magnet_h+.01) fwd(5)
            cylinder(d=magnet_d, h=magnet_h);
        up(base_h-magnet_h+.01) back(5)
            cylinder(d=magnet_d, h=magnet_h);
        build_tab(token_tab+[.1,.1,0], orient=ORIENT_YNEG, align=V_CENTER+V_UP);
    }
}

module build_tab(size=token_tab, orient=ORIENT_Z, align=V_FWD+V_UP, edges=EDGES_NONE) {
    //prismoid(size1=[5+tol,.8+tol], size2=[3+tol,.8],h=tab_h, orient=orient,align=align);
    orient_and_align(size, orient=orient, align=align)
        cuboid(size, fillet=1, edges=edges);
}

