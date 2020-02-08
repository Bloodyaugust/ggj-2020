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
  root_ship_node.disconnect("root_ship_node_team_set", self, "_on_root_ship_node_team_set")
  root_ship_node = null
  _circle2d.enabled = true
  _set_team(0)
  emit_signal("node_disconnected")

func do_damage(amount):
  _current_health -= amount

func _connect_node(connecting_to):
  root_ship_node.add_connected_node(self, connecting_to)
  emit_signal("node_connected")

func _on_area_entered(entering_area: Area2D):
  if node_state == NODE_STATES.DISCONNECTED:
    var _entering_ship_node = entering_area.get_parent()
    var _connected = false

    if _entering_ship_node.get_class() == "RootShipNode":
      root_ship_node = _entering_ship_node
      _connected = true

    if _entering_ship_node.get_class() == "ShipNode" && _entering_ship_node.node_state != NODE_STATES.DESTROYED && _entering_ship_node.node_state != NODE_STATES.DISCONNECTED:
      root_ship_node = _entering_ship_node.root_ship_node
      _connected = true

    if _connected:
      _set_team(root_ship_node.team)
      _circle2d.enabled = false
      node_state = NODE_STATES.CONNECTED

      root_ship_node.connect("root_ship_node_team_set", self, "_on_root_ship_node_team_set")

      call_deferred("_connect_node", _entering_ship_node)


func _on_root_ship_node_team_set():
  _set_team(root_ship_node.team)

func _process(_delta):
  if _current_health <= 0 && node_state != NODE_STATES.DESTROYED:
    var _explosion_scene = explosion_particle_system.instance()

    node_state = NODE_STATES.DESTROYED
    emit_signal("node_destroyed", self)

    _explosion_scene.global_position = global_position
    root.add_child(_explosion_scene)

    queue_free()

func _ready():
  node_state = NODE_STATES.DISCONNECTED

  _current_health = health
  _area2d = $Area2D
  _circle2d = $Circle2D

  _circle2d.enabled = true

  _area2d.connect("area_entered", self, "_on_area_entered")

func _set_team(new_team: int):
  _area2d.set_collision_layer_bit(team, false)
  _area2d.set_collision_mask_bit(team, true)

  team = new_team

  _area2d.set_collision_layer_bit(team, true)
  _area2d.set_collision_mask_bit(team, false)
