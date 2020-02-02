extends Node2D
class_name Projectile

export var damage: float
export var lifetime: float
export var speed: float

var starting_velocity: Vector2
var team: int

var _time_lived: float

func _on_area_entered(area: Area2D):
  var _area_parent = area.get_parent()

  if _area_parent.has_method("do_damage"):
    _area_parent.do_damage(damage)
    queue_free()

func _physics_process(delta):
  translate((Vector2(1, 0).rotated(rotation) * speed * delta) + starting_velocity)

func _process(delta):
  _time_lived += delta

  if _time_lived >= lifetime:
    queue_free()

func _ready():
  var _area2d: Area2D = $Area2D

  _area2d.set_collision_layer_bit(team, true)
  _area2d.set_collision_mask_bit(team, false)

  _area2d.connect("area_entered", self, "_on_area_entered")
