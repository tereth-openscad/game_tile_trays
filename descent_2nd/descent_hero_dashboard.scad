
include <../BOSL/constants.scad>
use <../BOSL/shapes.scad>
use <../BOSL/masks.scad>
use <../BOSL/transforms.scad>
use <../BOSL/math.scad>

is_sleeved = true;
card_thickness = is_sleeved ? .8 : .4;
bottom_thickness = 1;
hero_wall_height=1;
wall_thickness=2;

hero_card = [127,102];
mini_card = [45,68,card_thickness];

$fn=50;

card_sep=0;
card_slot_dim = [mini_card.x+card_sep, 10, 6];
num_cards_in_slot = 1;
card_holder_width = mini_card.x+wall_thickness;
spin_down_holder_dim = [26.5*2, 11.5*2, 9.4];
token_front_z = hero_wall_height+bottom_thickness+.98;
fillet_r = .6;


//build_full_dashboard();
//!skew_xy(xa=1.2, ya=1.2) cylinder(r1=.6, r2=0, h=5+.2, center=true, $fn=50);
difference() {
    cube([5,5,5]);
    translate([0,0,5])
        build_layered_tapered_fillet(l=1,r1=.5,r2=.1);
}

module build_layered_tapered_fillet(l=undef, r1=1.0, r2=1.0, orient=ORIENT_Z, align=V_CENTER, h=undef, center=undef) {
    l = first_defined([l,h,1]);
    max_r = max(r1,r2);
    sides = quantup(segs(max_r),4);
    orient_and_align([2*max_r, 2*max_r, l], orient, align, center=center) {
        difference() {
            cube([max_r*2,max_r*2, l],center=true);
            layer_height = .01;
            num_layers = l/layer_height;
            layer_r_diff = (r2-r1)/num_layers;
            !hull() {
                translate([r1,r1,-l/2+.005])
                    cylinder(r=r1,h=.01,center=true);
                #translate([r2,r2,l/2-.005])
                    cylinder(r=r2,h=.01,center=true);
               // for(layer=[1:(l-layer_height)/layer_height])
               // {
               //     layer_r = r1 + layer*layer_r_diff;
               //     translate([layer_r,layer_r,layer*layer_height-l/2])
               //         linear_extrude(layer_height) {
               //             circle(r=layer_r);
               //         }
               // }
            }
        }
    }
}

module build_tapered_fillet(l=undef, r1=1.0, r2=1.0, orient=ORIENT_Z, align=V_CENTER, h=undef, center=undef) {
    l = first_defined([l,h,1]);
    max_r = max(r1,r2);
    sides = quantup(segs(max_r),4);
    orient_and_align([2*max_r, 2*max_r, l], orient, align, center=center) {
        difference() {
            //prismoid(size1=[r1*2,r1*2], size2=[r2*2,r2*2],h=l,center=true);
            cube([max_r*2,max_r*2, l],center=true);
            xspread(2*max_r) yspread(2*max_r) cylinder(r1=r1, r2=r2, h=l, center=true, $fn=sides);
        }
    }
}

module build_full_dashboard() {
    build_hero_card();
    build_side_card_slots();
    build_top_bar();
    build_top_card_slot();
}

