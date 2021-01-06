extends SoundManagerModule

####################################################################
#	SOUND MANAGER MODULE FOR GODOT 3.2
#			Version 4.1
#			© Xecestel
####################################################################
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
#####################################

# Constants

const DEBUG = true

###########

# Variables

export (Dictionary) var Default_Sounds_Properties = {
	"BGM" : {
		"Volume" : 0,
		"Pitch" : 1,
	},
	"BGS" : {
		"Volume" : 0,
		"Pitch" : 1,
	},
	"SE" : {
		"Volume" : 0,
		"Pitch" : 1,
	},
	"ME" : {
		"Volume" : 0,
		"Pitch" : 1,
	},
}

export (bool) var preload_resources		= false
export (bool) var preinstantiate_nodes	= false

onready var Audiostreams : Array = self.get_children()
onready var soundmgr_dir_rel_path = self.get_script().get_path().get_base_dir()

var sounds_playing : Array = []
var bgm_playing				: String
var bgs_playing				: Array		= [ "BGS0" ]
var se_playing				: Array		= [ "SE0" ]
var me_playing				: Array		= [ "ME0" ]

var Audio_Busses : Dictionary = {
	"BGM" : "Master",
	"BGS" : "Master",
	"SE" : "Master",
	"ME" : "Master",
}

var Preloaded_Resources : Dictionary = {}
var Instantiated_Nodes : Array = []

##################

# Methods


##################################################
#				SOUNDS HANDLING					 #
# Use this methods to handle sounds in your game #
##################################################

# Plays a given BGM
func play_bgm(bgm : String, from_position : float = 0.0, volume_db : float = -81, pitch_scale : float = -1, sound_to_override : String = "") -> void:
	if bgm != "" and bgm != null:
		self.play("BGM", bgm, from_position, volume_db, pitch_scale, sound_to_override)
	elif DEBUG:
		print_debug("No sound selected.")


# Plays a given BGS
func play_bgs(bgs : String, from_position : float = 0.0, volume_db : float = -81, pitch_scale : float = -1, sound_to_override : String = "") -> void:
	if bgs != "" and bgs != null:
		self.play("BGS", bgs, from_position, volume_db, pitch_scale, sound_to_override)
	elif DEBUG:
		print_debug("No BGS selected.")


# Plays selected Sound Effect
func play_se(sound_effect : String, from_position : float = 0.0, volume_db : float = -81, pitch_scale : float = -1, sound_to_override : String = "") -> void:
	if sound_effect != "" and sound_effect != null:
		self.play("SE", sound_effect, from_position, volume_db, pitch_scale, sound_to_override)
	elif DEBUG:
		print_debug("No sound effect selected.")


# Play a given Music Effect
func play_me(music_effect : String, from_position : float = 0.0, volume_db : float = -81, pitch_scale : float = -1,	 sound_to_override : String = "") -> void:
	if music_effect != "" and music_effect != null:
		self.play("ME", music_effect, from_position, volume_db, pitch_scale, sound_to_override)
	elif DEBUG:
		print_debug("No sound selected.")


# Stops selected Sound
func stop(sound : String) -> void:
	var sound_index = 0
	if sound != "" and sound != null:
		if self.is_playing(sound):
			sound_index = find_sound(sound)
			if sound_index >= 0:
				Audiostreams[sound_index].stop()
				if not preinstantiate_nodes:
					self.erase_sound(sound)
					sounds_playing.erase(sound)
			elif DEBUG:
				print_debug("No sound found: " + sound)
	elif DEBUG:
		print_debug("No sound selected")


# Returns the index of the given sound if it's playing
# Returns -1 if it doesn't exist
func find_sound(sound : String) -> int:
	var sound_index = -1
	if not is_audio_file(sound):
		sound = Audio_Files_Dictionary.get(sound, null)
	if sound != null and sound != "":
		sound_index = sounds_playing.find(sound)
	return sound_index


