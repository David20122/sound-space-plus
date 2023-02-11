extends Control

var fading:bool = false
var vfading:bool = false
var possible = [
	"Sometimes the slower you go the faster you learn.",
	"Finally, absolute mode.",
	"kermeet",
	"Do any top players in Sound Space+ use mouses?",
	"You will rip SS+ out of my cold, dead hands.",
	"The missile knows where it is at all times. It knows this because it knows where it isn't.",
	"This.. experiment, has taught me a lot.",
	"Ridiculous.",
	"Drama is in the air? Wrong! Delete Server.",
	"discord.gg/92N5a7zKr4",
	"Hustle in silence, and let your success make the noise.",
	"zee! - HATE",
	"I'll knock all of this shit over - pyrule 2023",
	"aHR0cHM6Ly90d2l0dGVyLmNvbS9zc0RyYW1hRGF5cw==",
]

func _ready():
	var rand = possible[randi() % possible.size()]
	if rand == "kermeet":
		yield(get_tree().create_timer(2),"timeout")
		vfading = true
		$kermeet.visible = true
		$kermeet.play()
	else:
		$Real.text = rand
		$Real.anchor_bottom = 0.5
		$Real.anchor_top = 0.5
		$Real.anchor_left = 0.5
		$Real.anchor_right = 0.5
		yield(get_tree().create_timer(2),"timeout")
		fading = true

func _physics_process(delta):
	if fading:
		$Real.modulate.a = lerp($Real.modulate.a, 1, 0.05)
	if vfading:
		$kermeet.modulate.a = lerp($kermeet.modulate.a, 1, 0.05)

func _on_kermeet_finished():
	get_tree().quit()
