extends Control

@export_multiline var product_name: String
@export var product_icon: Texture2D
@export_multiline var product_decription: String
@export var cost_coins: int
@export var cost_gems: int
@export var product_code: String
@export var product_type: String

@onready var desc: Button = $VBoxContainer/NinePatchRect/MarginContainer/Desc
@onready var buy: Button = $VBoxContainer/Buy
@onready var activate_sound: AudioStreamPlayer = $ActivateSound
@onready var deactivate_sound: AudioStreamPlayer = $DeactivateSound
@onready var buy_sound: AudioStreamPlayer = $BuySound
@onready var popup_sound: AudioStreamPlayer = $Popup/PopupSound
@onready var close_sound: AudioStreamPlayer = $Popup/CloseSound
@onready var popup: Popup = $Popup
@onready var product_details_label: Label = %ProductDetails
@onready var product_icon_button: Button = $Popup/Details/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer3/HBoxContainer/NinePatchRect/MarginContainer/ProductIcon
@onready var product_name_label: Label = $Popup/Details/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer3/HBoxContainer/ProductName
@onready var buy_button: Button = $Popup/Details/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer4/Buy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desc.icon = product_icon
	popup.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.activated_goods.has(product_code):
		buy.text = "❌Отменить"
		buy.disabled = false
		buy_button.text = "❌Отменить"
		buy_button.disabled = false
	elif GameManager.purchased_goods.has(product_code):
		buy.text = "✔️Применить"
		buy.disabled = false
		buy_button.text = "✔️Применить"
		buy_button.disabled = false
	else:
		var cost_text = ""
		if cost_gems > 0:
			cost_text += str(cost_gems) + "💎 "
		if cost_coins > 0:
			cost_text += str(cost_coins) + "🟡"
		buy.text = cost_text
		buy.disabled = !(GameManager.coins >= cost_coins && GameManager.gems >= cost_gems)
		buy_button.text = "Купить (" + cost_text + ")"
		buy_button.disabled = !(GameManager.coins >= cost_coins && GameManager.gems >= cost_gems)


func _on_desc_pressed() -> void:
	product_name_label.text = product_name
	product_details_label.text = product_decription
	product_icon_button.icon = product_icon
	popup.visible = true
	popup_sound.play()

func _on_buy_pressed() -> void:
	if GameManager.activated_goods.has(product_code):
		deactivate_sound.play()
		GameManager.activated_goods.erase(product_code)
		GameManager.save_game()
	elif GameManager.purchased_goods.has(product_code):
		activate_sound.play()
		GameManager.activated_goods.append(product_code)
		GameManager.save_game()
	elif GameManager.coins >= cost_coins && GameManager.gems >= cost_gems:
		buy_sound.play()
		GameManager.purchased_goods.append(product_code)
		GameManager.add_coins(-1 * cost_coins)
		GameManager.add_gems(-1 * cost_gems)
		if product_type == "":
			GameManager.activated_goods.append(product_code)
		GameManager.save_game()
	else:
		print("Not enough coins")

func _on_close_pressed() -> void:
	popup.visible = false
	close_sound.play()
