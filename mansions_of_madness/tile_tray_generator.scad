

square_tile_width = 26.5
rectangle_tile_width=20;
rectangle_tile_height=32.5;
circle_tile_d=25;
tile_thickness=2.25;
thickness=6*.4;
bottom_thickness=1.4;
num_tiles=7;
height_slop=.4;
base_fill_percentage=0.6;
grid_line_width=1.6;
hole_border_thickness=2;
box_height=num_tiles*tile_thickness+height_slop;

$fn=50;

square_tile=[square_tile_width,square_tile_width];
vert_rectangle_tile=[rectangle_tile_width,rectangle_tile_height];

tile_list = [[square_tile, vert_rectangle_tile, square_tile],[square_tile],[vert_rectangle_tile, square_tile]];

function add2(v) = [for(p=v) 1]*v;

echo(add2(tile_list[0]));


module gridify(width, height, percentage, line_width) {
    for(a = [0:1.75/percentage*line_width:width-line_width])
        translate([a,0])resize([line_width, height]) square(1);
    translate([width-line_width,0])resize([line_width,height]) square(1);

    for(a = [0:1.75/percentage*line_width:height-line_width])
        translate([0,a])resize([width, line_width]) square(1);
    translate([0,height-line_width])resize([width,line_width]) square(1);
}

module create_tile(width_height, fill_percentage=1) {
    width= width_height[0];
    height=width_height[1];
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

module translated_tile(size_vector, idx=0) {
    if(idx < len(size_vector)) {
        width = size_vector[idx][0];
        height = size_vector[idx][1];

        create_tile(size_vector[idx]);
        //resize([width,height])square(1);
        translate([width+thickness,0,0]) {
            translated_tile(size_vector, idx+1);
        }
    }
}

module vertically_translated_tile(size_vector, idx=0) {
    if(idx < len(size_vector)) {
        translated_tile(size_vector[idx],0);
        max_height = max([ for(a=tile_list[idx]) a[1] ]);
        translate([0,max_height+thickness,0])
            vertically_translated_tile(size_vector, idx+1);

    }
}

vertically_translated_tile(tile_list);




