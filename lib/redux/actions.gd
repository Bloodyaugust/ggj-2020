extends Node

onready var types = get_node('/root/action_types')

func game_set_start_time(time):
  return {
    'type': types.GAME_SET_START_TIME,
    'time': time
  }
