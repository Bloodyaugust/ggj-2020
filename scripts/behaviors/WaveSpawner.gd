extends Node

enum WAVE_STATES {IDLE, WAITING, SPAWNING}

export var player_scene: PackedScene
export var spawn_distance: float
export var spawn_interval: float
export var waves: Dictionary

onready var tree := get_tree()
onready var root := tree.get_root()

var _current_wave: int
var _player: RootShipNode
var _player_team: int
var _time_to_spawn: float
var _wave_state: int

func _on_ship_destroyed(team: int):
  if team != _player_team:
    if tree.get_nodes_in_group("Enemies").size() <= 1:
      _wave_state = WAVE_STATES.WAITING
  else:
    _respawn_player()

func _process(delta):
  if _wave_state == WAVE_STATES.WAITING:
    _time_to_spawn -= delta

    if _time_to_spawn <= 0:
      _wave_state = WAVE_STATES.SPAWNING

  if _wave_state == WAVE_STATES.SPAWNING:
    var _wave_key = str(_current_wave)
    for _enemy_scene in waves[_wave_key]:
      var _new_enemy = _enemy_scene.instance()

      root.add_child(_new_enemy)
      _new_enemy.global_position = _player.global_position + (Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * spawn_distance)
    
    _time_to_spawn = spawn_interval
    _current_wave += 1
    _wave_state = WAVE_STATES.IDLE

func _ready():
  _time_to_spawn = spawn_interval

  if tree.get_nodes_in_group("Player").size() > 0:
    _player = tree.get_nodes_in_group("Player")[0]
    _player_team = _player.team

  store.connect("ship_destroyed", self, "_on_ship_destroyed")
  _wave_state = WAVE_STATES.WAITING

func _respawn_player():
  var _new_player = player_scene.instance()
  _player = _new_player.get_node("RootShipNode")

  _new_player.global_position = Vector2(0, 0)
  root.add_child(_new_player)

  _current_wave = 0
  _wave_state = WAVE_STATES.WAITING
