extends StateMachine
# TRANSFORM VARS FOR TESTING
var cooldown_time = 1.0
var time_since_last_ex = 0.0
var transform = 0
var just_jumped = false


@onready var id = get_parent().id


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NORMAL STATES
	add_state('STAND')
	add_state('DASH')
	add_state('AIRDASH')
	add_state('RUN')
	add_state('AIR')
	add_state('LANDING')
	add_state('GROUND_ATTACK')
	add_state('B_DOWN')
	add_state('B_SIDE')
	add_state('B_NEUTRAL')
	add_state('AIR_ATTACK')
	add_state('A_DOWN')
	add_state('A_NEUTRAL')
	add_state('A_SIDE')
	# TRANSFORMED STATES
	add_state('T_B_DOWN')
	add_state('T_B_SIDE')
	add_state('T_B_NEUTRAL')
	add_state('T_A_DOWN')
	add_state('T_A_NEUTRAL')
	add_state('T_A_SIDE')
	# HITFREEZE STATE
	add_state('HITFREEZE')
	# HITSTUN STATE
	add_state('HITSTUN')
	call_deferred("set_state", states.STAND)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
	
func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	#if parent.regrab > 0:
		#parent.regrab -= 1
	#parent._hit_pause(delta)

func get_transition(delta):
	parent.set_velocity(parent.velocity)
	parent.set_up_direction(Vector2.UP)
	parent.move_and_slide()
	
	# FOR TRANSFORM TESTING
	time_since_last_ex += delta
	if time_since_last_ex > cooldown_time and Input.is_action_pressed('transformation%s' % id):
		_transform()
		time_since_last_ex = 0.0
	
	if Landing() == true:
		parent._frame()
		return states.LANDING

	if Falling() == true:
		return states.AIR

	if Input.is_action_pressed('attack%s' % id) and Ground():
		parent._frame()
		return states.GROUND_ATTACK
	
	
	match state:
		states.STAND:
			parent.reset_jump()
			if Input.is_action_pressed("move_right%s" %id):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.RUN
			if Input.is_action_pressed("move_left%s" %id):
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.RUN
			if Input.is_action_pressed("jump%s" %id):
				parent.velocity.y = -parent.JUMPFORCE
				just_jumped = true
				parent._frame()
				return states.AIR
			if Input.is_action_pressed("dash%s" %id):
				parent._frame()
				return states.DASH
				# Slows the player down if player is in a stand state and is moving right
			if parent.velocity.x > 0:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
				# Slows the player down if the player is in a stand state and is moving left
			elif parent.velocity.x < 0:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
			return states.STAND
			
		states.AIR:
			AIRMOVEMENT()
			if Input.is_action_pressed("attack%s" %id):
				parent._frame()
				return states.AIR_ATTACK
			if Input.is_action_pressed("dash%s" %id):
				parent._frame()
				return states.AIRDASH
			# Code for double jump
			if Input.is_action_just_pressed("jump%s" %id) and parent.air_jump_num > 0:
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.air_jump_num -= 1
				if Input.is_action_pressed("move_left%s" %id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("move_right%s" %id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR
			return states.AIR
			
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				# Slows down moving to right
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				# Slows down moving to left
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION / 2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			# Landing animation is finished
			else:
				parent._frame()
				parent.lag_frames = 0
				parent.reset_jump()
				return states.STAND
				
		states.DASH:
			# 5 frames to decide which direction to go
			if parent.frame < 5:
				if Input.is_action_pressed("move_left%s" %id):
					parent.turn(true)
					parent.velocity.x = -parent.DASHSPEED
				if Input.is_action_pressed("move_right%s" %id):
					parent.turn(false)
					parent.velocity.x = parent.DASHSPEED
			# When you are in the dash state you cannot go into any other state
			# You must wait for the dash state to finish
			if parent.frame >= parent.dash_duration-1:
				return states.STAND
			else:
				return states.DASH
				
		states.AIRDASH:
			AIRMOVEMENT()
			if (parent.GroundL.is_colliding()) or parent.GroundR.is_colliding():
				parent.velocity.y = 0
				parent._frame()
				return states.STAND
			# 5 frames to decide which direction to go
			if parent.frame < 5:
				if Input.is_action_pressed("move_left%s" %id):
					parent.turn(true)
					parent.velocity.x = -parent.DASHSPEED
				if Input.is_action_pressed("move_right%s" %id):
					parent.turn(false)
					parent.velocity.x = parent.DASHSPEED
			# When you are in the dash state you cannot go into any other state
			# You must wait for the dash state to finish
			if parent.frame >= parent.dash_duration-1:
				return states.AIR
			else:
				return states.AIRDASH
				
		states.RUN:
			if Input.is_action_pressed("jump%s" %id):
				parent.velocity.y = -parent.JUMPFORCE
				just_jumped = true
				parent._frame()
				return states.AIR
			if Input.is_action_pressed("dash%s" %id):
				parent._frame()
				return states.DASH
			if Input.is_action_pressed("move_right%s"%id):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = parent.RUNSPEED
				parent.turn(false)
				return states.RUN
			if Input.is_action_pressed("move_left%s" %id):
				if parent.velocity.x < 0:
					parent._frame() 
				parent.velocity.x = -parent.RUNSPEED
				parent.turn(true)
				return states.RUN
			# If I am not hitting anything else, state should return to stand
			else:
				return states.STAND
				
		states.GROUND_ATTACK:
			if Input.is_action_pressed('move_down%s' %id) and transform == 0:
				parent._frame()
				return states.B_DOWN
			if Input.is_action_pressed('move_down%s' %id) and transform == 1:
				parent._frame()
				return states.T_B_DOWN
			if Input.is_action_pressed('move_left%s' %id) and transform == 0:
				parent.turn(true)
				parent._frame()
				return states.B_SIDE
			if Input.is_action_pressed('move_left%s' %id) and transform == 1:
				parent.turn(true)
				parent._frame()
				return states.T_B_SIDE
			if Input.is_action_pressed('move_right%s' %id) and transform == 0:
				parent.turn(false)
				parent._frame()
				return states.B_SIDE
			if Input.is_action_pressed('move_right%s' %id) and transform == 1:
				parent.turn(false)
				parent._frame()
				return states.T_B_SIDE
			else:
				if transform == 0:
					parent._frame()
					return states.B_NEUTRAL
				else:
					parent._frame()
					return states.T_B_NEUTRAL
			
		states.B_DOWN:
			if parent.frame == 0:
				parent.B_DOWN()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.B_DOWN(): # If animation finished
				parent._frame()
				return states.STAND
				
		states.B_SIDE:
			if parent.frame == 0:
				parent.B_SIDE()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.B_SIDE():
				parent._frame()
				return states.STAND
				
		states.B_NEUTRAL:
			if parent.frame == 0:
				parent.B_NEUTRAL()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.B_NEUTRAL():
				parent._frame()
				return states.STAND
				
		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed('move_down%s' %id) and transform == 0:
				parent._frame()
				return states.A_DOWN
			if Input.is_action_pressed('move_down%s' %id) and transform == 1:
				parent._frame()
				return states.T_A_DOWN
			if Input.is_action_pressed('move_left%s' %id) and transform == 0:
				parent.turn(true)
				parent._frame()
				return states.A_SIDE
			if Input.is_action_pressed('move_left%s' %id) and transform == 1:
				parent.turn(true)
				parent._frame()
				return states.T_A_SIDE
			if Input.is_action_pressed('move_right%s' %id) and transform == 0:
				parent.turn(false)
				parent._frame()
				return states.A_SIDE
			if Input.is_action_pressed('move_right%s' %id) and transform == 1:
				parent.turn(false)
				parent._frame()
				return states.T_A_SIDE
			else:
				if transform == 0:
					parent._frame()
					return states.A_NEUTRAL
				else: 
					parent._frame()
					return states.T_A_NEUTRAL
				
		states.A_DOWN:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.A_DOWN()
			if parent.A_DOWN():
				return states.AIR
				
		states.A_SIDE:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.A_SIDE()
			if parent.A_SIDE():
				return states.AIR
				
		states.A_NEUTRAL:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.A_NEUTRAL()
			if parent.A_NEUTRAL():
				return states.AIR
				
		# TRANSFORMED STATES
		# Ground Attacks
		states.T_B_DOWN:
			if parent.frame == 0:
				parent.T_B_DOWN()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.T_B_DOWN(): # If animation finished
				parent._frame()
				return states.STAND
		
		states.T_B_SIDE:
			if parent.frame == 0:
				parent.T_B_SIDE()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.T_B_SIDE():
				parent._frame()
				return states.STAND
			
		states.T_B_NEUTRAL:
			if parent.frame == 0:
				parent.T_B_NEUTRAL()
				pass
			if parent.frame >= 1:
				if parent.velocity.x < 0:
					parent.velocity.x += parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x > 0:
					parent.velocity.x -= parent.TRACTION * 3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			if parent.T_B_NEUTRAL():
				parent._frame()
				return states.STAND
			
		# Air Attacks
		states.T_A_DOWN:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.T_A_DOWN()
			if parent.T_A_DOWN():
				return states.AIR

		states.T_A_SIDE:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.T_A_SIDE()
			if parent.T_A_SIDE():
				return states.AIR

		states.T_A_NEUTRAL:
			AIRMOVEMENT()
			if parent.frame == 0:
				parent.T_A_NEUTRAL()
			if parent.T_A_NEUTRAL():
				return states.AIR

		states.HITFREEZE:
			if parent.freezeframes == 0:
				parent._frame()
				parent.velocity.x = kbx 
				parent.velocity.y = kby 
				parent.hdecay = hd 
				parent.vdecay = vd 
				return states.HITSTUN
			parent.position = pos

		states.HITSTUN:
			if parent.knockback >= 3: # If knockback is more than a certain amount you can bounce of the ground
				var bounce = parent.move_and_collide(parent.velocity * delta)
				if parent.is_on_wall() and not parent.is_on_floor():
					parent.velocity.x = kbx - parent.velocity.x
					parent.velocity = parent.velocity.bounce(parent.get_wall_normal()) * 0.8
					parent.hdecay *= -1 
					parent.hitstun = round(parent.hitstun * 0.8)
				if parent.is_on_floor():
					parent.velocity.y = kby - parent.velocity.y
					parent.velocity = parent.velocity.bounce(parent.get_floor_normal()) * 0.8
					parent.hitstun = round(parent.hitstun * 0.8)
				# NOT WORKING - SLIDING ON FLOOR AND STAYING IN HITSTUN STATE
				#if bounce:
					#parent.velocity = parent.velocity.bounce(bounce.get_normal()) * 0.8
					#parent.hitstun = round(parent.hitstun * 0.8)
			if parent.velocity.y < 0:
				parent.velocity.y += parent.vdecay*.05 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y, parent.velocity.y, 0)
			if parent.velocity.x < 0:
				parent.velocity.x += (parent.hdecay)*.04 * -1 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.hdecay*0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				
			if parent.frame == parent.hitstun:
					parent._frame()
					return states.AIR
			elif parent.frame > 60 * 5:
				return states.AIR

func Landing():
	if state_includes([states.AIR, states.AIR_ATTACK, states.A_DOWN, states.A_SIDE, states.A_NEUTRAL, states.T_A_DOWN, states.T_A_SIDE, states.T_A_NEUTRAL]):
		if (parent.GroundL.is_colliding()) or parent.GroundR.is_colliding():
			parent.frame = 0
			parent.velocity.y = 0
			return true

# Checks to see if character is in the air
func AIREAL():
	if state_includes([states.AIR, states.AIR_ATTACK, states.A_DOWN, states.A_SIDE, states.A_NEUTRAL, states.T_A_DOWN, states.T_A_SIDE, states.T_A_NEUTRAL]):
		if (parent.GroundL.is_colliding()) or parent.GroundR.is_colliding():
			return false
		else:
			return true

# Checks to see if character is on the ground
func Ground():
	if state_includes([states.STAND, states.RUN]):
		return true

func Falling():
	if state_includes([states.STAND, states.LANDING, states.RUN]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
				return true

func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			if transform == 0:
				parent.play_animation('Idle')
				parent.states.text = str('Idle')
			else:
				parent.play_animation('TIdle')
				parent.states.text = str('T_Idle')
		states.RUN:
			if transform == 0:
				parent.play_animation('Run')
				parent.states.text = str('RUN')
			else:
				parent.play_animation('TRun')
				parent.states.text = str('T_Run')
		states.AIR:
			if transform == 0:
				parent.play_animation('Jump')
				parent.states.text = str('Air')
			else: 
				parent.play_animation('TJump')
				parent.states.text = str('T_Air')
		states.DASH:
			if transform == 0:
				parent.play_animation('Dash')
				parent.states.text = str('Dash')
			else: 
				parent.play_animation('TDash')
				parent.states.text = str('T_Dash')
		states.AIRDASH:
			if transform == 0:
				parent.play_animation('Dash')
				parent.states.text = str("Air_Dash")
			else:
				parent.play_animation("TDash")
				parent.states.text = str("T_Air_Dash")
		states.LANDING:
			parent.states.text = str('Landing')
		states.GROUND_ATTACK:
			parent.states.text = str('Ground_Attack')
		states.B_DOWN:
			parent.play_animation('BDown')
			parent.states.text = str('B_Down')
		states.B_SIDE:
			parent.play_animation('BSide')
			parent.states.text = str('B_SIDE')
		states.B_NEUTRAL:
			parent.play_animation('BNeutral')
			parent.states.text = str('B_NEUTRAL')
		states.AIR_ATTACK:
			parent.states.text = str('Air_Attack')
		states.A_DOWN:
			parent.play_animation('ADown')
			parent.states.text = str("A_DOWN")
		states.A_SIDE:
			parent.play_animation('ASide')
			parent.states.text = str("A_SIDE")
		states.A_NEUTRAL:
			parent.play_animation('ANeutral')
			parent.states.text = str("A_NEUTRAL")
		states.T_B_DOWN:
			parent.play_animation('TBDown')
			parent.states.text = str("T_B_DOWN")
		states.T_B_SIDE:
			parent.play_animation('TBSide')
			parent.states.text = str("T_B_SIDE")
		states.T_B_NEUTRAL:
			parent.play_animation('TBNeutral')
			parent.states.text = str("T_B_NEUTRAL")
		states.T_A_DOWN:
			parent.play_animation('TADown')
			parent.states.text = str("T_A_DOWN")
		states.T_A_SIDE:
			parent.play_animation('TASide')
			parent.states.text = str("T_A_SIDE")
		states.T_A_NEUTRAL:
			parent.play_animation('TANeutral')
			parent.states.text = str("T_A_NEUTRAL")
		states.HITSTUN:
			if transform == 0:
				parent.play_animation('Hurt')
				parent.states.text = str("HitStun")
			if transform == 1:
				parent.play_animation('THurt')
				parent.states.text = str("HitStun")
		states.HITFREEZE:
			if transform == 0:
				parent.play_animation('Hurt')
				parent.states.text = str("HitFreeze")
			if transform == 1:
				parent.play_animation('THurt')
				parent.states.text = str("HitFreeze")
			

func AIRMOVEMENT():
	if just_jumped and parent.velocity.y == 0:
		parent.velocity.y = -parent.JUMPFORCE
		just_jumped = false
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
	# Slows the player down in the air if they are at max speed
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("move_left%s" %id):
				parent.velocity.x -= parent.AIR_ACCEL
		if parent.velocity.x < 0:
			if Input.is_action_pressed("move_right%s" %id):
				parent.velocity.x += parent.AIR_ACCEL
	# Speeds player up if he is below max speed
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("move_left%s" %id):
			parent.velocity.x -= parent.AIR_ACCEL
		if Input.is_action_pressed("move_right%s" %id):
			parent.velocity.x += parent.AIR_ACCEL
	# If the player is not pressing anything 
	if not Input.is_action_pressed("move_left%s" %id):
		if not Input.is_action_pressed("move_right%s" %id):
			if parent.velocity.x < 0:
				parent.velocity.x += parent.AIR_ACCEL / 5
			elif parent.velocity.x > 0: 
				parent.velocity.x -= parent.AIR_ACCEL / 5

# TESTING TRANSFORM
func _transform():
	if transform == 0:
		transform = 1
	else:
		transform = 0
func exit_state(old_state, new_state):
	pass 
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knockback):
	pos = parent.get_position()
	parent.freezeframes = duration
	kbx = knockback[0]
	kby = knockback[1]
	hd = knockback[2]
	vd = knockback[3]
