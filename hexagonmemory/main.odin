package game
import "core:encoding/hex"
import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:os"
import "core:strconv"
import "core:strings"


// global vars
ODIN_DEBUG := true
GAME_HEIGHT: f32 = 1920
GAME_WIDTH: f32 = 1080
FPS: i32 = 30
GAME_MAX_LEVEL :: 6
GAME_MIN_LEVEL :: 1
RADIUS: f32 : 100.0
SQRT_THREE :: 1.73205080757
SHADER_DIR := "./shaders/"
GAME: Game
// structs
Game :: struct {
	score:        i32,
	state:        GameState,
	level:        i32,
	every_second: f32,
	rainbow_mode: bool,
	select_count: i32,
	hexagons:     [dynamic]Hexagon,
	thicness:     f32,
	shaders:      [dynamic]rl.Shader,
	shader_names: [dynamic]string,
}

Hexagon :: struct {
	center:        rl.Vector2,
	animation:     ANIMATION,
	animation_rec: rl.Rectangle,
	is_selected:   bool,
}

GameState :: enum {
	RUNNING,
	WON,
	LOST,
	CONFIG,
}

load_shaders :: proc(basedir: string) -> ([dynamic]rl.Shader, [dynamic]string) {
	result_shader := [dynamic]rl.Shader{}
	result_names := [dynamic]string{}

	// Open the directory
	dir, err := os.open(basedir)
	if err != nil {
		fmt.eprintln("Error opening directory:", err)
		return result_shader, result_names
	}
	defer os.close(dir)

	entries, read_err := os.read_dir(dir, 0)
	if read_err != nil {
		fmt.eprintln("Error reading directory:", read_err)
		return result_shader, result_names
	}
	defer delete(entries)

	for entry in entries {
		append(&result_names, entry.name)
		append(&result_shader, rl.LoadShader("", strings.unsafe_string_to_cstring(entry.fullpath)))
	}

	return result_shader, result_names
}


// returns the hexagon index of game object where mouse is closest to center
get_hexagon_at_mouse_position :: proc(GAME: ^Game, position: rl.Vector2) -> int{
	result := 0

	min_dist := max(f32)

	for i:= 0 ; i < len(GAME.hexagons); i+=1 {
		helper := min(min_dist, rl.Vector2Distance(GAME.hexagons[i].center, position))
		if helper < min_dist {
			result = i
            min_dist = helper
		}
	}

	return result
}
//redo collision get a function that maps mouse position to a hexagon?!
//rather then checking every hexagon and mouse
// maybe get first hexagon and then go to neighbors to check?!
depricated_get_hexagon_at_mouse_position :: proc() {
	for &hexagon in GAME.hexagons {
		verticies := [dynamic]rl.Vector2{}
		inner_radius := f32(60 - 15)
		append(
			&verticies,
			rl.Vector2 {
				hexagon.center.x + inner_radius / 2,
				hexagon.center.y - math.sqrt_f32(3) / 2 * inner_radius,
			},
		)
		append(&verticies, rl.Vector2{hexagon.center.x + inner_radius, hexagon.center.y})
		append(
			&verticies,
			rl.Vector2 {
				hexagon.center.x + inner_radius / 2,
				hexagon.center.y + math.sqrt_f32(3) / 2 * inner_radius,
			},
		)
		append(
			&verticies,
			rl.Vector2 {
				hexagon.center.x - inner_radius / 2,
				hexagon.center.y + math.sqrt_f32(3) / 2 * inner_radius,
			},
		)
		append(&verticies, rl.Vector2{hexagon.center.x - inner_radius, hexagon.center.y})
		append(
			&verticies,
			rl.Vector2 {
				hexagon.center.x - inner_radius / 2,
				hexagon.center.y - math.sqrt_f32(3) / 2 * inner_radius,
			},
		)

		collision :=
			rl.CheckCollisionPointTriangle(
				rl.GetMousePosition(),
				verticies[0],
				verticies[2],
				verticies[1],
			) ||
			rl.CheckCollisionPointTriangle(
				rl.GetMousePosition(),
				verticies[5],
				verticies[4],
				verticies[3],
			) ||
			rl.CheckCollisionPointTriangle(
				rl.GetMousePosition(),
				verticies[0],
				verticies[2],
				verticies[1],
			) ||
			rl.CheckCollisionPointTriangle(
				rl.GetMousePosition(),
				verticies[3],
				verticies[0],
				verticies[5],
			) ||
			rl.CheckCollisionPointTriangle(
				rl.GetMousePosition(),
				verticies[3],
				verticies[2],
				verticies[0],
			)

		if collision {
			hexagon.is_selected = !hexagon.is_selected
		}
	}
}

