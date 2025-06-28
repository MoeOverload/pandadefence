extends CharacterBody2D
#refernce to the enemy
var enemy : CharacterBody2D 
#refernce to the home area
@export var home_area: Node2D

#panda
var pandaHealth = 10
var move_speed = 100
var accel = 7


#state options
enum State {

	IDLE,
	CHASE,
	ATTACK,
	RETURN_HOME,
	DEAD
}
#set current state
@onready var current_state =  State.IDLE
func _ready() -> void:
	#wait for scene to load
	await get_tree().process_frame
func _physics_process(delta: float) -> void:
	print('home is at', home_area.global_position)
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

	
#check if enemy is within =chasing distance
func _on_enemy_detection_area_body_entered(body:Node2D) -> void:
	#check if body is enemy
	if body.is_in_group("Enemy"):
		print('chase')
		#assign the body as a target
		enemy = body
		#change state 
		current_state  = State.CHASE
#check if panda enters the home area
func _on_home_checker_area_entered(area: Area2D) -> void:
	if area == home_area:

		current_state = State.IDLE

#check if panda left the home area
func _on_home_checker_area_exited(area: Area2D) -> void:
# THIS IS BROKEN PROBABLY
	if area == home_area:
		if !enemy:
			current_state= State.RETURN_HOME
		else:
			current_state = State.CHASE
	else:
		current_state= State.IDLE





#check if the enemy leaves area or dies
func _on_enemy_detection_area_body_exited(body:Node2D) -> void:
	if body == enemy:
		#reset target to null 
		enemy = null 
		#change state
		current_state = State.RETURN_HOME

func _on_kill_zone_body_entered(body:Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemy = body
		current_state = State.DEAD

func handle_idle(_delta):
	velocity = Vector2.ZERO
	move_and_slide()

func handle_chase(delta):
	#if enemy is detected
	if enemy:
		#update direction toward enemy
		var direction = (enemy.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * move_speed , accel * delta)
	else:
		# reset the state
		current_state = State.RETURN_HOME
	
	move_and_slide()


func handle_attack(_delta):
	#TODO ADD THE ATTACK LOGIC
	velocity = Vector2.ZERO
	move_and_slide()

func handle_return(delta):
	#if home area is detected
	if home_area:
		#set direction towards home
		var direction = (home_area.global_position - global_position).normalized()
		#check distance to home
		if direction.length() == 0:
			velocity = Vector2.ZERO
		else:
			velocity = velocity.lerp(direction * move_speed , accel * delta)
	else:
		current_state = State.IDLE
	move_and_slide()

func handle_death(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
	if pandaHealth <= 0:
		queue_free()
