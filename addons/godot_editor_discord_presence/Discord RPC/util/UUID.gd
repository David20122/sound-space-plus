#
#
# Author: Binogure Studio
# Original source: https://github.com/binogure-studio/godot-uuid/
#
#

class_name UUID

const MODULO_8_BIT: int = 256

static func getRandomInt() -> int:
	# Randomize every time to minimize the risk of collisions
	randomize()
	
	return randi() % MODULO_8_BIT

static func uuidbin() -> PoolByteArray:
	# 16 random bytes with the bytes on index 6 and 8 modified
	return PoolByteArray([
		getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
		getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
		((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
		getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	])

static func v4() -> String:
	# 16 random bytes with the bytes on index 6 and 8 modified
	var b: PoolByteArray = uuidbin()
	
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		# low
		b[0], b[1], b[2], b[3],
	
		# mid
		b[4], b[5],
	
		# hi
		b[6], b[7],
	
		# clock
		b[8], b[9],
	
		# clock
		b[10], b[11], b[12], b[13], b[14], b[15]
	]
