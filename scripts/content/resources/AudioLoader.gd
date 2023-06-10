#GDScriptAudioImport v0.1

#MIT License
#
#Copyright (c) 2020 Gianclgar (Giannino Clemente) gianclgar@gmail.com
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#I honestly don't care that much, Kopimi ftw, but it's my little baby and I want it to look nice :3

extends Node
class_name AudioLoader

func report_errors(err, filepath):
	# See: https://docs.godotengine.org/en/latest/classes/class_@globalscope.html#enum-globalscope-error
	var result_hash = {
		ERR_FILE_NOT_FOUND: "File: not found",
		ERR_FILE_BAD_DRIVE: "File: Bad drive error",
		ERR_FILE_BAD_PATH: "File: Bad path error.",
		ERR_FILE_NO_PERMISSION: "File: No permission error.",
		ERR_FILE_ALREADY_IN_USE: "File: Already in use error.",
		ERR_FILE_CANT_OPEN: "File: Can't open error.",
		ERR_FILE_CANT_WRITE: "File: Can't write error.",
		ERR_FILE_CANT_READ: "File: Can't read error.",
		ERR_FILE_UNRECOGNIZED: "File: Unrecognized error.",
		ERR_FILE_CORRUPT: "File: Corrupt error.",
		ERR_FILE_MISSING_DEPENDENCIES: "File: Missing dependencies error.",
		ERR_FILE_EOF: "File: End of file (EOF) error."
	}
	if err in result_hash:
		print("Error: ", result_hash[err], " ", filepath)
	else:
		print("Unknown error with file ", filepath, " error code: ", err)

func get_format(bytes:PoolByteArray) -> String:
	if bytes.size() < 10: return "unknown"
	# Figure out file format from signatures
	# https://en.wikipedia.org/wiki/List_of_file_signatures
	
#	print(bytes.subarray(0,3).hex_encode())
	
	# .ogg
	if bytes.subarray(0,3) == PoolByteArray([0x4F,0x67,0x67,0x53]): return "ogg"
	# .wav
	# doesn't load correctly atm
#	if (bytes.subarray(0,3) == PoolByteArray([0x52,0x49,0x46,0x46])
#	and bytes.subarray(8,11) == PoolByteArray([0x57,0x41,0x56,0x45])): return "wav"
	# .mp3
	if (bytes.subarray(0,1) == PoolByteArray([0xFF,0xFB])
	or bytes.subarray(0,1) == PoolByteArray([0xFF,0xF3])
	or bytes.subarray(0,1) == PoolByteArray([0xFF,0xFA])
	or bytes.subarray(0,1) == PoolByteArray([0xFF,0xF2])
	or bytes.subarray(0,2) == PoolByteArray([0x49,0x44,0x33])): return "mp3"
	# unsupported
	return "unknown"

func load_buffer(bytes:PoolByteArray,loop:bool=false):
	var format = get_format(bytes)
	
	# if File is wav
	if format == "wav":
		var newstream = AudioStreamSample.new()

		#---------------------------
		#parrrrseeeeee!!! :D
		
		var bits_per_sample = 0
		
		for i in range(0, 100):
			var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
			
#			if those4bytes == "RIFF": 
#				print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
				#RIP bytes 4-7 integer for now
#			if those4bytes == "WAVE": 
#				print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

			if those4bytes == "fmt ":
#				print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
				
				#get format subchunk size, 4 bytes next to "fmt " are an int32
				var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
#				print ("Format subchunk size: " + str(formatsubchunksize))
				
				#using formatsubchunk index so it's easier to understand what's going on
				var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

				#get format code [Bytes 0-1]
				var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
				var format_name
				if format_code == 0: format_name = "8_BITS"
				elif format_code == 1: format_name = "16_BITS"
				elif format_code == 2: format_name = "IMA_ADPCM"
				else: 
					format_name = "UNKNOWN (trying to interpret as 16_BITS)"
					format_code = 1
#				print ("Format: " + str(format_code) + " " + format_name)
				#assign format to our AudioStreamSample
				newstream.format = format_code
				
				#get channel num [Bytes 2-3]
				var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
#				print ("Number of channels: " + str(channel_num))
				#set our AudioStreamSample to stereo if needed
				if channel_num == 2: newstream.stereo = true
				
				#get sample rate [Bytes 4-7]
				var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
#				print ("Sample rate: " + str(sample_rate))
				#set our AudioStreamSample mixrate
				newstream.mix_rate = sample_rate
				
				#get byte_rate [Bytes 8-11] because we can
				var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
#				print ("Byte rate: " + str(byte_rate))
				
				#same with bits*sample*channel [Bytes 12-13]
				var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
#				print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
				
				#aaaand bits per sample/bitrate [Bytes 14-15]
				bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
