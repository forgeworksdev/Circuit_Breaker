extends AudioStreamPlayer

var loop: bool = false

func _init() -> void:
	self.connect(&"finished", loop_song)

func change_song(path: String):
	stream = load(path)
	play()

func loop_song():
	if !playing and loop:
		self.play()

#func change_song(path: String):
	#var audio_track: AudioStream = ResourceLoader.load(path, "AudioStream")
	#if audio_track == null:
		#print("Failed to load audio track from path: ", path)
		#return
