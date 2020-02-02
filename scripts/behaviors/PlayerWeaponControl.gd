extends Node

onready var _parent: RootShipNode = get_parent()

func _process(_delta):
  var _mouse_position = _parent.get_global_mouse_position()

  _parent.emit_signal("weapon_set_look", _mouse_position)

  if Input.is_action_pressed("player_fire"):
    _parent.emit_signal("weapon_fire")
