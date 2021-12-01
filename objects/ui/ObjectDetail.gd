extends Panel

var object_type
var grant
var character
var goal
var is_changable = true
var darkinator
var game_manager
var parent_uid

onready var icon_rect = $Margins/Control/Layout/TextureRect
onready var name_label = $Margins/Control/Layout/InfoBox/NameL
onready var description_label = $Margins/Control/Layout/InfoBox/DescriptionL
onready var detail_label = $Margins/Control/Layout/InfoBox/BottomRowHB/DetailL
onready var change_button = $Margins/Control/Layout/InfoBox/BottomRowHB/Control/HBoxContainer/TextureButton
onready var close_button = $CloseButton


func generic_setup(obj):
    var suffix
    match object_type:
        0:
            suffix = tr(obj.specialty_uid)
        1:
            suffix = tr(obj.title)
        2:
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


func _on_ChangeButtonPressed():
    var choice_dialog = game_manager.ObjectChoice_res.instance()
    choice_dialog.darkinator = darkinator
    choice_dialog.game_manager = game_manager
    choice_dialog.object_type = object_type
    choice_dialog.parent_uid = parent_uid
    get_node("/root/Main/UI").add_child(choice_dialog)
    self.queue_free()


func _on_CloseButtonPressed():
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
