extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var character_body_2d: CharacterBody2D = $"."
@onready var hitbox_area: Area2D = $hitboxArea
@onready var health_bar: Node2D = $Camera2D/HealthBar

signal healthChanged

var double_jump = true
var maxHealth = 20
var health = 20
var alive = true
const SPEED = 200
const JUMP_VELOCITY = -600
var side = false

@onready var attacking_animation: AnimationPlayer = $attackingAnimation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var attacking = false

func _process(delta: float) -> void:
	if alive:
		if Input.is_action_just_pressed("attack"):
			attack()
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
		else: 
			velocity.x = 0
		if !attacking:
			if velocity.x:
				animated_sprite_2d.flip_h = side
				if velocity.x < 0:
					side = true
					hitbox_area.position.x=-47.75
				else: 
					side = false
					hitbox_area.position.x=40.75
					
					
				
				if is_on_floor(): 
					animated_sprite_2d.play("run")
				else: 
					animated_sprite_2d.play("jump")
			else:
				if is_on_floor():
					animated_sprite_2d.play("idle")
				else:
					if velocity.y < 0:
						animated_sprite_2d.play("jump")
					else:
						animated_sprite_2d.play("fall")
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			double_jump = true
			velocity.y = JUMP_VELOCITY
			
		if Input.is_action_just_pressed("jump") and !is_on_floor() and double_jump:
			double_jump = false
			velocity.y = JUMP_VELOCITY
		
		if not is_on_floor():
			velocity += get_gravity() * delta
	else:
		velocity.x = 0
		animated_sprite_2d.play("die")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
			velocity += get_gravity() * delta
	move_and_slide()
	
		
func attack():
	var overlapping_objects = hitbox_area.get_overlapping_areas()
	
	for area in overlapping_objects:
		var parent = area.get_parent().get_parent()
		parent.take_damage(side)
		
	
	attacking = true
	animated_sprite_2d.play("attack")
	attacking_animation.play("attack")



func take_damage(damage):
	health -= damage
	animation_player.play("take_damage")
	print("Ninja health: " , health)
	if health==0:
		print("Ninja Died")
		player_dead()
	healthChanged.emit()
		
func player_dead():
	alive = false
	await animated_sprite_2d.animation_finished
	get_tree().reload_current_scene()
	
