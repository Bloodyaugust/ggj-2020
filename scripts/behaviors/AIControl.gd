extends Node

enum AI_STATES {IDLE, ATTACKING}

export var attack_range: float
export var move_range: float

onready var tree := get_tree()
onready var root := tree.get_root()

onready var _parent: RootShipNode = get_parent()
onready var _player: RootShipNode = tree.get_nodes_in_group("Player")[0]

var _ai_state: int

func short_angle_dist(from, to):
  var _max_angle = PI * 2
  var _difference = fmod(to - from, _max_angle)
  return fmod(2 * _difference, _max_angle) - _difference

func _process(_delta):
  if _parent.global_position.distance_to(_player.global_position) <= attack_range:
    _ai_state = AI_STATES.ATTACKING
  else:
    _ai_state = AI_STATES.IDLE

  if _ai_state == AI_STATES.ATTACKING:
    var _rotation = _parent.global_rotation
    var _target_rotation = _parent.global_position.angle_to_point(_player.global_position) + PI

    _parent.emit_signal("weapon_set_look", _player.global_position)
    _parent.emit_signal("weapon_fire")

    var _queued_acceleration = Vector2(0, 0)
    if _parent.global_position.distance_to(_player.global_position) >= move_range:
      _queued_acceleration = Vector2(0, -1)

    var _queued_angular_acceleration = 0
    if short_angle_dist(_rotation, _target_rotation) > 0:
      _queued_angular_acceleration = lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))
    else:
      _queued_angular_acceleration = -lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))

    _parent.queue_acceleration(_queued_acceleration)
    _parent.queue_angular_acceleration(_queued_angular_acceleration)
