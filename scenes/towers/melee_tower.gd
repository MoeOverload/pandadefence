extends Node2D

@export var meleePanda: PackedScene
var new_panda_instance = null

var spawn_max = 0

func _ready():
	
	#start timer
	$spawntimer.start()
	
func _on_spawntimer_timeout() -> void:
	if  spawn_max <= 5:
		spawn_panda() 

func spawn_panda():
	if new_panda_instance:
		new_panda_instance.queue_free()

	#create a child panda 
	new_panda_instance = meleePanda.instantiate()
	add_child(new_panda_instance)

	
	#set global position
	new_panda_instance.global_position = self.global_position
	spawn_max +=1
