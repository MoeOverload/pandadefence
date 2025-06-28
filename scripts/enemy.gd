extends CharacterBody2D
# target
@export var target: Node2D
#nav agent
@onready var nav =  $NavigationAgent2D

#export the speed variable
@export var move_speed = 150
var accel = 7 
func _ready():
	#wait for scene to load
	await get_tree().process_frame
	#set direction to target
	nav.target_position = target.global_position

func _physics_process(delta):
	#check if finished moving
	if nav.is_navigation_finished():
		velocity=Vector2.ZERO
		return
	#set next position
	var next_position = nav.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	velocity = velocity.lerp(direction * move_speed , accel * delta)
	move_and_slide()