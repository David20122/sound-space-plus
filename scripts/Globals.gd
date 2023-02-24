extends Node

enum RootFolder {
	USER,
	RES,
	EXECUTABLE,
	SKIN
}

var Folders = {
	user = "user://",
	res = "res://",
	executable = "",
	skin = "",
}
const _folders = {
	skin = [RootFolder.RES,"assets"],
	maps = [RootFolder.USER,"maps"],
	playlists = [RootFolder.USER,"playlists"]
}

func update_folders():
	Folders.executable = OS.get_executable_path()
	for key in _folders.keys():
		var value = _folders[key]
		match value[0]:
			RootFolder.USER: Folders[key] = Folders.user.path_join(value[1])
			RootFolder.RES: Folders[key] = Folders.res.path_join(value[1])
			RootFolder.EXECUTABLE: Folders[key] = Folders.executable.path_join(value[1])
			RootFolder.SKIN: Folders[key] = Folders.skin.path_join(value[1])

enum AudioFormat {
	UNKNOWN,
	MP3,
	OGG,
	WAV
}
func get_ogg_packet_sequence(data:PackedByteArray):
	var packets = []
	var granule_positions = []
	var sampling_rate = 0
	var pos = 0
	while pos < data.size():
		# Parse the Ogg packet header
		var packet_start = pos
		var header = data.slice(pos, pos + 27)
		pos += 27
		# Check the capture pattern
		if header.slice(0, 4) != "OggS".to_ascii_buffer():
			break
		# Get the packet type
		var packet_type = header.decode_u8(5)
#		print("packet type: %s" % packet_type)
		# Get the granule position
		var granule_position = header.decode_u64(6)
#		print("granule position: %s" % granule_position)
		granule_positions.append(granule_position)
		# Get the bitstream serial number
		var serial_number = header.decode_u32(14)
#		print("serial number: %s" % serial_number)
		# Get the page sequence number
		var sequence_number = header.decode_u32(18)
#		print("sequence number: %s" % sequence_number)
		# Get the segment table
		var segment_table_length = header.decode_u8(26)
#		print("segment table length: %s" % segment_table_length)
		var segment_table = data.slice(pos, pos + segment_table_length)
		pos += segment_table_length
		# Get the packet data
		var packet_data = []
		var appending = false
		for i in range(segment_table_length):
			var segment_size = segment_table.decode_u8(i)
			var segment = data.slice(pos, pos + segment_size)
			if appending: packet_data.back().append_array(segment)
			else: packet_data.append(segment)
			appending = segment_size == 255
			pos += segment_size
		# Add the packet data to the array
		packets.append(packet_data)
		if sampling_rate == 0 and packet_type == 2:
			var info_header = packet_data[0]
			if info_header.slice(1, 7).get_string_from_ascii() != "vorbis":
				break
			sampling_rate = info_header.decode_u32(12)
	var packet_sequence = OggPacketSequence.new()
	packet_sequence.sampling_rate = sampling_rate
	packet_sequence.granule_positions = granule_positions
	packet_sequence.packet_data = packets
	return packet_sequence

const StatusMessages = {
	DEBUG = [Color("#2483b3"),"This is a development build. Some features may not function correctly."],
	EDITOR = [Color("#2483b3"),"You are running the game from the editor. Some features may be disabled."]
}

func _ready():
	update_folders()
