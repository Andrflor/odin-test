package main
import "core:fmt"
import "core:math"
import "vendor:raylib"
import rl "vendor:raylib/rlgl"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080
PLAYER_SPEED :: 0.1
GRID_SIZE: f32 : 10.0
GRID_DRAW_DISTANCE: f32 : 100.0


Player :: struct {
	position: raylib.Vector3,
	speed:    f32,
	rotation: f32,
	camera:   raylib.Camera3D,
}

init_player :: proc() -> Player {
	return Player {
		position = {0, 0, 0},
		speed = 0.1,
		rotation = 0,
		camera = {
			position = {-30, 30, 30},
			target = {60, 40, 450},
			up = {0, 1, 0},
			fovy = 45.0,
			projection = .PERSPECTIVE,
		},
	}
}

main :: proc() {
	raylib.SetConfigFlags({.FULLSCREEN_MODE, .MSAA_4X_HINT})
	raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "3D Mario Kart Clone")
	defer raylib.CloseWindow()
	raylib.SetTargetFPS(60)

	shader := raylib.LoadShader("assets/shaders/lightning.vert", "assets/shaders/lightning.frag")
	model := raylib.LoadModel("assets/scene.gltf")
	for i := 0; i < int(model.materialCount); i += 1 {
		model.materials[i].shader = shader
	}

	// Example light and camera positions
	light_position := raylib.Vector3{10.0, 10.0, 10.0}
	light_color := raylib.Vector3{1.0, 1.0, 1.0}
	raylib.DisableCursor()
	player := init_player()

	for !raylib.WindowShouldClose() {
		// Update MVP matrix (projection * view * model)
		projection := raylib.MatrixPerspective(
			45.0,
			f32(SCREEN_WIDTH) / f32(SCREEN_HEIGHT),
			0.1,
			100.0,
		)
		mouse_delta := raylib.GetMouseDelta()
		rotation_speed: f32 = 0.003

		if mouse_delta.x != 0 || mouse_delta.y != 0 {
			dir := player.camera.target - player.camera.position
			transform := raylib.MatrixRotateY(-mouse_delta.x * rotation_speed)
			dir = raylib.Vector3Transform(dir, transform)

			right := raylib.Vector3{dir.z, 0, -dir.x}
			right =
				right *
				(1.0 / math.sqrt(right.x * right.x + right.y * right.y + right.z * right.z))
			transform = raylib.MatrixRotate(right, mouse_delta.y * rotation_speed)
			dir = raylib.Vector3Transform(dir, transform)

			player.camera.target = player.camera.position + dir
		}

		// Calculate camera direction vectors
		forward := player.camera.target - player.camera.position

		// Right vector is perpendicular to forward in xz plane
		right := raylib.Vector3{forward.z, 0, -forward.x}

		// Movement based on camera direction
		movement := raylib.Vector3{0, 0, 0}


		if raylib.IsKeyDown(.W) {
			movement += forward
		}
		if raylib.IsKeyDown(.S) {
			movement -= forward
		}
		if raylib.IsKeyDown(.D) {
			movement -= right
		}
		if raylib.IsKeyDown(.A) {
			movement += right
		}

		if movement.x != 0 || movement.z != 0 {
			len := math.sqrt(movement.x * movement.x + movement.z * movement.z)
			movement = movement * (PLAYER_SPEED / len)

			player.camera.position = player.camera.position + movement
			player.camera.target = player.camera.target + movement
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.SKYBLUE)
		raylib.BeginMode3D(player.camera)
		raylib.DrawGrid(200, 10)

		raylib.DrawModel(model, player.position, 0.05, raylib.WHITE)
		raylib.EndMode3D()

		raylib.DrawFPS(10, 10)
		raylib.DrawText(
			raylib.TextFormat(
				"Camera Pos: %.2f, %.2f, %.2f",
				player.camera.position.x,
				player.camera.position.y,
				player.camera.position.z,
			),
			10,
			30,
			20,
			raylib.GREEN,
		)
		raylib.DrawText(
			raylib.TextFormat(
				"Target Pos: %.2f, %.2f, %.2f",
				player.camera.target.x,
				player.camera.target.y,
				player.camera.target.z,
			),
			10,
			50,
			20,
			raylib.GREEN,
		)

		raylib.EndDrawing()
	}
}
