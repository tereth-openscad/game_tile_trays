
//printer parameters
line_width=.4;
layer_thickness=.2;

//tile parameters
tile_thickness=2.25;

square_tile=26.5;

circle_tile_d=square_tile;
circle_tile_r=circle_tile_d/2;

rectangle_tile_width=20;
rectangle_tile_height=32.5;

//tolerance values
height_slop=1.2;

//calculated box parameters
wall_thickness=wall_lines*line_width;
bottom_thickness=bottom_layers*layer_thickness;
box_height = bottom_thickness + num_tiles*tile_thickness + height_slop;

//grid parameters
base_fill_percentage=1;
grid_line_width=1.6;

//hold parameters
hole_border=false;
hole_border_thickness=2;

//calculated helper tile parameters
sq_tile_vec = [square_tile, square_tile];
sq_tile = square_tile;

rec_tile_vec = [rectangle_tile_width, rectangle_tile_height];
rec_tile_w = rec_tile_vec.x;
rec_tile_h = rec_tile_vec.y;

hsq = sq_tile/2;
ht = wall_thickness/2;
hrw = rec_tile_w/2;


