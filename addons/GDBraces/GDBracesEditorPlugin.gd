#GDBracesEditorPlugin.gd
@tool
extends EditorPlugin
class_name GDBracesEditorPlugin

var contextMenu := GDBracesContextMenuPlugin.new()
var addScriptInspectorPlugin := GDBracesInspectorPlugin.new()
var loader := GDBracesResourceFormatLoader.new()
var saver := GDBracesResourceFormatSaver.new()

var script_editor := GDBraceScriptEditor.new(self)

var editor_instance: Control
var use_external: bool

#NOTE: Move this to a class managing all the logic of the code editor
var current_script: GDBraceScript:
	set(value):
		if current_script != value:
			current_script = value
			current_script_changed.emit()

signal current_script_changed

func _enter_tree():
	ResourceSaver.add_resource_format_saver(saver)
	ResourceLoader.add_resource_format_loader(loader)

	add_tool_menu_item("Create GDBraceScript", _create_new_script)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, contextMenu)
	add_inspector_plugin(addScriptInspectorPlugin)

func _exit_tree():
	ResourceLoader.remove_resource_format_loader(loader)
	ResourceSaver.remove_resource_format_saver(saver)

	if editor_instance:
		editor_instance.queue_free()
	
	remove_context_menu_plugin(contextMenu)
	remove_inspector_plugin(addScriptInspectorPlugin)

func _create_new_script():
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.braces", "GDBraceScript")
	dialog.file_selected.connect(_on_file_selected)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)

func _on_file_selected(path: String):
	var resource = GDBraceScript.new()
	resource.source_code = "# New GDBraces script\n"

	var err = ResourceSaver.save(resource, path)
	if err == OK:
		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Failed to create script: " + str(err))

func _edit(object):
	if object is Node and object.has_meta(&"script"):
		var path = object.get_meta(&"script")
		current_script = load(path) as GDBraceScript
		print(current_script.resource_path)
		_open_in_script_editor()

	elif object is GDBraceScript:
		use_external = EditorInterface.get_editor_settings().get_setting("text_editor/external/use_external_editor")
		
		current_script = object
		# var path = object.resource_path
		
		# if use_external:
			# _open_in_external_editor(object)

		_open_in_script_editor()

func _open_in_script_editor():
	if not editor_instance:
		editor_instance = script_editor.create_editor() # _create_editor()
		EditorInterface.get_editor_main_screen().add_child(editor_instance)
	
	_make_visible(true)

#TODO: Must open the project in on external editor, currently only opens the file
func _open_in_external_editor(resource: GDBraceScript):
	var path = ProjectSettings.globalize_path(resource.resource_path)
	OS.shell_open(path)

#NOTE: Tentative solution for internal code editor
# func _create_editor() -> Control:
# 	var container = VBoxContainer.new()
# 	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
# 	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
# 	var code_edit = CodeEdit.new()
# 	code_edit.text = current_script.source_code
# 	code_edit.auto_brace_completion_enabled = true
# 	code_edit.indent_size = 3
# 	code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
# 	code_edit.syntax_highlighter = GDScriptSyntaxHighlighter.new()
	
# 	code_edit.text_changed.connect(func():
# 		current_script.source_code = code_edit.text
# 	)

# 	current_script_changed.connect(func():
# 		code_edit.text = current_script.source_code
# 	)
	
# 	container.add_child(code_edit)
# 	return container

func _make_visible(visible: bool):
	if editor_instance:
		editor_instance.visible = visible

func _handles(object) -> bool:
	# return object is GDBraceScript
	if object is GDBraceScript:
		return true
	
	if object is Node:
		print(editor_description)
		return object.has_meta(&"script")

	# if object is Node:
		
	# 	return object.editor_description != ""

	return false
	

func _get_plugin_name() -> String:
	return "GDBraces"

func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/icons/Script64x64.svg")

func _has_main_screen() -> bool:
	return true
