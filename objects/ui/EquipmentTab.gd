extends Control

export(Color) var good_color
export(Color) var bad_color
export(Color) var hired_panel_color
export(Color) var available_panel_color
export(Texture) var plus_texture
export(Texture) var cross_texture

var character
var EffectLabel
var is_hired
var game_manager: GameManager


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
