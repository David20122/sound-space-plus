
class_name UpdateRichPresencePayload extends IPCPayload

func _init(presence: RichPresence) -> void:

	self.op_code = OpCodes.FRAME
	self.command = DiscordRPCEnum.Commands.SET_ACTIVITY
	self.arguments = {
		"pid": OS.get_process_id(),
		# warning-ignore:incompatible_ternary
		"activity": presence.to_dict() if presence else null
	}
