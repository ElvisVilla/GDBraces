extends Control
class_name GDBraceScriptEditor

var editor_plugin: GDBracesEditorPlugin
var container: VBoxContainer
var code_edit: CodeEdit

func _init(editor_plugin):
	self.editor_plugin = editor_plugin

func create_editor() -> Control:
	container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_edit = CodeEdit.new()
	code_edit.text = editor_plugin.current_script.source_code
	code_edit.auto_brace_completion_enabled = true
	code_edit.indent_size = 3
	code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_edit.syntax_highlighter = GDScriptSyntaxHighlighter.new()
	code_edit.add_theme_font_size_override("font_size", current_font_size)

	code_edit.text_changed.connect(func():
		editor_plugin.current_script.source_code = code_edit.text
	)

	editor_plugin.current_script_changed.connect(func():
		code_edit.text = editor_plugin.current_script.source_code
	)
	
	container.add_child(code_edit)
	return container

const MIN_FONT_SIZE = 8
const MAX_FONT_SIZE = 48
const FONT_SIZE_STEP = 2

var current_font_size: int = 36 # Default size

func _ready():
	_apply_font_size(current_font_size)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		# Keyboard shortcuts
		if event.ctrl_pressed or event.meta_pressed:
			if event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD:
				_increase_font_size()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
				_decrease_font_size()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_0 or event.keycode == KEY_KP_0:
				_reset_font_size()
				get_viewport().set_input_as_handled()
	
	# Mouse wheel zoom
	elif event is InputEventMouseButton:
		if event.ctrl_pressed or event.meta_pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				_increase_font_size()
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				_decrease_font_size()
				get_viewport().set_input_as_handled()

# func _input(event: InputEvent):
# 	if event is InputEventKey and event.pressed:
# 		# Check for Cmd/Ctrl + Plus (increase)
# 		if event.ctrl_pressed or event.meta_pressed: # meta_pressed is Cmd on macOS
# 			if event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD: # '+' key
# 				_increase_font_size()
# 				get_viewport().set_input_as_handled()
			
# 			# Check for Cmd/Ctrl + Minus (decrease)
# 			elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT: # '-' key
# 				_decrease_font_size()
# 				get_viewport().set_input_as_handled()
			
# 			# Check for Cmd/Ctrl + 0 (reset)
# 			elif event.keycode == KEY_0 or event.keycode == KEY_KP_0:
# 				_reset_font_size()
# 				get_viewport().set_input_as_handled()

func _increase_font_size():
	current_font_size = min(current_font_size + FONT_SIZE_STEP, MAX_FONT_SIZE)
	_apply_font_size(current_font_size)

func _decrease_font_size():
	current_font_size = max(current_font_size - FONT_SIZE_STEP, MIN_FONT_SIZE)
	_apply_font_size(current_font_size)

func _reset_font_size():
	current_font_size = 16
	_apply_font_size(current_font_size)

func _apply_font_size(size: int):
	# Get the editor font from theme
	# var editor_font = EditorInterface.get_editor_settings().get_setting("interface/editor/code_font")
	if code_edit:
		# Create a new theme or modify existing one
		# if not code_edit.theme:
		# 	code_edit.theme = Theme.new()
		code_edit.add_theme_font_size_override("font_size", current_font_size)
		
		# If you want to use the editor's font as well
		# if editor_font:
		# 	code_edit.add_theme_font_override("font", editor_font)