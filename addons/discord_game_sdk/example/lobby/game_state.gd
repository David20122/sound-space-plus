extends Resource
class_name GameState

signal members_changed
signal chat_changed

@export var members: Dictionary
@export var chat # (Array, Resource)
