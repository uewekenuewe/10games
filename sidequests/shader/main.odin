package custom_mesh_test

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"


SHADERS: [dynamic]rl.Shader

CURRENT_INDEX := 0

load_shaders :: proc(basedir: string) -> [dynamic]rl.Shader {
	result := [dynamic]rl.Shader{}

	// Open the directory
	dir, err := os.open(basedir)
	if err != nil {
		fmt.eprintln("Error opening directory:", err)
		return result
	}
	defer os.close(dir)

	entries, read_err := os.read_dir(dir, 0)
	if read_err != nil {
		fmt.eprintln("Error reading directory:", read_err)
		return result
	}
	defer delete(entries)

	for entry in entries {
		append(&result, rl.LoadShader("", strings.unsafe_string_to_cstring(entry.fullpath)))
	}


	return result
}

main :: proc() {
	rl.InitWindow(800, 600, "TEST_LOAD_MESH")
	rl.SetTargetFPS(60)

	dir_path := "C:\\projekte\\10games\\sidequests\\shader\\shaders"
	SHADERS := load_shaders(dir_path)

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		{
			rl.BeginShaderMode(SHADERS[CURRENT_INDEX])
			rl.DrawRectangleV(rl.Vector2{0.0, 0.0}, rl.Vector2{1000.0, 600.0}, rl.RED)
			rl.EndShaderMode()
		}

		rl.EndDrawing()

		if (rl.IsKeyPressed(rl.KeyboardKey.N)) {
			CURRENT_INDEX += 1
			CURRENT_INDEX %= len(SHADERS)
		}


	}
	rl.CloseWindow()
}
