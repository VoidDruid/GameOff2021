extends Control

export(Color) var good_color
export(Texture) var cross_texture

var faculty
var game_manager: GameManager
var grant_chance_button_path = "HBoxContainer/TextureRectRight/Right/GrantChance/Button"
var enrollee_count_path = "HBoxContainer/LeftTextureRect/Left/Slider/TextureRect/Control/SpinBox"

func _on_AddStaff_pressed():
    pass

func _on_GrantButton_pressed():
    #game_manager.on_GrButton_pressed(gr_id)
    pass
    
func _on_SpinBox_value_changed(value):
    game_manager.on_EnrolleeCount_changed(faculty.uid, value)

func _ready():
    var _rs = get_node(grant_chance_button_path).connect("pressed", self, "_on_GrantButton_pressed")
    get_node(enrollee_count_path).value = faculty.enrollee_count
