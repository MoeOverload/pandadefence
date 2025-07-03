extends CharacterBody2D
#refernce to the enemy
var enemy : CharacterBody2D 
#refernce to the home area
@export var home_area: Node2D
var dist
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
func _ready() -> void:
	
	#wait for scene to load
	await get_tree().process_frame
	
func _process(_delta: float) -> void:
	if enemy :
		dist = global_position.distance_to(enemy.global_position)
		print(current_state,"  ", dist , " health: ",pandaHealth)
		#check if enemy is within =chasing distance
		if dist < 40 :
			if is_attacking == false and is_attacked == false:
				#change state
				current_state = State.ATTACK
			elif is_attacked == true:
				current_state = State.DAMAGED
		
		else:
				#change state 
				current_state  = State.CHASE	
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
		if enemy:
			enemy.connect("enemyAttackAttempt", Callable(self, "_on_attack_recieved"))
		else:
			print("enemyAttackAttempt signal missing on enemy")
		
		
			
#check if the enemy leaves area or dies
func _on_detection_area_body_exited(body:Node2D) -> void:
	if body == enemy:
		#reset target to null 
		enemy = null 
		#change state
		current_state = State.IDLE



func handle_chase(delta):
		#update direction toward enemy
		var direction = (enemy.global_position - global_position).normalized()

		if direction.x < 0:
			$animatedSprite2D.flip_h = true
		else:
			$animatedSprite2D.flip_h = false
		velocity = velocity.lerp(direction * move_speed , accel * delta)
		$animatedSprite2D.play('walking')
		move_and_slide()

func handle_attack(_delta):
	var direction = (enemy.global_position - global_position).normalized()
	if direction.x < 0:
		$animatedSprite2D.flip_h = true
	else: 
		$animatedSprite2D.flip_h = false
	if can_attack:
		var rDamage = randf_range(1,5)
		emit_signal("panda_attack_attempt",rDamage)
		#update direction toward enemy
	
		velocity = Vector2.ZERO
		$attckcooldown.start()
		$animatedSprite2D.play('attacking')
		move_and_slide()

func handle_idle(_delta):
	velocity = Vector2.ZERO
	$animatedSprite2D.play('idle')
	move_and_slide()

func handle_damaged(_delta):
	
	pandaHealth -= dmgRecieved
	if pandaHealth <=0:
		current_state = State.DEAD
	#TODO IMPLEMENT KNOCKBACK FUNCTION
func handle_death(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
	
	queue_free()

func _on_attckcooldown_timeout() -> void:
	can_attack = true


#check if panda enters the home area
func _on_detection_area_area_entered(area:Area2D) -> void:
	if area.is_in_group("home"):
		
		if enemy == null:
			current_state = State.IDLE




#check if panda left the home area
func _on_detection_area_area_exited(area: Area2D) -> void:
# THIS IS BROKEN PROBABLY
	if area == home_area:
		if !enemy:
			current_state= State.RETURN_HOME
		else:
			current_state = State.CHASE
	else:
		current_state= State.IDLE


func handle_return(delta):
	#if home area is detected
	if not home_area:
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
