extends Node

var statusLabel: Label = null
var is_debug: bool = false
var last_uid: int = 0


func get_node_from_group(group: String, name: String) -> Node:
    var group_list = get_tree().get_nodes_in_group(group)
    for node in group_list:
        if is_debug:
            if node.get_name() == name:
                return node
        else:
            node.queue_free()
    return null


func _ready():
    is_debug = OS.is_debug_build()
    statusLabel = get_node_from_group(consts.DEBUG_UI_N, consts.STATUS_LABEL_N)


func set_status(status) -> void:
    var status_string = str(status)
    if is_debug:
        statusLabel.text = status_string


func clear_status() -> void:
    if is_debug:
        statusLabel.text = ""


func notify_error(error_dict: Dictionary) -> void:
    log_error(error_dict)
    set_status(str(error_dict))


func log_error(error_dict: Dictionary) -> void:
    push_error(str(error_dict))


func assert_e(condition: bool, error_dict: Dictionary) -> void:
    assert(condition, str(error_dict))


func json_readf(path: String):
    var file = File.new()
    var open_status = file.open(path, file.READ)
    assert_e(open_status == OK, {"err": "Could not open file " + path})

    var text = file.get_as_text()

    var result_json = JSON.parse(text)
    assert_e(
        result_json.error == OK,
        {
            "text": "[load_json_file] Error loading JSON file '" + str(path),
            "error": result_json.error,
            "error_line": result_json.error_line,
            "error_string": result_json.error_string,
        }
    )

    return result_json.result


func get_uid() -> String:
    last_uid += 1
    return str(last_uid)


func intersection(first, second):
    var result = []
    for item in first:
        if item in second:
            result.append(item)
    return result


func build_text(text_src) -> String:
    var text
    match typeof(text_src):
        TYPE_ARRAY:
            text = ""
            for text_src_item in text_src:
                text += build_text(text_src_item)
        TYPE_STRING:
            text = tr(text_src)
    return text


func load_icon(name):
    return load("res://gamedata/icons/" + name + ".png")


var val = [
    1000, 900, 500, 400,
    100, 90, 50, 40,
    10, 9, 5, 4,
    1
]
var syb = [
    "M", "CM", "D", "CD",
    "C", "XC", "L", "XL",
    "X", "IX", "V", "IV",
    "I"
]
func to_roman(num):
    if num <= 0:
        return str(num)
    var roman_num = ''
    var count
    for i in range(len(val)):
        count = int(num / val[i])
        for _i in range(count):
            roman_num += syb[i]
        num -= val[i] * count
    return roman_num


func with_chance(chance: float) -> bool:
    return randi() % 100 < chance * 100


func random_choice(arr):
    return arr[randi() % len(arr)]
