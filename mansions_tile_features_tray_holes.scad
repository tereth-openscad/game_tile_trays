
/////// ---- Holes ---- ///////
//  [0  1  2]
//  [3  4  5]
column0_hx = hsq;
column1_hx = sq_tile+thickness+hrw;
column2_hx = 3*hsq + rec_tile_w + 2*thickness;

row0_vy = rec_tile_h+hsq+thickness;
row1_vy = hsq;

top_hy = sq_tile+thickness+rec_tile_h+ht;
bottom_hy = -ht;
left_vx = -ht;
row1_right_vx = sq_tile*2 + rec_tile_w + 2*thickness + ht;

// [[w, h], is_vert, diameter]
hole_locations=[ [[left_vx,row1_vy],true,hsq],
                 [[column0_hx,bottom_hy],false,hsq],
                 [[sq_tile+ht,row1_vy],true,hsq],
                 [[column0_hx,sq_tile+ht],false,hrw],
                 [[column1_hx,bottom_hy],false,hrw],
                 [[column1_hx,rec_tile_h+ht],false,hrw],
                 [[column0_hx,top_hy],false,hrw],
                 [[column2_hx,top_hy],false,hrw],
                 [[row1_right_vx,row1_vy],true,hrw],
                 [[column2_hx, bottom_hy],false,hsq],
                 [[column2_hx, sq_tile+ht], false,hrw],
                 //right of 4
                 [[sq_tile+thickness+rec_tile_w+ht, row1_vy],true,hsq],
                 //top of 1
                 [[column1_hx,top_hy], false,hsq],
                 //left of 0
                 [[left_vx+row_offset,row0_vy],true,hsq],
                 //right of 0 && left of 1
                 [[row_offset+rec_tile_w+ht, row0_vy],true,hsq],
                 //right of 1 && left of 2
                 [[row_offset+rec_tile_w+thickness+sq_tile+ht, row0_vy],true,hsq],
                 //right of 2
                 [[row_offset+2*rec_tile_w+2*thickness+sq_tile+ht, row0_vy],true,hsq],
                 ];
/////// ---- Holes ---- ///////

module create_hole_border(is_vert, size, line_width) {
    difference() {
        create_single_hole(is_vert, size);
        create_single_hole(is_vert, size-line_width);
    }
}

module create_single_hole(is_vert, size) {
    rotate(is_vert ? 0 : 90) {
        translate([thickness/2,0]) {
            hull() {
                translate([-thickness,0]) {
                    circle(size/2);
                }
                circle(size/2);
            }
        }
    }
}

module create_holes() {
    linear_extrude(bottom_thickness+num_tiles*tile_thickness+2) {
        for(i = hole_locations) {
            translate(i[0]) {
                is_vert = i[1];
                create_single_hole(is_vert, i[2]);
            }
        }
    }
}

module create_hole_borders() {
    linear_extrude(bottom_thickness) {
        for(i = hole_locations) {
            translate(i[0]) {
                is_vert = i[1];
                create_hole_border(is_vert, i[2], hole_border_thickness);
            }
        }
    }
}

