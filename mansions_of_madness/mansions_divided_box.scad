include <../BOSL/constants.scad>;
use <../BOSL/shapes.scad>;
use <../BOSL/transforms.scad>;

//size.z includes bottom_t
function compute_box_size(size, columns, rows, wall_t=1.2, bottom_t=.4) =
    [size.x*columns+(columns-1)*wall_t,size.y*rows+(rows-1)*wall_t,size.z]+2*[wall_t,wall_t,0];

module build_divided_box(size, columns, rows, wall_t=1.2, bottom_t=.4, string="box") {
    difference() {
        // box_size=[size.x*columns+(columns-1)*wall_t,size.y*rows+(rows-1)*wall_t,size.z]+outer_walls;
        box_size=compute_box_size(size,columns,rows,wall_t,bottom_t);
        echo(str(string, ": ", box_size));
        cuboid(box_size, align=V_UP, fillet=.6);
        up(bottom_t)
            grid2d(spacing=[size.x+wall_t,size.y+wall_t], cols=columns, rows=rows)
                cuboid(size+[0,0,1],align=V_UP);
    }
}


