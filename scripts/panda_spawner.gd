extends Node2D
@export var meleePanda: PackedScene


var spawn_max = 0

func _ready():
	#set the spawners global position to its parents global position
	global_position = get_parent().global_position
	#wait for first frame 
	await get_tree().process_frame
	
	#start timer
	$pandaSpawnTimer.start()

	
func _on_panda_spawn_timer_timeout() -> void:
	
	if  spawn_max <= 4:
		spawn_panda() 


func spawn_panda():
	
	
	#create a child panda 
	var new_panda = meleePanda.instantiate()
	new_panda.home_area = get_node("home/home_area")
	add_child(new_panda)

	
	#set the home area and global position
	
	new_panda.global_position = get_parent().global_position
	spawn_max +=1
