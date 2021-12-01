extends Panel

onready var close_button = $CloseButton
onready var container = $Margin/VBoxContainer/ScrollContainer/VBoxContainer

var darkinator
var game_manager
var object_type


func _on_CloseButtonPressed():
    if darkinator != null:
        darkinator.queue_free()
    self.queue_free()


func _ready():
    close_button.connect("pressed", self, "_on_CloseButtonPressed")
    var dt
    var i
    match object_type:
        0:
            # Grant
            dt = game_manager.simulation.get_grants_data()
            i = 0
            for gr in dt.current_grants:
                var grTab = game_manager.GrantTab_res.instance()
                grTab.game_manager = game_manager
                grTab.get_node("HBoxContainer/Background").color = game_manager.get_color_index(i)
                grTab.setup_for_grant(gr, game_manager.simulation.get_specialty_color(gr.specialty_uid), game_manager.EffectLabel, game_manager.PlusButton, game_manager.GrantChance, false, true, false)
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
                chTab.get_node("Background").color = game_manager.get_color_index(i)
                container.add_child(chTab)
                i += 1
