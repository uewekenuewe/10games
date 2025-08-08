package colortd
import rl "vendor:raylib"

import "core:fmt"
import "core:math/rand"
import "core:strconv"
import "core:strings"


ODIN_DEBUG := true
GAME_HEIGHT: i32 = 800
GAME_WIDTH: i32 = 600
FACTOR: i32 = 30
GAME_HEIGHT_SCALE: i32 = i32(GAME_HEIGHT / FACTOR)
GAME_WIDTH_SCALE: i32 = i32(GAME_WIDTH / FACTOR)
FPS: i32 = 60

Tower :: struct {
	radius:   i32,
	position: rl.Vector2,
	type:     string,
	damage:   int,
}

Creep :: struct {
	position:   rl.Vector2,
	color:      rl.Color,
	health:     int,
	speed:      f32,
	path_index: int,
	move_to:    rl.Vector2,
	delay:      int,
}

Game :: struct {
	towers:          [dynamic]Tower,
	score:           i32,
	state:           GameState,
	creeps:          [dynamic]Creep,
	avaiable_towers: i32,
	every_second:    f32,
	path:            [dynamic]rl.Vector2,
	wave:            rl.Color,
	player_life:     int,
	assets:          [dynamic]rl.Texture2D,
    frame_count : i32,
    frame_speed : i32,
    frame_current : i32,
}

GameState :: enum {
	NEW_WAVE,
	RUNNING,
	WON,
	LOST,
	CONFIG,
}

increment_color :: proc(c: ^rl.Color) {
	//// Color, 4 components, R8G8B8A8 (32bit)
	//red
	//green
	//blue
	if c.b < 255 {
		c.b += 1
		return
	}
	if c.g < 255 {
		c.g += 1
		return
	}

	if c.r < 255 {
		c.r += 1
		return
	}
}
increment_wave :: proc(g: ^Game) {
	increment_color(&g.wave)
}
wave_to_int :: proc(c: rl.Color) -> int {
	result := 100 * int(c.r) + 10 * int(c.g) + int(c.b)
	return result
}


draw_hexagon :: proc(center: rl.Vector2, radius: f32, color: rl.Color) {

	//rl.DrawPolyLines((rl.Vector2){f32(GAME_WIDTH / 4.0 * 3), 330}, 6, 90, 0.0, color)
	//rl.DrawPolyLinesEx((rl.Vector2){f32(GAME_WIDTH / 4.0 * 3), 330}, 6, 85, 0.0, 6, color)

}

update :: proc(g: ^Game) {
	//fmt.println(g.wave)
	// set tower
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && g.avaiable_towers > 0 {
		g.avaiable_towers -= 1
		t: Tower = {}
		t.type = "normal"
		t.radius = 100
		t.position = rl.GetMousePosition()
		t.damage = 1
		append(&g.towers, t)
	}

	// update all elements in game

	//update:creeps
	for &c in g.creeps {
		if c.delay > 0 {
			c.delay -= 1
			break
		}
		update_done := false
		if c.path_index < len(g.path) - 1 {
			move_to := g.path[c.path_index + 1]
			if move_to.x != c.position.x {
				if move_to.x > c.position.x {
					c.position.x += c.speed
				} else {
					c.position.x -= c.speed
				}
				update_done = true
			}
			if move_to.y != c.position.y {
				if move_to.y > c.position.y {
					c.position.y += c.speed
				} else {
					c.position.y -= c.speed
				}
				update_done = true
			}
			if !update_done {
				c.path_index += 1
			}

		}
	}

	// check if creep is in tower range for every tower
	creep_index := 0
	for t in g.towers {
		for &c in g.creeps {
			if rl.CheckCollisionCircles(t.position, f32(t.radius), c.position, 1) {
				c.health -= t.damage
				break
			}
		}
		creep_index += 1
	}

	// update GameState
	if g.player_life == 0 {
		g.state = GameState.LOST
	}

	if g.player_life > 0 && len(g.creeps) == 0 {
		g.state = GameState.NEW_WAVE
		fmt.println("wave:", g.wave)
	}

	if g.state == GameState.NEW_WAVE {
		increment_wave(g)
		for i in 0 ..< g.wave.b {
			append(
				&g.creeps,
				Creep {
					speed = 5,
					move_to = g.path[1],
					path_index = 0,
					color = g.wave,
					health = 10 + wave_to_int(g.wave),
					position = g.path[0],
					delay = int(i),
				},
			)
		}
		// new have give a new tower 
		if g.wave % 3 == 0 {
			g.avaiable_towers += 1
		}

		g.state = GameState.RUNNING
	}
}

