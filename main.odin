package main

import "core:fmt"
import "vendor:raylib"

Widget :: struct {
	render:       proc(self: ^Widget),
	handle_event: proc(self: ^Widget),
}

Button :: struct {
	base:     Widget,
	label:    cstring,
	on_click: proc(),
}

Container :: struct {
	base:     Widget,
	children: []^Widget,
}

render_button :: proc(widget: ^Widget) {
	btn: ^Button = cast(^Button)widget
	rect := raylib.Rectangle{0, 0, 10, 10}

	if raylib.CheckCollisionPointRec(raylib.GetMousePosition(), rect) {
		btn.on_click()
	} else {
		raylib.DrawRectangle(0, 0, 100, 100, raylib.GRAY)
	}

	raylib.DrawText(btn.label, 0 + 10, 0 + 10, 20, raylib.WHITE)
}

handle_button_event :: proc(widget: ^Widget) {
	// Input handling is inside `render_button`
}

render_container :: proc(widget: ^Widget) {
	container: ^Container = cast(^Container)widget
	for child in container.children {
		child.render(child)
	}
}

new_button :: proc(x, y, width, height: int, label: cstring, on_click: proc()) -> Button {
	return Button {
		base = Widget{render = render_button, handle_event = handle_button_event},
		label = label,
		on_click = on_click,
	}
}

new_container :: proc(x, y, width, height: int, children: []^Widget) -> Container {
	return Container{base = Widget{render = render_container}, children = children}
}

main :: proc() {
	raylib.InitWindow(800, 600, "Odin UI System")
	defer raylib.CloseWindow()

	raylib.SetTargetFPS(60)

	btn := new_button(300, 250, 200, 50, "Click Me", proc() {
		fmt.printf("Button Clicked!\n")
	})

	container := new_container(0, 0, 800, 600, []^Widget{&btn.base})

	for !raylib.WindowShouldClose() {
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		container.base.render(&container.base)

		raylib.EndDrawing()
	}
}
