extends Node

var first_load:bool = true # True during the first run of init
var loading:bool = false # True during any run of init or reload
var need_menu:bool = false # True during first run of init until menu is shown

func init():
	if loading: return
	loading = true
	if first_load:
		do_init()
		return
	reload()

func do_init():
	need_menu = true

func after_init():
	first_load = false

func reload():
	pass