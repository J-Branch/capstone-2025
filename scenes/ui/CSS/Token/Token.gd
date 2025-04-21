extends RigidBody2D

# Is the token picked up
var picked = false

# Token ID 
@export var id = 0

var rest_point
var rest_positions
var is_colliding = false
@export var min_dist = 100
@export var text_color: Color:
	get:
		return text_color
	set(value):
		text_color = value
		$"Token Area/Label".modulate = text_color

func player_pos(): # Position of each token
	var pos
	match id:
		1:
			pos = Globals.css["Token_1_pos"]
			return pos
		2:
			pos = Globals.css["Token_2_pos"]
			return pos

func _ready():
	# Char_select are the char buttons
	rest_positions = get_tree().get_nodes_in_group("Char_select")
	# The resting point of each token
	rest_point = player_pos()
	print ("rest point is " + str(rest_point))
	# Text of Token is related to it's ID number
	$"Token Area/Label".text = ("P"+str(id))

func _physics_process(delta):
	# Change Global token's position to self's global position
	# Makes it so token will go to its previously left position when CSS scene opens again
	Globals.css["Token_%s_pos" %id] = self.global_position
	if picked == true:
		# Change self's position to the position of the hand that selected it
		global_position = get_node("../Hand_%s/Position2D" %id).global_position
	else:
		# Go from global pos to the next rest_point
		global_position = lerp(global_position, rest_point, 5*delta)

#This is used to have the token snap to a character button
func auto_snap():
	#If self is less than a certain distance from a character button, it then gravitates to the button
	for child in rest_positions:
		var distance = self.global_position.distance_to(child.get_node("point").global_position)
		if distance < min_dist:
			rest_point = child.get_node("point").global_position
	# If token isn't selected, it then checks for character button, and if it's there the button will be pressed
	if picked == false:
		var dec = $"Token Area".get_overlapping_areas()
		for b in dec:
			if b.name == "CharacterArea":
				b.get_parent().emit_signal("button_down")
