extends Button

func _pressed():
	print(ProjectSettings.globalize_path(SSP.user_pack_dir))
	OS.shell_open(ProjectSettings.globalize_path(SSP.user_pack_dir))