# Returns true if the selected sound is playing
func is_playing(sound : String) -> bool:
	var playing : bool = false
	if sound != "" and sound != null:
		var sound_index = find_sound(sound)
		playing = sound_index >= 0
	elif DEBUG:
		print_debug("Sound not found: " + sound)
	return playing


func pause(sound : String) -> void:
	set_paused(sound, true)


func unpause(sound : String) -> void:
	set_paused(sound, false)


func set_paused(sound : String, paused : bool = true) -> void:
	var sound_index = self.find_sound(sound)
	if sound_index >= 0:
		Audiostreams[sound_index].set_stream_paused(paused)
	elif DEBUG:
		print_debug("Sound not found: " + sound)


# Returns true if the given sound is paused
func is_paused(sound : String) -> bool:
	var sound_index = self.find_sound(sound)
	var paused : bool = false
	if sound_index >= 0:
		paused = Audiostreams[sound_index].get_stream_paused()
	elif DEBUG:
		print_debug("Sound not found: " + sound)
	return paused



#################################
#		GETTERS AND SETTERS		#
#################################

# Returns the name of the currently playing sounds
func get_playing_sounds() -> Array:
	return sounds_playing


# Sound Properties #

func set_bgm_volume_db(volume_db : float) -> void:
	self.set_sound_property("BGM", "Volume", volume_db)


func get_bgm_volume_db() -> float:
	return Default_Sounds_Properties["BGM"]["Volume"]


func set_bgm_pitch_scale(pitch_scale : float) -> void:
	self.set_sound_property("BGM", "Pitch", pitch_scale)


func get_bgm_pitch_scale() -> float:
	return Default_Sounds_Properties["BGM"]["Pitch"]


func set_bgs_volume_db(volume_db : float) -> void:
	self.set_sound_property("BGS", "Volume", volume_db)


func get_bgs_volume_db() -> float:
	return Default_Sounds_Properties["BGS"]["Volume"]


func set_bgs_pitch_scale(pitch_scale : float) -> void:
	self.set_sound_property("BGS", "Pitch", pitch_scale)


func get_bgs_pitch_scale() -> float:
	return Default_Sounds_Properties["BGS"]["Pitch"]


func set_se_volume_db(volume_db : float) -> void:
	self.set_sound_property("SE", "Volume", volume_db)


func get_se_volume_db() -> float:
	return Default_Sounds_Properties["SE"]["Volume"]


func set_se_pitch_scale(pitch_scale : float) -> void:
	self.set_sound_property("SE", "Pitch", pitch_scale)


func get_se_pitch_scale() -> float:
	return Default_Sounds_Properties["SE"]["Pitch"]


func set_me_volume_db(volume_db : float) -> void:
	self.set_sound_property("ME", "Volume", volume_db)


func get_me_volume_db() -> float:
	return Default_Sounds_Properties["ME"]["Volume"]


func set_me_pitch_scale(pitch_scale : float) -> void:
	self.set_sound_property("ME", "Pitch", pitch_scale)


func get_me_pitch_scale() -> float:
	return Default_Sounds_Properties["ME"]["Pitch"]


func set_volume_db(volume_db : float, sound : String) -> void:
	var sound_index = self.find_sound(sound)
	if sound_index >= 0:
		Audiostreams[sound_index].set_volume_db(volume_db)
	elif DEBUG:
		print_debug("Sound not found: " + sound)


func get_volume_db(sound : String) -> float:
	var sound_index = self.find_sound(sound)
	var volume_db : float = -81.0
	if sound_index >= 0:
		volume_db = Audiostreams[sound_index].get_volume_db()
	elif DEBUG:
		print_debug("Sound not found: " + sound)
	return volume_db


func set_pitch_scale(pitch_scale : float, sound : String = "") -> void:
	var sound_index = self.find_sound(sound)
	if sound_index >= 0:
		Audiostreams[sound_index].set_pitch_scale(sound)
	elif DEBUG:
		print_debug("Soud not found: " + sound)


