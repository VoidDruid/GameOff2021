extends Control

export(Color) var good_color
export(Color) var bad_color

onready var option_name = $VLayout/TextureButton/Label
onready var button = $VLayout/TextureButton
var EffectLabel = load("res://objects/ui/EffectLabel.tscn")

var option
var destructor


func on_click():
    destructor.call_func(option.name)


func _ready():
    option_name.text = option.name
    button.connect("pressed", self, "on_click")
