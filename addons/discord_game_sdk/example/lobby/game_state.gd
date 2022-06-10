extends Resource
class_name GameState

signal members_changed
signal chat_changed

export(Dictionary) var members
export(Array, Resource) var chat
