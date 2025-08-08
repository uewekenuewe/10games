package shader
import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import "core:strings"

main :: proc() {

	SCREEN_WIDTH: i32 = 1200
	SCREEN_HEIGHT: i32 = 1080
	rl.InitWindow(1200, 1080, "shader sidequest")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)


	// Create a render texture to draw the matrix effect on
	target := rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
	defer rl.UnloadRenderTexture(target)

	//shader := rl.LoadShader("", "basic.fs")
	shader := rl.LoadShader("", "shader_triangle.fs")
	defer rl.UnloadShader(shader)


	source_rec := rl.Rectangle{0, 0, f32(SCREEN_WIDTH), -f32(SCREEN_HEIGHT)}
	dest_rec := rl.Rectangle{0, 0, f32(SCREEN_WIDTH), f32(SCREEN_HEIGHT)}

    samples := []f32{4.0}
    quality := []f32{2.5}



	for !rl.WindowShouldClose() {
		//rgb(255,208,105)

		rl.ClearBackground(rl.BLUE)

        rl.SetShaderValue(shader, rl.GetShaderLocation(shader, "samples"), &samples[0], .FLOAT)

        rl.BeginTextureMode(target)


        rl.EndTextureMode()

		rl.BeginDrawing()
            rl.BeginShaderMode(shader)
            rl.DrawTexturePro(target.texture, source_rec, dest_rec, {0, 0}, 0, rl.WHITE)
            rl.EndShaderMode()
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
