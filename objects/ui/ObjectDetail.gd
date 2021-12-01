extends Panel

var object_type
var grant
var character
var goal
var game_over
var is_changable = true
var darkinator
var game_manager
var parent_uid

onready var icon_rect = $Margins/Control/TextureRect
onready var name_label = $Margins/Control/Layout/InfoBox/NameL
onready var description_label = $Margins/Control/Layout/InfoBox/DescriptionL
onready var detail_label = $Margins/Control/Layout/InfoBox/BottomRowHB/DetailL
onready var change_button = $Margins/Control/Layout/InfoBox/BottomRowHB/Control/HBoxContainer/TextureButton
onready var close_button = $CloseButton


func generic_setup(obj):
    var suffix
    match object_type:
        0:
            var years_text = ""
            if grant.is_taken:
                years_text += tr("YEARS_LEFT") + " "
            else:
                years_text += tr("YEARS_GIVEN") + " "
            years_text += str(grant.years_left) + " "
            if grant.years_left == 1:
                years_text += tr("YEAR")
            elif grant.years_left < 5:
                years_text += tr("YEARS_L5")
            else:
                years_text += tr("YEARS_GE5")
            suffix = tr(obj.specialty_uid) + ". " + years_text
        1:
            suffix = tr(obj.title)
            if obj.icon_uid != null:
                var icon_res = utils.load_icon(obj.icon_uid)
                if icon_res != null:
                    icon_rect.texture = icon_res
                    icon_rect.rect_size.x = 256
                    icon_rect.rect_size.y = 256
        2:
            suffix = null
        3:
            suffix = null
            
    if suffix != null:
        name_label.text = tr(obj.name) + ", " + suffix
    else:
        name_label.text = obj.name
    if "specialty_uid" in obj:
        name_label.hint_tooltip = tr(obj.specialty_uid)
    description_label.text = utils.build_text(obj.description)
    # TODO: icon setup


func setup_grant():
    detail_label.text = str(grant.difficulty) + " " + tr("GRANT_DIFFICULTY")


func setup_character():
    detail_label.text = str(character.cost_per_year) + " " + tr("CHARACTER_COST_PER_YEAR")


func setup_goal():
    detail_label.queue_free()   
    
func setup_game_over():
    change_button.get_node("Label").text = tr("EXIT_")
    #detail_label.text = "                            "
    detail_label.queue_free()   


func _on_ChangeButtonPressed():
    if object_type == 3:
        get_tree().quit()
    var choice_dialog = game_manager.ObjectChoice_res.instance()
    choice_dialog.darkinator = darkinator
    choice_dialog.game_manager = game_manager
    choice_dialog.object_type = object_type
    choice_dialog.parent_uid = parent_uid
    get_node("/root/Main/UI").add_child(choice_dialog)
    self.queue_free()


func _on_CloseButtonPressed():
    if object_type == 3:
        get_tree().quit()
    if darkinator != null:
        darkinator.queue_free()
    self.queue_free()


func _ready():
    close_button.connect("pressed", self, "_on_CloseButtonPressed")

    if not is_changable:
        change_button.queue_free()
    else:
        change_button.connect("pressed", self, "_on_ChangeButtonPressed")

    match object_type:
        0:
            generic_setup(grant)
            setup_grant()
        1:
            generic_setup(character)
            setup_character()
        2:
            generic_setup(goal)
            setup_goal()
        3:
            generic_setup(game_over)
            setup_game_over()
