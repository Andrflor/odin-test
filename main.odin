package main
import "core:fmt"
import "core:math"
import "vendor:raylib"
import rl "vendor:raylib/rlgl"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080
GAME_TITLE: string : "3D Mario Kart Clone"

Player :: struct {
	position: raylib.Vector3,
	speed:    f32,
	rotation: f32,
	camera:   raylib.Camera3D,
}

init_player :: proc() -> Player {
	return Player{speed = 0.1, position = {0, 0, 0}, rotation = 0}
}

get_camera :: proc() -> raylib.Camera3D {
	return raylib.Camera3D {
		position = {player.position.x, player.position.y + 8, player.position.z + 8},
		target = {player.position.x, player.position.y + 4, player.position.z},
		up = {0, 1, 0},
		fovy = 45.0,
		projection = .PERSPECTIVE,
	}
}

Karts :: enum {
	kart1,
	kart2,
}

Tracks :: enum {
	track1,
	track2,
}

init_game :: proc() {
	raylib.SetConfigFlags({.FULLSCREEN_MODE, .MSAA_4X_HINT})
	raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, fmt.ctprint(GAME_TITLE))
	raylib.SetTargetFPS(60)
	raylib.DisableCursor()
}

init_stage :: proc() {
	player = init_player()
	kart = load_kart(Karts.kart1)
	track = load_track(Tracks.track1)
}

kart: raylib.Model
track: raylib.Model
player: Player


load_track :: proc(track: Tracks) -> raylib.Model {
	return raylib.LoadModel(fmt.ctprintf("assets/models/tracks/%s/scene.gltf", track))
}

load_kart :: proc(kart: Karts) -> raylib.Model {
	kart := raylib.LoadModel(fmt.ctprintf("assets/models/karts/%s/scene.gltf", kart))
	kart.transform = raylib.MatrixRotateXYZ({0, raylib.PI, 0})
	return kart
}

main :: proc() {
	init_game()
	init_stage()

	for !raylib.WindowShouldClose() {
		input_loop()
		draw_loop()
	}
	raylib.CloseWindow()
}

input_loop :: proc() {}

draw_3D :: proc() {
	// raylib.DrawModel(track, {0, 0, 0}, 0.05, raylib.WHITE)
	raylib.DrawModel(kart, player.position, 1, raylib.WHITE)
}

draw_loop :: proc() {
	raylib.BeginDrawing()
	raylib.ClearBackground(raylib.SKYBLUE)
	raylib.BeginMode3D(get_camera())
	draw_3D()
	raylib.EndMode3D()

	display_debug()
	raylib.EndDrawing()
}

display_debug :: proc() {
	using camera := get_camera()
	raylib.DrawFPS(10, 10)
	raylib.DrawText(
		raylib.TextFormat("Camera Pos: %.2f, %.2f, %.2f", position.x, position.y, position.z),
		10,
		30,
		20,
		raylib.GREEN,
	)
	raylib.DrawText(
		raylib.TextFormat("Target Pos: %.2f, %.2f, %.2f", target.x, target.y, target.z),
		10,
		50,
		20,
		raylib.GREEN,
	)
}