update :: proc(GAME: ^Game) {
	if (rl.IsKeyPressed(rl.KeyboardKey.A)) {
		GAME.level = math.min(GAME.level + 1, GAME_MAX_LEVEL)
		init_hexagons(GAME, GAME.level)
	}
	if (rl.IsKeyPressed(rl.KeyboardKey.S)) {
		GAME.level = math.max(GAME.level - 1, GAME_MIN_LEVEL)
		init_hexagons(GAME, GAME.level)
	}
	if (rl.IsKeyPressed(rl.KeyboardKey.RIGHT)) {
		GAME.thicness += 10}
	if (rl.IsKeyPressed(rl.KeyboardKey.LEFT)) {
		GAME.thicness -= 10}
	if GAME.thicness < 10 {
		GAME.thicness = 10
	}
	// left to select
	if (GAME.select_count < 2 && rl.IsMouseButtonPressed(rl.MouseButton.LEFT)) {
        hexagon_index := get_hexagon_at_mouse_position(GAME,rl.GetMousePosition())
        GAME.hexagons[hexagon_index].is_selected = true
		GAME.select_count += 1
	}
	// right to delselect
	if (GAME.select_count > 0 && rl.IsMouseButtonPressed(rl.MouseButton.RIGHT)) {
        hexagon_index := get_hexagon_at_mouse_position(GAME,rl.GetMousePosition())
        GAME.hexagons[hexagon_index].is_selected = false
		GAME.select_count -= 1
	}
}

draw_hexagon :: proc(hexagon: Hexagon) {
	rl.DrawPolyLinesEx(hexagon.center, 6, RADIUS, 60, 5, rl.Color{139, 58, 0, 255})
	rl.DrawCircleV(hexagon.center, 10.0, rl.RED)

	verticies := [dynamic]rl.Vector2{}
	inner_radius := RADIUS
	append(
		&verticies,
		rl.Vector2 {
			hexagon.center.x + inner_radius / 2,
			hexagon.center.y - math.sqrt_f32(3) / 2 * inner_radius,
		},
	)
	append(&verticies, rl.Vector2{hexagon.center.x + inner_radius, hexagon.center.y})
	append(
		&verticies,
		rl.Vector2 {
			hexagon.center.x + inner_radius / 2,
			hexagon.center.y + math.sqrt_f32(3) / 2 * inner_radius,
		},
	)

	append(
		&verticies,
		rl.Vector2 {
			hexagon.center.x - inner_radius / 2,
			hexagon.center.y + math.sqrt_f32(3) / 2 * inner_radius,
		},
	)
	append(&verticies, rl.Vector2{hexagon.center.x - inner_radius, hexagon.center.y})
	append(
		&verticies,
		rl.Vector2 {
			hexagon.center.x - inner_radius / 2,
			hexagon.center.y - math.sqrt_f32(3) / 2 * inner_radius,
		},
	)

	for v in verticies {
		rl.DrawCircleV(v, 10, rl.RED)
	}

	if hexagon.is_selected {
		rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.BLUE)
		rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.BLUE)
		rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.BLUE)
		rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.BLUE)
	} else {
		rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.BLACK)
		rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.BLACK)
		rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.BLACK)
		rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.BLACK)
	}


	//do we move this collision to update?
	/* collision should be in update?! based on state of object we do some drawing
	collision :=
		rl.CheckCollisionPointTriangle(
			rl.GetMousePosition(),
			verticies[0],
			verticies[2],
			verticies[1],
		) ||
		rl.CheckCollisionPointTriangle(
			rl.GetMousePosition(),
			verticies[5],
			verticies[4],
			verticies[3],
		) ||
		rl.CheckCollisionPointTriangle(
			rl.GetMousePosition(),
			verticies[0],
			verticies[2],
			verticies[1],
		) ||
		rl.CheckCollisionPointTriangle(
			rl.GetMousePosition(),
			verticies[3],
			verticies[0],
			verticies[5],
		) ||
		rl.CheckCollisionPointTriangle(
			rl.GetMousePosition(),
			verticies[3],
			verticies[2],
			verticies[0],
		)

	if collision {
		rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.RED)
		rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.RED)

		rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.RED)
		rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.RED)

		GLOBAL_COLLISION = true
		rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.RED)
		rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.RED)
		rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.RED)
		rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.RED)

	} else {
		if hexagon.is_selected {
			rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.BLUE)
			rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.BLUE)
			rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.BLUE)
			rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.BLUE)
		} else {
			rl.DrawTriangle(verticies[0], verticies[2], verticies[1], rl.BLACK)
			rl.DrawTriangle(verticies[5], verticies[4], verticies[3], rl.BLACK)
			rl.DrawTriangle(verticies[3], verticies[0], verticies[5], rl.BLACK)
			rl.DrawTriangle(verticies[3], verticies[2], verticies[0], rl.BLACK)
		}

	}

        */

}


