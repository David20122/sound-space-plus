extends Control

onready var pbar = $ProgressBar
export(float) var percent = 0 setget _set_percent

func _update_progress(value:float=percent):
	pbar.rect_size.x = 280*value

func _set_percent(value:float):
	percent = value
	_update_progress()

func _ready():
	_update_progress()
