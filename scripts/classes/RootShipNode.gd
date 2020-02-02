extends Node2D
class_name RootShipNode

signal node_find_connections

export var angular_friction: float
export var base_acceleration: float
export var friction: float
export var base_angular_acceleration: float
export var max_angular_velocity: float
export var max_velocity: float

onready var tree := get_tree()
onready var root := tree.get_root()
onready var instance_id = get_instance_id()
onready var navigation_map = AStar2D.new()

var connected_nodes := {} # References to nodes connected to me
var node_connections := {} # Dictionary of arrays, single node to many

var _angular_velocity: float
var _queued_acceleration: Vector2
var _queued_angular_acceleration: float
var _velocity: Vector2

func get_class():
  return "RootShipNode"

func add_connected_node(connecting_node, connecting_node_connections):
  var _node_global_position = connecting_node.global_position

  connected_nodes[connecting_node.get_instance_id()] = connecting_node
  node_connections[connecting_node.get_instance_id()] = connecting_node_connections

  connecting_node.connect("node_destroyed", self, "_on_node_destroyed")

  connecting_node.get_parent().remove_child(connecting_node)

  navigation_map.add_point(connecting_node.instance_id, connecting_node.position)
  for _node in connecting_node_connections:
    navigation_map.connect_points(connecting_node.instance_id, _node.instance_id)

  add_child(connecting_node)
  connecting_node.global_position = _node_global_position

  emit_signal("node_find_connections")

func queue_acceleration(amount: Vector2):
  _queued_acceleration += amount.rotated(rotation) * base_acceleration

func queue_angular_acceleration(amount: float):
  _queued_angular_acceleration += amount * base_angular_acceleration

func update_connected_node(updating_node, updating_node_connections):
  node_connections[updating_node.get_instance_id()] = updating_node_connections
  for _node in updating_node_connections:
    navigation_map.connect_points(updating_node.instance_id, _node.instance_id)

func _on_node_destroyed(_node):
  connected_nodes.erase(_node.instance_id)
  node_connections.erase(_node.instance_id)
  navigation_map.remove_point(_node.instance_id)

  for _node_key in node_connections.keys():
    var _current_node = connected_nodes[_node_key]

    node_connections[_node_key].erase(_node)

    if navigation_map.get_id_path(_current_node.instance_id, instance_id).size() == 0:
      _current_node.disconnect_node()
  
  _process_disconnected_nodes()

func _physics_process(delta):
  rotation += clamp(_queued_angular_acceleration * delta, -max_angular_velocity, max_angular_velocity)

  if _queued_acceleration.length() < 1:
    _velocity += _velocity * -1 * friction * delta

  _velocity += _queued_acceleration * delta
  _velocity = _velocity.clamped(max_velocity)

  _queued_angular_acceleration = 0
  _queued_acceleration = Vector2(0, 0)

  position += _velocity

func _process_disconnected_nodes():
  var _disconnected_node_ids = []

  for _node_key in connected_nodes.keys():
    if connected_nodes[_node_key].node_state == 1: # NODE_STATES.DISCONNECTED
      _disconnected_node_ids.append(_node_key)

  for _node_key in _disconnected_node_ids:
    var _current_node = connected_nodes[_node_key]
    var _current_global_position = _current_node.global_position
    connected_nodes.erase(_node_key)
    node_connections.erase(_node_key)
    navigation_map.remove_point(_node_key)
    
    remove_child(_current_node)
    _current_node.global_position = _current_global_position
    root.add_child(_current_node)

func _ready():
  navigation_map.add_point(instance_id, Vector2(0, 0))
