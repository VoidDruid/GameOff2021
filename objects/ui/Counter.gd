extends MarginContainer


export(Texture) var texture


# Called when the node enters the scene tree for the first time.
func _ready():
    $TextureRect.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