module build_side_card_slots() {
    h = hero_card.y + wall_thickness + spin_down_holder_dim.y;
    translate([hero_card.x+wall_thickness,0,0]) {
        difference() {
            for(i = [0:10:h]) {
                translate([0,i,0]) {
                    build_card_slot(1,card_sep,true);
                }
            }

            color("red") {
                fillet_mask_x(l=card_holder_width, r=fillet_r, align=V_RIGHT);
                translate([0,0,card_slot_dim.z])
                    fillet_mask_x(l=card_holder_width, r=fillet_r, align=V_RIGHT);
                translate([0,0,card_slot_dim.z])
                    fillet_mask_y(l=h-10-7.1, r=fillet_r, align=V_BACK);
                translate([card_holder_width,0,0])
                    fillet_mask_y(l=h+card_slot_dim.y, r=fillet_r, align=V_BACK);
                translate([card_holder_width,0,card_slot_dim.z])
                    fillet_mask_y(l=h+card_slot_dim.y, r=fillet_r, align=V_BACK);
                translate([0,0,hero_wall_height])
                    fillet_mask_z(l=card_slot_dim.z, r=fillet_r, align=V_UP);
                translate([card_holder_width,0,0])
                    fillet_mask_z(l=card_slot_dim.z, r=fillet_r, align=V_UP);
                translate([0,h-7.1,card_slot_dim.z])
                    build_tapered_fillet(l=10,r1=fillet_r,r2=0, orient=ORIENT_Y, align=V_FRONT);
            }
        }
    }
}


module build_health_spin_down_holder() {
    translate([spin_down_holder_dim.x/2, spin_down_holder_dim.y/2, -2]) {
        difference() {
            import("tinker.stl");
            translate([-.5,-.5,.9])
                cube([spin_down_holder_dim.x+2, spin_down_holder_dim.y+2, 2.2],center=true);
        }
    }
}
module build_stamina_spin_down_holder() {
    translate([hero_card.x-spin_down_holder_dim.x/2+wall_thickness+1,0,-2]) {
        difference() {
            translate([spin_down_holder_dim.x/2, spin_down_holder_dim.y/2, 0])
                difference() {
                    import("tinker.stl");
                    translate([-.5,-.5,.9])
                        cube([spin_down_holder_dim.x+1, spin_down_holder_dim.y+1, 2.2],center=true);
                }
            translate([spin_down_holder_dim.x/2-1,0,-.5]) 
                cube([spin_down_holder_dim.x/2+2, spin_down_holder_dim.y+1, spin_down_holder_dim.z+1]); }
    }
}

module build_token_holder() {
    token_size=[hero_card.x-spin_down_holder_dim.x*1.5+wall_thickness+1,spin_down_holder_dim.y];
    translate([spin_down_holder_dim.x, 0,0]) {
        difference() {
            union() {
                cube([token_size.x,token_size.y, token_front_z]);
                translate([token_size.x/2,token_size.y/2,token_front_z])
                    prismoid(size1=token_size, size2=[token_size.x,0], shift=[0,token_size.y/2], h=4.5);
            }
            translate([0,wall_thickness,bottom_thickness])
                cuboid([token_size.x,spin_down_holder_dim.y-2*wall_thickness, spin_down_holder_dim.z+bottom_thickness], fillet=2,center=false);

        }
    }
}

module build_top_bar() {
    translate([0,hero_card.y+wall_thickness,0]) {
        difference() {
            group() {
                build_health_spin_down_holder();
                build_stamina_spin_down_holder();
                build_token_holder();
            }

            translate([0,0,card_slot_dim.z])
                cube([hero_card.x+2*wall_thickness,hero_card.y+spin_down_holder_dim.y+2*wall_thickness+2,10]);

            color("red") {
                fillet_mask_y(l=spin_down_holder_dim.y, r=fillet_r, align=V_BACK);
                translate([0,0,token_front_z])
                    fillet_mask_x(l=hero_card.x+wall_thickness, r=fillet_r, align=V_RIGHT);

                translate([0,0,bottom_thickness])
                    fillet_mask_z(l=card_slot_dim.z, r=fillet_r, align=V_UP);
                translate([0,0,card_slot_dim.z])
                    fillet_mask_y(l=spin_down_holder_dim.y, r=fillet_r, align=V_BACK);
            }
        }
    }
}

