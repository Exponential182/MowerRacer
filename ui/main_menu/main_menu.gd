extends Control

@onready var _ui_selector: TextureRect = $_ui_selector
@onready var _start: TextureButton = %_start
@onready var _options: TextureButton = %_options
@onready var _quit: TextureButton = %_quit

@onready var _mower_customise_0: PanelContainer = %_mower_customise_0
@onready var _mower_customise_1: PanelContainer = %_mower_customise_1

@onready var _title_screen: Control = %_title_screen
@onready var _mower_select_screen: Control = %_mower_select_screen
@onready var _course_select_screen: Control = %_course_select_screen
@onready var _course_select_default_focus: TextureRect = %_course_select_default_focus

var selected_ui : Control
var selected_player : int = 0
var time := 0.0

var last_menu_node : Control
var current_menu_node : Control

var current_menu : MENUS
enum MENUS {
	TITLE,
	MOWER,
	COURSE
}
func change_menu(_new_menu: MENUS):
	if current_menu_node:
		last_menu_node = current_menu_node
		last_menu_node.focus_mode = Control.FOCUS_NONE
		
	current_menu = _new_menu
	
	match current_menu:
		MENUS.TITLE: current_menu_node = _title_screen
		MENUS.MOWER: 
			current_menu_node = _mower_select_screen
			
			_mower_customise_0.focus()
			
		MENUS.COURSE: current_menu_node = _course_select_screen

	for m in [_title_screen,_mower_select_screen,_course_select_screen]: 
		m.position.x = 480
		m.hide()
		
	if last_menu_node:
		last_menu_node.show()
		current_menu_node.show()

		last_menu_node.position = Vector2.ONE
		
		var l := create_tween()
		l.tween_property(last_menu_node,"position:x",-480,2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		var c := create_tween()
		c.tween_property(current_menu_node,"position:x",0,2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		await get_tree().create_timer(2.0).timeout
		
		last_menu_node.hide()
	else:
		current_menu_node.show()
		current_menu_node.position.x = 0.0
		
func _ready() -> void:
	change_menu(MENUS.TITLE)
	
	_mower_customise_0.active = true
	_start.grab_focus()
	
	_start.pressed.connect(func():
		change_menu(MENUS.MOWER)
		)


func _process(delta: float) -> void:
	time += delta
		
	var update_selected : bool = false
	if selected_ui != get_viewport().gui_get_focus_owner():
		update_selected = true
		
		if selected_ui:
			selected_ui.modulate = Color.WHITE
			
			var t := create_tween()
			t.tween_property(selected_ui,"scale",Vector2.ONE,0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		
	selected_ui = get_viewport().gui_get_focus_owner()
		
	if selected_ui and update_selected:
		SfxManager.playfile(SfxManager.BLIP)
		
		selected_ui.pivot_offset = selected_ui.size/2
			
		var t2 := create_tween()
		t2.tween_property(selected_ui,"scale",Vector2(1.25,1.25),0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		var tar_pos = (selected_ui.global_position - Vector2(_ui_selector.size.x, _ui_selector.size.y/2)) + Vector2(0,selected_ui.size.y/2)
		var margin = Vector2i(-15,0)
		
		var t := create_tween()
		t.tween_property(_ui_selector,"position",Vector2(Vector2i(tar_pos) + margin),0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if selected_ui:
		var mod = (((sin(time * 10)+1)/2))
		selected_ui.modulate = lerp(Color.WHITE,Color(1.0, 1.0, 0.67, 1.0),mod)
	else:
		reset_focus()
		
	match current_menu:
		MENUS.TITLE:
			if Input.is_action_just_pressed("confirm_customisation"):
				if _start == selected_ui:
					change_menu(MENUS.MOWER)
		
		MENUS.MOWER:
			if Input.is_action_just_pressed("confirm_customisation"):
				if _mower_customise_0.active:
						_mower_customise_1.active = true
						_mower_customise_1.focus()
						_mower_customise_0.active = false
				else:
					change_menu(MENUS.COURSE)

func reset_focus():
	print("[MAIN MENU] Resetting Focus")
	match current_menu:
		MENUS.TITLE: _start.grab_focus()
		MENUS.MOWER: _mower_customise_0.focus()
		MENUS.COURSE: _course_select_default_focus.grab_focus()
	
