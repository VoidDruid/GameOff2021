extends Node

export(NodePath) var simulation_node_path
var simulation: SimulationCore


func _ready():
	simulation = get_node(simulation_node_path)


func _process(_delta):
	pass
