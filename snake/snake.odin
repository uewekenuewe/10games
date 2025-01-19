package game
import rl "vendor:raylib"

import "core:fmt"
import "core:math/rand"
import "core:strconv"
import "core:strings"


ODIN_DEBUG := true
GAME_HEIGHT: i32 = 800
GAME_WIDTH: i32 = 600
FPS: i32 = 30

Player :: struct {
	position:  Vector2,
	positions: [dynamic]Vector2,
	direction: Vector2,
	length:    i32,
}

Game :: struct {
	player: Player,
	score:  i32,
	state:  GameState,
}

GameState :: enum {
	RUNNING,
	WON,
	LOST,
}

FACTOR: i32 = 30

slider_variable :: struct {
	name:  string,
	min:   f32,
	max:   f32,
	value: f32,
}
SLIDER_VARIBLES: map[string]slider_variable

Vector2 :: struct {
	x: i32,
	y: i32,
}

main :: proc() {

	rl.InitWindow(GAME_HEIGHT, GAME_WIDTH, "snake")

	g := Game{}

	g.score = 0

	g.state = GameState.RUNNING

	g.player = Player{}
	g.player.position = Vector2{15, 15}
	g.player.length = 3
    g.player.direction = {-1,0}

	rl.SetTargetFPS(FPS)


    every_second : f32 = 0.0

	frames: i32 = 0

	for !rl.WindowShouldClose() {

		rl.ClearBackground(rl.BLACK)
		frames += 1

        every_second += rl.GetFrameTime()


		player_old_pos := g.player.position
		// player movement
		if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
            g.player.direction = {-1,0}
		}
		if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
            g.player.direction = {1,0}
		}
		if rl.IsKeyDown(rl.KeyboardKey.W) || rl.IsKeyDown(rl.KeyboardKey.UP) {
            g.player.direction = {0,-1}
		}
		if rl.IsKeyDown(rl.KeyboardKey.S) || rl.IsKeyDown(rl.KeyboardKey.DOWN) {
            g.player.direction = {0,1}
		}

		rl.BeginDrawing()

		if g.state == GameState.RUNNING {

            // every second update player position in direciton
            if every_second >= 1 {
                every_second = 0.0
                g.player.position.x += g.player.direction.x
                g.player.position.y += g.player.direction.y
            }

			if player_old_pos != g.player.position {
				//append(g.player.positions, g.player.position)
			}
			// draw player
			rl.DrawRectangle(
				g.player.position.x * FACTOR,
				g.player.position.y * FACTOR,
				FACTOR,
				FACTOR,
				rl.YELLOW,
			)
		}
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