#				print ("Bits per sample: " + str(bits_per_sample))
				
			if those4bytes == "data":
				assert(bits_per_sample != 0)
				
				var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
#				print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

				var data_entry_point = (i+8)
#				print ("Audio data starts at byte " + str(data_entry_point))
				
				var data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
				
				if bits_per_sample in [24, 32]:
					newstream.data = convert_to_16bit(data, bits_per_sample)
				else:
					newstream.data = data
			# end of parsing
			#---------------------------

		#get samples and set loop end
		var samplenum = newstream.data.size() / 4
		newstream.loop_end = samplenum
		newstream.loop_mode = int(loop)
		return newstream  #:D

	#if file is ogg
	elif format == "ogg":
		var newstream = AudioStreamOGGVorbis.new()
		newstream.loop = loop #set to false or delete this line if you don't want to loop
		newstream.data = bytes
		return newstream

	#if file is mp3
	elif format == "mp3":
		var newstream = AudioStreamMP3.new()
		newstream.loop = loop #set to false or delete this line if you don't want to loop
		newstream.data = bytes
		return newstream

	else:
		print("ERROR: Unknown filetype or format")
		push_error("Unknown filetype or format!")
		return Globals.error_sound

func load_file(filepath:String,loop:bool=false):
	var file = File.new()
	var err = file.open(Globals.p(filepath), File.READ)
	if err != OK:
		report_errors(err, Globals.p(filepath))
		file.close()
		return Globals.error_sound
	
	var bytes:PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	return load_buffer(bytes,loop)

# Converts .wav data from 24 or 32 bits to 16
#
# These conversions are SLOW in GDScript
# on my one test song, 32 -> 16 was around 3x slower than 24 -> 16
#
# I couldn't get threads to help very much
# They made the 24bit case about 2x faster in my test file
# And the 32bit case abour 50% slower
# I don't wanna risk it always being slower on other files
# And really, the solution would be to handle it in a low-level language
func convert_to_16bit(data: PoolByteArray, from: int) -> PoolByteArray:
	print("converting to 16-bit from %d" % from)
	var time = OS.get_ticks_msec()
	# 24 bit .wav's are typically stored as integers
	# so we just grab the 2 most significant bytes and ignore the other
	if from == 24:
		var j = 0
		for i in range(0, data.size(), 3):
			data[j] = data[i+1]
			data[j+1] = data[i+2]
			j += 2
		data.resize(data.size() * 2 / 3)
	# 32 bit .wav's are typically stored as floating point numbers
	# so we need to grab all 4 bytes and interpret them as a float first
	if from == 32:
		var spb := StreamPeerBuffer.new()
		var single_float: float
		var value: int
		for i in range(0, data.size(), 4):
			spb.data_array = data.subarray(i, i+3)
			single_float = spb.get_float()
			value = single_float * 32768
			data[i/2] = value
			data[i/2+1] = value >> 8
		data.resize(data.size() / 2)
	print("Took %f seconds for slow conversion" % ((OS.get_ticks_msec() - time) / 1000.0))
	return data


# ---------- REFERENCE ---------------
# note: typical values doesn't always match

#Positions  Typical Value Description
#
#1 - 4      "RIFF"        Marks the file as a RIFF multimedia file.
#                         Characters are each 1 byte long.
#
#5 - 8      (integer)     The overall file size in bytes (32-bit integer)
#                         minus 8 bytes. Typically, you'd fill this in after
#                         file creation is complete.
#
#9 - 12     "WAVE"        RIFF file format header. For our purposes, it
#                         always equals "WAVE".
#
#13-16      "fmt "        Format sub-chunk marker. Includes trailing null.
#
#17-20      16            Length of the rest of the format sub-chunk below.
#
#21-22      1             Audio format code, a 2 byte (16 bit) integer. 
#                         1 = PCM (pulse code modulation).
#
#23-24      2             Number of channels as a 2 byte (16 bit) integer.
#                         1 = mono, 2 = stereo, etc.
#
#25-28      44100         Sample rate as a 4 byte (32 bit) integer. Common
#                         values are 44100 (CD), 48000 (DAT). Sample rate =
#                         number of samples per second, or Hertz.
#
#29-32      176400        (SampleRate * BitsPerSample * Channels) / 8
#                         This is the Byte rate.
#
#33-34      4             (BitsPerSample * Channels) / 8
#                         1 = 8 bit mono, 2 = 8 bit stereo or 16 bit mono, 4
#                         = 16 bit stereo.
#
#35-36      16            Bits per sample. 
#
#37-40      "data"        Data sub-chunk header. Marks the beginning of the
#                         raw data section.
#
#41-44      (integer)     The number of bytes of the data section below this
#                         point. Also equal to (#ofSamples * #ofChannels *
#                         BitsPerSample) / 8
#
#45+                      The raw audio data.            