func get_pitch_scale(sound : String = "") -> float:
	var sound_index = self.find_sound(sound)
	var pitch_scale : float = -1.0
	if sound_index >= 0:
		pitch_scale = Audiostreams[sound_index].get_pitch_scale()
	elif DEBUG:
		print_debug("Sound not found: " + sound)
	return pitch_scale


func get_default_sound_properties(sound_type : String) -> Dictionary:
	return Default_Sounds_Properties[sound_type]


func set_sound_property(sound_type : String, property : String, value : float) -> void:
	match property:
		"Volume":
			value = clamp(value, -80, 24)
		"Pitch":
			value = clamp(value, 0.01, 4)
	Default_Sounds_Properties[sound_type][property] = value


# Audio Files Dictionary #

# Returns the Audio Files Dictionary
func get_audio_files_dictionary() -> Dictionary:
	return Audio_Files_Dictionary


# Returns the file name of the given stream name
# Returns null if an error occures.
func get_config_value(stream_name : String) -> String:
	return Audio_Files_Dictionary.get(stream_name)


# Allows you to change or add a stream file and name to the dictionary in runtime
func set_config_key(new_stream_name : String, new_stream_file : String) -> void:
	if (new_stream_file == "" or new_stream_name == ""):
		if DEBUG:
			print_debug("Invalid arguments")
		return
	
	self.add_to_dictionary(new_stream_name, new_stream_file)
	
	if (preload_resources):
		self.preload_resource_from_string(new_stream_file)


# Adds a new voice to the Audio Files Dictionary
func add_to_dictionary(audio_name : String, audio_file : String) -> void:
	Audio_Files_Dictionary[audio_name] = audio_file


# Resources preloading #

func enable_preload_resources(enabled : bool = true) -> void:
	self.preload_resources = enabled


func is_preload_resources_enabled() -> bool:
	return self.preload_resources



#############################
#	RESOURCE PRELOADING		#
#############################

func preload_audio_files_from_path(path : String):
	var file_name : String
	var dir := Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	if dir:
		file_name = dir.get_next()
		while file_name != "":
			if self.is_audio_file(file_name):
				var file_path = dir.get_current_dir() + file_name
				self.preload_resource_from_string(file_path)
			file_name = dir.get_next()
	elif DEBUG:
		print_debug("An error occurred when trying to access the path: " + path)
		


func preload_resources_from_list(files_list : Array) -> void:
	if (preload_resources):
		if DEBUG:
			print_debug("Resources already preloaded.")
		return
			
	for file in files_list:
		if (file is String):
			self.preload_resource_from_string(file)
		elif (file is Resource):
			self.preload_resource(file)


func preload_resource(file : Resource) -> void:		
	if (file == null):
		if DEBUG:
			print_debug("Invalid resource passed")
		return
	
	var file_path = file.get_path()
	
	Preloaded_Resources[file_path] = file


func preload_resource_from_string(file : String) -> void:	
	var res = null
	var file_name = file
	
	if self.is_import_file(file):
		file_name = file_name.get_basename()
	elif not self.is_audio_file(file):
		file_name = Audio_Files_Dictionary.get(file)
		if file_name == null:
			if DEBUG:
				print_debug("Audio File not found in Dictionary")
			return
	
	res = load(file_name)
	
	if res:
		Preloaded_Resources[file_name] = res
	elif DEBUG:
		print_debug("An error occured while preloading resource: " + file)


func unload_all_resources(force_unload : bool = false) -> void:
	if preload_resources:
		if force_unload == false:
			if DEBUG:
				print_debug("To unload resources with Preload Resources variable on, pass force_unload argument on true")
			return
		preload_resources = false
		
	Preloaded_Resources.clear()


