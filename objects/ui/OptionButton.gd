extends Control

export(Color) var good_color
export(Color) var bad_color

onready var option_name = $VLayout/EffectsLayout/EffectLabel
onready var effects_layout = $VLayout/EffectsLayout
var EffectLabel = load("res://objects/ui/EffectLabel.tscn")

var option

func _ready():
    pass
