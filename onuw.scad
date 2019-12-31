

card_size = [57,78];
circle_token_d = 31;


box_size = [122, 163, 36];

layer_thickness = .2;
line_width = .4;
wall_thickness = 5 * line_width;
bottom_thickness = layer_thickness * 5;

build_card_holder();
//translate([card_size.x+wall_thickness, card_size.y-20+wall_thickness+10, 0])
translate([box_size.x+10,0,0])
    build_space_holder();

$fn=50;
module build_card_holder() {
    echo(card_size * 2);



    difference() {
        cube([box_size.x, card_size.y+wall_thickness, bottom_thickness]);

        //cut out triangles for first card box
        translate([0,0,-.1])
        linear_extrude(bottom_thickness+1) {
            x_divisions = 3;
            y_divisions = 3;
            for(j=[0:y_divisions-1]) {
                for(i=[0:x_divisions-1]) 
                {
                    triangle_pair(card_size.x/x_divisions,card_size.y / y_divisions,1);
                    translate([i*card_size.x/x_divisions,j*card_size.y / y_divisions])
                        triangle_pair(card_size.x/x_divisions,card_size.y / y_divisions,1);
                }
            }
        }
        
        //cut out trangles for 2nd card box
        translate([box_size.x-card_size.x,0,0])
            translate([0,0,-.1])
            linear_extrude(bottom_thickness+1) {
                x_divisions = 3;
                y_divisions = 3;
                for(j=[0:y_divisions-1]) {
                    for(i=[0:x_divisions-1]) 
                    {
                        triangle_pair(card_size.x/x_divisions,card_size.y / y_divisions,1);
                        translate([i*card_size.x/x_divisions,j*card_size.y / y_divisions])
                            triangle_pair(card_size.x/x_divisions,card_size.y / y_divisions,1);
                    }
                }
            }
    }


    //card walls
    linear_extrude(box_size.z) {
        difference() {
            group() {
                translate([0,card_size.y,0])
                    square([card_size.x+wall_thickness, wall_thickness]);

                translate([card_size.x,0,0])
                    square([wall_thickness, card_size.y+wall_thickness]);

                translate([box_size.x-(card_size.x+wall_thickness),card_size.y,0])
                    square([card_size.x+wall_thickness, wall_thickness]);

                translate([box_size.x-(card_size.x+wall_thickness),0,0])
                    square([wall_thickness, card_size.y+wall_thickness]);
            }
            translate([card_size.x+wall_thickness/2,card_size.y/2,0])
                square([wall_thickness, card_size.y/3],center=true);
            translate([box_size.x-(card_size.x+wall_thickness/2),card_size.y/2,0])
                square([wall_thickness, card_size.y/3],center=true);
        }
    }

    translate([card_size.x, 0, box_size.z-bottom_thickness])
        cube([box_size.x-(card_size.x*2),20,bottom_thickness]);

    translate([card_size.x, card_size.y-20+wall_thickness, 0])
        build_slider_hole();
        

    translate([0,card_size.y+wall_thickness])
        build_token_holder();

}

module build_slider_hole() {
    difference() {
        cube([box_size.x-(card_size.x*2), 20, box_size.z]);
        translate([-.5,10-.5,-.1])
        cube([box_size.x-(card_size.x*2)+1, 10+1, 10+.1]);
    }
}

module build_space_holder() {
    tolerance=.4;
    slider_size = [box_size.x-(card_size.x*2)-wall_thickness*2-tolerance, box_size.y-card_size.y+10, 10+.1-tolerance];
    difference() {
        cube(slider_size);
        translate([-.1, -.1, -.1])
            cube([slider_size.x+.2, 20+.1, bottom_thickness+.1]);
    }
    translate([slider_size.x/2-10, slider_size.y-wall_thickness,0])
        cube([20,wall_thickness,20]);
}



module build_token_holder() {
    //cube([box_size.x,circle_token_d+wall_thickness*2, circle_token_d]);

}

module triangle_pair(height, width, radius=1) {
    echo(wall_thickness);
    translate([wall_thickness,wall_thickness]) {
        triangle_size =[height-3*wall_thickness, width-3*wall_thickness];
        echo(triangle_size=triangle_size);

        rounded_triangle(triangle_size.y-wall_thickness, triangle_size.x-wall_thickness,radius);
        translate([triangle_size.x+wall_thickness,triangle_size.y+wall_thickness])
            rotate([0,0,180])
                rounded_triangle(triangle_size.y-wall_thickness, triangle_size.x-wall_thickness,radius);
    }
}

module rounded_triangle(height, width, radius) {
    r=radius;
    hull() {
        translate([r,r])
            circle(r=radius);
        translate([0+r,height-r])
            circle(r=radius);
        translate([width-r,0+r])
            circle(r=radius);
    }
}

