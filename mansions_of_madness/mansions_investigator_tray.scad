
__version__ = 1;

include <../BOSL/constants.scad>;
use <../BOSL/shapes.scad>;
use <../BOSL/transforms.scad>;
use <../BOSL/masks.scad>;

$fn=50;

box_w=105;
investigator_h=40;

wall_t=1.2;

magnet_d=5.4;
magnet_t=2;
mag_hole_w=magnet_d/2+.2;

outer_wall_w=magnet_d+.8;

bottom_t=.4;

investigator_w=(box_w-4*wall_t)/3;
echo(investigator_w=investigator_w);

difference() {
    cuboid([box_w,box_w,investigator_h+bottom_t], align=V_UP, fillet=.6);
    up(bottom_t)
    grid2d(spacing=investigator_w+wall_t, cols=3, rows=3)
        cuboid([investigator_w,investigator_w, investigator_h+10], align=V_UP);
}

