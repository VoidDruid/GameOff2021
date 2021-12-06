extends Panel

export(Color) var good_color
export(Color) var bad_color

onready var background = $Margins/VLayout/Visuals/Background
onready var object = $Margins/VLayout/Visuals/Object
onready var video_player = $Margins/VLayout/Visuals/VideoPlayer
onready var global_effect_label = $Margins/VLayout/GlobalEffectsLayout/EffectLabel
onready var name_label = $Margins/VLayout/NameL
onready var description_label = $Margins/VLayout/DescriptionL
onready var options_grid = $Margins/VLayout/OptionsControl/Margins/OptionsGrid

var OptionButton_res = load("res://objects/ui/OptionButton.tscn")

var darkinator
var continue_game_manager
var event
var simulation
onready var EventScript = load(event.script_name)
onready var event_script = EventScript.new()


func destructor(option_name):
    event_script.options_map[option_name.to_lower().substr(7)].call_func(event.params, simulation)
    simulation.Storage.is_event_active = false
    continue_game_manager.call_func()
    darkinator.queue_free()
    self.queue_free()


func setup_visuals():
    var visuals = event.visuals
    global_effect_label.hide()
    if visuals["background"] != null:
        background.texture = load(visuals["background"])
    else:
        background.hide()
    if visuals["object"] != null:
        object.texture = load(visuals["object"])
    else:
        object.hide()
    if visuals["video"] != null:
        video_player.stream = load(visuals["video"])
        video_player.play()


func _ready():
    name_label.text = event.name
    description_label.text = tr(event.description)
    setup_visuals()
    
    for options_data in event.options:
        var option_node = OptionButton_res.instance()
        option_node.option = options_data
        option_node.destructor = funcref(self, "destructor")
        options_grid.add_child(option_node)
