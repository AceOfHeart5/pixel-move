camera_init_basic(200, 112, 10);
pixel_move = new PixelMove(x, y);

//pixel_move_set_movement_type_smooth(pixel_move);

create_positions = function() {
	return ds_map_create();
};

positions = create_positions();

/**
 * @param {real} _x
 * @param {real} _y
 */
position_add = function (_x, _y) {
	ds_map_set(positions,  $"{_x},{_y}", [_x, _y])
};

stick = gamepad_get_left_stick_data();
stick_mag = sqrt(sqr(stick.axis_h) + sqr(stick.axis_v));
stick_angle = arctan2(stick.axis_v, stick.axis_h) + pi/2;

angle = 0;