module build_top_card_slot() {
    translate([0,hero_card.y+wall_thickness+spin_down_holder_dim.y]) {
        difference() {
            build_slot_width(hero_card.x+card_holder_width,true,false);
            color("red") {
                fillet_mask_y(l=card_slot_dim.y, r=fillet_r, align=V_BACK);
                translate([0,0,card_slot_dim.z])
                    fillet_mask_y(l=card_slot_dim.y, r=fillet_r, align=V_BACK);
                translate([0,card_slot_dim.y,0])
                    fillet_mask_x(l=hero_card.x+card_holder_width+wall_thickness, r=fillet_r, align=V_RIGHT);
                translate([0,card_slot_dim.y,card_slot_dim.z])
                    fillet_mask_x(l=hero_card.x+card_holder_width+wall_thickness, r=fillet_r, align=V_RIGHT);
                translate([0,card_slot_dim.y,0])
                    fillet_mask_z(l=card_slot_dim.z, r=fillet_r, align=V_UP);
                translate([hero_card.x+card_holder_width+wall_thickness,0,0]) {
                    fillet_mask_y(l=card_slot_dim.y, r=fillet_r, align=V_BACK);
                    translate([0,0,card_slot_dim.z])
                        fillet_mask_y(l=card_slot_dim.y, r=fillet_r, align=V_BACK);
                    translate([0,card_slot_dim.y,0])
                        fillet_mask_z(l=card_slot_dim.z, r=fillet_r, align=V_UP);
                }
            }
        }
    }
}

module build_card_slot(num_cards, card_separation, is_open_right=false, is_open_left=false) {
    w = (mini_card.x+card_separation)*num_cards;
    build_slot_width(w, is_open_right, is_open_left);
}

module build_slot_width(width, is_open_right=false, is_open_left=false) {
    difference() {
        num_walls = (is_open_right ? 0 : 1) + (is_open_left ? 0 : 1);
        slot = [is_open_left ? 0 : wall_thickness, 0, 1];
        cube([width + wall_thickness * num_walls, 10, card_slot_dim.z]);
        translate(slot+[0,4.4,0])
            rotate([80,0,0])
                cube([width-(is_open_right ? 0 : wall_thickness), mini_card.y, mini_card.z]);
    }
}

module build_hero_card() {
    difference() {
        build_hole(hero_card,hero_wall_height);
        translate([hero_card.x/2,0,-.1])
            linear_extrude(bottom_thickness+hero_wall_height+1)
                circle(r=10);

        hole_size = [hero_card.x/2.6, hero_card.y+2*wall_thickness-25,10];
        translate([10+wall_thickness, 15,-4])
            cuboid(hole_size, fillet=2, center=false);
        translate([hero_card.x-10-hole_size.x-wall_thickness, 15,-4])
            cuboid(hole_size, fillet=2, center=false);

        color("red") {
            fillet_mask_x(l=hero_card.x+2*wall_thickness, r=fillet_r, align=V_RIGHT);
            translate([0,0,hero_wall_height+bottom_thickness])
                fillet_mask_x(l=hero_card.x+wall_thickness+.4, r=fillet_r, align=V_RIGHT);
            translate([wall_thickness,wall_thickness,hero_wall_height+bottom_thickness])
                fillet_mask_x(l=hero_card.x, r=fillet_r, align=V_RIGHT);
            fillet_mask_y(l=hero_card.y+2*wall_thickness, r=fillet_r, align=V_BACK);
            translate([0,0,hero_wall_height+bottom_thickness])
                fillet_mask_y(l=hero_card.y+2*wall_thickness, r=fillet_r, align=V_BACK);
            fillet_mask_z(l=hero_wall_height+wall_thickness, r=fillet_r, align=V_UP);
        }
    }
}

module build_hole(size, wall_height) {
    difference() {
        linear_extrude(bottom_thickness+wall_height)
            square(size+[wall_thickness*2,wall_thickness*2]);

        translate([wall_thickness,wall_thickness])
            translate([0,0,bottom_thickness])
                linear_extrude(wall_height+1)
                    square(size);
    }
}

