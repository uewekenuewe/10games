package custom_mesh_test

import "core:fmt"
import "core:math"
import la "core:math/linalg"
import "core:mem"
import rl "vendor:raylib"

generate_custom_mesh :: proc() -> rl.Mesh {
	m := rl.Mesh{}

	m.triangleCount = 1
	m.vertexCount = 3
	m.vertices = mp_allocate(f32, m.vertexCount * 3) // x,y,z
	m.texcoords = mp_allocate(f32, m.vertexCount * 2) // u,v
	m.normals = mp_allocate(f32, m.vertexCount * 3) // x,y,z
	m.colors = mp_allocate(u8, m.vertexCount * 4) // x,y,z
	// (0,0,0)
	m.vertices[0] = 0
	m.vertices[1] = 0
	m.vertices[2] = 0

	m.normals[0] = 0
	m.normals[1] = 1
	m.normals[2] = 0

	m.texcoords[0] = 0
	m.texcoords[1] = 0

	m.colors[1] = 255
	m.colors[3] = 255

	// (1,0,2)
	m.vertices[3] = 1
	m.vertices[4] = 0
	m.vertices[5] = 0

	m.normals[3] = 0
	m.normals[4] = 1
	m.normals[5] = 0

	m.texcoords[0] = .5
	m.texcoords[1] = .5

	m.colors[4] = 255
	m.colors[7] = 255

	// (2,0,0)
	m.vertices[6] = 2
	m.vertices[7] = 0
	m.vertices[8] = 0

	m.normals[6] = 0
	m.normals[7] = 1
	m.normals[8] = 0

	m.texcoords[0] = 1
	m.texcoords[1] = 1

	m.colors[10] = 255
	m.colors[11] = 255

	rl.UploadMesh(&m, false) // sends to gpu

	return m // really just need where gpu stuck it, but load-model consumes the mesh
}

mp_allocate :: proc($T: typeid, #any_int length: int) -> [^]T {
	buf, err := mem.alloc(size_of(i32) * length)
	assert(err == mem.Allocator_Error.None)
	return cast([^]T)buf
}

main :: proc() {
	rl.InitWindow(1000, 600, "TEST_LOAD_MESH")
	rl.SetTargetFPS(60)

	shader := rl.LoadShader("./vertex_shader.vs", "./fragment_shader.fs")
	// shader.locs[rl.ShaderLocationIndex.MATRIX_MVP] = rl.GetShaderLocation(shader, "mvp")

	// checked := rl.GenImageChecked(2, 2, 1, 1, rl.DARKGREEN, rl.GREEN)
	// texture := rl.LoadTextureFromImage(checked)
	// rl.UnloadImage(checked)

	model := rl.LoadModelFromMesh(generate_custom_mesh())
	// model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = texture
	model.materials[0].shader = shader

	camera := rl.Camera{{5, 5, 0}, {0, 0, 0}, {0, 1, 0}, 45, rl.CameraProjection.PERSPECTIVE}
	position := rl.Vector3{0, 0, 0}

	for !rl.WindowShouldClose() {
		// mvp := rl.GetCameraMatrix(camera)
		// rl.SetShaderValueMatrix(shader, rl.ShaderLocationIndex.MATRIX_MVP, mvp)

		// when adjusting mesh buffer data after upload use: UpdateMeshBuffer
		rl.BeginDrawing()
		{
			rl.ClearBackground(rl.WHITE)
			rl.BeginMode3D(camera)
			{
				rl.DrawModel(model, {0, 0, 0}, 1, rl.WHITE)
			}
			rl.EndMode3D()
			rl.DrawFPS(10, 10)
		}
		rl.EndDrawing()
	}
	rl.UnloadModel(model)
	rl.CloseWindow()
}
