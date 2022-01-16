extends CanvasLayer

"""
GifGetterUI

Single scene + script that can be dropped in and out of any scene.

Most gif-related variables are set from the LineEdit values.
"""

const MAX_CONSOLE_MESSAGE_COUNT: int = 20

onready var control: Control = $Control/Options

onready var capture_now_button: Button = $Control/Options/VBoxContainer/ButtonContainer/CaptureNowButton
onready var capture_in_five_seconds_button: Button = $Control/Options/VBoxContainer/ButtonContainer/CaptureInFiveSecondsButton
onready var render_quality_line_edit: LineEdit = $Control/Options/VBoxContainer/RenderQualityContainer/LineEdit
onready var frames_line_edit: LineEdit = $Control/Options/VBoxContainer/FramesContainer/LineEdit
onready var frame_skip_line_edit: LineEdit = $Control/Options/VBoxContainer/FrameSkipContainer/LineEdit
onready var frame_delay_line_edit: LineEdit = $Control/Options/VBoxContainer/FrameDelayContainer/LineEdit
onready var threads_line_edit: LineEdit = $Control/Options/VBoxContainer/ThreadsContainer/LineEdit
onready var hotkey_line_edit: LineEdit = $Control/Options/VBoxContainer/HotkeyContainer/LineEdit

onready var console: VBoxContainer = $Control/Console/ScrollContainer/VBoxContainer

onready var _viewport_rid: RID = get_viewport().get_viewport_rid()

# Determines if viewport texture data should be stored for processing
var _should_process: bool = false

var _stop_capture: bool = true
# Holds viewport texture data
var _images: Array = []

# Delay between storing viewport texture data
var _frame_skip: int = 0
# Count ticks between each frame skip
var _frame_skip_counter: int = 0
# Delay between each frame in the gif
var _gif_frame_delay: int = 0

var _second_recording: int = 5000

var _elapsed_time: int = 0

onready var start_time = OS.get_ticks_msec()

# Rendering quality for gifs from 1 - 30. 1 is highest quality but slow
var _render_quality: int = 30

# Background thread for capturing screenshots
var _process_thread: Thread = Thread.new()
# Number of render threads
var _max_threads: int = 4

# Path to intended save location. Uses Rust's fs library instead of Godot's
var _save_location: String

# Rust gif creation library
var _gif_handler: Reference = load("res://addons/godot-gif-getter/GifHandler.gdns").new()

var _hide_ui_action: String

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$Control/Options/VBoxContainer/SaveContainer/Button.connect("pressed", self, "_on_save_settings_pressed")
	$Control/Settings/Button.connect("pressed", self, "_on_settings_pressed")
	$Control/Options/VBoxContainer/SaveLocationContainer/Button.connect("pressed", self, "_on_select_path_button_pressed")
	control.visible = false

func _physics_process(_delta: float) -> void:
	if _elapsed_time < _second_recording:
		_elapsed_time = OS.get_ticks_msec() - start_time
	if not _stop_capture:
		_capture()
	if _should_process:
		if not _process_thread.is_active():
			_process_thread.start(self, "_process_frames")


func _input(event: InputEvent) -> void:
	if _hide_ui_action:
		if (not _should_process and event.is_action_pressed(_hide_ui_action)):
			control.visible = not control.visible

	if Input.is_action_pressed("screenshot") && not _stop_capture:
		_log_message("GIF processing...")

		_should_process = true
		_stop_capture = true

func _exit_tree() -> void:
	if _process_thread.is_active():
		_process_thread.wait_to_finish()

func _capture() -> void:
	var image: Image = get_viewport().get_texture().get_data()
	
	_images.push_back(image)

	if (_elapsed_time >= _second_recording):
		_images.pop_front()

func _process_frames(_x) -> void:
	var dir: Directory = Directory.new()
	if not dir.dir_exists(_save_location.get_base_dir()):
		_log_message("Directory does not exist.", true)
		return

	_should_process = false

	_images.pop_back()
		
	_rust_multi_thread()

	_log_message("GIF saved!")

	_images.clear()
	
	_process_thread.call_deferred("wait_to_finish")
	_stop_capture = false
	_elapsed_time = 0
	start_time = OS.get_ticks_msec()


###############################################################################
# Connections                                                                 #
###############################################################################

func _on_select_path_button_pressed() -> void:
	var fd: FileDialog = FileDialog.new()
	fd.name = "fd"
	fd.mode = FileDialog.MODE_OPEN_DIR
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.current_dir = OS.get_executable_path().get_base_dir()
	fd.current_path = fd.current_dir
	fd.connect("dir_selected", self, "_on_system_path_selected")
	fd.connect("popup_hide", self, "_on_popup_hide")
	
	var screen_middle: Vector2 = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	fd.set_global_position(screen_middle)
	fd.rect_size = screen_middle
	
	control.add_child(fd)
	fd.popup_centered_clamped(screen_middle)
	
	yield(fd, "dir_selected")
	fd.queue_free()

func _on_settings_pressed() -> void:
	control.visible = !control.visible

func _on_save_settings_pressed() -> void:
	control.visible = false
	if not _should_process:
		_stop_capture = !$Control/Options/VBoxContainer/CaptureGIFsContainer/CheckBox.is_pressed()
	
	if not _stop_capture:
		_elapsed_time = 0
		start_time = OS.get_ticks_msec()

func _on_system_path_selected(path: String) -> void:
	_save_location = path

func _on_popup_hide() -> void:
	var fd: FileDialog = get_node_or_null("fd")
	if fd:
		fd.queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

func _rust_multi_thread() -> void:
	"""
	Wrapper function for calling a Rust library to process and render a gif.
	"""
	var images_bytes: Array = []
	for image in _images:
		image.convert(Image.FORMAT_RGBA8)
		image.flip_y()
		images_bytes.append(image.get_data())

	var time : Dictionary = OS.get_datetime()
	var file : String = "/%d-%02d-%02d_%02d_%02d.gif" % [time.year, time.month, time.day, time.hour, time.minute];
	var full_path = _save_location + file

	_gif_handler.set_file_name(full_path)
	_gif_handler.set_frame_delay(2)
	_gif_handler.set_parent(self)
	_gif_handler.set_render_quality(_render_quality)
	_gif_handler.write_frames(
			images_bytes,
			int(get_viewport().size.x),
			int(get_viewport().size.y),
			_max_threads,
			_images.size())

func _log_message(message: String, is_error: bool = false) -> void:
	var label: Label = Label.new()
	if is_error:
		label.text += "[ERROR] "
	label.text += message
	console.call_deferred("add_child", label)
	yield(label, "ready")
	console.move_child(label, 0)
	print(message)
	
	while console.get_child_count() > MAX_CONSOLE_MESSAGE_COUNT:
		console.get_child(console.get_child_count() - 1).free()

###############################################################################
# Public functions                                                            #
###############################################################################


