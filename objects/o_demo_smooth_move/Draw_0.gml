var _up = keyboard_check(vk_up);
var _dn = keyboard_check(vk_down);
var _lt = keyboard_check(vk_left);
var _rt = keyboard_check(vk_right);

var _vert = 0;
var _horz = 0;

if (_up) _vert -= 1;
if (_dn) _vert += 1;
if (_rt) _horz += 1;
if (_lt) _horz -= 1;

var _angle = arctan2(_vert, _horz)

var _vel = (_vert != 0 || _horz != 0) ? 0.5 : 0;

stick = gamepad_get_left_stick_data();
stick_mag = sqrt(sqr(stick.axis_h) + sqr(stick.axis_v));
stick_angle = arctan2(stick.axis_v, stick.axis_h);
if (stick_mag > 0) {
	_angle = stick_angle;
	//_vel = stick_mag * 1;
	_vel = 1
}

prev_x = smooth_move_get_x(smooth_move);
prev_y = smooth_move_get_y(smooth_move);

if (x == 89 && y == 61) {
	show_debug_message("debug");
}

//smooth_move_by_vector(smooth_move, _angle, _vel);
smooth_move_by_vector(smooth_move, angle, 1);
angle += 0.033;

//smooth_move_by_magnitudes(smooth_move, 0.3, 1);
//smooth_move_by_magnitudes(smooth_move, 1, 0.3);
//smooth_move_by_magnitudes(smooth_move, 1, -0.3);
//smooth_move_by_magnitudes(smooth_move, 0.3, -1);
//smooth_move_by_magnitudes(smooth_move, -0.3, -1);
//smooth_move_by_magnitudes(smooth_move, -1, -0.3);
//smooth_move_by_magnitudes(smooth_move, -1, 0.3);
//smooth_move_by_magnitudes(smooth_move, -0.3, 1);

//smooth_move_by_magnitudes(smooth_move, 0.3, 0);
//smooth_move_by_magnitudes(smooth_move, -0.3, 0);
//smooth_move_by_magnitudes(smooth_move, 0, 0.3);
//smooth_move_by_magnitudes(smooth_move, 0, -0.3);

//smooth_move_by_magnitudes(smooth_move, 0.5, -0.5);
//smooth_move_by_magnitudes(smooth_move, -0.5, -0.5);
//smooth_move_by_magnitudes(smooth_move, -0.5, 0.5);
//smooth_move_by_magnitudes(smooth_move, 0.5, 0.5);

//smooth_move_by_magnitudes(smooth_move, 1, toggle_y);
//toggle_y = toggle_y == 0 ? 0.3 : 0;

var _x = smooth_move_get_x(smooth_move);
var _y = smooth_move_get_y(smooth_move);

var _delta = smooth_move.delta;
var _total_delta_x = smooth_move.total_delta_x;
var _total_delta_y = smooth_move.total_delta_y;
var _off_axis_delta = smooth_move.off_axis_delta;

x = _x;
y = _y;

//draw_self();

if (keyboard_check_pressed(ord("C"))) {
	positions = create_positions();
}

if (_x != positions[positions_index][0] || _y != positions[positions_index][1]) {
	positions_index += 1;
	if (positions_index >= array_length(positions)) positions_index = 0;
	positions[positions_index] = [_x, _y];
}


draw_set_color(c_lime);
for (var _i = 0; _i < array_length(positions); _i++) {
	draw_point(positions[_i][0], positions[_i][1]);
}
