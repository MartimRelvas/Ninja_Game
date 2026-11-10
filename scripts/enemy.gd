extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var hurt_animation: AnimationPlayer = $AnimatedSprite2D/hurtAnimation
@onready var die_animation: AnimationPlayer = $AnimatedSprite2D/dieAnimation

const SPEED = 90
const JUMP_VELOCITY = -150

var player_chase = false
var alive = true
var attacking = false

var player = null
var health = 3
var damage = 5

func _ready() -> void:
	animated_sprite_2d.play("appear")
	await animated_sprite_2d.animation_finished
	
func _physics_process(delta: float) -> void:
	if alive:
		if player_chase and player:
			if !attacking:
				animated_sprite_2d.play("chase")
				var old_pos = player.position - position
				var side = player.position.x > position.x
				position += old_pos / SPEED
				animated_sprite_2d.flip_h = side
			else:
				animated_sprite_2d.play("attack")
		else:
			animated_sprite_2d.play("idle")
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_chase = false

func take_damage():
	health -= 1
	if health <= 0:
		kill_enemy()
	else:
		hurt_animation.play("hurt")

func kill_enemy():
	alive = false
	animated_sprite_2d.play("die")
	die_animation.play("die")
	await die_animation.animation_finished
	queue_free()

func applyKnockback():
	velocity.y = JUMP_VELOCITY
	
func resetVel():
	velocity.y = 0

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attacking = true
		player = area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(damage)

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attacking = false
