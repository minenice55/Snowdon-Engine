extends AudioStreamPlayer

####################################################################
#SOUNDS SCRIPT FOR THE SOUND MANAGER MODULE FOR GODOT 3.2
#			© Xecestel
####################################################################
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
#####################################

# Variables

var sound_type : String
var sound_name : String;

###########

# Signals

signal finished_playing(sound_name)

##########


func _ready():
	self.set_properties();


func connect_signals(connect_to : Node) -> void:
	self.connect("finished", self, "_on_self_finished")
	self.connect("finished_playing", connect_to, "_on_sound_finished");


func set_properties(volume_db : float = 0.0, pitch_scale : float = 1.0) -> void:
	self.set_volume_db(volume_db);
	self.set_pitch_scale(pitch_scale);


func set_sound_name(sound_name : String) -> void:
	self.sound_name = sound_name;


func set_sound_type(type : String) -> void:
	self.sound_type = type


func get_sound_type() -> String:
	return self.sound_type


func get_sound_name() -> String:
	return sound_name


func _on_self_finished() -> void:
	emit_signal("finished_playing", self.get_sound_name());

