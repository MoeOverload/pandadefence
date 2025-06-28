extends Node2D
@export var meleePanda: PackedScene
var home_area: Node2D


var spawn_max = 0

func _ready():
	#set the spawners global position to its parents global position
	global_position = get_parent().global_position
	#wait for first frame 
	await get_tree().process_frame
	
	#start timer
	$pandaSpawnTimer.start()

	
func _on_panda_spawn_timer_timeout() -> void:
	
	if  spawn_max <= 2:
		spawn_panda() 


func spawn_panda():
	#wait again
	await get_tree().process_frame
	#create a child panda 
	var new_panda = meleePanda.instantiate()
	
	add_child(new_panda)

	
	#set the home area and global position
	new_panda.home_area = get_node("home")
	new_panda.global_position = global_position
	spawn_max +=1
