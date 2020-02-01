extends Node2D
class_name RootShipNode

onready var tree := get_tree()
onready var root := tree.get_root()

var connected_nodes := {}
var node_connections := {}

func get_class():
  return "RootShipNode"

func add_connected_node(connecting_node, connecting_node_connections):
  connected_nodes[connecting_node.get_instance_id()] = connecting_node
  node_connections[connecting_node.get_instance_id()] = connecting_node_connections

  connecting_node.get_parent().remove_child(connecting_node)
  add_child(connecting_node)
