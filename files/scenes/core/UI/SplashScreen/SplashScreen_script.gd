class_name SplashScreen
extends CanvasLayer

# Exported variables with clear descriptions
@export var audio_player: AudioStreamPlayer  # Handles background music or sound effects
@export var interpolation_speed: float = 3.0  # Speed of screen fade transitions
@export var blank_screen_start: bool = true  # Whether to start with a blank screen
@export var timers: Array[Timer] = []  # Timers for controlling screen durations
@export var screens: Array[CanvasItem] = []  # Screens to transition between
@export var path_to_scene_target: String  # Path to the target scene after the splash
@export var manipulate_audio: bool = false  # Whether to fade out audio
@export var bus_name: String = "sfx_1"  # Audio bus to manipulate
@export var sound_fade_duration: float = 9.0  # Duration of audio fade-out
@export var target_volume: float = -80.0  # Target volume for audio fade-out

# Internal variables
var times_switched: int = 0  # Tracks the current screen index
var last_switch_time: int = 0  # Tracks the last screen switch time
var fading_out: bool = false  # Whether a screen is currently fading out

func _ready() -> void:
	# Validate inputs before proceeding
	if screens.is_empty():
		push_error("No screens defined for the splash screen.")
		return
	if timers.is_empty():
		push_error("No timers defined for the splash screen.")
		return

	hide_all_screens()  # Hide all screens initially
	initialize_splash()  # Set up the initial screen state
	if audio_player:
		audio_player.play()  # Play audio if available
	setup_timers()  # Configure and start timers

func hide_all_screens() -> void:
	# Hide all screens to ensure a clean start
	for screen in screens:
		if screen:
			screen.hide()

func initialize_splash() -> void:
	# Set up the initial screen based on `blank_screen_start`
	if blank_screen_start:
		screens[0].hide()  # Start with a blank screen
		times_switched = -1  # Indicates no screen is visible yet
	else:
		screens[0].show()  # Show the first screen immediately
		screens[0].modulate.a = 1.0  # Ensure it's fully visible
		times_switched = 0  # Indicates the first screen is visible

func setup_timers() -> void:
	# Connect each timer to the `switch_screen` function
	for timer in timers:
		if timer:
			timer.connect("timeout", switch_screen)
			timer.one_shot = true  # Ensure timers only trigger once
	timers[0].start()  # Start the first timer

func switch_screen() -> void:
	times_switched += 1  # Move to the next screen
	if times_switched < timers.size() and times_switched < screens.size():
		timers[times_switched].start()  # Start the next timer
		fading_out = true  # Begin fading out the current screen
		last_switch_time = Time.get_ticks_msec()  # Record the switch time
	else:
		change_scene()  # Transition to the target scene if all screens are done
	if times_switched + 1 == screens.size():
		fade_out_sfx()  # Fade out audio if on the last screen

func transition_screen(current_screen: CanvasItem, next_screen: CanvasItem, target_alpha: float) -> void:
	# Smoothly transition between screens using lerp
	var delta_time = (Time.get_ticks_msec() - last_switch_time) / 1000.0
	current_screen.modulate.a = lerp(current_screen.modulate.a, target_alpha, interpolation_speed * delta_time)
	if abs(current_screen.modulate.a - target_alpha) < 0.05:
		current_screen.hide()  # Hide the current screen once faded out
		next_screen.show()  # Show the next screen
		next_screen.modulate.a = 0.0 if target_alpha == 0.0 else 1.0  # Reset alpha for the next screen
		fading_out = false  # End the fade-out process

func change_scene() -> void:
	# Transition to the target scene
	if path_to_scene_target:
		call_deferred("_deferred_change_scene")  # Use deferred call to avoid crashes
	else:
		push_error("No target scene path specified.")
		queue_free()  # Free the splash screen if no target scene is defined

func _deferred_change_scene() -> void:
	# Safely change the scene in a deferred manner
	get_tree().change_scene_to_file(path_to_scene_target)
	queue_free()  # Free the splash screen after the transition

func _on_skip_button_pressed() -> void:
	# Skip the splash screen and go directly to the target scene
	change_scene()

func _process(delta: float) -> void:
	# Handle screen transitions in real-time
	if times_switched >= 0 and times_switched < screens.size():
		if fading_out:
			transition_screen(screens[times_switched - 1], screens[times_switched], 0.0)  # Fade out the current screen
		else:
			screens[times_switched].modulate.a = lerp(screens[times_switched].modulate.a, 1.0, interpolation_speed * delta)  # Fade in the next screen

func fade_out_sfx() -> void:
	# Fade out audio if enabled
	if manipulate_audio:
		var current_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
		var tween = create_tween()
		tween.tween_method(Callable(self, "_set_bus_volume"), current_volume, target_volume, sound_fade_duration)

func _set_bus_volume(volume: float) -> void:
	# Set the volume of the specified audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), volume)

func _on_button_pressed() -> void:
	# Handle button press to skip the splash screen
	change_scene()
