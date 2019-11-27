
circle_tile_d=25;
square_tile=26.5;
rectangle_tile_width=20;
rectangle_tile_height=32.5;
tile_thickness=2.25;
thickness=6*.4;
bottom_thickness=1.4;
num_tiles=7;
height_slop=.4;
base_fill_percentage=1;
grid_line_width=1.6;
hole_border_thickness=2;

$fn=50;

sq_tile = square_tile;
rec_tile_w = rectangle_tile_width;
rec_tile_h = rectangle_tile_height;

hsq = sq_tile/2;
ht = thickness/2;
hrw = rec_tile_w/2;

row_1_w = sq_tile*2+rec_tile_w;
row_2_w = sq_tile + 2*rec_tile_w;
row_offset = (row_1_w-row_2_w)/2;
echo(wall_thickness=thickness);
echo(row_offset=row_offset);

box_height = bottom_thickness + num_tiles*tile_thickness + height_slop;

module magnet_hole(size, depth) {
    translate([0,0,-depth])
        linear_extrude(depth+.1) 
            circle(d=size);
}

module gridify(width, height, percentage, line_width) {
    for(a = [0:1.75/percentage*line_width:width-line_width])
        translate([a,0])resize([line_width, height]) square(1);
    translate([width-line_width,0])resize([line_width,height]) square(1);

    for(a = [0:1.75/percentage*line_width:height-line_width])
        translate([0,a])resize([width, line_width]) square(1);
    translate([0,height-line_width])resize([width,line_width]) square(1);
}

module create_tile(width, height, fill_percentage=1) {
    intersection() {
        linear_extrude(bottom_thickness) {
            resize([width, height])square(10);
        }
        if(fill_percentage < 1) {
            linear_extrude(bottom_thickness+1) {
                gridify(width, height, fill_percentage, grid_line_width);
            }
        }
    }

    linear_extrude(box_height) {
        difference() {
            translate([-thickness,-thickness])resize([width+thickness*2, height+thickness*2])square(10);
            resize([width, height])square(10);
        }
    }
}

module square_tile (fill_percentage=1) {
    create_tile(sq_tile, sq_tile, fill_percentage);
}

module rectangle_tile(fill_percentage=1) {
    create_tile(rectangle_tile_width, rectangle_tile_height, fill_percentage);
}

module create_base(fill_percentage=1) {
    square_tile(fill_percentage);
    translate([sq_tile+thickness,0])rectangle_tile(fill_percentage);
    translate([sq_tile+2*thickness+rec_tile_w,0])square_tile(fill_percentage);

    translate([row_offset,0]) {
        translate([0,sq_tile+thickness])rectangle_tile(fill_percentage);
        translate([rec_tile_w+thickness,rec_tile_h+thickness])square_tile(fill_percentage);
        translate([rec_tile_w+2*thickness+sq_tile,sq_tile+thickness])rectangle_tile(fill_percentage);
    }
}

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
hole_locations=[ [[left_vx,row1_vy],"vert",hsq],
                 [[column0_hx,bottom_hy],"horiz",hsq],
                 [[sq_tile+ht,row1_vy],"vert",hsq],
                 [[column0_hx,sq_tile+ht],"horiz",hrw],
                 [[column1_hx,bottom_hy],"horiz",hrw],
                 [[column1_hx,rec_tile_h+ht],"horiz",hrw],
                 [[column0_hx,top_hy],"horiz",hrw],
                 [[column2_hx,top_hy],"horiz",hrw],
                 [[row1_right_vx,row1_vy],"vert",hrw],
                 [[column2_hx, bottom_hy],"horiz",hsq],
                 [[column2_hx, sq_tile+ht], "horiz",hrw],
                 //right of 4
                 [[sq_tile+thickness+rec_tile_w+ht, row1_vy], "vert",hsq],
                 //top of 1
                 [[column1_hx,top_hy], "horiz",hsq],
                 //left of 0
                 [[left_vx+row_offset,row0_vy], "vert",hsq],
                 //right of 0 && left of 1
                 [[row_offset+rec_tile_w+ht, row0_vy], "vert",hsq],
                 //right of 1 && left of 2
                 [[row_offset+rec_tile_w+thickness+sq_tile+ht, row0_vy], "vert",hsq],
                 //right of 2
                 [[row_offset+2*rec_tile_w+2*thickness+sq_tile+ht, row0_vy], "vert",hsq],
                 ];


module create_holes() {
    linear_extrude(bottom_thickness+num_tiles*tile_thickness+2) {
        for(i = hole_locations) {
            translate(i[0]) {
                is_vert = i[1] == "vert" ? true : false;
                create_single_hole(is_vert, i[2]);
            }
        }
    }
}

module create_hole_borders() {
    linear_extrude(bottom_thickness) {
        for(i = hole_locations) {
            translate(i[0]) {
                is_vert = i[1] == "vert" ? true : false;
                create_hole_border(is_vert, i[2], hole_border_thickness);
            }
        }
    }
}

//magnet_height = sq_tile+(rec_tile_h-sq_tile)/2+thickness/2;
sq_rec_diff = (sq_tile-(rec_tile_w+2*thickness))/2;
magnet_diameter=5;
magnet_radius=magnet_diameter/2;
magnet_thickness=1;

difference() {
    group() {
        //create the border for the moddle left magnet cutout
        intersection() {
            translate([-thickness,sq_tile+thickness])
                linear_extrude(box_height)
                    resize([thickness+sq_rec_diff,magnet_diameter+1])square(1);

            translate([row_offset-magnet_radius,sq_tile+magnet_radius+1])
                linear_extrude(box_height)
                    circle(d=magnet_diameter+row_offset/2);
        }

        //create the border for the middle right magnet cutout
        intersection() {
            translate([row_offset+row_2_w+3*thickness,sq_tile+thickness])
                linear_extrude(box_height)
                    resize([thickness+sq_rec_diff,magnet_diameter+1])square(1);

            group() {
                translate([row_offset+row_2_w+3*thickness,sq_tile+magnet_radius+1])
                    linear_extrude(box_height)
                        circle(d=magnet_diameter+row_offset/2);

            }
        }

        //create the border for the bottom left magnet cutout
        linear_extrude(box_height)
            translate([-magnet_radius, -magnet_radius])
                circle(d=magnet_diameter+2);


        //this intersection is there to clean the outside of the box of any outlying features
        intersection() {
            group() {
                difference() {
                    translate([0,0,.01])create_base(base_fill_percentage);
                    create_holes();
                }
                create_hole_borders();
            }
            create_base(1);
        }
    }

    //magnet cut outs
    group() {
        //middle left
        translate([row_offset-magnet_radius,sq_tile+magnet_radius+1,box_height])
            magnet_hole(magnet_diameter,magnet_thickness);

        //middle right
        translate([row_offset+row_2_w+thickness*2+magnet_radius,sq_tile+magnet_radius+1,box_height])
            magnet_hole(magnet_diameter,magnet_thickness);

        //bottom left
        translate([-magnet_radius,-magnet_radius,box_height])
            magnet_hole(magnet_diameter,magnet_thickness);
        
    }
}


