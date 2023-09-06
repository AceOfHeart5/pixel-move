/**
 * SmoothMove uses a linear algorithm to derive its position. This
 * ensures that any position changes appear smooth and consistent.
 * 
 * @param {Real} _x starting x position
 * @param {Real} _y starting y position
 */
function SmoothMove(_x, _y) constructor {
	// @notignore
	start_x = _x;
	// @notignore
	start_y = _y;
	// @notignore
	angle = 0;
	// @notignore
	delta = 0;
	
	/*
	This data allows for checking between the calculated position following the strict
	linear line algorithm, and what the position would have been if position was
	calculated normally.
	*/
	
	// @notignore
	error_x = start_x;
	// @notignore
	error_y = start_y;
	
	/*
	This is not for calculating x/y position. This is used to track how far this instance
	has travelled along the same angle.
	*/
	delta_on_angle = 0;
	
	/**
	 * Get the difference in radians between 2 angles. Both angles must be between 0
	 * and 2*pi radians. Favors the shortest distance. For example using 7*pi/4 and
	 * 1*pi/4 will return a difference of 2*pi/4.
	 * 
	 * @param {real} _a angle a in radians
	 * @param {real} _b angle b in radians
	 * @notignore
	 */
	function get_angle_diff(_a, _b) {
		var _diff1 = abs(_a - _b);
		var _diff2 = 2*pi - _diff1;
		return min(_diff1, _diff2);
	}
	
	/**
	 * Round given value to 0 if it's already close. This is mostly to deal
	 * with sin and cos not returning a perfect 0 on certain values.
	 *
	 * @param {real} _value
	 * @notignore
	 */
	function snap_to_zero(_value) {
		return abs(_value) < 0.001 ? 0 : _value;
	};
	
	/**
	 * Wrapper function around sin that snaps the result to 0 if it's within 0.001 of 0.
	 *
	 * @param {real} _angle angle in radians
	 * @notignore
	 */
	function snap_sin(_angle) {
		return snap_to_zero(sin(_angle));
	}
	
	/**
	 * Wrapper function around cos that snaps the result to 0 if it's within 0.001 of 0.
	 *
	 * @param {real} _angle angle in radians
	 * @notignore
	 */
	function snap_cos(_angle) {
		return snap_to_zero(cos(_angle));
	}
	
	/**
	 * @param {real} _value
	 * @notignore
	 */
	function round_to_thousandths(_value) {
		var _result = floor(_value * 1000 + 0.5) / 1000;
		return _result;
	}
	
	/**
	 * Rounding function to account for gamemaker's imperfect real tracking
	 *
	 * @param {real} _value
	 * @notignore
	 */
	function round_to_correct(_value) {
		var _result = floor(_value * 100000 + 0.5) / 100000;
		return _result;
	}
	
	/**
	 * Return the given angle in radians rounded roughly towards the cardinal directions
	 * and their intermediates.
	 *
	 * @param {real} _angle
	 * @notignore
	 */
	function snap_to_cardinals(_angle) {
		if (round_to_thousandths(_angle) == round_to_thousandths(0*pi/4)) _angle = 0*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(1*pi/4)) _angle = 1*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(2*pi/4)) _angle = 2*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(3*pi/4)) _angle = 3*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(4*pi/4)) _angle = 4*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(5*pi/4)) _angle = 5*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(6*pi/4)) _angle = 6*pi/4;
		if (round_to_thousandths(_angle) == round_to_thousandths(7*pi/4)) _angle = 7*pi/4;
		return _angle;
	}
	
	/**
	 * Given real _a and real _b, returns _a rounded in the direction of _b. It is possible for 
	 * sign(result - _b) to be different from sign(_a - _b) if _a and _b have the same whole
	 * number value.
	 *
	 * @notignore
	 */
	function round_towards(_a, _b) {
		var _result = (_a - _b) >= 0 ? floor(_a) : ceil(_a);
		return _result == 0 ? 0 : _result; // prevents -0
	}
	
	/**
	 * SmoothMove works by inferring x and y positions based off the 2D vector it's moved by.
	 * This function returns true if the x magnitude of the vector is greater than the y
	 * magnitude, indicating that the y position should be inferred from the x position.
	 * Returns false if the reverse is true.
	 *
	 * @notignore
	 */
	infer_y_from_x = function() {
		return (angle <= 1*pi/4 || angle >= 7*pi/4 || (angle >= 3*pi/4 && angle <= 5*pi/4));
	};
	
	/**
	 * Get the x magnitude given the given angle and delta.
	 *
	 * @notignore
	 */
	get_magnitude_x = function() {
		return snap_cos(angle) * delta;
	}
	
	/**
	 * Get the y magnitude given the current angle and delta.
	 *
	 * @notignore
	 */
	get_magnitude_y = function() {
		return snap_sin(angle) * delta;
	};
	
	/**
	 * Get the x component of the given vector.
	 *
	 * @param {real} _angle
	 * @param {real} _delta
	 * @notignore
	 */
	function get_x_component(_angle, _delta) {
		if (_delta == 0 || _angle == 2*pi/4 || _angle == 6*pi/4) return 0;
		return snap_cos(_angle) * _delta;
	}
	
	/**
	 * Get the y component of the given vector.
	 *
	 * @param {real} _angle
	 * @param {real} _delta
	 * @notignore
	 */
	function get_y_component(_angle, _delta) {
		if (_delta == 0 || _angle == 0 || _angle == 4*pi/4) return 0;
		return snap_sin(_angle) * _delta;
	}
	
	/**
	 * Get the slope to be used to infer an x or y position. The slope changes depending on
	 * whether the x or y magnitude of the 2D vector is greater.
	 *
	 * @notignore
	 */
	slope = function() {
		if (delta == 0) return 0;
		var _result = infer_y_from_x() ? get_magnitude_y() / get_magnitude_x() : get_magnitude_x() / get_magnitude_y();
		return _result;
	}
	
	/**
	 * Reset the start and delta values of this instance.
	 *
	 * @notignore
	 */
	reset = function() {
		var _x = smooth_move_get_x(self);
		var _y = smooth_move_get_y(self);
		start_x = _x;
		start_y = _y;
		delta = 0;
		delta_on_angle = 0;
	};
	
	/**
	 * Get the real, non-integer value of x calculated from the vector.
	 *
	 * @notignore
	 */
	get_vector_x = function() {
		return start_x + get_magnitude_x();
	};
	
	/**
	 * Get the real, non-integer value of y calculated from the vector.
	 *
	 * @notignore
	 */
	get_vector_y = function() {
		return start_y + get_magnitude_y();
	};
}

