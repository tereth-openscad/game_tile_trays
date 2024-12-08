
include <../BOSL/constants.scad>
use <../BOSL/shapes.scad>
use <../BOSL/masks.scad>
use <../BOSL/transforms.scad>
use <../BOSL/math.scad>


box_dim=[75.5,40,15];

card_w=73.5;
card_8_t=12;
card_7_t=10;

difference() {
    cuboid(box_dim, align=V_FWD+V_UP);
    up(1) fwd(1)
    cuboid([card_w,card_8_t,15], align=V_FWD+V_UP);
    up(1) fwd(1+card_8_t+1)
    cuboid([card_w,card_8_t,15], align=V_FWD+V_UP);
    up(1) fwd(1+2*card_8_t+1+1)
    cuboid([card_w,card_8_t,15], align=V_FWD+V_UP);
}

