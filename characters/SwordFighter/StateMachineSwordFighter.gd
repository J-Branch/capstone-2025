extends StateMachine

@onready var id = get_parent().id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_state('STAND')
	add_state('JUMP')
	add_state('DASH')
	add_state('RUN')
	call_deferred("set_state", states.STAND)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	# Used so that the character can basically float around on the map
	parent.move_and_slide_with_snap(parent.velocity*2, Vector2.ZERO, Vector2.UP)
	match state:
		states.STAND:
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.RUN
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.RUN
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x -= parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION
				parent.velocity.x = clampf(parent.velocity.x, parent.velocity.x, 0)
		states.JUMP:
			pass
		states.DASH:
			if parent.frame >= parent.dash_duration-1:
				return states.Stand
		states.RUN:
			if Input.get_action_strength("right_%s" % id) == 1:
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = parent.RUNSPEED
			if Input.get_action_strength("left_%s" % id) == 1:
				if parent.velocity.x < 0:
					parent._frame()
				parent.velocity.x = -parent.RUNSPEED
	
func enter_state(new_state, old_state):
	pass
	
func exit_state(old_state, new_state):
	pass 
	
func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
