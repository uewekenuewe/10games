package custom_mesh_test

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"

SHADERS: [dynamic]rl.Shader
SHADER_NAMES: [dynamic]string

CURRENT_INDEX := 0

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
		fmt.println(entry.name)
		append(&result_names, entry.name)
		append(&result_shader, rl.LoadShader("", strings.unsafe_string_to_cstring(entry.fullpath)))
	}


	return result_shader, result_names
}

main :: proc() {
	rl.InitWindow(800, 600, "TEST_LOAD_MESH")
	rl.SetTargetFPS(60)

	dir_path := "C:\\projekte\\10games\\sidequests\\shader\\shaders"

	SHADERS, SHADER_NAMES := load_shaders(dir_path)

	rl.SetWindowTitle(strings.unsafe_string_to_cstring(SHADER_NAMES[CURRENT_INDEX]))

	// Get uniform location
	time_loc := rl.GetShaderLocation(SHADERS[CURRENT_INDEX], "time")


	for !rl.WindowShouldClose() {

		time := f32(rl.GetTime())
		time_array := [1]f32{time}
		rl.SetShaderValueV(
			SHADERS[CURRENT_INDEX],
			time_loc,
			&time_array[0],
			rl.ShaderUniformDataType.FLOAT,
			1,
		)
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
			rl.SetWindowTitle(strings.unsafe_string_to_cstring(SHADER_NAMES[CURRENT_INDEX]))

			time_loc = rl.GetShaderLocation(SHADERS[CURRENT_INDEX], "time")
		}


	}
	rl.CloseWindow()
}
