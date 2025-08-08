package shader
import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"

main :: proc() {

	SCREEN_WIDTH: f32 = 800
	SCREEN_HEIGHT: f32 = 600
	rl.InitWindow(i32(SCREEN_WIDTH), i32(SCREEN_HEIGHT), "shader_basicsidequest")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	shader_basic := rl.LoadShader("", "basic.fs")
	defer rl.UnloadShader(shader_basic)

    texture := rl.LoadRenderTexture(i32(SCREEN_WIDTH),i32(SCREEN_HEIGHT))
    recrec := rl.Rectangle{100.0,100.0,SCREEN_WIDTH/2,SCREEN_HEIGHT/2}

	for !rl.WindowShouldClose() {
		//rgb(255,208,105)

		rl.ClearBackground(rl.BLUE)

		rl.BeginShaderMode(shader_basic)
            rl.DrawRectangleRec(recrec,rl.RED)
		rl.EndShaderMode()


		rl.EndDrawing()
	}
	rl.CloseWindow()
}
