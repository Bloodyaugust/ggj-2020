extends Node2D
class_name Weapon

enum WEAPON_STATES {IDLE, COOLDOWN, RELOAD}

export var clip_size: int
export var cooldown: float
export var projectile: PackedScene
export var reload: float

onready var tree := get_tree()
onready var parent: ShipNode = get_parent()
onready var root_ship_node: RootShipNode = parent.root_ship_node
onready var root := tree.get_root()

var team: int

var _clip_remaining: int
var _time_to_cooldown: float
var _time_to_reload: float
var _weapon_state: int

func get_class():
  return "Weapon"

func fire():
  if _weapon_state == WEAPON_STATES.IDLE && is_instance_valid(root_ship_node):
    var _new_projectile = projectile.instance()

    _new_projectile.global_position = global_position
    _new_projectile.rotation = global_rotation
    _new_projectile.starting_velocity = root_ship_node.get_velocity()
    _new_projectile.team = team
    root.add_child(_new_projectile)
    
    _clip_remaining -= 1
    _time_to_cooldown = cooldown

    if _clip_remaining <= 0:
      _time_to_reload = reload

func _on_node_connected():
  team = parent.team
  root_ship_node = parent.root_ship_node
  root_ship_node.connect("weapon_fire", self, "fire")
  root_ship_node.connect("weapon_set_look", self, "_on_weapon_set_look")

func _on_node_disconnected():
  team = 0
  root_ship_node.disconnect("weapon_fire", self, "fire")
  root_ship_node.disconnect("weapon_set_look", self, "_on_weapon_set_look")
  root_ship_node = null

func _on_weapon_set_look(at: Vector2):
  look_at(at)

func _process(delta):
  _time_to_cooldown -= delta
  _time_to_reload -= delta

  if _time_to_cooldown > 0:
    _weapon_state = WEAPON_STATES.COOLDOWN

  if _time_to_reload > 0:
    _weapon_state = WEAPON_STATES.RELOAD

  if _time_to_reload <= 0 && _time_to_cooldown <= 0 && _weapon_state == WEAPON_STATES.RELOAD:
    _clip_remaining = clip_size
    _weapon_state = WEAPON_STATES.IDLE
  if _time_to_reload <= 0 && _time_to_cooldown <= 0 && _weapon_state == WEAPON_STATES.COOLDOWN:
    _weapon_state = WEAPON_STATES.IDLE

func _ready():
  _clip_remaining = clip_size
  _weapon_state = WEAPON_STATES.IDLE

  parent.connect("node_connected", self, "_on_node_connected")
