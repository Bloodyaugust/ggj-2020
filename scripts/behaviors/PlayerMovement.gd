extends Node

onready var _parent = get_parent()

func _physics_process(delta):
  var _queued_acceleration = Vector2(
    -Input.get_action_strength("player_move_left") + Input.get_action_strength("player_move_right"),
    Input.get_action_strength("player_move_down") + -Input.get_action_strength("player_move_up"))
  var _queued_angular_acceleration = -Input.get_action_strength("player_rotate_counterclockwise") + Input.get_action_strength("player_rotate_clockwise")

  _parent.queue_acceleration(_queued_acceleration)
  _parent.queue_angular_acceleration(_queued_angular_acceleration)
