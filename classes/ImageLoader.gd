
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
class_name ImageLoader

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
	
	if bytes.subarray(0,7) == PoolByteArray([0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A]): return "png"
	if bytes.subarray(0,2) == PoolByteArray([0x42,0x4D]): return "bmp"
	if bytes.subarray(0,2) == PoolByteArray([0xFF,0xD8,0xFF]): return "jpg"
	if bytes.subarray(0,3) == PoolByteArray([0x52,0x49,0x46,0x46]) and bytes.subarray(8,11) == PoolByteArray([0x57,0x45,0x42,0x50]): return "webp"
	
	# unsupported
	return "unknown"

var error_texture:Texture = load("res://error.jpg")
var invalid_texture:Texture = load("res://error2.jpg") # make the invalid texture show up instead of being treated 

func load_buffer(bytes:PoolByteArray) -> Texture:
	var format = get_format(bytes)
	var img:Image = Image.new()
	
	if format == "png": img.load_png_from_buffer(bytes)
	elif format == "bmp": img.load_bmp_from_buffer(bytes)
	elif format == "jpg": img.load_jpg_from_buffer(bytes)
	elif format == "webp": img.load_webp_from_buffer(bytes)
	else: return invalid_texture
	
	var imgtex:ImageTexture = ImageTexture.new()
	imgtex.create_from_image(img)
	return imgtex

func load_file(filepath:String) -> Texture:
	var file = File.new()
	var err = file.open(Globals.p(filepath), File.READ)
	if err != OK:
		report_errors(err, Globals.p(filepath))
		file.close()
		return error_texture
	
	var bytes:PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	return load_buffer(bytes)

func load_if_exists(path:String):
	var file:File = File.new()
	path = Globals.p(path)
	if file.file_exists(path + ".png"): path += ".png"
	elif file.file_exists(path + ".jpg"): path += ".jpg"
	elif file.file_exists(path + ".jpeg"): path += ".jpeg"
	elif file.file_exists(path + ".webp"): path += ".webp"
	elif file.file_exists(path + ".bmp"): path += ".bmp"
	if file.file_exists(path): return load_file(path)
	else: return null