/**
 * Get a copy of the given SmoothMove instance.
 *
 * @param {Struct.SmoothMove} _smooth_move
 */
function smooth_move_get_copy(_smooth_move) {
	var _copy = new SmoothMove(0, 0);
	_copy.start_x = _smooth_move.start_x;
	_copy.start_y = _smooth_move.start_y;
	_copy.angle = _smooth_move.angle;
	_copy.delta = _smooth_move.delta;
	_copy.erro_x = _smooth_move.error_x;
	_copy.error_y = _smooth_move.error_y;
	_copy.error_x = _smooth_move.error_x;
	_copy.error_y = _smooth_move.error_y;
	return _copy;
}

/**
 * Get the current x position of the given SmoothMove instance.
 *
 * @param {Struct.SmoothMove} _smooth_move
 */
function smooth_move_get_x(_smooth_move) {
	with (_smooth_move) {
		if (delta == 0) return start_x;
		if (infer_y_from_x()) {
			var _change = get_magnitude_x();
			var _x = round_to_correct(start_x + _change);
			var _result = round_towards(_x, start_x);
			return _result;
		}
		
		// derive x position from linear line function of y
		var _slope = slope();
		var _y_diff = smooth_move_get_y(self) - start_y;
		var _x = round_to_thousandths(_slope * _y_diff + start_x);
		return round_towards(_x, start_x);
	}
}