draw :: proc(GAME: ^Game) {
	for hexagon in GAME.hexagons {
		if hexagon.is_selected && hexagon.animation == ANIMATION.SPIRAL {
			rl.BeginShaderMode(GAME.shaders[0])
			draw_hexagon(hexagon)
			rl.EndShaderMode()
		} else {
			draw_hexagon(hexagon)
		}
	}
}

ANIMATION :: enum {
	LOGO,
	DOOMFIRE,
	SPIRAL,
}
DIRECTIONS :: enum {
	NORTH,
	SOUTH,
	NORTH_WEST,
	SOUTH_WEST,
	NORTH_EAST,
	SOUTH_EAST,
}
get_hexagon_neighbors_with_direction :: proc(
	center: rl.Vector2,
	radius: f32,
	direction: DIRECTIONS,
) -> rl.Vector2 {
	result: rl.Vector2 = rl.Vector2{}

	if direction == DIRECTIONS.NORTH {
		result = rl.Vector2{center.x, center.y + math.sqrt_f32(3) * -RADIUS} // NORTH
	}

	if direction == DIRECTIONS.SOUTH {
		result = rl.Vector2{center.x, center.y + math.sqrt_f32(3) * RADIUS} // SOUTH
	}
	if direction == DIRECTIONS.NORTH_WEST {
		result = rl.Vector2{center.x - 1.5 * RADIUS, center.y - math.sqrt_f32(3) / 2 * RADIUS} //NORTH WEST
	}
	if direction == DIRECTIONS.NORTH_EAST {
		result = rl.Vector2{center.x + 1.5 * RADIUS, center.y - math.sqrt_f32(3) / 2 * RADIUS} //NORTH EAST
	}
	if direction == DIRECTIONS.SOUTH_WEST {
		result = rl.Vector2{center.x - 1.5 * RADIUS, center.y + math.sqrt_f32(3) / 2 * RADIUS} //SOUTH WEST
	}
	if direction == DIRECTIONS.SOUTH_EAST {
		result = rl.Vector2{center.x + 1.5 * RADIUS, center.y + math.sqrt_f32(3) / 2 * RADIUS} //SOUTH EAST
	}

	return result
}
get_hexagon_neighbors_all :: proc(center: rl.Vector2, radius: f32) -> [6]rl.Vector2 {
	result: [6]rl.Vector2 = [6]rl.Vector2{}


	result[0] = rl.Vector2{center.x, center.y + math.sqrt_f32(3) * -RADIUS} // NORTH
	result[1] = rl.Vector2{center.x, center.y + math.sqrt_f32(3) * RADIUS} // SOUTH

	result[2] = rl.Vector2{center.x - 1.5 * RADIUS, center.y - math.sqrt_f32(3) / 2 * RADIUS} //NORTH WEST
	result[3] = rl.Vector2{center.x + 1.5 * RADIUS, center.y - math.sqrt_f32(3) / 2 * RADIUS} //NORTH EAST

	result[4] = rl.Vector2{center.x - 1.5 * RADIUS, center.y + math.sqrt_f32(3) / 2 * RADIUS} //SOUTH EAST
	result[5] = rl.Vector2{center.x + 1.5 * RADIUS, center.y + math.sqrt_f32(3) / 2 * RADIUS} //SOUTH EAST


	return result
}

