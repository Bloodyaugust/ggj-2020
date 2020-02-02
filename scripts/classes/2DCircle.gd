tool
extends Node2D
class_name Circle2D

export var angle_from: float
export var angle_to: float
export var color: Color
export var radius: float
export var resolution: int

var enabled: bool

func _draw():
  if enabled:
    var _nb_points = resolution
    var _points_arc = PoolVector2Array()

    for _i in range(_nb_points + 1):
        var _angle_point = deg2rad(angle_from + _i * (angle_to - angle_from) / _nb_points - 90)
        _points_arc.push_back(position + Vector2(cos(_angle_point), sin(_angle_point)) * radius)

    for _index_point in range(_nb_points):
        draw_line(_points_arc[_index_point], _points_arc[_index_point + 1], color)
