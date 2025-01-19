package game
import rl "vendor:raylib"

import "core:fmt"
import "core:math/rand"
import "core:strconv"
import "core:strings"


MAX_FRAME_SPEED: i32 = 15
MIN_FRAME_SPEED: i32 = 1
sliderValue: f32 = 5.0


main :: proc() {

	screenWidth: i32 = 800
	screenHeight: i32 = 450

	rl.InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim -- ODIN")

	rl.SetTargetFPS(60)

	scarfy: rl.Texture2D = rl.LoadTexture("resources/scarfy.png")

	position: rl.Vector2 = {350.0, 280.0}

	frameRec: rl.Rectangle = {0.0, 0.0, f32(scarfy.width / 6), f32(scarfy.height)}
	currentFrame: i32 = 0

	framesCounter: i32 = 0
	framesSpeed: i32 = 8 // Number of spritesheet frames shown by second


	for !rl.WindowShouldClose() {

		framesCounter += 1

		if (framesCounter >= (60 / framesSpeed)) {
			framesCounter = 0
			currentFrame += 1

			if (currentFrame > 5) {
				currentFrame = 0
			}
			frameRec.x = f32(currentFrame * scarfy.width / 6)
		}


        sliderValueI32 : i32 = i32(sliderValue)

        if sliderValueI32 > MAX_FRAME_SPEED {
            sliderValueI32 = MAX_FRAME_SPEED
        }
        if sliderValueI32 < MIN_FRAME_SPEED {
            sliderValueI32 = MIN_FRAME_SPEED
        }

        framesSpeed = sliderValueI32

		rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawTexture(scarfy, 15, 40, rl.WHITE)
		rl.DrawRectangleLines(15, 40, scarfy.width, scarfy.height, rl.LIME)
		rl.DrawRectangleLines(
			15 + i32(frameRec.x),
			40 + i32(frameRec.y),
			i32(frameRec.width),
			i32(frameRec.height),
			rl.RED,
		)

		rl.DrawText("FRAME SPEED: ", 165, 210, 10, rl.DARKGRAY)
		rl.DrawText(rl.TextFormat("%02i FPS", framesSpeed), 575, 210, 10, rl.DARKGRAY)
		rl.DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, rl.DARKGRAY)

		for i: i32 = 0; i < MAX_FRAME_SPEED; i += 1 {
			if (i < framesSpeed) {
				rl.DrawRectangle(250 + 21 * i, 205, 20, 20, rl.RED)
			}
			rl.DrawRectangleLines(250 + 21 * i, 205, 20, 20, rl.MAROON)
		}

		rl.DrawTextureRec(scarfy, frameRec, position, rl.WHITE) // Draw part of the texture

		rl.DrawText(
			"(c) Scarfy sprite -- ODIN by Uwe Schmidt",
			screenWidth - 200,
			screenHeight - 20,
			10,
			rl.GRAY,
		)

		sliderValuePointer: ^f32 = &sliderValue

        sliderRec : rl.Rectangle = rl.Rectangle{0.0,f32(screenHeight - 20),f32(screenWidth),20.0} 
		rl.GuiSlider(
            sliderRec,
			"SOME SLIDER",
			"SOME SLIDER",
			sliderValuePointer,
			f32(0.0),
			15.0,
		)


		rl.EndDrawing()


	}

	rl.UnloadTexture(scarfy)

	rl.CloseWindow()


}
