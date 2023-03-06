extends ObjectManager

func prepare(_game:GameScene):
	super.prepare(_game)
	
	append_object(origin.get_node("World"),false)
	append_object(origin.get_node("HUD"),false)
	build_map(game.map)
