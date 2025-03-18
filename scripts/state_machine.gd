class_name StateMachine
extends Node2D

## the current state
var current_state: State

## the starting state
@export var starting_state: State

## initialize the state
func init() -> void: change_state(starting_state)


## handles frames for each state
func process_frame(delta: float) -> void: 
	var new_state: State = current_state.process_frame(delta) 
	if new_state: change_state(new_state)

## handles player input for each state
func process_input(event: InputEvent) -> void: 
	var new_state: State = current_state.process_input(event) 
	if new_state: change_state(new_state)

## handles the physics for each state
func process_physics(delta: float) -> void: 
	var new_state: State = current_state.process_physics(delta) 
	if new_state: change_state(new_state) 

## handles when a state changes
func change_state(new_state: State) -> void: 
	if current_state: current_state.exit()
	current_state = new_state
	current_state.enter()
