extends Node2D
@export var enemy: PackedScene
var wave_max = 0
func _ready():
	$spawnTimer.start()




func _on_spawn_timer_timeout():
	if wave_max !=1:

		spawnEnemy()
	
func spawnEnemy():
	var new_enemy = enemy.instantiate()
	var x = 1424
	var y = 112

	new_enemy.position = Vector2(x,y)
	new_enemy.target = get_parent().get_node("mainTower")
	add_child(new_enemy)
	wave_max +=1
