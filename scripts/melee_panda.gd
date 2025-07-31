extends CharacterBody2D
#refernce to the enemy
@onready var nav =  $NavigationAgent2D

var enemy : CharacterBody2D 
#refernce to the home area
var home_area : Vector2
var max_distance_from_home := 200

#panda
var pandaHealth = 10
var move_speed = 100
var accel = 7
signal panda_attack_attempt(damage_amount)
var is_attacked = false
var dmgRecieved
var can_attack = true
var is_attacking = false




#state options
enum State {

	IDLE,
	CHASE,
	ATTACK,
	RETURN_HOME,
	DAMAGED,
	DEAD
}


#set current state
@onready var current_state =  State.IDLE
func _ready():
	home_area = get_parent().global_position
	
	

func _physics_process(delta: float) -> void:
	#print(current_state,"  " , " health: ",pandaHealth)
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
		State.DAMAGED:
			handle_damaged(delta)
		State.DEAD:
			handle_death(delta)



#thinking through the  logic of all this i was lost in the sauce
#all we need is a single area to check distance to from

#on-area-entered if distance to enemy is greater than x chase
#if distance is less than x attack


#then i can use a signal fromthe enemy to check if the attack lands 
#if distance to enemy is less than y and signal is-attacking 
#take damage 
func _on_attack_recieved(damage: int):
	is_attacked = true
	dmgRecieved = damage


func _on_detection_area_body_entered(body:Node2D) -> void:
	#check if the body is in group
	if body.is_in_group("Enemy"):
		
		#assign the body as a target
		enemy = body
		if not enemy.is_connected("enemyAttackAttempt", Callable(self, "_on_attack_recieved")):
			enemy.connect("enemyAttackAttempt", Callable(self, "_on_attack_recieved"))
		#check if enemy is within =chasing distance
		var dist = global_position.distance_to(enemy.global_position)
		if dist < 40:
			if is_attacking == false and is_attacked == false:
			#change state
				current_state = State.ATTACK
			elif is_attacked == true:
				current_state = State.DAMAGED
		else:
			#change state 
			current_state  = State.CHASE
		
		




#check if the enemy leaves area or dies
func _on_detection_area_body_exited(body:Node2D) -> void:
	if body.is_in_group("Enemy"):
		#reset target to null 
		enemy = null  
		#change state
		current_state = State.RETURN_HOME

func handle_chase(delta):
		nav.target_position = enemy.global_position
		#update direction toward enemy
		var next_position = nav.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		if direction.x < 0:
			$animatedSprite2D.flip_h = true
		else:
			$animatedSprite2D.flip_h = false
		if distance_check():
			current_state = State.RETURN_HOME
		velocity = velocity.lerp(direction * move_speed , accel * delta)
		$animatedSprite2D.play('walking')
		move_and_slide()


func handle_attack(_delta):
	if not enemy or not is_instance_valid(enemy):
		current_state = State.RETURN_HOME
		return
	var direction = (enemy.global_position - global_position).normalized()
	if direction.x < 0:
		$animatedSprite2D.flip_h = true
	else: 
		$animatedSprite2D.flip_h = false
	if can_attack:
		can_attack = false
		var rDamage = randf_range(1,5)
		emit_signal("panda_attack_attempt",rDamage)
		$attckcooldown.start()
		$animatedSprite2D.play('attacking')
		#update direction toward enemy
	velocity = Vector2.ZERO
	move_and_slide()



func handle_idle(_delta):
	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	if direction.x < 0:
		$animatedSprite2D.flip_h = true
	else:	
		$animatedSprite2D.flip_h = false
	if distance_check():
		current_state = State.RETURN_HOME
	velocity=Vector2.ZERO
	$animatedSprite2D.play('idle')
	move_and_slide()



func handle_damaged(_delta):
	
	pandaHealth -= dmgRecieved
	if pandaHealth <= 0:
		current_state = State.DEAD
	#TODO IMPLEMENT KNOCKBACK FUNCTION





func handle_death(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
	
	queue_free()





func _on_attckcooldown_timeout() -> void:
	can_attack = true





func distance_check():
	var distance = global_position.distance_to(home_area)
	return distance > max_distance_from_home







func handle_return(delta):
	nav.target_position = home_area  # always reset target position

	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()

	if direction.x < 0:
		$animatedSprite2D.flip_h = true
	else:	
		$animatedSprite2D.flip_h = false

	if global_position.distance_to(home_area) < 40:  # close enough
		velocity = Vector2.ZERO
		current_state = State.IDLE
	else:
		velocity = velocity.lerp(direction * move_speed , accel * delta)

	move_and_slide()
