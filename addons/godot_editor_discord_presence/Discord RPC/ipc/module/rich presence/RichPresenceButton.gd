class_name RichPresenceButton

var label: String
var url: String

func _init(label: String, url: String) -> void:
	self.label = label
	self.url = url

func to_dict() -> Dictionary:
	return {
		"label": self.label,
		"url": self.url
	}
