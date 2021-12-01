extends Panel

onready var close_button = $CloseButton
onready var container = $Margin/VBoxContainer/ScrollContainer/VBoxContainer

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
            var fcTab = game_manager.FacultyMapTab_res.instance()
            var cntr = game_manager.HelpHolder_res.instance()
            container.add_child(cntr)

            var faculties_help = Label.new()
            faculties_help.text = "HELP_FACULTIES_"
            cntr.add_child(faculties_help)
            var characters_help = Label.new()
            characters_help.text = "HELP_CHARACTERS_"
            cntr.add_child(characters_help)
            var grants_help = Label.new()
            grants_help.text = "HELP_GRANTS_"
            cntr.add_child(grants_help)
            var start_help = Label.new()
            start_help.text = "HELP_START_"
            cntr.add_child(fcTab)