bool_to_string :: proc(b: bool) -> string {
	if (b) {
		return string("true")
	} else {
		return string("false")
	}
}

int_to_string :: proc(inp: int) -> string {

	buf: [28]byte
	result := strconv.itoa(buf[:], inp)

	return result
}

draw :: proc(g: ^Game) {

	// draw field
	rl.DrawSplineLinear(&g.path[0], i32(len(g.path)), 10, rl.DARKGREEN)

	// draw game statistics
	rl.DrawFPS(15, 500)

	buf: [4]byte
	// draw boxes with level couts
	rl.DrawRectangle(55, 550, 20, 20, rl.BLUE)
	wave_b := strconv.itoa(buf[:], int(g.wave.b))
	rl.DrawText(strings.clone_to_cstring(wave_b), 55, 550, 20, rl.BLACK)

	rl.DrawRectangle(35, 550, 20, 20, rl.GREEN)
	wave_g := strconv.itoa(buf[:], int(g.wave.g))
	rl.DrawText(strings.clone_to_cstring(wave_g), 35, 550, 20, rl.BLACK)

	rl.DrawRectangle(15, 550, 20, 20, rl.RED)
	wave_r := strconv.itoa(buf[:], int(g.wave.r))
	rl.DrawText(strings.clone_to_cstring(wave_g), 15, 550, 20, rl.BLACK)

	//draw:tower
	for t in g.towers {

		fireball_asset: rl.Texture2D = g.assets[0]
		frameRec: rl.Rectangle = {
			0.0,
			0.0,
			f32(fireball_asset.width / 5),
			f32(fireball_asset.height),
		}

		if (g.frame_count>= (60 / g.frame_speed)) {
			g.frame_count = 0
			g.frame_current += 1

			if (g.frame_current > 4) {
				g.frame_current = 0
			}
			frameRec.x = f32(g.frame_current * fireball_asset.width / 5)
		}
		// correct position for drawing texture

		draw_position: rl.Vector2 = t.position
		draw_position.x -= f32(fireball_asset.height / 2)
		draw_position.y -= f32((fireball_asset.width / 5) / 2)

		rl.DrawTextureRec(fireball_asset, frameRec, draw_position, rl.WHITE)
	}


	// draw:creep
	creep_index := 0
	for c in g.creeps {
		if c.health >= 0 {
			rl.DrawPoly(c.position, 6, 15, 0.0, rl.BLACK)
			buf: [4]byte
			result := strconv.itoa(buf[:], c.health)
			rl.DrawText(
				strings.clone_to_cstring(result),
				i32(c.position.x),
				i32(c.position.y),
				15,
				rl.RED,
			)
		} else {
			ordered_remove(&g.creeps, creep_index)
		}
		creep_index += 1
	}


}


initGame :: proc() -> Game {
	game := Game{}
	game.avaiable_towers = 1
	game.score = 0
	game.state = GameState.RUNNING
	game.towers = [dynamic]Tower{}
	game.assets = [dynamic]rl.Texture2D{}

    game.frame_speed = 4
    game.frame_count = 0
    game.frame_current = 0

	fireball: rl.Texture2D = rl.LoadTexture("assets/fireball.png")

	append(&game.assets, fireball)

	game.every_second = 0.0

	//wave
	game.wave = rl.Color{0, 0, 1, 1}

	// 800x600
	game.path = [dynamic]rl.Vector2{}
	append(&game.path, rl.Vector2{55, 55})
	append(&game.path, rl.Vector2{600, 55})
	append(&game.path, rl.Vector2{600, 205})
	append(&game.path, rl.Vector2{200, 205})
	append(&game.path, rl.Vector2{200, 405})
	append(&game.path, rl.Vector2{600, 405})
	append(&game.path, rl.Vector2{600, 545})

	game.creeps = [dynamic]Creep{}
	append(
		&game.creeps,
		Creep {
			color = game.wave,
			path_index = 0,
			position = game.path[0],
			speed = 5,
			health = 5,
			move_to = game.path[1],
		},
	)

	//player_life
	game.player_life = 100

	return game
}

main :: proc() {

	rl.InitWindow(GAME_HEIGHT, GAME_WIDTH, "Color - Tower Defense")

	g := initGame()

	rl.SetTargetFPS(FPS)

	rotation: f32 = 0.0

	for !rl.WindowShouldClose() {


		rl.ClearBackground(rl.DARKGRAY)

        g.frame_count += 1

		update(&g)

		rl.BeginDrawing()

		draw(&g)

		rl.EndDrawing()
	}
	rl.CloseWindow()
}
