extends Node2D
class_name ShipNode

enum NODE_STATES {CONNECTED, DISCONNECTED, DESTROYED}

signal node_connected
signal node_disconnected
signal node_destroyed

export var connection_range: float
export var health: float

onready var explosion_particle_system := preload("res://doodads/ExplosionEffect.tscn")
onready var tree := get_tree()
onready var root := tree.get_root()
onready var instance_id = get_instance_id()

var node_state: int
var root_ship_node: RootShipNode
var team: int

var _area2d: Area2D
var _circle2d: Circle2D
var _current_health: float

func get_class():
  return "ShipNode"

func disconnect_node():
  node_state = NODE_STATES.DISCONNECTED
  root_ship_node = null
  _circle2d.enabled = true
  emit_signal("node_disconnected")

func do_damage(amount):
  _current_health -= amount

func _connect_nodes():
  var _nodes = tree.get_nodes_in_group("ShipNodes")
  var _connecting_nodes := []
  var _already_connected_to_root: bool = is_instance_valid(root_ship_node)

  for _node in _nodes:
    if _node.global_position.distance_to(global_position) <= connection_range && _node != self:
      if _node.get_class() == "ShipNode" && _node.node_state != NODE_STATES.DESTROYED:
        if !is_instance_valid(root_ship_node) && is_instance_valid(_node.root_ship_node):
          root_ship_node = _node.root_ship_node

        _connecting_nodes.append(_node)

      if _node.get_class() == "RootShipNode":
        root_ship_node = _node
        _connecting_nodes.append(_node)

  if is_instance_valid(root_ship_node):
    _set_team(root_ship_node.team)
    node_state = NODE_STATES.CONNECTED
    _circle2d.enabled = false
    emit_signal("node_connected")

    if _already_connected_to_root:
      root_ship_node.update_connected_node(self, _connecting_nodes)
    else:
      root_ship_node.add_connected_node(self, _connecting_nodes)

    root_ship_node.connect("node_find_connections", self, "_on_node_find_connections")

func _on_node_destroyed(_destroyed_node):
  # find if we have connection to heart node
  pass

func _on_node_disconnected(_disconnected_node):
  # find if we have connection to heart node
  pass

func _on_node_find_connections():
  _connect_nodes()

func _process(_delta):
  if _current_health <= 0 && node_state != NODE_STATES.DESTROYED:
    var _explosion_scene = explosion_particle_system.instance()

    node_state = NODE_STATES.DESTROYED
    emit_signal("node_destroyed", self)

    _explosion_scene.global_position = global_position
    root.add_child(_explosion_scene)

    queue_free()

  if node_state == NODE_STATES.DISCONNECTED:
    _connect_nodes()

func _ready():
  node_state = NODE_STATES.DISCONNECTED

  _current_health = health

  call_deferred("_connect_nodes")
  _area2d = $Area2D
  _circle2d = $Circle2D

  _circle2d.enabled = true

func _set_team(new_team: int):
  _area2d.set_collision_layer_bit(team, false)
  _area2d.set_collision_mask_bit(team, true)

  team = new_team

  _area2d.set_collision_layer_bit(team, true)
  _area2d.set_collision_mask_bit(team, false)
