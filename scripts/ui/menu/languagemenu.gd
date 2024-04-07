extends ColorRect

onready var languageselect = $ChangeLanguage/SelectLanguageWindow/languageselector


# en = 0
# jp = 1

# # Called when the node enters the scene tree for the first time.
func _ready():
	# TranslationServer.set_locale("ja")
	add_items()
	languageselect.selected = Rhythia.language

func add_items():
	languageselect.add_item("ENGLISH")
	languageselect.add_item("JAPANESE")

func _on_languageselector_item_selected(index):
	Rhythia.language = index
	TranslationServer.set_locale(Globals.locale[Rhythia.language])
