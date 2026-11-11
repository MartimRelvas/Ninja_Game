extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var hurt_animation: AnimationPlayer = $AnimatedSprite2D/hurtAnimation
@onready var die_animation: AnimationPlayer = $AnimatedSprite2D/dieAnimation
@onready var health_bar: ProgressBar = $HealthBar
@onready var hurtbox: Area2D = $AnimatedSprite2D/hurtbox

signal healthChanged

const SPEED = 90
const JUMP_VELOCITY = -150

var player_chase = false
var alive = true
var attacking = false

var player = null
var health
var damage = 5

func _ready() -> void:
	health=3
	health_bar.init_health(health)
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

func take_damage(side):
	health -= 1
	health_bar.health = health
	if health <= 0:
		kill_enemy()
	else:
		if(side):
			hurt_animation.play("hurt_left")
		else:
			hurt_animation.play("hurt_right")
	healthChanged.emit()

func kill_enemy():
	hurtbox.queue_free()
	alive = false
	animated_sprite_2d.play("die")
	die_animation.play("die")
	await die_animation.animation_finished
	queue_free()

func applyKnockbackLeft():
	velocity.y = JUMP_VELOCITY
	velocity.x = JUMP_VELOCITY
	
func applyKnockbackRight():
	velocity.y = JUMP_VELOCITY
	velocity.x = -JUMP_VELOCITY
	
func resetVel():
	velocity.y = 0
	velocity.x = 0

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attacking = true
		player = area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(damage)

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		attacking = false
