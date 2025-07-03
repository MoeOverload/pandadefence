extends CharacterBody2D
# target
@export var tower: Node2D
var target
#ref to panda
@export var panda : CharacterBody2D
#nav agent
@onready var nav =  $NavigationAgent2D
var can_attack = true
var is_attacking = false
#export the speed variable
@export var move_speed = 100
var accel = 7 
var monkeyHealth = 10
var is_attacked = false
var dmgRecieved
#attack signal
signal enemyAttackAttempt(damage_amount)
#State Machine
enum State{
	IDLE,
	ATTACK,
	FIND,
	DAMAGED,
	DEAD
}
@onready var current_state = State.IDLE


func _ready():
	
	#wait for scene to load
	await get_tree().process_frame
	#set direction to target
	nav.target_position = target.global_position


func _physics_process(delta):
	
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.ATTACK:
			handle_attack(delta)
		State.FIND:
			handle_find(delta)
		State.DAMAGED:
			handle_damaged(delta)
		State.DEAD:
			handle_death(delta)

#so each state SHOULD UPDATE 
#THE NAV DIRECTION AND TARGET POSITION
func _on_attack_recieved(damage):
	is_attacked = true
	dmgRecieved = damage

func _on_panda_checker_body_entered(body:Node2D) -> void:
	if body.is_in_group('meleePanda'):
		panda = body 
		if panda.has_signal("panda_attack_attempt"):
			panda.connect("panda_attack_attempt", Callable(self , "_on_attack_recieved"))
		else:
			print('panda_attack_attempt signal missing')	
		target = panda
		#update state
		if is_attacking == false and is_attacked == false:
			current_state = State.ATTACK
		elif is_attacked == true:
			current_state = State.DAMAGED 
		else:
			current_state = State.IDLE
	else:
		current_state = State.FIND





func handle_idle(_delta):
	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	if nav.is_navigation_finished():
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:	
			$AnimatedSprite2D.flip_h = false
		velocity=Vector2.ZERO
		#play idle anim
		move_and_slide()
		
func handle_attack(_delta):
	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	#flip sprite based on driection
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	if can_attack == true:
		is_attacking =true 
		velocity = Vector2.ZERO
		var rDamage = randi_range(1,5)
		emit_signal("enemyAttackAttempt",rDamage)
		#play atack anim
		move_and_slide()
		#set state to idle quick
		current_state = State.IDLE
		$attackcooldown.start()
		is_attacking = false	
		can_attack =false

func handle_find(delta):
	target= tower
	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	#flip sprite based on driection
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	velocity = velocity.lerp(direction * move_speed , accel * delta)
	$AnimatedSprite2D.play("walking")
	
	move_and_slide()
func handle_damaged(_delta):
	monkeyHealth -= dmgRecieved
	if monkeyHealth <= 0:
		current_state = State.DEAD
	#TODO IMPLEMENT KNOCKBACK FUNCTION
func handle_death(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
	
	queue_free()
func _on_attackcooldown_timeout() -> void:
	can_attack = true
