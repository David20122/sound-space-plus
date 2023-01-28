extends Node

var first_load:bool = true

func init():
	if first_load:
		first_init()
		return
	reload()

func first_init():
	first_load = false

func reload():
	pass