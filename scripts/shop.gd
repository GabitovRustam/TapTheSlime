extends Popup

@onready var coins: Label = %Coins
@onready var products: HFlowContainer = %Products
@onready var items: HFlowContainer = %Items
@onready var close_sound: AudioStreamPlayer = $Shop/CloseSound
@onready var buy_gem: Button = %BuyGem
@onready var sell_gem: Button = %SellGem
@onready var buy_sound: AudioStreamPlayer = $BuySound


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sorted_products := products.get_children()
	
	sorted_products.sort_custom(func(a, b):
		var val_a = 2000 * a.cost_gems + a.cost_coins
		var val_b = 2000 * b.cost_gems + b.cost_coins
		return val_a < val_b
	)
	
	for i in range(sorted_products.size()):
		var product = sorted_products[i]
		products.move_child(product, i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	coins.text = "Доступно:\n" + str(GameManager.gems) + "💎\n " + str(GameManager.coins)+ "/" + str(GameManager.get_max_coins()) + "🟡"
	sell_gem.disabled = GameManager.gems < 1
	buy_gem.disabled = GameManager.coins < 1200
		
	for product in products.get_children():
		if GameManager.activated_goods.has(product.product_code) || GameManager.purchased_goods.has(product.product_code):
			product.reparent(items, true)

	for product in items.get_children():
		if !(GameManager.activated_goods.has(product.product_code) || GameManager.purchased_goods.has(product.product_code)):
			product.reparent(products, true)

	if products.get_child_count() == 0:
		if GameManager.gem_probability / 16384 < 1:
			GameManager.can_new_game = true
		else:
			GameManager.can_new_game = false
	else:
		GameManager.can_new_game = false
		
func _on_close_pressed() -> void:
	close_sound.play()
	visible = false

func _on_close_sound_finished() -> void:
	queue_free()

func _on_sell_gem_pressed() -> void:
	buy_sound.play()
	GameManager.add_coins(1000)
	GameManager.add_gems(-1)


func _on_buy_gem_pressed() -> void:
	buy_sound.play()
	GameManager.add_coins(-1200)
	GameManager.add_gems(1)
