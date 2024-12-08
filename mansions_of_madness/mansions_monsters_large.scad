
__version__ = 1;

include <../BOSL/constants.scad>;
use <../BOSL/shapes.scad>;
use <../BOSL/transforms.scad>;
use <../BOSL/masks.scad>;
include <mansions_divided_box.scad>;

$fn=50;

bottom_t=.4;
wall_t=1.2;
small_box_h=40+bottom_t;
big_box_h=2*small_box_h;
max_box=[285,285,big_box_h];

box_number=0; //[0:large, 1:extra_large, 2:small, 3:medium, 4:medium_tall, 99:test]

monster_tile=[35.4,35.4,2.25];
//small_monster=[monster_tile.x, 28.5, small_box_h];
small_monster=[28.6, 28.5, small_box_h];
med_monster=[61.9,53.4, big_box_h];
large_monster=[77,82,big_box_h];
ex_large_monster=[77,112,big_box_h];

// 2x star spawn
// 1x ancient basilisk
// 1x formless spawn
if(box_number == 0)
    build_large_box();


// 1x lloigor
// 2x star vampire (combined in one slot - sideways) 
if(box_number == 1)
    build_ex_large_box();

//256+6 = 262;
//total box width = 285

// 24 smalls
// 6 - cultists
// 4 - deep one hybrid
// 2 - ghost
// 2 - hired gun
// 2 - hunting deep one
// 2 - skeleton
// 4 - thrall
// 2 - warlock
//can do two stacked trays

if(box_number == 2)
    build_small_box();

if(box_number == 3)
    build_med_box();

if(box_number == 4)
    build_med_tall_box();

// 2 smalls
// 1 - child of dagon
// 1 - priest of dagon

module build_large_box() { build_divided_box(large_monster, columns=2,rows=2,string="large"); }
module build_ex_large_box() { build_divided_box(ex_large_monster,columns=2,rows=1,string="xl"); }
module build_small_box() { 
    build_divided_box(small_monster,columns=3,rows=4,string="small"); 
    small_box_size=compute_box_size(small_monster,3,4);
    right(small_box_size.x/2+36.8/2-wall_t/2) {
        difference() {
            cuboid([36.8+wall_t,120,small_box_h], align=V_UP, fillet=.6);
            up(bottom_t) {
                back(small_box_size.y/2 - small_monster.y/2-wall_t)
                    cuboid([36.8-wall_t,small_monster.y,small_monster.z]+[0,0,1], align=V_UP);
                
                back(small_box_size.y/2 - small_monster.y - 2*wall_t-86.7/2/2)
                    cuboid([36.8-wall_t,86.7/2,small_monster.z]+[0,0,1], align=V_UP);

                back(small_box_size.y/2 - small_monster.y - 3*wall_t-3*86.7/4)
                    cuboid([36.8-wall_t,86.7/2,small_monster.z]+[0,0,1], align=V_UP);
            }
        }
    }
}
module build_med_box() { 
    difference() {
        cuboid([126.8,89.6,small_box_h], align=V_UP, fillet=.6);
        // 122, 86

        //Deep One

        // 7 = 35.6
        // 10 = 50.8
        // 8 = 122/3
        up(bottom_t) {
            left(126.8/2 - 35.6/2 - wall_t) back(89.6/2 - 35.6/2 - wall_t)
                cuboid([35.6, 35.6,small_box_h], align=V_UP);
            left(126.8/2 - 35.6/2 - 35.6 - 2*wall_t) back(89.6/2 - 35.6/2 - wall_t)
                cuboid([35.6, 35.6,small_box_h], align=V_UP);
            left(126.8/2 - 50.8/2 - 2*35.6 - 3*wall_t) back(89.6/2 - 35.6/2 - wall_t)
                cuboid([50.8, 35.6,small_box_h], align=V_UP);

            left(126.8/2 - 122/3/2 - wall_t) fwd(89.6/2-50.8/2-wall_t)
                cuboid([122/3, 50.8,small_box_h], align=V_UP);
            left(126.8/2 - 122/3/2 - 122/3 - 2*wall_t) fwd(89.6/2-50.8/2-wall_t)
                cuboid([122/3, 50.8,small_box_h], align=V_UP);
            left(126.8/2 - 122/3/2 - 2*122/3 - 3*wall_t) fwd(89.6/2-50.8/2-wall_t)
                cuboid([122/3, 50.8,small_box_h], align=V_UP);
        }
    }
}

module build_med_tall_box() {
    difference() {
        mt_size=[126.8,75.4,big_box_h];
        cuboid(mt_size, align=V_UP, fillet=.6);
        ds_size=[46,(mt_size.y-3*wall_t)/2,big_box_h+1];
        tg_size=[mt_size.x-ds_size.x-3*wall_t,mt_size.y-2*wall_t,big_box_h+1];
        up(bottom_t) {
            left(mt_size.x/2-wall_t-ds_size.x/2) {
                back(mt_size.y/2-wall_t-ds_size.y/2)
                    cuboid(ds_size, align=V_UP);
                back(mt_size.y/2-2*wall_t-3*ds_size.y/2)
                    cuboid(ds_size, align=V_UP);
            }
            right(mt_size.x/2-tg_size.x/2-wall_t)
                cuboid(tg_size, align=V_UP);
        }
    }
}

if(box_number == 99) {
    large_box_size=compute_box_size(large_monster,columns=2,rows=2);
    ex_large_box_size=compute_box_size(ex_large_monster,2,1);
    small_box_size=compute_box_size(small_monster,3,4);
    med_box_size=[126.8,89.6,small_box_h];
    med_tall_box_size=[126.8,75.4,big_box_h];

    // cardboard box size
    fwd(max_box.y/2) right(max_box.y/2)
        build_divided_box(max_box,columns=1,rows=1,string="cardboard");
    // large box
    right(max_box.y-large_box_size.x/2) fwd(large_box_size.y/2)
        build_large_box();
    // ex large box
    right(max_box.y-ex_large_box_size.x/2) fwd(ex_large_box_size.y/2+large_box_size.y)
        build_ex_large_box();

    right(small_box_size.x/2) fwd(small_box_size.y/2) {
        build_small_box();
        up(small_box_size.z)
            build_small_box();
    }

    right(med_box_size.x/2) fwd(small_box_size.y+med_box_size.y/2) {
        build_med_box();
        up(small_box_size.z)
            build_med_box();
    }

    right(med_tall_box_size.x/2) fwd(small_box_size.y+med_box_size.y+med_tall_box_size.y/2)
        build_med_tall_box();
}


