extends Node2D
class_name ShipNode

enum NODE_STATES {CONNECTED, DISCONNECTED}

signal node_destroyed

export var connection_range: float
export var health: float

onready var tree := get_tree()
onready var root := tree.get_root()
onready var instance_id = get_instance_id()

var node_state: int
var root_ship_node: RootShipNode

var _current_health: float

func get_class():
  return "ShipNode"

func _connect_nodes():
  var _nodes = tree.get_nodes_in_group("ShipNodes")
  var _connecting_nodes := []
  var _already_connected_to_root: bool = is_instance_valid(root_ship_node)

  for _node in _nodes:
    if _node.position.distance_to(position) <= connection_range && _node != self:
      if _node.get_class() == "ShipNode":
        if !is_instance_valid(root_ship_node) && is_instance_valid(_node.root_ship_node):
          root_ship_node = _node.root_ship_node

        _connecting_nodes.append(_node)

      if _node.get_class() == "RootShipNode":
        root_ship_node = _node
        _connecting_nodes.append(_node)

  if is_instance_valid(root_ship_node):
    node_state = NODE_STATES.CONNECTED

    for _node in _connecting_nodes:
      _node.connect("node_destroyed", self, "_on_node_destroyed", [_node])
      _node.connect("node_disconnected", self, "_on_node_disconnected", [_node])
    
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
  if _current_health <= 0:
    emit_signal("node_destroyed")

  if !is_instance_valid(root_ship_node):
    _connect_nodes()

func _ready():
  node_state = NODE_STATES.DISCONNECTED

  _current_health = health

  call_deferred("_connect_nodes")
