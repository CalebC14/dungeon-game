class_name ShopSystem
extends RefCounted

var inventory_system = InventorySystem.new()

func get_shop(shop_id: String) -> Dictionary:
	if not ShopData.SHOPS.has(shop_id):
		return {}
	return ShopData.SHOPS[shop_id]

func get_stock(shop_id: String) -> Array:
	var shop = get_shop(shop_id)
	if shop.is_empty():
		return []
	return shop["stock"]

func get_buy_price(item_id: String) -> int:
	if not ItemData.ITEMS.has(item_id):
		return 0
	return int(ItemData.ITEMS[item_id].get("value", 0))

func get_sell_price(shop_id: String, item_id: String) -> int:
	if not ItemData.ITEMS.has(item_id):
		return 0
	var shop = get_shop(shop_id)
	var rate = float(shop.get("sell_rate", 0.50))
	return max(0, int(floor(get_buy_price(item_id) * rate)))

func buy_item(
	shop_id: String,
	character: Dictionary,
	item_id: String,
	progression: ProgressionSystem
) -> String:
	if not ItemData.ITEMS.has(item_id):
		return "That item is not available."

	var stock = get_stock(shop_id)
	if item_id not in stock:
		return "That item is not sold here."

	var price = get_buy_price(item_id)
	if not progression.can_afford(price):
		return "The party does not have enough gold."

	if inventory_system.party_model == null and inventory_system.get_inventory(character).size() >= InventorySystem.MAX_INVENTORY_SLOTS:
		return character["name"] + "'s pack is full."

	if not progression.spend_gold(price):
		return "The party does not have enough gold."

	if not inventory_system.add_item(character, item_id):
		progression.add_gold(price)
		return "The item could not be added to the pack."

	return "The party buys " + ItemData.ITEMS[item_id]["name"] + " for " + str(price) + " gold."

func sell_item(
	shop_id: String,
	character: Dictionary,
	inventory_index: int,
	progression: ProgressionSystem
) -> String:
	if inventory_index < 0 or inventory_index >= inventory_system.get_inventory(character).size():
		return "That inventory slot is empty."

	var item_id = inventory_system.get_inventory(character)[inventory_index]
	if not ItemData.ITEMS.has(item_id):
		return "That item cannot be sold."

	var price = get_sell_price(shop_id, item_id)
	if price <= 0:
		return ItemData.ITEMS[item_id]["name"] + " has no resale value."

	inventory_system.get_inventory(character).remove_at(inventory_index)
	progression.add_gold(price)

	return "The party sells " + ItemData.ITEMS[item_id]["name"] + " for " + str(price) + " gold."
