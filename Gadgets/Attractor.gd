extends Node2D


export var texture: Texture
onready var radius = $Area2D/CollisionShape2D.shape.radius
var strength = 0
var strength_decay = 0.0001
	

func _process(delta):
	strength = clamp(strength - strength_decay, 0, INF)
	update()


func _draw():
	draw_texture(texture, Vector2.ZERO, Color.red.linear_interpolate(Color.green, strength))


func _on_Area2D_body_entered(body: PhysicsBody2D):
	print((body.position - position).length() < radius * strength)


# TODO Depending on static noise / might need a setting 
const MIN_LOUDNESS_TRESHOLD = 0.1
func _on_MicrophoneInput_loudness_available(loudness):
	if loudness > strength:
		strength = loudness
	
