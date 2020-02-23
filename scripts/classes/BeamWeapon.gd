extends Node2D
class_name BeamWeapon

enum BEAM_WEAPON_STATES {IDLE, FIRING, COOLDOWN}

export var beam_damage: float
export var beam_range: float
export var cooldown_rate: float
export var heat_capacity: float
export var heat_rate: float

onready var line: Line2D = $"Line2D"
onready var tree := get_tree()
onready var parent: ShipNode = get_parent()
onready var raycast: RayCast2D = $"RayCast2D"
onready var root_ship_node: RootShipNode = parent.root_ship_node
onready var root := tree.get_root()

var team: int

var _beam_weapon_state: int
var _current_heat: float

func get_class():
  return "BeamWeapon"

func fire():
  if _beam_weapon_state != BEAM_WEAPON_STATES.COOLDOWN:
    _beam_weapon_state = BEAM_WEAPON_STATES.FIRING

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

func _physics_process(delta):
  if _beam_weapon_state == BEAM_WEAPON_STATES.FIRING:
    raycast.enabled = true
  else:
    raycast.enabled = false

func _process(delta):
  if _beam_weapon_state == BEAM_WEAPON_STATES.FIRING:
    _current_heat += heat_rate * delta
    
    if _current_heat >= heat_capacity:
      _beam_weapon_state = BEAM_WEAPON_STATES.COOLDOWN
    else:
      _beam_weapon_state = BEAM_WEAPON_STATES.IDLE

  if _beam_weapon_state == BEAM_WEAPON_STATES.COOLDOWN && _current_heat <= 0:
    _beam_weapon_state = BEAM_WEAPON_STATES.IDLE

  _current_heat -= cooldown_rate * delta

func _ready():
  _beam_weapon_state = BEAM_WEAPON_STATES.IDLE

  parent.connect("node_connected", self, "_on_node_connected")
  parent.connect("node_disconnected", self, "_on_node_disconnected")
