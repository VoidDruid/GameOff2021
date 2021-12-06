extends Reference

var faculty

func option_physics(_params: Dictionary, simulation: SimulationCore):
    faculty = simulation.Storage.FACULTY_MAP["PHYSICS_FACULTY_"]
    faculty.default_breakthrough_chance += 7

func option_math(_params: Dictionary, simulation: SimulationCore):
    faculty = simulation.Storage.FACULTY_MAP["MATH_FACULTY_"]
    faculty.default_breakthrough_chance += 7

func option_bio(_params: Dictionary, simulation: SimulationCore):
    faculty = simulation.Storage.FACULTY_MAP["BIOLOGY_FACULTY_"]
    faculty.default_breakthrough_chance += 7

func option_ling(_params: Dictionary, simulation: SimulationCore):
    faculty = simulation.Storage.FACULTY_MAP["LING_SOC_FACULTY_"]
    faculty.default_breakthrough_chance += 7

var options_map = {
    "physics": funcref(self, "option_physics"),
    "math": funcref(self, "option_math"),
    "bio": funcref(self, "option_bio"),
    "ling": funcref(self, "option_ling"),
}
