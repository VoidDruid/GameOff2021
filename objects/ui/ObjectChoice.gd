extends Panel

export(Color) var text_color
onready var close_button = $CloseButton
onready var container = $Margin/VBoxContainer/ScrollContainer/VBoxContainer
onready var name_l = $Margin/VBoxContainer/NameL

var darkinator
var game_manager
var object_type
var parent_uid
var has_actions = true
var action_type = null

func _on_CloseButtonPressed():
    if darkinator != null:
        darkinator.queue_free()
    self.queue_free()


func _ready():
    close_button.connect("pressed", self, "_on_CloseButtonPressed")
    var dt
    var i
    var button
    match object_type:
        0:
            # Grant
            name_l.text = tr("CHOOSE_GRANT_")
            dt = game_manager.simulation.get_grants_data()
            i = 0
            for gr in dt.current_grants:
                var grTab = game_manager.GrantTab_res.instance()
                grTab.game_manager = game_manager
                grTab.get_node("HBoxContainer/Background").color = game_manager.get_color_index(i)
                if has_actions:
                    grTab.action_type = game_manager.ASSIGN_GRANT if action_type == null else action_type
                    grTab.faculty_uid = parent_uid
                else:
                    grTab.action_type = -1
                grTab.setup_for_grant(gr, game_manager.simulation.get_specialty_color(gr.specialty_uid), game_manager.EffectLabel, game_manager.PlusButton, game_manager.GrantChance, game_manager.TickButton, false, true, false)
                if has_actions:
                    button = grTab.get_node("HBoxContainer/Background/TickButton")
                    button.connect("pressed", self, "queue_free")
                    button.connect("pressed", darkinator, "queue_free")
                container.add_child(grTab)
        1:
            # Character
            name_l.text = tr("CHOOSE_CHARACTER_")
            dt = game_manager.simulation.get_characters_data()
            i = 0
            for ch in dt.hired_characters:
                var chTab = game_manager.ACharacterTab_res.instance()
                chTab.game_manager = game_manager
                chTab.EffectLabel = game_manager.EffectLabel
                chTab.character = ch
                if has_actions:
                    chTab.action_type = game_manager.LEADER_ASSIGN if action_type == null else action_type
                    chTab.faculty_uid = parent_uid
                    button = chTab.get_node("Background/TextureButton")
                    button.connect("pressed", self, "queue_free")
                    button.connect("pressed", darkinator, "queue_free")
                else:
                    chTab.action_type = -1
                chTab.get_node("Background").color = game_manager.get_color_index(i)
                container.add_child(chTab)
                i += 1
        2:
            # Faculty
            name_l.text = tr("CHOOSE_FACULTY_")
            var faculties = game_manager.simulation.get_faculties()
            i = 0
            for fc in faculties:
                if !fc.is_opened:
                    var fcTab = game_manager.FacultyMapTab_res.instance()
                    fcTab.game_manager = game_manager
                    fcTab.get_node("HBoxContainer/Background").color = game_manager.get_color_index(i)
                    if has_actions:
                        fcTab.action_type = game_manager.FACULTY_ADD
                        fcTab.faculty_uid = fc.uid
                    else:
                        fcTab.action_type = -1
                    fcTab.setup_for_faculty_map_tab(fc, game_manager.simulation.get_specialty_color(fc.specialty_uid), game_manager.EffectLabel, game_manager.PlusButton, game_manager.GrantChance, game_manager.TickButton)
                    if has_actions:
                        button = fcTab.get_node("HBoxContainer/Background/TickButton")
                        button.connect("pressed", self, "queue_free")
                        button.connect("pressed", darkinator, "queue_free")
                    container.add_child(fcTab)
        3:
            # Help window
            name_l.text = tr("HELP_WINDOW_")
            var help_holder = game_manager.HelpHolder_res.instance()
            var faculties_help = help_holder.get_node("RichTextLabel")
            faculties_help.text = tr("HELP_FACULTIES_") + "\n" + tr("HELP_CHARACTERS_") + "\n" + tr("HELP_GRANTS_") + "\n" + tr("HELP_START_")
            container.add_child(help_holder)
