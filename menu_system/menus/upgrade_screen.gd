extends Menu
class_name UpgradeScreen

signal upgrades_confirmed

const ZOOM_MIN: float = 0.3
const ZOOM_MAX: float = 2.5
const ZOOM_STEP: float = 0.12

@onready var tree_container: Control = $TreeContainer
@onready var tree_canvas: Control = $TreeContainer/TreeCanvas
@onready var bits_label: Label = $BitsLabel
@onready var continue_button: Button = $ContinueButton
@onready var tooltip: PanelContainer = $Tooltip
@onready var tooltip_name: Label = $Tooltip/MarginContainer/VBox/UpgradeName
@onready var tooltip_cost: Label = $Tooltip/MarginContainer/VBox/Cost
@onready var tooltip_description: Label = $Tooltip/MarginContainer/VBox/Description
@onready var tooltip_fluff: Label = $Tooltip/MarginContainer/VBox/FluffText

var _upgrade_data: Array[UpgradeData] = []
var _upgrade_nodes: Dictionary[String, UpgradeNode] = {}
var _connection_lines: Array[Line2D] = []

var _is_panning: bool = false
var _pan_start_mouse: Vector2 = Vector2.ZERO
var _pan_start_canvas: Vector2 = Vector2.ZERO


func _ready() -> void:
	_upgrade_data = UpgradeDatabase.get_all_upgrades()
	_build_tree()
	tooltip.hide()
	continue_button.pressed.connect(_on_continue_pressed)


func show_menu() -> void:
	super.show_menu()
	Engine.time_scale = 1.0
	if Level.instance:
		Level.instance.process_mode = Node.PROCESS_MODE_DISABLED
	_refresh_all()


func hide_menu() -> void:
	super.hide_menu()
	if Level.instance:
		Level.instance.process_mode = Node.PROCESS_MODE_INHERIT
		var player := Level.instance.get_tree().get_first_node_in_group("player") as Player
		if player:
			player.heal_to_full(1.0)


func _build_tree() -> void:
	# Lines first so they render behind nodes
	for data in _upgrade_data:
		for parent_id in data.parent_ids:
			var line := Line2D.new()
			line.width = 2.0
			line.default_color = Color(0.3, 0.35, 0.45, 0.5)
			tree_canvas.add_child(line)
			_connection_lines.append(line)

	# Nodes on top
	for data in _upgrade_data:
		var node: UpgradeNode = Prefabs.upgrade_node.instantiate()
		tree_canvas.add_child(node)
		node.position = data.tree_position - Vector2(UpgradeNode.RADIUS, UpgradeNode.RADIUS)
		node.setup(data)
		node.hovered.connect(_on_node_hovered)
		node.unhovered.connect(_on_node_unhovered)
		node.purchase_requested.connect(_on_purchase_requested)
		_upgrade_nodes[data.id] = node

	_update_line_positions()


func _refresh_all() -> void:
	bits_label.text = "Bits: %d" % UpgradeManager.instance.bits
	for node in _upgrade_nodes.values():
		node.refresh()
	_update_line_colors()


func _update_line_positions() -> void:
	var line_index := 0
	for data in _upgrade_data:
		for parent_id in data.parent_ids:
			if line_index >= _connection_lines.size():
				break
			if _upgrade_nodes.has(parent_id) and _upgrade_nodes.has(data.id):
				var parent_center := _upgrade_nodes[parent_id].position + Vector2(UpgradeNode.RADIUS, UpgradeNode.RADIUS)
				var child_center := _upgrade_nodes[data.id].position + Vector2(UpgradeNode.RADIUS, UpgradeNode.RADIUS)
				_connection_lines[line_index].points = PackedVector2Array([parent_center, child_center])
			line_index += 1


func _update_line_colors() -> void:
	var line_index := 0
	for data in _upgrade_data:
		for parent_id in data.parent_ids:
			if line_index >= _connection_lines.size():
				break
			var parent_purchased := UpgradeManager.instance.is_purchased(parent_id)
			var child_purchased := UpgradeManager.instance.is_purchased(data.id)
			if parent_purchased and child_purchased:
				_connection_lines[line_index].default_color = Color(1.0, 0.82, 0.18, 0.9)
			elif parent_purchased:
				_connection_lines[line_index].default_color = Color(0.35, 0.60, 1.0, 0.55)
			else:
				_connection_lines[line_index].default_color = Color(0.22, 0.22, 0.27, 0.4)
			line_index += 1


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_RIGHT:
				_is_panning = event.pressed
				if event.pressed:
					_pan_start_mouse = event.global_position
					_pan_start_canvas = tree_canvas.position
				accept_event()
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_at(event.global_position, 1.0 + ZOOM_STEP)
				accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at(event.global_position, 1.0 - ZOOM_STEP)
				accept_event()
	elif event is InputEventMouseMotion and _is_panning:
		tree_canvas.position = _pan_start_canvas + (event.global_position - _pan_start_mouse)
		accept_event()


func _zoom_at(screen_pos: Vector2, factor: float) -> void:
	var new_zoom: float = clamp(tree_canvas.scale.x * factor, ZOOM_MIN, ZOOM_MAX)
	var actual_factor: float = new_zoom / tree_canvas.scale.x
	var local_pos: Vector2 = screen_pos - tree_canvas.global_position
	tree_canvas.position += local_pos * (1.0 - actual_factor)
	tree_canvas.scale = Vector2(new_zoom, new_zoom)


func _on_node_hovered(data: UpgradeData, screen_pos: Vector2) -> void:
	tooltip_name.text = data.display_name
	tooltip_cost.text = "%d bits" % data.cost
	tooltip_description.text = data.description
	tooltip_fluff.text = data.fluff_text
	tooltip.show()
	var vp := get_viewport_rect().size
	var tip_pos := screen_pos + Vector2(28.0, -8.0)
	tip_pos.x = clamp(tip_pos.x, 4.0, vp.x - tooltip.size.x - 4.0)
	tip_pos.y = clamp(tip_pos.y, 4.0, vp.y - tooltip.size.y - 4.0)
	tooltip.global_position = tip_pos


func _on_node_unhovered() -> void:
	tooltip.hide()


func _on_purchase_requested(data: UpgradeData) -> void:
	if UpgradeManager.instance.purchase(data):
		_refresh_all()


func _on_continue_pressed() -> void:
	hide_menu()
	upgrades_confirmed.emit()
