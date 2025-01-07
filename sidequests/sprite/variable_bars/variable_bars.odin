package variable_bars
import rl "vendor:raylib"

variable_bar :: struct {
	name:          cstring,
	min_value:     f32,
	max_value:     f32,
	current_value: ^f32,
}


draw_variable_bars :: proc(var: []variable_bar, window_height: i32, window_width: i32) {
    //TODO maybe calc lenght of text // variable name and increase decrease size of slider
    //idea: loop over all variables find biggets textsize then take this -> may result in very small sliders
	if len(var) > 0 {
		rl.SetWindowSize(window_width, window_height + i32(20 * len(var)))
		for value, index in var {
			slider_rec: rl.Rectangle = rl.Rectangle {
				0.0,
				f32(f32(window_height)+ f32(20 * index)),
				f32(window_width-100),
				20.0,
			}
			rl.GuiSlider(
                slider_rec,
				value.name,
				value.name,
				value.current_value,
				value.min_value,
				value.max_value,
			)
		}
	}
}
