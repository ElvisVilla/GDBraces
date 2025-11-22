@tool
@icon("res://addons/icons/Script128x128.png")
class_name GDBraceScript
extends Resource

var source_code: String = ""
var gd_script_path: String = ""

func get_source_code() -> String:
    return source_code

func set_source_code(value: String) -> void:
    source_code = value
    _transpile_and_save()

func _transpile_and_save() -> void:
    if resource_path.is_empty():
        return

    var filename = resource_path.get_file().get_basename()
    gd_script_path = "res://generated/%s.gd" % filename

    if not DirAccess.dir_exists_absolute("res://generated"):
        DirAccess.make_dir_absolute("res://generated")

    var transpiled_code = Lox.transpile(self) # _transpile(source_code)
    print(transpiled_code)
    if transpiled_code.is_empty(): return

    var file = FileAccess.open(gd_script_path, FileAccess.WRITE)
    if file:
        file.store_string(transpiled_code)
        file.close()
        
        EditorInterface.get_resource_filesystem().scan()
    else:
        push_error("Failed to save generated script: " + gd_script_path)

func _transpile(source: String) -> String:
    return """
extends Node

# Transpiled from: %s
# TODO: Actual transpilation logic

func _ready():
    print("It does!")
    pass
""" % resource_path