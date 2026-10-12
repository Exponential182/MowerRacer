extends Resource
class_name MowerItem

enum MOWER_ITEM_TYPES {
	MOWER,
	PAINT,
	WRAP
}

@export var mower_item_type : MOWER_ITEM_TYPES
@export var mower_item_icon : Texture2D
