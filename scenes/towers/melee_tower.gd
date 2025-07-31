extends Node2D

@export var meleePanda: PackedScene
var new_panda_instance = null

var spawn_max = 0

func _ready():
	if new_panda_instance:
		new_panda_instance.queue_free()
	#start timer
	$spawntimer.start()
	
func _on_spawntimer_timeout() -> void:
	if  spawn_max <= 5:
		spawn_panda() 

func spawn_panda():

	

	#create a child panda 
	new_panda_instance = meleePanda.instantiate()
	add_child(new_panda_instance)

	
	#set global position
	new_panda_instance.global_position += Vector2(randi_range(-8, 8), randi_range(-8, 8))
	spawn_max +=1
	print(spawn_max)
