extends Node2D

export var max_distance_from_parent: float

onready var _parent: RootShipNode = get_parent()

func _physics_process(_delta):
  var _global_mouse_position = _parent.get_global_mouse_position()
  var _position = _parent.global_position

  global_position = (_position.direction_to(_global_mouse_position) * _position.distance_to(_global_mouse_position)).clamped(max_distance_from_parent) + _position
