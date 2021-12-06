extends Reference


func option_take(params: Dictionary, simulation: SimulationCore):
    var _rv = simulation.gain_money(params["money"])


func option_donate(params: Dictionary, simulation: SimulationCore):
    var _rv = simulation.change_reputation(params["reputation"])


var options_map = {
    "take": funcref(self, "option_take"),
    "donate": funcref(self, "option_donate"),
}
