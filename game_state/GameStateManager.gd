extends Node

## Global Class used for managing and referancing game states
## acts as the superiority and should be written to very carefully
## referance the game state when running code relevant to differant
## parts of the game

signal game_state_changed(_new_state : GAME_STATES)

@export var players : Array[PlayerData]

const PLAYER_COUNT : int = 2


enum GAME_STATES {
	MAIN_MENU, ## Main Menu
	RACING, ## Racing
	PAUSE, ## Paused while mid-race
	POST, ## Post-Race statistics
}

var last_game_state : GAME_STATES
var current_game_state : GAME_STATES

func _ready() -> void:
	## Currently hardcoded for 2 players, I made this modular
	## so theoretically you could have as many as you want ( negating hardware logistics )
	
	for i in range(PLAYER_COUNT):
		var p := PlayerData.new()
		p.player_name = "Player" + str(i)
		players.append(p)
		
	change_game_state(GAME_STATES.MAIN_MENU)

func change_game_state(_new_state : GAME_STATES) -> void: ## Use very carefully
	last_game_state = current_game_state
	current_game_state = _new_state
	
	match current_game_state:
		GAME_STATES.MAIN_MENU: pass
		GAME_STATES.RACING: pass
		GAME_STATES.PAUSE: pass
		GAME_STATES.POST: pass
	
	game_state_changed.emit(current_game_state)
