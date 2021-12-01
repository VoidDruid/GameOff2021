extends Control

export(Color) var texture_color
export(Color) var good_color
export(Color) var bad_color

var faculty_uid
var game_manager: GameManager
var action_type = null


func _on_Button_pressed():
    if game_manager != null:
        game_manager.on_FcButton_pressed(faculty_uid, action_type)


var faculty_left_tab_color_path = "HBoxContainer/LeftTabColor"
var faculty_background = "HBoxContainer/Background"
var faculty_add_info_path = faculty_background + "/HBoxContainer/Control"
var faculty_label = faculty_background + "/HBoxContainer/Label"
var faculty_labels_placeholder = faculty_background + "/HBoxContainer/VBoxContainer"

func infer_action(faculty):
    pass

func setup_assign(faculty, TickButton):
    var tick = TickButton.instance()
    tick.name = "TickButton"
    var _rs = tick.connect("pressed", self, "_on_Button_pressed")
    get_node(faculty_background).add_child(tick)


func setup_for_faculty_map_tab(faculty, left_tab_color, EffectLabel, PlusButton, facultyChance, TickButton):
    get_node(faculty_left_tab_color_path).color = left_tab_color
    get_node(faculty_label).text = faculty.name + ", " + tr(faculty.specialty_uid)
    faculty_uid = faculty.uid

    if action_type == null:
        infer_action(faculty)
    match action_type:
        game_manager.FACULTY_ADD:
            setup_assign(faculty, TickButton)
