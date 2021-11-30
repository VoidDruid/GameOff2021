extends Control

export(Color) var good_color
export(Texture) var cross_texture

var faculty_uid
var game_manager: GameManager
var grant_chance_button_path = "HBoxContainer/TextureRectRight/Right/GrantChance/Button"

func _on_AddStaff_pressed():
    pass

func _on_GrantButton_pressed():
    #game_manager.on_GrButton_pressed(gr_id)
    pass

func _ready():
    var _rs = get_node(grant_chance_button_path).connect("pressed", self, "_on_GrantButton_pressed")