func unload_resources_from_list(files_list : Array) -> void:
	for file in files_list:
		if (file is String):
			self.unload_resource_from_string(file)


func unload_resource_from_string(file : String) -> void:	
	var file_name = file
	
	if self.is_import_file(file):
		file_name = file_name.get_basename()
	elif not self.is_audio_file(file):
		file_name = Audio_Files_Dictionary.get(file)
		if file_name == null:
			if DEBUG:
				print_debug("Audio File not found in Dictionary")
			return
	
	if Preloaded_Resources.has(file_name):
		Preloaded_Resources.erase(file_name)
	elif DEBUG:
		print_debug("An error occured while unloading resource: " + file)


func unload_resources_from_dir(path : String) -> void:
	var dir = Directory.new()
	if dir.open(path + "/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if (self.is_audio_file(file_name)):
				self.unload_resource_from_string(dir.get_current_dir() + file_name)
			file_name = dir.get_next()
	elif DEBUG:
		print_debug("An error occurred when trying to access the path: " + path)


#############################
#	NODES PREINSTANTIATION	#
#############################

func preinstantiate_nodes_from_path(path : String, sound_type : String = ""):
	var file_name : String
	var dir := Directory.new()
	dir.open(path)
	if dir:
		dir.list_dir_begin(true, true)
		file_name = dir.get_next()
		while file_name != "":
			if self.is_audio_file(file_name) or self.is_import_file(file_name):
				var file_path = dir.get_current_dir() + file_name
				self.preinstantiate_node_from_string(file_path, sound_type)
			file_name = dir.get_next()
	elif DEBUG:
		print_debug("An error occurred when trying to access the path: " + path)


func preinstantiate_nodes_from_list(files_list : Array, type_list : Array, all_same_type : bool = false) -> void:	
	var index = 0
	for file in files_list:
		if file is String:
			if (all_same_type == false):
				index = files_list.find(file)
			self.preinstantiate_node_from_string(file, type_list[index])


func preinstantiate_node_from_string(file : String, sound_type : String = "") -> void:	
	var Stream = null
	var file_name = file
	var sound_index = 0

	if self.is_import_file(file):
		file_name = file_name.get_basename()
	elif not self.is_audio_file(file):
		file_name = Audio_Files_Dictionary.get(file)
		if file_name == null:
			if DEBUG:
				print_debug("Audio File not found in Dictionary")
			return
	
	if Preloaded_Resources.has(file_name):
		Stream = Preloaded_Resources.get(file_name)
	else:
		Stream = load(file_name)
	
	if not self.preinstantiate_node(Stream, sound_type) and DEBUG:
		print_debug("An error occured while creating a node from resource: " + file)


func preinstantiate_node(stream : Resource, sound_type : String = "") -> bool:
	if stream != null:
		var file_name = stream.get_path()
		if not Instantiated_Nodes.has(file_name):
			var sound_index = 0
			sound_index = self.add_sound(file_name, sound_type, true)
			Audiostreams[sound_index].set_stream(stream)
		elif DEBUG:
			print_debug("Node already instantiated")
		return true
	
	return false


func uninstantiate_all_nodes(force_uninstantiation : bool = false) -> void:
	if preinstantiate_nodes:
		if not force_uninstantiation:
			if DEBUG:
				print_debug("To uninstantiate resources with Preinstantiate Nodes on, pass force_uninstantiation argument on true")
			return
		preinstantiate_nodes = false

	uninstantiate_nodes_from_list(Instantiated_Nodes)


func uninstantiate_nodes_from_list(files_list : Array) -> void:
	var index = 0
	for file in files_list:
		if (file is String):
			self.uninstantiate_node_from_string(file)


func uninstantiate_node_from_string(file : String) -> void:
	var file_name = file
	var sound_index = 0

	if self.is_import_file(file):
		file_name = file_name.get_basename()
	elif not self.is_audio_file(file):
		file_name = Audio_Files_Dictionary.get(file)
		if file_name == null:
			if DEBUG:
				print_debug("Audio File not found in Dictionary")
			return
	
	self.erase_sound(file_name)


func uninstantiate_nodes_from_dir(path : String) -> void:
	var dir = Directory.new()
	if dir.open(path + "/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var sound_index = 0
		while (file_name != ""):
			if (self.is_audio_file(file_name)):
				self.uninstantiate_node_from_string(file_name)
			file_name = dir.get_next()
	elif DEBUG:
		print_debug("An error occurred when trying to access the path: " + path)


func enable_node_preinstantiation(enabled : bool = true) -> void:
	self.preinstantiate_nodes = enabled


func is_preinstantiate_nodes_enabled() -> bool:
	return preinstantiate_nodes


#############################
#	INTERNAL METHODS		#
#############################

# Called when the node enters the scene for the first time
func _ready() -> void:
	if(ProjectSettings.get_setting("editor_plugins/enabled") and
	Array(ProjectSettings.get_setting("editor_plugins/enabled")).has("sound_manager")):
			get_sound_manager_settings()
			
	if preload_resources and Preloaded_Resources.empty():
		if DEBUG:
			print_debug("Preloading...")
		self.preload_audio_files()
	if preinstantiate_nodes:
		if DEBUG:
			print_debug("Instantiating nodes...")
		self.preinstantiate_nodes()


# Load the Sound Manager settings from the JSON file:  SoundManager.json
func get_sound_manager_settings()-> void:
	var data_settings : Dictionary
	var file: File = File.new()
	file.open("res://addons/sound_manager/SoundManager.json", File.READ)
	var json : JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	if typeof(json.result) == TYPE_DICTIONARY:
		data_settings = json.result
		
		Default_Sounds_Properties = data_settings["DEFAULT_SOUNDS_PROPERTIES"]
		Audio_Busses = data_settings["Audio_Busses"]
		Audio_Files_Dictionary = data_settings["Audio_Files_Dictionary"]
		preload_resources = data_settings["PRELOAD_RES"]
		preinstantiate_nodes = data_settings["PREINSTANTIATE_NODES"]
		
	elif DEBUG:
		print_debug("Failed to load the sound manager's settings file: " + 'res://addons/sound_manager/SoundManager.json')


# Plays the selected sound
func play(sound_type : String, sound : String, from_position : float = 1.0, volume_db : float = -81, pitch_scale : float = -1, sound_to_override : String = "") -> void:
	var sound_path : String
	var volume = Default_Sounds_Properties[sound_type]["Volume"] if volume_db < -80 else volume_db
	var pitch = Default_Sounds_Properties[sound_type]["Pitch"] if pitch_scale < 0 else pitch_scale
	var audiostream : AudioStreamPlayer
	var sound_index = 0
	
	Audiostreams = self.get_children()
	
	if Audio_Files_Dictionary.has(sound):
		sound_path = Audio_Files_Dictionary.get(sound)
	elif sound.is_abs_path() and is_audio_file(sound.get_file()):
		sound_path = sound
	else:
		if DEBUG:
			print_debug("Error: file not found " + sound)
		return
	if Instantiated_Nodes.has(sound_path):
		sound_index = Instantiated_Nodes.find(sound_path)
		audiostream = Audiostreams[sound_index]
		if audiostream.get_bus() != Audio_Busses[sound_type]:
			audiostream.set_bus(Audio_Busses[sound_type])
		if DEBUG:
			print_debug("Node preinstantiated " + sound_path)
	else:
		if sound_to_override != "":
			if self.is_playing(sound):
				return
		
		var Stream
		if Preloaded_Resources.has(sound_path):
			if DEBUG:
				 print_debug("Resource preloaded " + sound_path)
			Stream = Preloaded_Resources.get(sound_path)
		else:
			Stream = load(sound_path)
			
			if Stream == null:
				if DEBUG:
					print_debug("Failed to load file from path: " + sound_path)
				return
		
		if sound_to_override != "":
			sound_index = find_sound(sound_to_override)
				
			if sound_index < 0:
				if DEBUG:
					print_debug("Sound not found: " + sound_to_override)
				return
		else:
			sound_index = add_sound(sound_path, sound_type)
		audiostream = Audiostreams[sound_index]
		audiostream.set_stream(Stream)
	
	audiostream.set_volume_db(volume)
	audiostream.set_pitch_scale(pitch)
	
	
	audiostream.play(from_position)
	if audiostream.get_script() != null:
		audiostream.set_sound_name(sound)
	if sound_index < sounds_playing.size():
		sounds_playing[sound_index] = sound_path
	else:
		sounds_playing.append(sound_path)


# Adds a new AudioStreamPlayer
func add_sound(sound : String, sound_type : String, preinstance : bool = false) -> int:
	var sound_index
	var new_audiostream = AudioStreamPlayer.new()
	var sound_script = load(soundmgr_dir_rel_path + "/Sounds.gd")
	var bus : String
	
	if sound_type == "":
		bus = "Master"
	else:
		bus = Audio_Busses[sound_type]
	
	self.add_child(new_audiostream)
	if not preinstance:
		new_audiostream.set_script(sound_script)
		new_audiostream.set_sound_name(sound)
		new_audiostream.set_sound_type(sound_type)
		new_audiostream.connect_signals(self)
	new_audiostream.set_bus(bus)
	sound_index = new_audiostream.get_index()
	if not Instantiated_Nodes.has(sound):
		Instantiated_Nodes.append(sound)
	Audiostreams.append(new_audiostream)
	sound_index = Instantiated_Nodes.find(sound)
	
	return sound_index


func erase_sound(sound : String) -> void:
	var sound_index : int = find_sound(sound)
	
	if sound_index >= 0:
		Instantiated_Nodes.remove(sound_index)
		Audiostreams.remove(sound_index)
		sounds_playing.remove(sound_index)
		self.get_children()[sound_index].queue_free()
	elif DEBUG:
		print_debug("Sound not found: " + sound)


func _on_sound_finished(sound_name : String) -> void:
	if not preinstantiate_nodes:
		self.erase_sound(sound_name)


func preload_audio_files() -> void:
	var directory := Directory.new()
	directory.open("res://")
	self.preload_audio_files_from_path("res://")
	self.preload_audio_files_r(directory)


func preload_audio_files_r(directory : Directory):
	if directory == null:
		return
	directory.list_dir_begin(true, true)
	var dir_name = directory.get_next()
	while dir_name != "":
		if directory.current_is_dir():
			if dir_name != "addons":
				var dir_path = directory.get_current_dir() + dir_name
				self.preload_audio_files_from_path(dir_path)
		dir_name = directory.get_next()


func preinstantiate_nodes() -> void:
	var directory := Directory.new()
	directory.open("res://")
	self.enable_node_preinstantiation(true)
	self.preinstantiate_nodes_from_path("res://")
	self.preinstatiate_nodes_r(directory)


func preinstatiate_nodes_r(directory : Directory):
	if directory == null:
		return
	directory.list_dir_begin(true, true)
	var dir_name = directory.get_next()
	while dir_name != "":
		if directory.current_is_dir():
			if dir_name != "addons":
				var dir_path = directory.get_current_dir() + dir_name
				self.preinstantiate_nodes_from_path(dir_path)
		dir_name = directory.get_next()


func is_audio_file(file_name : String) -> bool:
	return	(file_name.get_extension() == "wav" or
			file_name.get_extension() == "ogg" or
			file_name.get_extension() == "opus")


func is_import_file(file_name : String) -> bool:
	return (file_name.get_extension() == "import" and
			self.is_audio_file(file_name.get_basename()))
