extends Node

enum AI_STATES {IDLE, ATTACKING}

export var attack_range: float
export var move_range: float
export var team: int

onready var tree := get_tree()
onready var root := tree.get_root()

onready var _parent: RootShipNode = get_parent()

var _ai_state: int
var _target: RootShipNode

func short_angle_dist(from, to):
  var _max_angle = PI * 2
  var _difference = fmod(to - from, _max_angle)
  return fmod(2 * _difference, _max_angle) - _difference

func _find_target():
  var _root_ship_nodes = tree.get_nodes_in_group("RootShipNodes")

  for _ship in _root_ship_nodes:
    if _ship.team != team && !_ship.is_queued_for_deletion():
      _target = _ship
      _target.connect("root_ship_node_destroyed", self, "_on_root_ship_node_destroyed")
      print("target found")
      break

func _on_root_ship_node_destroyed():
  _target = null
  print("target destroyed")
  _find_target()

func _on_root_ship_node_team_set():
  team = _parent.team

func _process(_delta):
  if _target && _parent.global_position.distance_to(_target.global_position) <= attack_range:
    _ai_state = AI_STATES.ATTACKING
  else:
    _ai_state = AI_STATES.IDLE

  if _ai_state == AI_STATES.ATTACKING:
    var _rotation = _parent.global_rotation
    var _target_rotation = _parent.global_position.angle_to_point(_target.global_position) + PI

    _parent.emit_signal("weapon_set_look", _target.global_position)
    _parent.emit_signal("weapon_fire")

    var _queued_acceleration = Vector2(0, 0)
    if _parent.global_position.distance_to(_target.global_position) >= move_range:
      _queued_acceleration = Vector2(0, -1)

    var _queued_angular_acceleration = 0
    if short_angle_dist(_rotation, _target_rotation) > 0:
      _queued_angular_acceleration = lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))
    else:
      _queued_angular_acceleration = -lerp(0, 1, clamp(abs(short_angle_dist(_rotation, _target_rotation)) / (PI / 4), 0, 1))

    _parent.queue_acceleration(_queued_acceleration)
    _parent.queue_angular_acceleration(_queued_angular_acceleration)

  if _ai_state == AI_STATES.IDLE && !_target:
    _find_target()

func _ready():
  _parent.team = team

  _parent.connect("root_ship_node_team_set", self, "_on_root_ship_node_team_set")
