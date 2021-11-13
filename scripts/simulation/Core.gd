extends Node

class_name SimulationCore


class FrontendState:
    var money: int
    var trust: int

    func _init():
        pass


func get_frontend_state() -> FrontendState:
    return FrontendState.new()
