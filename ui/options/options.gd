extends TabContainer

func _ready():
	self.connect("tab_changed", Callable(self, "on_tab_changed"))

func on_tab_changed():
	sfx.play("sword3")
