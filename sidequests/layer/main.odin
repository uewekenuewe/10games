package sidequest
import "base:intrinsics"
import "core:fmt"
import "core:math/rand"
import "core:reflect"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"


ODIN_DEBUG := true
GAME_HEIGHT: i32 = 800
GAME_WIDTH: i32 = 600
FPS: i32 = 60


red_circle :: struct {
	center: rl.Vector2,
}
blue_circle :: struct {
	center: rl.Vector2,
}


// Example structs
Person :: struct {
	name: string,
	age:  int,
}

Car :: struct {
	model: string,
	year:  int,
}
draw :: proc(value: $T) where intrinsics.type_is_struct(T) {


	//type_info := type_info_of(T)
	//fmt.println(type_info )

	if type_of(value) == red_circle {
		rl.DrawCircleV(rl.Vector2{100, 100}, 30, rl.RED)
	}

	if type_of(value) == blue_circle {
		rl.DrawCircleV(rl.Vector2{130, 130}, 30, rl.BLUE)
	}
}

draw_layer :: struct($T: typeid, $HT: typeid) {
	items: [dynamic]T,
	num:   int,
}
main :: proc() {

	rl.InitWindow(GAME_HEIGHT, GAME_WIDTH, "layers")

	rl.SetTargetFPS(FPS)

	rr := red_circle {
		center = rl.Vector2{0, 0},
	}
	bb := blue_circle {
		center = rl.Vector2{0, 0},
	}

	layers: [2]draw_layer


	for !rl.WindowShouldClose() {

		rl.ClearBackground(rl.BLACK)
		rl.BeginDrawing()
		draw(rr)
		draw(bb)
		rl.EndDrawing()

	}
	rl.CloseWindow()
}
