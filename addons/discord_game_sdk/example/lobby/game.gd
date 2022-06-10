extends Control

var game_state_ := GameState.new()

func _ready() -> void:
	game_state_.connect("chat_changed", self, "_on_chat_changed")
	game_state_.connect("members_changed", self, "_on_members_changed")

func _on_chat_changed() -> void:
	find_node("chat").text = ""
	for chat_message in game_state_.chat:
		var member = game_state_.members.get(chat_message.member_id)
		if not member:
			return
		find_node("chat").text += "\n" + member.username + ": " + chat_message.message

	find_node("chat").scroll_vertical = 9999999

func _on_members_changed() -> void:
	find_node("members").text = ""
	for member in game_state_.members.values():
		find_node("members").text += member.username + "\n"

func _on_text_entered(new_text):
	$lobby.send_message(new_text)
	find_node("line_edit").clear()
