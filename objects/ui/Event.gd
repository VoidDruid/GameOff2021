extends Panel

export(Color) var good_color
export(Color) var bad_color

onready var visuals_container = $Margins/VLayout/Visuals
onready var global_effect_label = $Margins/VLayout/GlobalEffectsLayout/EffectLabel
onready var name_label = $Margins/VLayout/NameL
onready var description_label = $Margins/VLayout/DescriptionL
onready var options_grid = $Margins/VLayout/OptionsControl/Margins/OptionsGrid

var OptionButton_res = load("res://objects/ui/OptionButton.tscn")

var event

func _ready():
    pass
