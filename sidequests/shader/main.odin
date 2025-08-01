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


	// Get uniform location
	time_loc := rl.GetShaderLocation(SHADERS[CURRENT_INDEX], "time")


	for !rl.WindowShouldClose() {

		//       SetShaderValueV         :: proc(shader: Shader, #any_int locIndex: c.int, value: rawptr, uniformType: ShaderUniformDataType, count: c.int) --- // Set shader uniform value vector 
		//rl.SetShaderValueV(SHADERS[CURRENT_INDEX], 0, &time, rl.ShaderUniformDataType.FLOAT)
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
			time_loc = rl.GetShaderLocation(SHADERS[CURRENT_INDEX], "time")
		}


	}
	rl.CloseWindow()
}
