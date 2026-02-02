extends Control

@onready var roller: DiceRollerControl = $DiceRollerControl

func _ready():
	_select_dice("D6") # default

func _on_d6_pressed():
	_select_dice("D6")

func _on_d12_pressed():
	_select_dice("D12")

func _on_d20_pressed():
	_select_dice("D20")

func _select_dice(type: String):
	var def := DiceDef.new()
	def.name = type
	def.color = Color.WHITE
	def.shape = DiceShape.new(type)
	roller.dice_set = [def]
