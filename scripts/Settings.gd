extends Resource
class_name Settings

var data:Dictionary = {}

var assets:Dictionary = {block="rounded",world="tunnel"}:
	get:
		if !data.has("assets"): data.assets = assets
		return data.get("assets")
	set(value):
		data.assets = value
var colorset:Array = ["#ff0000","#00ffff"]:
	get:
		if !data.has("colorset"): data.colorset = colorset
		return data.get("colorset") 
	set(value):
		data.colorset = value
var parallax:float:
	get:
		if !data.has("parallax"): data.parallax = parallax
		return data.get("parallax")
	set(value):
		data.parallax = value
