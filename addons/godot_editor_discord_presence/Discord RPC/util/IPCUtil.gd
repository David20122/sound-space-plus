class_name IPCUtil

class HandshakePayload extends IPCPayload:
	var version: int
	var client_id: int

	# warning-ignore:shadowed_variable
	# warning-ignore:shadowed_variable
	func _init(version: int, client_id: int) -> void:
		self.op_code = OpCodes.HANDSHAKE
		self.version = version
		self.client_id = client_id

	func to_dict() -> Dictionary:
		return {
			"v": self.version,
			"client_id": str(self.client_id),
		}

class AuthorizePayload extends IPCPayload:
	func _init(client_id: int, scopes: PoolStringArray) -> void:
		self.op_code = OpCodes.FRAME
		self.command = DiscordRPCEnum.Commands.AUTHORIZE
		self.arguments = {
			"client_id": str(client_id),
			"scopes": scopes
		}

class AuthenticatePayload extends IPCPayload:
	func _init(access_token: String) -> void:
		self.op_code = OpCodes.FRAME
		self.command = DiscordRPCEnum.Commands.AUTHENTICATE
		self.arguments = {"access_token": access_token}

class SubscribePayload extends IPCPayload:
	func _init(subscribe_event: String, arg: Dictionary) -> void:
		self.op_code = OpCodes.FRAME
		self.command = DiscordRPCEnum.Commands.SUBSCRIBE
		self.arguments = arg
		self.event = subscribe_event.to_upper()

class UnsubscribePayload extends IPCPayload:
	func _init(usubscribe_event: String, arg: Dictionary) -> void:
		self.op_code = OpCodes.FRAME
		self.command = DiscordRPCEnum.Commands.UNSUBSCRIBE
		self.arguments = arg
		self.event = usubscribe_event.to_upper()
