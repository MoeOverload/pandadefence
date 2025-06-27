extends CharacterBody2D
#refernce to the enemy
var target : CharacterBody2D 
var pandaHealth = 10
#state options
enum State {

	IDLE,
	CHASE,
	ATTACK,
	RETURN_HOME,
	DEAD
}
#set current state
var current_state: State =  State.IDLE

func _physics_process(delta: float) -> void:
	#match state 
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack(delta)
		State.RETURN_HOME:
			handle_return(delta)
		State.DEAD:
			handle_death(delta)

#check if enemy is within attacking distance
func _on_enemy_detection_area_body_entered(body:Node2D) -> void:
	#check if body is enemy
	if body.is_in_group("Enemy"):
		#assign the body as a target
		target = body
		#change state 
		current_state  = State.ATTACK



#check if the enemy leaves area or dies
func _on_enemy_detection_area_body_exited(body:Node2D) -> void:
	if body == target:
		#reset target to null 
		target = null 
		#change state
		current_state = State.RETURN_HOME

func _on_kill_zone_body_entered(body:Node2D) -> void:
	if body.is_in_group("Enemy"):
		current_state = State.DEAD

func handle_idle(delta):
	pass
func handle_chase(delta):
	pass

func handle_attack(delta):
	pass

func handle_return(delta):
	pass

func handle_death(_delta):
	if pandaHealth == 0:
		self.queue_free()