/**
 * Get the current y position of the given SmoothMove instance.
 *
 * @param {Struct.SmoothMove} _smooth_move
 */
function smooth_move_get_y(_smooth_move) {
	with (_smooth_move) {
		if (delta == 0) return start_y;
		if (!infer_y_from_x()) {
			var _change = get_magnitude_y();
			var _y = round_to_correct(start_y + _change);
			var _result = round_towards(_y, start_y);
			return _result;
		}
		
		// derive y position from linear line function of x
		var _slope = slope();
		var _x_diff = smooth_move_get_x(self) - start_x;
		var _y = round_to_thousandths(_slope * _x_diff + start_y);
		return round_towards(_y, start_y);
	}
}

/**
 * Set the position of the given SmoothMove instance.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _x
 * @param {real} _y
 */
function smooth_move_set_position(_smooth_move, _x, _y) {
	_x = floor(_x);
	_y = floor(_y);
	with (_smooth_move) {
		start_x = _x;
		start_y = _y;
		delta = 0;
		error_x = _x;
		error_y = _y;
	}
}

/**
 * Move the given SmoothMove instance by the given vector. Angle of 0 corresponds to straight along positive x axis
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _angle angle of vector in radians
 * @param {real} _magnitude magnitude of vector
 */
function smooth_move_by_vector(_smooth_move, _angle, _magnitude) {
	with (_smooth_move) {
		if (_angle < 0) _angle = _angle % (-2*pi) + 2*pi;
		if (_angle >= 2*pi) _angle %= 2*pi;
		_angle = snap_to_cardinals(_angle);
		var _angle_changed = angle != _angle;
		
		// always reset smooth move state on no movement or angle change
		if ((_magnitude == 0) || _angle_changed) reset();
		
		// reset error data on no movement or too great an angle change
		if ((_magnitude == 0) || get_angle_diff(angle, _angle) >= pi/4) {
			error_x = smooth_move_get_x(self);
			error_y = smooth_move_get_y(self);
		}
		
		angle = _angle;
		delta += _magnitude;
		delta_on_angle += _magnitude;
		
		error_x += get_x_component(_angle, _magnitude);
		error_y += get_y_component(_angle, _magnitude);
		
		// correct error using delta_on_angle
		var _error_correct_percentage = min(sqr(delta_on_angle / 4), 1);
		var _error_diff_x = get_vector_x() - error_x;
		var _error_diff_y = get_vector_y() - error_y;
		var _end_diff_x = _error_correct_percentage * _error_diff_x;
		var _end_diff_y = _error_correct_percentage * _error_diff_y;
		
		var _final_x = get_vector_x();
		var _final_y = get_vector_y();
		
		var _fixed_error_x = error_x + _end_diff_x;
		var _fixed_error_y = error_y + _end_diff_y;
		error_x += _end_diff_x;
		error_y += _end_diff_y;
		
		// comparing x/y derived from line equation to these tracked values will always result in an error eventually, need to change
		// perhaps only check errors if _error_correct_percentage is less than 100%?
		var _error_x = round_towards(round_to_correct(error_x), start_x);
		var _error_y = round_towards(round_to_correct(error_y), start_y);
		
		var _calculated_x = smooth_move_get_x(self);
		var _calculated_y = smooth_move_get_y(self);
		
		var _error = sqrt(sqr(_error_x - _calculated_x) + sqr(_error_y - _calculated_y));
		
		if (_error >= 1) {
			start_x = _error_x;
			start_y = _error_y;
			delta = 0;
		}
		
		/*
		// error correction
		if (_error >= 1) {
			start_x += (_error_x - _calculated_x);
			start_y += (_error_y - _calculated_y);
			
			//Change delta so calculated x/y is as close to error as possible. New delta will
			//be hypotenuse of triangle formed by calculated_vector_xy, error_xy, and point on
			//vector that forms perpendicular line with error. This point is the closest possible
			//point to error on the vector line
			var _pre_delta_change_x = smooth_move_get_x(self);
			var _pre_delta_change_y = smooth_move_get_y(self);
			
			var _error_theta = arctan2(error_y - get_vector_y(), error_x - get_vector_x());
			var _theta = get_angle_diff(_error_theta, angle);
			var _side_b = sqrt(sqr(error_y - get_vector_y()) + sqr(error_x - get_vector_x()));
			var _delta_change = _side_b / cos(_theta);
			delta += _delta_change;
			
			var _post_delta_change_x = smooth_move_get_x(self);
			var _post_delta_change_y = smooth_move_get_y(self);
			if (_pre_delta_change_x != _post_delta_change_x || _pre_delta_change_y != _post_delta_change_y) {
				show_debug_message("delta change was too extreme");
			} else {
				show_debug_message("delta change was good");
			}
		}
		*/
	}
}

