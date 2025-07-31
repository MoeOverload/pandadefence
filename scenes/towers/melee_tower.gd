extends Node2D

@export var meleePanda: PackedScene


var spawn_max = 0

func _ready():
	
	#start timer
	$spawntimer.start()
	
func _on_spawntimer_timeout() -> void:
	if  spawn_max <= 5:
		spawn_panda() 

func spawn_panda():


	#create a child panda 
	var new_panda = meleePanda.instantiate()
	add_child(new_panda)

	
	#set the home area and global position
	new_panda.global_position = self.global_position
	spawn_max +=1
