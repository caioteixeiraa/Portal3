extends KinematicBody

# Camera control variables
var camera_angle = 0
var mouse_sensitivity = 0.3

# Player movement variables
var velocity = Vector3()
var direction = Vector3()


# flying vars
const FLY_MAX_SPEED = 40
const FLY_ACCEL = 4

# walking vars
var gravity = -9.8 * 3
const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 50
const ACCEL = 2
const DEACCEL = 6

# jumping
const JUMP_VERTICAL_SPEED = 20


# Boolean value to decide if the player is flying or walking
var is_flying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_flight"):
		is_flying = !is_flying
	if (is_flying): fly(delta)
	else: walk(delta)


func walk(delta):
	# reset player's direction
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $PlayerHead/Camera.get_camera_transform().basis
	
	# check input then change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.x.rotated(Vector3(0, 1, 0), -PI/2)
	if Input.is_action_pressed("move_backward"):
		direction += aim.x.rotated(Vector3(0, 1, 0), -PI/2)
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
			
	direction = direction.normalized()
	
	velocity.y += gravity * delta
	var temp_velocity = velocity
	
	temp_velocity.y = 0
	
	var speed
	if (Input.is_action_pressed("run")):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
		
	# where to go when at max speed
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	# calculate a the distance to go in this frame
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	#move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VERTICAL_SPEED

func _input(event):
	# Camera control input
	if event is InputEventMouseMotion:
		$PlayerHead.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))	
		var change = -event.relative.y * mouse_sensitivity
		var new_camera_angle = change + camera_angle
		if (new_camera_angle < 90 and new_camera_angle > -90):
			$PlayerHead/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		else:
			if (new_camera_angle > 90):
				$PlayerHead/Camera.rotate_x(deg2rad(90 - camera_angle))
				camera_angle = 90
			if (new_camera_angle < -90):
				$PlayerHead/Camera.rotate_x(deg2rad(-90 - camera_angle))
				camera_angle = -90


func fly(delta):
	# reset player's direction
	direction = Vector3()
	
	# get the rotation of the camera
	var aim = $PlayerHead/Camera.get_camera_transform().basis
	
	# check input then change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
			
	direction = direction.normalized()
	
	# where player would go if he is at max speed
	var target = direction * FLY_MAX_SPEED
	
	# calculate the speed to run on this frame
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
	# move
	move_and_slide(velocity)
	
