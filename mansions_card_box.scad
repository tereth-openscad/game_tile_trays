
wall_lines = 4;//should be even
bottom_layers=10;
num_tiles=0;

include <mansions_tile_sizes.scad>
include <mansions_tiles.scad>
use <helpers/openscad_manual/list.scad>

num_bays=1;

slide_cut = 2*line_width;

slide_thickness = 2;
card_extension = 20;
division_offset = 5+slide_thickness;

damage_thickness = 45;
sanity_thickness = 45;
c_item_thickness = 50;
u_item_thickness = 30;
spells_thickness = 45;
cond_thickness = 30;
insane_thickness = 20;
elixir_thickness = 5;

function calc_bay_usage(v, thickness) = add2(v) + len(v)*slide_thickness;
function calc_bay_size(size, last=1) = last*division_offset < size ? calc_bay_size(size,last+1) : last;

bay1 = calc_bay_usage([damage_thickness,sanity_thickness], slide_thickness);
bay2 = calc_bay_usage([c_item_thickness,u_item_thickness], slide_thickness);
bay3 = calc_bay_usage([spells_thickness,cond_thickness,insane_thickness], slide_thickness);

echo(bay1=bay1);
echo(bay2=bay2);
echo(bay3=bay3);

echo(max_usage=max(bay1,bay2,bay3));

num_divisions = calc_bay_size(max(bay1,bay2,bay3)) + 3;
num_divisions = 3;

card_size = [45, 68, 1];
divider_size = [card_size.x+2*slide_cut, card_size.y, 1];

box_size = [card_size.x, num_divisions*division_offset-slide_thickness, card_size.y-card_extension];

echo(box_size=box_size);

module make_card(size, block_size) {
    linear_extrude(card_size.y)
        resize([card_size.x,block_size])
            square(1);
}

module make_divider(size, thickness) {
    linear_extrude(size.y-card_extension)
        resize([size.x, thickness])
            square(1);
}

for(i=[1:1:num_bays]) {
    translate([(i-1)*(box_size.x+2*wall_thickness),0]) {
        difference() {
            group() {
                create_tile(box_size, bottom_thickness);
                create_wall(box_size, card_size.y-card_extension, wall_thickness);
            }

            for(i = [division_offset-slide_thickness:division_offset:box_size.y-slide_thickness])
                translate([-slide_cut,i,bottom_thickness])
                    make_divider(divider_size, slide_thickness);
        }
    }
}

