extends Button

func _pressed():
	OS.shell_open(ProjectSettings.globalize_path(SSP.user_mod_dir))
