
__version__ = 2;

include <../BOSL/constants.scad>;
use <../BOSL/shapes.scad>;
use <../BOSL/transforms.scad>;
use <../BOSL/masks.scad>;

$fn=50;

//tile parameters
tile_thickness=2.25;
tile_t_tol=.4;

square_tile=26.5;

circle_tile_d=square_tile;
circle_tile_r=circle_tile_d/2;

rectangle_tile_width=20;
rectangle_tile_height=32.5;

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
top_h = rectangle_tile_height - base_h + bottom_t*2;

far_right=5*(rectangle_tile_width+wall_t);

build_base();

fwd(40)
    build_lid();

box_width=7*tile_thickness+4*tile_thickness+2*tile_t_tol+wall_t;

module build_base() {
    difference() {
        back(wall_t) left(outer_wall_w)
            cuboid([ 5*rectangle_tile_width + 4*wall_t + 2*outer_wall_w, 
                     box_width+wall_t*2, 
                     base_h], 
                   align=V_FWD+V_UP+V_RIGHT,
                   fillet=.6, edges=EDGES_Z_ALL+EDGES_BOTTOM);

        up(bottom_t) {
            // rec: 10, 8, 8, 7, 7
            right(0*(rectangle_tile_width+wall_t))
                rec_tile(11);

            right(1*(rectangle_tile_width+wall_t))
                rec_tile(8);

            right(2*(rectangle_tile_width+wall_t))
                rec_tile(8);

            right(3*(rectangle_tile_width+wall_t))
                rec_tile(7);

            right(4*(rectangle_tile_width+wall_t))
                rec_tile(7);

            // sq: 4, 2, 2
                right(far_right-wall_t) 
                fwd(box_width-4*tile_thickness-tile_t_tol)
                    square_tile(4, align_x=V_LEFT);

                fwd(box_width-2*tile_thickness-tile_t_tol)
                right(far_right-wall_t-1*(wall_t + square_tile))
                    square_tile(2, align_x=V_LEFT);

                fwd(box_width-2*tile_thickness-tile_t_tol)
                right(far_right-wall_t-2*(wall_t + square_tile))
                    square_tile(2, align_x=V_LEFT);
        }

        fwd(magnet_d/2) {
            up(base_h-.4) left(mag_hole_w)
                mag_hole();

            fwd(box_width-magnet_d) up(base_h-.4) left(mag_hole_w)
            zrot(45)
                mag_hole();

            right(far_right-wall_t+mag_hole_w) 
            up(base_h-.4) 
            zrot(180)
                mag_hole();

            fwd(box_width-magnet_d) 
            right(far_right-wall_t+mag_hole_w) 
            up(base_h-.4) 
            zrot(180)
                mag_hole();
        }
    }
}

module build_lid() {
    difference() {
        back(wall_t) left(outer_wall_w)
            cuboid([ 5*rectangle_tile_width + 4*wall_t + 2*outer_wall_w, 
                     box_width+wall_t*2, 
                     top_h], 
                   align=V_FWD+V_UP+V_RIGHT,
                   fillet=.6, edges=EDGES_Z_ALL+EDGES_BOTTOM);

        up(bottom_t)
            cuboid([ 5*rectangle_tile_width + 4*wall_t,
                     box_width, 
                     top_h],
                   align=V_FWD+V_UP+V_RIGHT);

        fwd(magnet_d/2) {
            up(top_h-.4) left(mag_hole_w)
                mag_hole();

            fwd(box_width-magnet_d) up(top_h-.4) left(mag_hole_w)
                mag_hole();

            right(far_right-wall_t+mag_hole_w) 
            up(top_h-.4) 
            zrot(180)
                mag_hole();

            fwd(7*tile_thickness+4*tile_thickness+wall_t-magnet_d) 
            right(far_right-wall_t+mag_hole_w) 
            up(top_h-.4) 
            zrot(180)
                mag_hole();
        }
    }
}


module mag_hole() {
    cyl(d=magnet_d,h=magnet_t, align=V_DOWN);
    cuboid([mag_hole_w + 5 + .01,magnet_d,magnet_t], align=V_RIGHT+V_DOWN);
}

module rec_tile(count=1) {
    xrot(90)
    cuboid([rectangle_tile_width, rectangle_tile_height, tile_thickness*count+tile_t_tol], 
           align=V_BACK+V_RIGHT+V_UP);
}

module square_tile(count=1, align_x=V_RIGHT) {
    xrot(90)
    cuboid([square_tile,square_tile,tile_thickness*count+tile_t_tol],
           align=V_BACK+V_UP+align_x);
}

