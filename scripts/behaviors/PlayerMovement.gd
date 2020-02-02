extends Node

onready var _parent = get_parent()

func short_angle_dist(from, to):
  var _max_angle = PI * 2
  var _difference = fmod(to - from, _max_angle)
  return fmod(2 * _difference, _max_angle) - _difference

func _physics_process(delta):
  var _global_mouse_position = _parent.get_global_mouse_position()
  var _rotation = _parent.global_rotation
  var _target_rotation = _parent.global_position.angle_to_point(_global_mouse_position) + PI

  var _queued_acceleration = Vector2(
    -Input.get_action_strength("player_move_left") + Input.get_action_strength("player_move_right"),
    Input.get_action_strength("player_move_down") + -Input.get_action_strength("player_move_up")).normalized()

  var _queued_angular_acceleration = 0

  if short_angle_dist(_rotation, _target_rotation) > 0:
    _queued_angular_acceleration = lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))
  else:
    _queued_angular_acceleration = -lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))

  _parent.queue_acceleration(_queued_acceleration)
  _parent.queue_angular_acceleration(_queued_angular_acceleration)