init_hexagons :: proc(GAME: ^Game, level: i32) {
	GAME.hexagons = [dynamic]Hexagon{}
	center := rl.Vector2{GAME_HEIGHT / 2, GAME_WIDTH / 2}
	append(
		&GAME.hexagons,
		Hexagon {
			center = center,
			is_selected = false,
			animation = ANIMATION.LOGO,
			animation_rec = rl.Rectangle {
				x = center.x,
				y = center.y + GAME.thicness - math.sqrt_f32(3) / 2 * RADIUS,
				width = RADIUS * 2,
				height = math.sqrt_f32(3) * RADIUS,
			},
		},
	)

	for l in 0 ..< GAME.level {
		current_hexagons := GAME.hexagons
		for hexagon in current_hexagons {
			center := hexagon.center
			neighbors := get_hexagon_neighbors_all(center, RADIUS)
			x := 0
			for n in neighbors {

				add_hexagon := true
				for hexagon_result in GAME.hexagons {
					if hexagon_result.center == n {
						add_hexagon = false
						break
					}
				}
				if add_hexagon {
					if math.mod_f32(f32(x), 2.0) == 0 {

						append(
							&GAME.hexagons,
							Hexagon {
								center = n,
								is_selected = true,
								animation = ANIMATION.SPIRAL,
								animation_rec = rl.Rectangle {
									x = n.x,
									y = n.y + GAME.thicness - math.sqrt_f32(3) / 2 * RADIUS,
									width = RADIUS * 2,
									height = math.sqrt_f32(3) * RADIUS,
								},
							},
						)
					} else {
						append(
							&GAME.hexagons,
							Hexagon {
								center = n,
								is_selected = true,
								animation = ANIMATION.DOOMFIRE,
								animation_rec = rl.Rectangle {
									x = n.x,
									y = n.y + GAME.thicness - math.sqrt_f32(3) / 2 * RADIUS,
									width = RADIUS * 2,
									height = math.sqrt_f32(3) * RADIUS,
								},
							},
						)
					}
					x += 1
				}
			}
		}
	}
}

init_game :: proc() -> Game {
	result := Game{}
	result.thicness = RADIUS
	result.level = 1
	result.select_count = 0

	init_hexagons(&result, 1)

	result.shaders, result.shader_names = load_shaders(SHADER_DIR)

	return result
}


GLOBAL_COLLISION := false


// for a give center draw a rec tangle
draw_rectangle_center_v :: proc(center: rl.Vector2, height: f32, width: f32, color: rl.Color) {
	top_left: rl.Vector2 = {center.x - (width / 2), center.y - (height / 2)}
	rl.DrawRectangleV(top_left, rl.Vector2{height, width}, color)
}

main :: proc() {

	rl.InitWindow(i32(GAME_HEIGHT), i32(GAME_WIDTH), "hexagon shader memory")

	// game stuff
	GAME := init_game()

	time_loc := rl.GetShaderLocation(GAME.shaders[0], "time")
	rl.SetTargetFPS(FPS)

	frames: i32 = 0

	for !rl.WindowShouldClose() {

		background_color := rl.Color{255, 208, 105, 255}
		rl.ClearBackground(background_color)
		frames += 1

		update(&GAME)

		rl.BeginDrawing()
		draw(&GAME)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
