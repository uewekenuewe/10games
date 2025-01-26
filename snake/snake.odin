package game
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
	food:   Vector2,
}

GameState :: enum {
	RUNNING,
	WON,
	LOST,
}


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

update :: proc(g: ^Game) {
	//g := g

	if g.state == GameState.WON {
	}
	if g.state == GameState.LOST {
	}
	if g.state == GameState.RUNNING {

		//check if player out of bounce
		if 0 <= g.player.position.x < GAME_HEIGHT_SCALE {
			if g.player.position.x < 0 {
				g.player.position.x = GAME_HEIGHT_SCALE
			} else if g.player.position.x > GAME_HEIGHT_SCALE {
				g.player.position.x = 0
			}
		}
		if 0 <= g.player.position.y < GAME_WIDTH_SCALE {
			if g.player.position.y < 0 {
				g.player.position.y = GAME_WIDTH_SCALE
			} else if g.player.position.y > GAME_WIDTH_SCALE {
				g.player.position.y = 0
			}
		}

		if g.player.position == g.food {
			g.food.x = rl.GetRandomValue(0, GAME_WIDTH_SCALE - 5)
			g.food.y = rl.GetRandomValue(0, GAME_HEIGHT_SCALE - 5)
			append(&g.player.positions, g.player.position)
			g.player.length += 1
		}
	}
}

draw :: proc(g: Game) {
	if g.state == GameState.WON {
	}
	if g.state == GameState.LOST {
	}
	if g.state == GameState.RUNNING {
	}
}

initGame :: proc() -> Game {
	game := Game{}
	game.score = 0
	game.state = GameState.RUNNING

	// create player
	player := Player{}
	player.position = Vector2{15, 15}
	player.length = 5
	player.direction = {1, 0}
	append(&player.positions, Vector2{14, 15})
	append(&player.positions, Vector2{13, 15})
	append(&player.positions, Vector2{12, 15})
	append(&player.positions, Vector2{11, 15})

	game.player = player

	// add food to game
	food: Vector2
	food.x = rl.GetRandomValue(0, GAME_WIDTH_SCALE)
	food.y = rl.GetRandomValue(0, GAME_HEIGHT_SCALE)
	game.food = food

	return game
}

main :: proc() {

	rl.InitWindow(GAME_HEIGHT, GAME_WIDTH, "snake")


	g := initGame()


	rl.SetTargetFPS(FPS)

	every_second: f32 = 0.0

	frames: i32 = 0


	for !rl.WindowShouldClose() {

		rl.ClearBackground(rl.BLACK)
		frames += 1

		every_second += rl.GetFrameTime()

		// PLAYER INPUTS
		// player movement
		if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
			if g.player.direction != {1, 0} {
				g.player.direction = {-1, 0}
			}
		}
		if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
			if g.player.direction != {-1, 0} {
				g.player.direction = {1, 0}
			}
		}
		if rl.IsKeyDown(rl.KeyboardKey.W) || rl.IsKeyDown(rl.KeyboardKey.UP) {
			if g.player.direction != {0, 1} {
				g.player.direction = {0, -1}
			}
		}
		if rl.IsKeyDown(rl.KeyboardKey.S) || rl.IsKeyDown(rl.KeyboardKey.DOWN) {
			if g.player.direction != {0, -1} {
				g.player.direction = {0, 1}
			}
		}

		update(&g)

		rl.BeginDrawing()

        draw(&g)

		if g.state == GameState.RUNNING {

			// every second update player position in direciton
			if every_second >= 0.05 { 	//GAMESPEED?
				every_second = 0.0
				old_position := g.player.position
				new_position := g.player.position
				g.player.position.x += g.player.direction.x
				g.player.position.y += g.player.direction.y

				for i := 0; i < len(g.player.positions); i += 1 {
					old_position = g.player.positions[i]
					g.player.positions[i] = new_position
					if g.player.positions[i] == g.player.position {
						g.state = GameState.LOST
					}
					new_position = old_position
				}
			}

			// draw player
			rl.DrawRectangle(
				g.player.position.x * FACTOR,
				g.player.position.y * FACTOR,
				FACTOR,
				FACTOR,
				rl.YELLOW,
			)

			for pos in g.player.positions {
				rl.DrawRectangle(pos.x * FACTOR, pos.y * FACTOR, FACTOR, FACTOR, rl.YELLOW)
			}

			// draw food
			rl.DrawRectangle(g.food.x * FACTOR, g.food.y * FACTOR, FACTOR, FACTOR, rl.GREEN)
		}

		if g.state == GameState.LOST {
			rl.ClearBackground(rl.RAYWHITE)
			rl.DrawText("YOU LOST", 10, 10, 30, rl.RED)
			rl.DrawText("Press R to Restart", 10, 50, 30, rl.RED)
			if rl.IsKeyDown(rl.KeyboardKey.R) {
				g = initGame()
			}
		}
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
