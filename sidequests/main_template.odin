package sidequest
import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:strconv"
import "core:strings"


ODIN_DEBUG := true
GAME_HEIGHT: i32 = 800
GAME_WIDTH: i32 = 600
FPS: i32 = 60


main :: proc() {

	rl.InitWindow(GAME_HEIGHT, GAME_WIDTH, "sidequest")

	rl.SetTargetFPS(FPS)

	for !rl.WindowShouldClose() {

		rl.ClearBackground(rl.BLACK)

		rl.BeginDrawing()


		rl.EndDrawing()
	}
	rl.CloseWindow()
}