/**
 * Move the given SmoothMove instance by the given x and y magnitudes.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _magnitude_x
 * @param {real} _magnitude_y
 */
function smooth_move_by_magnitudes(_smooth_move, _magnitude_x, _magnitude_y) {
	with (_smooth_move) {
		var _angle = arctan2(_magnitude_y, _magnitude_x);
		var _m = sqrt(sqr(_magnitude_x) + sqr(_magnitude_y));
		smooth_move_by_vector(_smooth_move, _angle, _m);
	}
}

/**
 * Get the x position of the given SmoothMove instance if it was moved by the given vector.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _angle angle in radians of the vector
 * @param {real} _magnitude magnitude of the vector
 */
function smooth_move_get_x_if_moved_by_vector(_smooth_move, _angle, _magnitude) {
	var _copy = smooth_move_get_copy(_smooth_move);
	smooth_move_by_vector(_copy, _angle, _magnitude);
	return smooth_move_get_x(_copy);
}

/**
 * Get the y position of the given SmoothMove instance if it was moved by the given vector.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _angle angle in radians of the vector
 * @param {real} _magnitude magnitude of the vector
 */
function smooth_move_get_y_if_moved_by_vector(_smooth_move, _angle, _magnitude) {
	var _copy = smooth_move_get_copy(_smooth_move);
	smooth_move_by_vector(_copy, _angle, _magnitude);
	return smooth_move_get_y(_copy);
}

/**
 * Get the x position of the given SmoothMove instance if it was moved by the given x and y magnitudes.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _magnitude_x
 * @param {real} _magnitude_y
 */
function smooth_move_get_x_if_moved_by_magnitudes(_smooth_move, _magnitude_x, _magnitude_y) {
	var _copy = smooth_move_get_copy(_smooth_move);
	var _angle = arctan2(_magnitude_y, _magnitude_x);
	var _m = sqrt(sqr(_magnitude_x) + sqr(_magnitude_y));
	smooth_move_by_vector(_copy, _angle, _m);
	return smooth_move_get_x(_copy);
}

/**
 * Get the y position of the given SmoothMove instance if it was moved by the given x and y magnitudes.
 *
 * @param {Struct.SmoothMove} _smooth_move
 * @param {real} _magnitude_x
 * @param {real} _magnitude_y
 */
function smooth_move_get_y_if_moved_by_magnitudes(_smooth_move, _magnitude_x, _magnitude_y) {
	var _copy = smooth_move_get_copy(_smooth_move);
	var _angle = arctan2(_magnitude_y, _magnitude_x);
	var _m = sqrt(sqr(_magnitude_x) + sqr(_magnitude_y));
	smooth_move_by_vector(_copy, _angle, _m);
	return smooth_move_get_y(_copy);
}
