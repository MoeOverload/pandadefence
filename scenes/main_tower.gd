extends Node2D

var towerHealth = 50




#detect enemy
func _on_area_2d_body_entered(body:Node2D):
	#check for enemy
	if body.is_in_group("Enemy"):
		#subtract Tower Health
		towerHealth-=1
		print(towerHealth)