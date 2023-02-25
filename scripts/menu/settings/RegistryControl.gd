extends SettingControl

@export_subgroup("Registry")
@export var registry_name:String
@onready var registry:Registry = SoundSpacePlus.get(registry_name)
@onready var ids:Array = registry.get_ids()

func reset(value=get_setting()):
	var emitter = signal_emitter as OptionButton
	emitter.clear()
	for idx in range(ids.size()):
		var item = registry.items[idx]
		emitter.add_item(item.name,idx)
		emitter.set_item_tooltip(idx,"By %s" % item.creator)
		emitter.set_item_disabled(idx,item.broken)
	emitter.selected = ids.find(value)

func signal_received(value):
	set_setting(ids[value])
	pass
