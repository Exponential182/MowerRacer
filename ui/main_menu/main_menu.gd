extends Control
class_name MainMenu

static var selected_player_index : int = -1

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
@onready var _lawnmower: Sprite2D = $_lawnmower

var selected_ui : Control
var time := 0.0

var last_menu_node : Control
var current_menu_node : Control

const UI_SELECTOR = preload("uid://b6oln34h7k8ge")
const ITEM_FOCUS = preload("uid://dvx18trujl3k6")

var current_menu : MENUS
enum MENUS {
	TITLE,
	MOWER,
	COURSE
}
func change_menu(_new_menu: MENUS):
	SfxManager.playfile(SfxManager.CAROSUEL)
	SfxManager.playfile(SfxManager.TRANSITION)
	
	if current_menu_node:
		last_menu_node = current_menu_node
		last_menu_node.focus_mode = Control.FOCUS_NONE
		
	current_menu = _new_menu
	selected_player_index = -1
	
	for n in [_start,_options,_quit]: n.focus_mode = Control.FOCUS_NONE
	
	match current_menu:
		MENUS.TITLE: 
			current_menu_node = _title_screen
			_lawnmower.show()
			
			for n in [_start,_options,_quit]: n.focus_mode = Control.FOCUS_ALL
		MENUS.MOWER: 
			selected_player_index = 0
			current_menu_node = _mower_select_screen
			_mower_customise_0.focus()
			_lawnmower.hide()
			
		MENUS.COURSE: 
			current_menu_node = _course_select_screen
			_lawnmower.hide()

	for m in [_title_screen,_mower_select_screen,_course_select_screen]: 
		m.position.x = 480
		m.hide()
		
	if last_menu_node:
		last_menu_node.show()
		current_menu_node.show()

		last_menu_node.position = Vector2.ONE
		
		var l := create_tween()
		l.tween_property(last_menu_node,"position:x",-480,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		var c := create_tween()
		c.tween_property(current_menu_node,"position:x",0,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
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
		
		var parent_root_offset := Vector2.ZERO
		match current_menu:
			MENUS.TITLE: parent_root_offset= _title_screen.position
			MENUS.MOWER: parent_root_offset= _mower_select_screen.position
			MENUS.COURSE: parent_root_offset= _course_select_screen.position
		
		var tar_pos
		var margin 
		
		if selected_ui is ItemCarousel:
			_ui_selector.texture = ITEM_FOCUS
			tar_pos = ((selected_ui.global_position-parent_root_offset) + selected_ui.size/2) - Vector2(16,16)
			margin = Vector2i.ZERO
		
		else:
			selected_ui.pivot_offset = selected_ui.size/2
			var t2 := create_tween()
			t2.tween_property(selected_ui,"scale",Vector2(1.25,1.25),0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				
			_ui_selector.texture = UI_SELECTOR
			tar_pos = (selected_ui.global_position - Vector2(_ui_selector.size.x, _ui_selector.size.y/2)) + Vector2(0,selected_ui.size.y/2)
			margin = Vector2i(-15,0)
			
		var t := create_tween()
		t.tween_property(_ui_selector,"position",Vector2(Vector2i(tar_pos) + margin),0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if selected_ui:
		if !(selected_ui is ItemCarousel):
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
						SfxManager.playfile(SfxManager.CAROSUEL)
						selected_player_index = 1
						_mower_customise_0.unfocus()
						_mower_customise_1.focus()
			
				else:
					change_menu(MENUS.COURSE)
					
func reset_focus():
	print("[MAIN MENU] Resetting Focus")
	match current_menu:
		MENUS.TITLE: _start.grab_focus()
		MENUS.MOWER: _mower_customise_0.focus()
		MENUS.COURSE: _course_select_default_focus.grab_focus()
	
