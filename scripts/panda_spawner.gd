extends Node2D
@export var meleePanda: PackedScene

var spawn_max = 4
var numOfSpawned = 0
func _ready():
	$pandaSpawnTimer.start()

func _on_panda_spawn_timer_timeout() -> void:
	
	if numOfSpawned != spawn_max:
		spawn_panda() 


func spawn_panda():
	var new_panda = meleePanda.instantiate()
	
	new_panda.position = self.position
	add_child(new_panda)
	numOfSpawned +=1
