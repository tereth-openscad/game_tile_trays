
__version__ = 1;

include <../BOSL/constants.scad>;
use <../BOSL/shapes.scad>;
use <../BOSL/transforms.scad>;
use <../BOSL/masks.scad>;

$fn=50;

big_tile_w=177;

keys=4;
fire_tokens=38;
restraint_tokens=20;
rift_tokens=43;
overgrowth_tokens=27;
search_tokens=16;
explore_tokens=16;

//tile parameters
tile_thickness=2.25;
tile_t_tol=.4;

square_tile=26.5;

// Search/explore tokens
circle_tile_d=square_tile;
circle_tile_r=circle_tile_d/2;

// Clues and Keys
small_circle_tile_d=20;

//Color tokens for monsters
small_color_tile_w=20;
small_color_tile_h=20;

//calculated helper tile parameters
sq_tile_vec = [square_tile, square_tile];
sq_tile = square_tile;

wall_t=1.2;

magnet_d=5.4;
magnet_t=2;
mag_hole_w=magnet_d/2+.2;

outer_wall_w=magnet_d+.8;

bottom_t=.4;

base_h = square_tile / 2 + bottom_t;
base_w=rift_tokens*tile_thickness+tile_t_tol;

top_h = square_tile-base_h+bottom_t*2;

far_right=6*(sq_tile+wall_t);

fill_extra_container_lid=true;

build_base();

fwd(110)
    build_lid();

function tile_hole_width(count)=tile_thickness*count+tile_t_tol;

module build_base() {
    difference() {
        cuboid([ 6*sq_tile+5*wall_t + 2*outer_wall_w, 
                 base_w+wall_t*2, 
                 base_h], 
               align=V_FWD+V_UP+V_RIGHT,
               fillet=.6, edges=EDGES_Z_ALL+EDGES_BOTTOM);

        fwd(wall_t) right(outer_wall_w) up(bottom_t) {
            // rec: 10, 8, 8, 7, 7
            right(0*(square_tile+wall_t))
                square_tile(rift_tokens);
            right(1*(square_tile+wall_t))
                square_tile(rift_tokens);

            right(2*(square_tile+wall_t))
                square_tile(overgrowth_tokens);

            right(3*(square_tile+wall_t))
                square_tile(restraint_tokens);

            right(4*(square_tile+wall_t))
                circle_tile(search_tokens);

            right(5*(square_tile+wall_t))
                circle_tile(explore_tokens);

            fwd(base_w-tile_hole_width(4)) 
            right(2*(square_tile+wall_t)+square_tile/2) 
            up(circle_tile_r/(small_circle_tile_d/2))
                circle_tile(4, d=small_circle_tile_d, align_x=V_ZERO);

            back(tile_hole_width(4)+2*wall_t) 
            up(circle_tile_r/(small_circle_tile_d/2)) 
            right(2*(square_tile+wall_t)+square_tile/2) 
            fwd(base_w-tile_hole_width(1))
            {
                square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
                back(wall_t+tile_hole_width(1))
                    square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
                back(2*(wall_t+tile_hole_width(1)))
                    square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
                back(3*(wall_t+tile_hole_width(1)))
                    square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
                back(4*(wall_t+tile_hole_width(1)))
                    square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
                back(5*(wall_t+tile_hole_width(1)))
                    square_tile(1, w=small_color_tile_w, align_x=V_ZERO);
            }

            
            right(sq_tile*3+wall_t*3) fwd(tile_hole_width(restraint_tokens)+wall_t)
                cuboid([sq_tile*3+2*wall_t, base_w-tile_hole_width(restraint_tokens)-wall_t, sq_tile], 
                       align=V_UP+V_FWD+V_RIGHT, fillet=5);
        }

        fwd(wall_t) right(outer_wall_w) 
        fwd(magnet_d/2) {
            up(base_h-.4) left(mag_hole_w)
                mag_hole();

            fwd(base_w-magnet_d) up(base_h-.4) left(mag_hole_w)
                mag_hole();

            right(far_right-wall_t+mag_hole_w) 
            up(base_h-.4) 
            zrot(180)
                mag_hole();

            fwd(base_w-magnet_d) 
            right(far_right-wall_t+mag_hole_w) 
            up(base_h-.4) 
            zrot(180)
                mag_hole();
        }
    }
}

module build_lid() {
    difference() {
        union() {
            difference() {
                cuboid([ 6*sq_tile+5*wall_t + 2*outer_wall_w, 
                         base_w+wall_t*2, 
                         base_h], 
                       align=V_FWD+V_UP+V_RIGHT,
                       fillet=.6, edges=EDGES_Z_ALL+EDGES_BOTTOM);

                up(.4) right(outer_wall_w) fwd(wall_t)
                cuboid([ 6*sq_tile+5*wall_t, 
                         base_w, 
                         base_h+5], 
                       align=V_FWD+V_UP+V_RIGHT,
                       fillet=.6, edges=EDGES_Z_ALL+EDGES_BOTTOM);
            }

            difference() {
                right(sq_tile*3+wall_t*2 + outer_wall_w) fwd(wall_t) up(bottom_t) {
                    cuboid([sq_tile*3+4*wall_t, base_w-tile_hole_width(restraint_tokens)-wall_t+wall_t, sq_tile/2], 
                           align=V_UP+V_FWD+V_RIGHT);
                }
                if(!fill_extra_container_lid) {
                    right(wall_t+sq_tile*3+wall_t*2 + outer_wall_w) fwd(wall_t) {
                        cuboid([sq_tile*3+2*wall_t, base_w-tile_hole_width(restraint_tokens)-wall_t, sq_tile], 
                               align=V_UP+V_FWD+V_RIGHT, fillet=5);
                    }
                }
            }
        }

        fwd(wall_t) right(outer_wall_w) 
        fwd(magnet_d/2) {
            up(base_h-.4) left(mag_hole_w)
                mag_hole();

            fwd(base_w-magnet_d) up(base_h-.4) left(mag_hole_w)
                mag_hole();

            if(!fill_extra_container_lid) {
                right(far_right-wall_t+mag_hole_w) 
                up(base_h-.4) 
                zrot(180)
                    mag_hole();
            } else {
                right(far_right-wall_t+mag_hole_w) 
                up(base_h-magnet_t-.2) 
                cyl(d=magnet_d, h=.4+magnet_d+1, align=V_UP);
            }

            fwd(base_w-magnet_d) 
            right(far_right-wall_t+mag_hole_w) 
            up(base_h-.4) 
            zrot(180)
                mag_hole();
        }
   }
}


module mag_hole() {
    cyl(d=magnet_d,h=magnet_t, align=V_DOWN);
    cuboid([mag_hole_w + 5 + .01,magnet_d,magnet_t], align=V_RIGHT+V_DOWN);
}

module square_tile(count=1, w=sq_tile, align_x=V_RIGHT) {
    xrot(90)
    cuboid([w,w,tile_thickness*count+tile_t_tol],align=V_BACK+V_UP+align_x);
}

module circle_tile(count=1, d=circle_tile_d, align_x=V_RIGHT) {
    xrot(90)
    cyl(d=d,h=tile_thickness*count+tile_t_tol,align=V_BACK+V_UP+align_x);
}

