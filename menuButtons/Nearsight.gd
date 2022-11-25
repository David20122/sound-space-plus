extends CheckBox

func _pressed():
	pressed = false
	Globals.confirm_prompt.open(
		"The Nearsight modifier has been removed.\nTo achieve the same effect, set your spawn distance to 3/5 of your approach rate & your fade length to 100%.",
		"Notice",
		[{text="OK"}]
	)
	Globals.confirm_prompt.s_alert.play()
	var option = yield(Globals.confirm_prompt,"option_selected")
	Globals.confirm_prompt.close()
	Globals.confirm_prompt.s_next.play()
