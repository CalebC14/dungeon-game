extends Node2D

const DeveloperMenuScript = preload("res://dev/developer_menu.gd")


# ============================================================
# GAME STATES
# ============================================================

enum GameState {
	GUILD,
	CREATE_RACE,
	CREATE_STATS,
	CREATE_CLASS,
	CREATE_GENDER,
	CREATE_NAME,
	CREATE_REVIEW,
	PARTY_SELECT,
	CITY,
	WILDERNESS,
	TRAINING_HALL,
	SHOP,
	TOWN_HALL,
	WARDEN_KEEP,
	INN,
	INVENTORY,
	DUNGEON,
	COMBAT,
	COMBAT_RESULT,
	TEMPLE
}

var game_state = GameState.GUILD
var save_path: String = "user://dungeon-save.dat"
var save_message: String = ""
var temple_character_index: int = 0
var temple_message: String = ""



# ============================================================
# GAME DATA
# ============================================================

var races = GameData.RACES
var classes = GameData.CLASSES


# ============================================================
# SYSTEMS
# ============================================================

var city = CitySystem.new()
var wilderness = WildernessSystem.new()
var dungeon = DungeonSystem.new()
var combat = CombatSystem.new()
var progression = ProgressionSystem.new()
var inventory_system = InventorySystem.new()
var shop_system = ShopSystem.new()
var loot_system = LootSystem.new()
var quest_system = QuestSystem.new()
var developer_menu = DeveloperMenuScript.new()

var developer_menu_open: bool = false


# ============================================================
# ROSTER / PARTY
# ============================================================

const PartyScript = preload("res://systems/party.gd")
var party_system = PartyScript.new()
var roster: Array:
	get:
		return party_system.roster
var party: Array:
	get:
		return party_system.active_members()
var roster_page: int = 0
var selected_formation_slot: int = 0
var party_message: String = ""
var class_skills_open: bool = false
var class_character_index: int = 0
var class_skill_index: int = 0
var class_skill_message: String = ""
var rogue_skills_open: bool = false
var rogue_character_index: int = 0
var rogue_selected_skill: String = "pick_lock"
var rogue_message: String = ""
var formation_menu_open: bool = false
var formation_source: int = -1
const ROSTER_PAGE_SIZE = 9

const MAX_PARTY_SIZE = 6


# ============================================================
# CHARACTER CREATION
# ============================================================

var character: Dictionary = {}

var selected_race_index = -1
var selected_class_index = -1

var race_page = 0
var class_page = 0

const PAGE_SIZE = 7

var name_buffer = ""


# ============================================================
# DUNGEON / ENCOUNTERS
# ============================================================

var encounter_chance = 0.25


# ============================================================
# COMBAT CONTROLLER STATE
# ============================================================

var combat_character_index = 0
var combat_result_text = ""

var last_combat_rewards: Dictionary = {}
var current_combat_tag: String = ""

# Party-level quest items are kept separate from character packs.
var quest_items: Dictionary = {}
var inn_message: String = ""

# ============================================================
# INVENTORY / EQUIPMENT
# ============================================================

func inventory_at_guild() -> bool:
	return inventory_return_state in [GameState.GUILD, GameState.PARTY_SELECT]

func get_management_members() -> Array:
	return roster if inventory_at_guild() else party

func open_inventory(return_state):
	if game_state == GameState.COMBAT or return_state == GameState.COMBAT:
		return
	inventory_return_state = return_state
	var members = get_management_members()
	if members.is_empty():
		return
	inventory_character_index = clampi(inventory_character_index, 0, members.size() - 1)
	inventory_page = 0
	inventory_mode = "bag"
	inventory_message = ""
	game_state = GameState.INVENTORY
	queue_redraw()

func clamp_inventory_page():
	inventory_page = clampi(inventory_page, 0, maxi(0, int((party_system.inventory.size() - 1) / 9)))

func handle_inventory_input(event):
	if game_state != GameState.INVENTORY or not event.is_pressed() or event.is_echo():
		return
	var members = get_management_members()
	if event.keycode == KEY_ESCAPE:
		game_state = inventory_return_state
	elif event.keycode in [KEY_LEFT, KEY_RIGHT]:
		if not members.is_empty():
			inventory_character_index = (inventory_character_index + members.size() + (-1 if event.keycode == KEY_LEFT else 1)) % members.size()
		inventory_message = ""
	elif event.keycode in [KEY_PAGEUP, KEY_PAGEDOWN]:
		inventory_page += -1 if event.keycode == KEY_PAGEUP else 1
		clamp_inventory_page()
	elif event.keycode in [KEY_B, KEY_E, KEY_D]:
		inventory_mode = "bag" if event.keycode == KEY_B else ("equipment" if event.keycode == KEY_E else "details")
		inventory_message = ""
	else:
		var choice = number_key_to_roster_index(event.keycode)
		if choice < 0 or members.is_empty():
			return
		inventory_character_index = clampi(inventory_character_index, 0, members.size() - 1)
		var member = members[inventory_character_index]
		if inventory_mode == "equipment":
			inventory_message = inventory_system.unequip_item(member, InventorySystem.EQUIPMENT_SLOTS[choice], false, inventory_at_guild())
		elif inventory_mode == "bag":
			inventory_message = inventory_system.use_inventory_item(member, inventory_page * 9 + choice, false, inventory_at_guild())
		clamp_inventory_page()
	queue_redraw()


# ============================================================
# TRAINING HALL
# ============================================================

var training_message: String = ""
var training_pending_member: Dictionary = {}
var training_pending_hp_gain: int = 0
var training_pending_sp_gain: int = 0
var training_choosing_stat: bool = false
var training_choosing_specialization: bool = false

# ============================================================
# INVENTORY UI
# ============================================================

var inventory_character_index: int = 0
var inventory_message: String = ""
var inventory_page: int = 0
var inventory_mode: String = "bag"
var inventory_return_state = GameState.CITY

# ============================================================
# SHOP UI
# ============================================================

var shop_id: String = "general_store"
var shop_mode: String = "buy"
var shop_page: int = 0
var shop_message: String = ""

# ============================================================
# STARTUP
# ============================================================

func bind_party_services():
	combat.formation = party_system
	inventory_system.party_model = party_system
	shop_system.inventory_system = inventory_system
	loot_system.inventory_system = inventory_system

func _ready():

	bind_party_services()
	if not OS.get_environment("DUNGEON_SAVE_PATH").is_empty():
		save_path = OS.get_environment("DUNGEON_SAVE_PATH")

	randomize()

	reset_character_creator()

	queue_redraw()


# ============================================================
# CHARACTER CREATOR RESET
# ============================================================

func reset_character_creator():

	character = CharacterFactory.make_blank_character()

	selected_race_index = -1
	selected_class_index = -1

	race_page = 0
	class_page = 0

	name_buffer = ""


# ============================================================
# INPUT ROUTER
# ============================================================

func _input(event):
	if event.is_pressed() and not event.is_echo() and event.keycode in [KEY_F5, KEY_F9] and game_state not in [GameState.COMBAT, GameState.COMBAT_RESULT]:
		if event.keycode == KEY_F5:
			save_game()
		else:
			load_game()
		queue_redraw()
		return

	if class_skills_open:
		handle_class_skills_input(event)
		return
	if not rogue_skills_open and not formation_menu_open and not developer_menu_open and event.is_pressed() and not event.is_echo() and event.keycode == KEY_K:
		open_class_skills()
		return

	if rogue_skills_open:
		handle_rogue_skills_input(event)
		return
	if not formation_menu_open and not developer_menu_open and game_state == GameState.DUNGEON and event.is_pressed() and not event.is_echo() and event.keycode == KEY_R:
		open_rogue_skills()
		return

	if not formation_menu_open and event.is_pressed() and not event.is_echo() and event.keycode == KEY_I and game_state in [GameState.GUILD, GameState.PARTY_SELECT, GameState.CITY, GameState.WILDERNESS, GameState.DUNGEON, GameState.SHOP, GameState.TRAINING_HALL, GameState.TOWN_HALL, GameState.WARDEN_KEEP, GameState.INN, GameState.TEMPLE]:
		open_inventory(game_state)
		return

	if formation_menu_open:
		handle_formation_menu_input(event)
		return
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_F and game_state in [GameState.GUILD, GameState.PARTY_SELECT, GameState.CITY, GameState.WILDERNESS, GameState.DUNGEON, GameState.INVENTORY, GameState.SHOP, GameState.TRAINING_HALL, GameState.TOWN_HALL, GameState.WARDEN_KEEP, GameState.INN, GameState.TEMPLE]:
		open_formation_menu()
		return

	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_F12:
		developer_menu_open = not developer_menu_open
		queue_redraw()
		return

	if developer_menu_open:
		handle_developer_menu_input(event)
		return

	match game_state:
		GameState.TEMPLE:
			handle_temple_input(event)

		GameState.GUILD:
			handle_guild_input(event)

		GameState.CREATE_RACE:
			handle_race_input(event)

		GameState.CREATE_STATS:
			handle_stats_input(event)

		GameState.CREATE_CLASS:
			handle_class_input(event)

		GameState.CREATE_GENDER:
			handle_gender_input(event)

		GameState.CREATE_NAME:
			handle_name_input(event)

		GameState.CREATE_REVIEW:
			handle_review_input(event)

		GameState.PARTY_SELECT:
			handle_party_select_input(event)

		GameState.CITY:
			handle_city_input(event)

		GameState.WILDERNESS:
			handle_wilderness_input(event)

		GameState.TRAINING_HALL:
			handle_training_hall_input(event)

		GameState.SHOP:
			handle_shop_input(event)

		GameState.TOWN_HALL:
			handle_town_hall_input(event)

		GameState.WARDEN_KEEP:
			handle_warden_keep_input(event)

		GameState.INN:
			handle_inn_input(event)

		GameState.INVENTORY:
			handle_inventory_input(event)

		GameState.DUNGEON:
			handle_dungeon_input(event)

		GameState.COMBAT:
			handle_combat_input(event)

		GameState.COMBAT_RESULT:
			handle_combat_result_input(event)


# ============================================================
# DEVELOPER MENU
# ============================================================

func handle_developer_menu_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:
		developer_menu_open = false
		queue_redraw()
		return

	var action: String = developer_menu.get_action_for_key(event.keycode)
	if action == "":
		return

	apply_developer_action(action)
	queue_redraw()


func apply_developer_action(action: String):
	match action:
		"travel_thornwake":
			city.load_city("thornwake")
			city.reset()
			game_state = GameState.CITY
			developer_menu_open = false

		"travel_wilderness":
			wilderness.reset_to_thornwake()
			game_state = GameState.WILDERNESS
			developer_menu_open = false

		"travel_grayhaven":
			city.load_city("grayhaven")
			city.set_entry(Vector2i(1, 7), 1, "Developer travel: Grayhaven.")
			game_state = GameState.CITY
			developer_menu_open = false

		"travel_dreadmarch":
			wilderness.reset_to_oldroot()
			game_state = GameState.WILDERNESS
			developer_menu_open = false

		"travel_oldroot":
			city.load_city("oldroot")
			city.set_entry(Vector2i(0, 7), 1, "Developer travel: Oldroot.")
			game_state = GameState.CITY
			developer_menu_open = false

		"travel_ironreach":
			city.load_city("ironreach")
			city.set_entry(Vector2i(0, 8), 1, "Developer travel: Ironreach.")
			game_state = GameState.CITY
			developer_menu_open = false

		"dungeon_architect_nave":
			if party_system.can_adventure():
				dev_enter_dungeon("architect_test_church_nave")
			else:
				developer_menu.message = "Choose a conscious active party first. [T] loads the test party at the Guild."
		"dungeon_warehouse":
			dev_enter_dungeon("abandoned_warehouse")
		"dungeon_wine_cellar":
			dev_enter_dungeon("wine_cellar")
		"dungeon_sewers_upper":
			dev_enter_dungeon("thornwake_sewers_upper")
		"dungeon_sewers_lower":
			dev_enter_dungeon("thornwake_sewers_lower")
		"dungeon_prison_barracks":
			dev_enter_dungeon("old_prison_barracks")
		"dungeon_prison_holding":
			dev_enter_dungeon("old_prison_holding")
		"dungeon_prison_torture":
			dev_enter_dungeon("old_prison_torture")
		"dungeon_prison_morgue":
			dev_enter_dungeon("old_prison_morgue")
		"dungeon_reliquary_1":
			dev_enter_dungeon("broken_reliquary_church")
		"dungeon_reliquary_2":
			dev_enter_dungeon("broken_reliquary_archives")
		"dungeon_reliquary_3":
			dev_enter_dungeon("broken_reliquary_catacombs_upper")
		"dungeon_reliquary_4":
			dev_enter_dungeon("broken_reliquary_catacombs_lower")
		"dungeon_reliquary_5":
			dev_enter_dungeon("broken_reliquary_chapel")

		"quest_rats_start":
			quest_system.set_state("rats_in_the_warehouse", "active")
			developer_menu.message = "Rats in the Warehouse -> ACTIVE"
		"quest_rats_complete":
			quest_system.set_state("rats_in_the_warehouse", "completed")
			developer_menu.message = "Rats in the Warehouse -> COMPLETED"
		"quest_wine_start":
			quest_system.set_state("katys_special_vintage", "active")
			developer_menu.message = "A Very Particular Vintage -> ACTIVE"
		"quest_wine_complete":
			quest_system.set_state("katys_special_vintage", "completed")
			developer_menu.message = "A Very Particular Vintage -> COMPLETED"
		"quest_prison_start":
			quest_system.set_state("queen_of_the_old_prison", "active")
			developer_menu.message = "Queen of the Old Prison -> ACTIVE"
		"quest_onika_defeated":
			quest_system.set_state("queen_of_the_old_prison", "onika_defeated")
			add_quest_item("onikas_signet")
			developer_menu.message = "Onika defeated; signet added."
		"quest_prison_complete":
			quest_system.set_state("queen_of_the_old_prison", "completed")
			remove_quest_item("onikas_signet")
			add_quest_item("broken_reliquary_key")
			developer_menu.message = "Old Prison quest completed; Reliquary key added."

		"heal_party":
			for member in party:
				CharacterHealth.heal(member, int(member["max_hp"]))
			developer_menu.message = "Living party members healed."
		"give_xp":
			for member in party:
				member["xp"] = int(member.get("xp", 0)) + 500
			developer_menu.message = "+500 XP to every party member."
		"give_xp_5000":
			for member in party:
				member["xp"] = int(member.get("xp", 0)) + 5000
			developer_menu.message = "+5,000 XP to every party member."
		"give_xp_50000":
			for member in party:
				member["xp"] = int(member.get("xp", 0)) + 50000
			developer_menu.message = "+50,000 XP to every party member."
		"give_gold":
			progression.add_gold(1000)
			developer_menu.message = "+1000 party gold."
		"load_test_party":
			if is_at_guild():
				load_test_roster()
				developer_menu.message = "Test party loaded."
			else:
				developer_menu.message = "Return to the Guild to replace the party."
		"give_reliquary_key":
			add_quest_item("broken_reliquary_key")
			quest_system.set_state("purge_broken_reliquary", "active")
			developer_menu.message = "Broken Reliquary Key added; purge quest active."
		"quest_bristle_defeated":
			quest_system.set_state("purge_broken_reliquary", "bristle_defeated")
			developer_menu.message = "Bristle-Aptarj marked defeated."

		"unlock_dreadmarch":
			quest_system.start_quest("rescue_katy_thornwake")
			quest_system.set_state("rescue_katy_thornwake", "dreadmarch_unlocked")
			developer_menu.message = "Dreadmarch route unlocked; Kazinov revealed."


func dev_enter_dungeon(dungeon_id: String):
	if dungeon.load_dungeon(dungeon_id):
		reset_dungeon_for_adventure()
		game_state = GameState.DUNGEON
		developer_menu_open = false
	else:
		developer_menu.message = "Dungeon not found: " + dungeon_id


# ============================================================
# ADVENTURERS' GUILD
# ============================================================

func handle_guild_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	if handle_roster_paging(event):
		return

	match event.keycode:

		KEY_C:

			reset_character_creator()
			game_state = GameState.CREATE_RACE
			queue_redraw()

		KEY_P:

			if roster.size() > 0:

				game_state = GameState.PARTY_SELECT

				queue_redraw()

		KEY_D:

			if roster.size() > 0:

				party_system.delete_character(str(roster.back()["character_id"]), true)
				clamp_roster_page()

				queue_redraw()

		KEY_T:

			start_test_party()

		KEY_L:

			if party_system.can_adventure():

				game_state = GameState.CITY
				save_game()

				city.set_message(
					"You leave the Adventurers' Guild."
				)

				queue_redraw()


func is_at_guild() -> bool:
	return game_state == GameState.GUILD or game_state == GameState.PARTY_SELECT


func load_test_roster():
	if not is_at_guild():
		return
	party_system = PartyScript.new()
	bind_party_services()
	for member in TestParty.create():
		party_system.register_character(member)
		party_system.assign_member(str(member["character_id"]), party_system.roster.size() - 1, true)
	roster_page = 0


func start_test_party():
	load_test_roster()
	city.reset()
	game_state = GameState.CITY
	save_game()
	queue_redraw()


# ============================================================
# RACE SELECTION
# ============================================================

func handle_race_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:

		game_state = GameState.GUILD

		queue_redraw()

		return

	if event.keycode == KEY_N:

		if (
			(race_page + 1) * PAGE_SIZE
			< races.size()
		):

			race_page += 1

			queue_redraw()

		return

	if event.keycode == KEY_P:

		if race_page > 0:

			race_page -= 1

			queue_redraw()

		return

	var choice = number_key_to_index(
		event.keycode
	)

	if choice == -1:
		return

	var actual_index = (
		race_page * PAGE_SIZE
		+ choice
	)

	if actual_index >= races.size():
		return

	select_race(
		actual_index
	)


func select_race(
	index: int
):

	selected_race_index = index

	roll_character_stats()

	game_state = GameState.CREATE_STATS

	queue_redraw()


# ============================================================
# CHARACTER STAT GENERATION
# ============================================================

func roll_character_stats():

	CharacterFactory.roll_stats(
		character
	)

	CharacterFactory.apply_race(
		character,
		races[selected_race_index]
	)


func handle_stats_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	match event.keycode:

		KEY_R:

			roll_character_stats()

			queue_redraw()

		KEY_ENTER:

			selected_class_index = -1

			class_page = 0

			game_state = GameState.CREATE_CLASS

			queue_redraw()

		KEY_ESCAPE:

			game_state = GameState.CREATE_RACE

			queue_redraw()


# ============================================================
# CLASS SELECTION
# ============================================================

func qualifies_for_class(
	class_data: Dictionary
) -> bool:

	return CharacterFactory.qualifies_for_class(
		character,
		class_data
	)


func get_requirement_text(
	class_data: Dictionary
) -> String:

	var result = ""

	for stat in class_data["requirements"]:

		if result != "":
			result += ", "

		result += stat.to_upper()

		result += " "

		result += str(
			class_data["requirements"][stat]
		)

	return result


func handle_class_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:

		game_state = GameState.CREATE_STATS

		queue_redraw()

		return

	if event.keycode == KEY_N:

		if (
			(class_page + 1) * PAGE_SIZE
			< classes.size()
		):

			class_page += 1

			queue_redraw()

		return

	if event.keycode == KEY_P:

		if class_page > 0:

			class_page -= 1

			queue_redraw()

		return

	var choice = number_key_to_index(
		event.keycode
	)

	if choice == -1:
		return

	var actual_index = (
		class_page * PAGE_SIZE
		+ choice
	)

	if actual_index >= classes.size():
		return

	var class_data = classes[
		actual_index
	]

	if not qualifies_for_class(
		class_data
	):
		return

	selected_class_index = actual_index

	character["class"] = (
		class_data["name"]
	)

	# All new adventurers begin with a small shared SP pool.
	# Class differences appear through SP gained on later levels.
	character["max_sp"] = 10
	character["sp"] = character["max_sp"]

	game_state = GameState.CREATE_GENDER

	queue_redraw()


# ============================================================
# GENDER SELECTION
# ============================================================

func handle_gender_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:

		game_state = GameState.CREATE_CLASS

		queue_redraw()

		return

	match event.keycode:

		KEY_1:

			select_gender(
				"Male"
			)

		KEY_2:

			select_gender(
				"Female"
			)

		KEY_3:

			select_gender(
				"Nonbinary"
			)


func select_gender(
	gender: String
):

	CharacterFactory.apply_gender(
		character,
		gender
	)

	name_buffer = ""

	game_state = GameState.CREATE_NAME

	queue_redraw()


# ============================================================
# NAME
# ============================================================

func handle_name_input(event):

	if not event.is_pressed():
		return

	if event.keycode == KEY_ESCAPE:

		game_state = GameState.CREATE_GENDER

		queue_redraw()

		return

	if event.keycode == KEY_ENTER:

		var cleaned_name = (
			name_buffer.strip_edges()
		)

		if cleaned_name.length() > 0:

			character["name"] = cleaned_name

			game_state = GameState.CREATE_REVIEW

			queue_redraw()

		return

	if event.keycode == KEY_BACKSPACE:

		if name_buffer.length() > 0:

			name_buffer = name_buffer.left(
				name_buffer.length() - 1
			)

		queue_redraw()

		return

	if event.unicode > 0:

		var typed_character = char(
			event.unicode
		)

		if name_buffer.length() < 16:

			name_buffer += typed_character

		queue_redraw()


# ============================================================
# REVIEW / ADD TO ROSTER
# ============================================================

func handle_review_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	match event.keycode:

		KEY_ENTER:

			add_character_to_roster()

		KEY_ESCAPE:

			game_state = GameState.CREATE_NAME

			queue_redraw()


func add_character_to_roster():

	if not is_at_guild() and game_state != GameState.CREATE_REVIEW:
		return

	var finished_character = (
		character.duplicate(true)
	)

	party_system.register_character(finished_character)

	reset_character_creator()

	game_state = GameState.GUILD

	queue_redraw()


# ============================================================
# PARTY SELECTION
# ============================================================

func clamp_roster_page():
	roster_page = clampi(roster_page, 0, maxi(0, int((roster.size() - 1) / ROSTER_PAGE_SIZE)))


func handle_roster_paging(event) -> bool:
	if event.keycode == KEY_PAGEUP or event.keycode == KEY_PAGEDOWN:
		roster_page += -1 if event.keycode == KEY_PAGEUP else 1
		clamp_roster_page()
		queue_redraw()
		return true
	return false


func handle_party_select_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	if handle_roster_paging(event):
		return
	match event.keycode:
		KEY_ESCAPE:
			game_state = GameState.GUILD
		KEY_ENTER:
			if party_system.can_adventure():
				game_state = GameState.CITY
				save_game()
			else:
				party_message = "Choose at least one conscious adventurer before leaving."
		KEY_LEFT:
			selected_formation_slot = (selected_formation_slot + 5) % 6
		KEY_RIGHT:
			selected_formation_slot = (selected_formation_slot + 1) % 6
		KEY_BACKSPACE:
			party_system.remove_member(party_system.slots[selected_formation_slot], is_at_guild())
		_:
			var choice = number_key_to_roster_index(event.keycode)
			if choice >= 0:
				toggle_party_member(roster_page * ROSTER_PAGE_SIZE + choice)
	queue_redraw()


func number_key_to_roster_index(
	keycode: int
) -> int:

	match keycode:

		KEY_1:
			return 0

		KEY_2:
			return 1

		KEY_3:
			return 2

		KEY_4:
			return 3

		KEY_5:
			return 4

		KEY_6:
			return 5

		KEY_7:
			return 6

		KEY_8:
			return 7

		KEY_9:
			return 8

	return -1


func toggle_party_member(roster_index: int):
	if not is_at_guild() or roster_index < 0 or roster_index >= roster.size():
		return
	var id: String = roster[roster_index]["character_id"]
	party_system.assign_member(id, selected_formation_slot, is_at_guild())
	party_message = "Assigned " + str(roster[roster_index]["name"]) + " to " + PartyScript.SLOT_NAMES[selected_formation_slot] + "."


func get_party_index(target: Dictionary) -> int:
	var id = str(target.get("character_id", ""))
	for i in range(party.size()):
		if str(party[i].get("character_id", "")) == id:
			return i
	return -1


func reset_dungeon_for_adventure():

	dungeon.reset()
	dungeon.begin_expedition()

	for member in party:
		clear_temporary_combat_flags(member)

# ============================================================
# NUMBER KEY HELPERS
# ============================================================

func number_key_to_index(
	keycode: int
) -> int:

	match keycode:

		KEY_1:
			return 0

		KEY_2:
			return 1

		KEY_3:
			return 2

		KEY_4:
			return 3

		KEY_5:
			return 4

		KEY_6:
			return 5

		KEY_7:
			return 6

	return -1


# ============================================================
# CITY INPUT
# ============================================================

func handle_city_input(event):

	if (
		event.is_pressed()
		and not event.is_echo()
		and event.keycode == KEY_I
	):

		open_inventory(
			GameState.CITY
		)

		return

	if event.is_action_pressed("ui_up"):

		city.move_forward()
		queue_redraw()

	elif event.is_action_pressed("ui_down"):

		city.move_backward()
		queue_redraw()

	elif event.is_action_pressed("ui_left"):

		city.turn_left()
		queue_redraw()

	elif event.is_action_pressed("ui_right"):

		city.turn_right()
		queue_redraw()

	elif (
		event.is_pressed()
		and not event.is_echo()
		and event.keycode == KEY_ENTER
	):

		activate_city_location()


func activate_city_location():

	var location = city.get_current_location()

	if location.is_empty():
		return

	match location["type"]:

		"guild":
			game_state = GameState.GUILD

		"town_hall":
			enter_town_hall()

		"dungeon":
			var dungeon_id = location.get("dungeon_id", "")

			if dungeon_id == "abandoned_warehouse" and not quest_system.is_started("rats_in_the_warehouse"):
				city.set_message("The warehouse is shut tight. Perhaps someone at Town Hall knows more.")
			elif dungeon_id == "old_prison_barracks" and not quest_system.is_started("queen_of_the_old_prison"):
				city.set_message("The Old Prison is sealed by order of Warden Harlic Dorn.")
			elif dungeon_id != "":
				enter_dungeon(dungeon_id)

		"warden_keep":
			enter_warden_keep()

		"training_hall":
			enter_training_hall()

		"shop":
			enter_shop()

		"inn":
			enter_inn()

		"wilderness_exit":
			enter_wilderness()

		"temple":
			temple_character_index = 0
			temple_message = "Resurrection restores a dead adventurer to 1 HP."
			game_state = GameState.TEMPLE

	queue_redraw()



# ============================================================
# ASHENWOOD WILDERNESS
# ============================================================

func enter_wilderness():
	match city.city_id:
		"grayhaven":
			wilderness.reset_to_grayhaven()
		"oldroot":
			wilderness.reset_to_oldroot()
		"ironreach":
			wilderness.reset_to_ironreach()
		_:
			wilderness.reset_to_thornwake()
	game_state = GameState.WILDERNESS
	queue_redraw()


func handle_wilderness_input(event):
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_I:
		open_inventory(GameState.WILDERNESS)
		return
	var moved = false
	if event.is_action_pressed("ui_up"):
		moved = wilderness.move_forward()
	elif event.is_action_pressed("ui_down"):
		moved = wilderness.move_backward()
	elif event.is_action_pressed("ui_left"):
		wilderness.turn_left()
	elif event.is_action_pressed("ui_right"):
		wilderness.turn_right()
	elif event.is_pressed() and not event.is_echo() and event.keycode == KEY_ENTER:
		activate_wilderness_location()
	if moved:
		var rate = wilderness.get_encounter_chance()
		if randf() < rate:
			start_wilderness_combat()
	queue_redraw()


func activate_wilderness_location():
	var location = wilderness.get_current_location()
	if location.is_empty():
		return

	match location.get("type", ""):
		"town":
			var town_id = location.get("town_id", "")
			if city.load_city(town_id):
				if town_id == "thornwake":
					city.set_entry(Vector2i(16, 12), 3, "You pass through Thornwake's east gate.")
				elif town_id == "grayhaven":
					city.set_entry(Vector2i(0, 7), 1, "You pass through Grayhaven's west gate.")
				elif town_id == "oldroot":
					city.set_entry(Vector2i(0, 7), 1, "You enter Oldroot from the Dreadmarch.")
				elif town_id == "ironreach":
					city.set_entry(Vector2i(0, 8), 1, "You pass beneath Ironreach's western gate.")
				game_state = GameState.CITY

		"dungeon":
			if location.get("dungeon_id", "") == "broken_reliquary":
				if has_quest_item("broken_reliquary_key"):
					if dungeon.load_dungeon("broken_reliquary_church"):
						reset_dungeon_for_adventure()
						game_state = GameState.DUNGEON
				else:
					wilderness.message = "The doors to the Broken Reliquary are locked shut."

		"zone_exit":
			var target = location.get("wilderness_id", "")
			if target == "dreadmarch_wilderness":
				if quest_system.get_state("rescue_katy_thornwake") == "dreadmarch_unlocked":
					wilderness.reset_to_dreadmarch_west_gate()
				else:
					wilderness.message = "The eastern road is closed. Chief Warden Rorik Feld may know why."
			elif target == "ashenwood_wilderness":
				wilderness.reset_to_ashenwood_east_gate()

		"fort_dread":
			wilderness.message = "Fort Dread rises like a black tooth from the stone. Kazinov holds Katy somewhere beyond its walls. The fortress is not yet ready to enter."

	queue_redraw()


func start_wilderness_combat():
	current_combat_tag = "wilderness"
	var table = WildernessEncounterData.get_table(wilderness.wilderness_id)
	if table.is_empty(): return
	var encounter = roll_dungeon_encounter(table)
	combat.start_specific_encounter(encounter["enemy_id"], randi_range(encounter["min_group"], encounter["max_group"]))
	prepare_combat_state()


# ============================================================
# THORNWAKE TOWN HALL / KATY THORNWAKE
# ============================================================

func enter_town_hall():

	game_state = GameState.TOWN_HALL
	queue_redraw()


func handle_town_hall_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
		city.set_message("You leave Thornwake Town Hall.")
		queue_redraw()
		return

	if event.keycode != KEY_ENTER:
		return

	var rescue_state = quest_system.get_state("rescue_katy_thornwake")
	if rescue_state == "katy_missing":
		quest_system.set_state("rescue_katy_thornwake", "dreadmarch_unlocked")
		queue_redraw()
		return
	if rescue_state == "dreadmarch_unlocked":
		return

	var rat_state = quest_system.get_state("rats_in_the_warehouse")

	match rat_state:
		"not_started":
			quest_system.start_quest("rats_in_the_warehouse")

		"boss_defeated":
			quest_system.complete_quest("rats_in_the_warehouse")
			progression.add_gold(100)
			quest_system.start_quest("katys_special_vintage")

		"completed":
			if (
				quest_system.get_state("katys_special_vintage") == "wine_found"
				and has_quest_item("katys_special_wine")
			):
				remove_quest_item("katys_special_wine")
				quest_system.complete_quest("katys_special_vintage")
				progression.add_gold(250)

		_:
			pass

	queue_redraw()


func get_katy_dialogue() -> String:
	var rescue_state = quest_system.get_state("rescue_katy_thornwake")
	if rescue_state == "katy_missing":
		return (
			"Chief Warden Rorik Feld waits beside Katy's empty desk, travel dust still on his boots.\n\n"
			+ "\"Katy was taken. The rider was Kazinov -- a Death Knight out of Fort Dread. "
			+ "He has terrorized the eastern country for years, but this is the first time he has struck this far into Ashenwood.\"\n\n"
			+ "Rorik points to the eastern road on a worn map. \"Cross into the Dreadmarch and make for Oldroot. "
			+ "Ironreach lies farther southeast. Fort Dread stands north of it, hard against the Krual foothills.\""
		)
	if rescue_state == "dreadmarch_unlocked":
		return (
			"Rorik Feld keeps the eastern road marked on the map.\n\n"
			+ "\"Oldroot is your first safe stop. From there, cross the Dreadmarch toward Ironreach. "
			+ "Fort Dread lies north of the trading town. Find Kazinov. Bring Katy home.\""
		)

	var rat_state = quest_system.get_state("rats_in_the_warehouse")
	var wine_state = quest_system.get_state("katys_special_vintage")

	match rat_state:
		"not_started":
			return (
				"Welcome to Thornwake. I'm Katy Thornwake.\n\n"
				+ "We've got a rat problem, and it is getting worse. "
				+ "I believe they're coming from the abandoned warehouse here in town.\n\n"
				+ "If your company is looking for work, investigate the warehouse "
				+ "and put an end to whatever is nesting there."
			)
		"active":
			return "The rats are still coming from the abandoned warehouse.\n\nSearch it thoroughly. If there's a nest in there, I want the source dealt with."
		"boss_defeated":
			return "You cleared the warehouse? Good. Thornwake owes you a debt.\n\nTake 100 gold for the work. You've proven your company can be trusted."
		"completed":
			match wine_state:
				"active":
					return "I do have another job for you. A less heroic one, perhaps.\n\nI'm looking for a very particular bottle of wine. The innkeeper believes one may still be in the old wine cellar beneath the inn.\n\nSpeak with the innkeeper. Bring the bottle to me if you find it."
				"cellar_open":
					return "The innkeeper has opened the cellar for you. Find that bottle and bring it back to me."
				"wine_found":
					return "You found it! And judging by the smell of you, the cellar was more complicated than expected.\n\nTake 250 gold. I suspect this will not be the last strange thing we ask of your company."
				"completed":
					return "Enjoy the quiet while it lasts. Ashenwood has a habit of producing new troubles."

	return "Katy Thornwake studies your company with interest."


func get_katy_prompt() -> String:
	var rescue_state = quest_system.get_state("rescue_katy_thornwake")
	if rescue_state == "katy_missing":
		return "[ENTER] ASK RORIK ABOUT KATY / OPEN EASTERN ROAD     [ESC] LEAVE"
	if rescue_state == "dreadmarch_unlocked":
		return "[ESC] LEAVE TOWN HALL"

	var rat_state = quest_system.get_state("rats_in_the_warehouse")
	var wine_state = quest_system.get_state("katys_special_vintage")
	match rat_state:
		"not_started":
			return "[ENTER] ACCEPT: RATS IN THE WAREHOUSE     [ESC] LEAVE"
		"boss_defeated":
			return "[ENTER] COMPLETE QUEST / CLAIM REWARD     [ESC] LEAVE"
		"completed":
			if wine_state == "wine_found":
				return "[ENTER] GIVE KATY THE WINE / CLAIM REWARD     [ESC] LEAVE"
	return "[ESC] LEAVE TOWN HALL"


# ============================================================
# GRAYHAVEN WARDEN KEEP / HARLIC DORN
# ============================================================

func enter_warden_keep():
	game_state = GameState.WARDEN_KEEP
	queue_redraw()

func handle_warden_keep_input(event):
	if not event.is_pressed() or event.is_echo(): return
	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
		city.set_message("You leave Warden Keep.")
		queue_redraw()
		return
	if event.keycode != KEY_ENTER: return

	var prison_state = quest_system.get_state("queen_of_the_old_prison")
	var reliquary_state = quest_system.get_state("purge_broken_reliquary")

	if prison_state == "not_started":
		quest_system.start_quest("queen_of_the_old_prison")
	elif prison_state == "onika_defeated" and has_quest_item("onikas_signet"):
		remove_quest_item("onikas_signet")
		quest_system.complete_quest("queen_of_the_old_prison")
		progression.add_gold(500)
		for member in party:
			member["xp"] += 150
		add_quest_item("broken_reliquary_key")
		quest_system.start_quest("purge_broken_reliquary")
	elif prison_state == "completed" and reliquary_state == "bristle_defeated":
		quest_system.complete_quest("purge_broken_reliquary")
		progression.add_gold(1000)
		for member in party:
			member["xp"] += 300
		quest_system.start_quest("rescue_katy_thornwake")
		quest_system.set_state("rescue_katy_thornwake", "katy_missing")
	queue_redraw()

func get_harlic_dialogue() -> String:
	var prison_state = quest_system.get_state("queen_of_the_old_prison")
	var reliquary_state = quest_system.get_state("purge_broken_reliquary")
	var rescue_state = quest_system.get_state("rescue_katy_thornwake")

	if prison_state == "not_started":
		return "Warden Harlic Dorn is a broad, scarred veteran in worn mail.\n\n\"The Old Prison belongs to bandits now. Onika calls herself their queen. I don't have enough wardens left to take four levels room by room.\"\n\n\"Kill Onika. Break her crew. Bring me proof she's dead.\""
	if prison_state == "active":
		return "Harlic rests both hands on the pommel of an old campaign sword.\n\n\"Onika is somewhere below the Guard Barracks. Don't underestimate her. She didn't earn that crown by being stupid.\""
	if prison_state == "onika_defeated":
		return "Harlic turns Onika's silver signet between two scarred fingers.\n\n\"So. The Bandit Queen is dead. Good work.\"\n\nHe pays the company 500 gold and awards each adventurer 150 XP. Then he sets an old black iron key on the table.\n\n\"This opens the Broken Reliquary out in Ashenwood. It was once a church of Tay'lore. Bristle-Aptarj turned it into a charnel house. My wardens sealed him in. Take the key. Go finish what we couldn't.\""
	if reliquary_state == "active":
		return "Harlic studies the old black iron key.\n\n\"The magic lock will know it. Once you're inside, expect the dead. Bristle-Aptarj tried to raise an army from those catacombs. Purge the church and make certain he never tries again.\""
	if reliquary_state == "bristle_defeated":
		return "Harlic listens without interrupting as you describe Bristle-Aptarj's fall.\n\n\"Then it's finally done. Ashenwood owes you more than it knows.\"\n\nHe awards the company 1,000 gold and 300 XP to each adventurer.\n\n\"You've done what my wardens could not. Go back to Thornwake. You've earned some rest.\""
	if rescue_state == "katy_missing" or rescue_state == "dreadmarch_unlocked":
		return "Harlic nods once. \"The Reliquary is finished. Whatever comes next, Grayhaven remembers what you did there.\""
	return "Harlic nods once. \"Grayhaven remembers what you did.\""

func get_harlic_prompt() -> String:
	var prison_state = quest_system.get_state("queen_of_the_old_prison")
	var reliquary_state = quest_system.get_state("purge_broken_reliquary")
	if prison_state == "not_started": return "[ENTER] ACCEPT: QUEEN OF THE OLD PRISON     [ESC] LEAVE"
	if prison_state == "onika_defeated": return "[ENTER] GIVE ONIKA'S SIGNET / CLAIM REWARD     [ESC] LEAVE"
	if reliquary_state == "bristle_defeated": return "[ENTER] REPORT BRISTLE-APTARJ'S DEATH / CLAIM REWARD     [ESC] LEAVE"
	return "[ESC] LEAVE WARDEN KEEP"


# ============================================================
# WAYFARER'S INN
# ============================================================

func enter_inn():

	inn_message = ""
	game_state = GameState.INN
	queue_redraw()


func handle_inn_input(event):

	if not event.is_pressed() or event.is_echo():
		return

	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
		city.set_message("You leave the inn.")
		queue_redraw()
		return

	if city.city_id != "thornwake":
		return

	if event.keycode != KEY_ENTER:
		return

	var wine_state = quest_system.get_state("katys_special_vintage")

	if wine_state == "active":
		quest_system.set_state("katys_special_vintage", "cellar_open")
		inn_message = (
			"The innkeeper sighs and produces a heavy iron key. "
			+ "\"If Katy sent you, you can look. The cellar door is behind the bar. "
			+ "Mind the rats... and anything else that's taken up drinking down there.\""
		)
		queue_redraw()
		return

	if wine_state == "cellar_open" or wine_state == "wine_found":
		enter_dungeon("wine_cellar")
		return

	if wine_state == "completed":
		inn_message = "The innkeeper nods toward the cellar door. \"I've had enough of that place.\""
	else:
		inn_message = "The innkeeper polishes a mug. \"Cellar's closed. Nothing down there worth your neck.\""

	queue_redraw()


func get_inn_dialogue() -> String:

	if city.city_id == "grayhaven":
		return "The Iron Lantern is quiet compared with Thornwake's inn. Prison guards, caravan hands, and off-duty wardens keep mostly to themselves. For now, it offers shelter and rumors rather than services."
	if city.city_id == "oldroot":
		return "The Old Root Inn is low-roofed and sturdy. Dreadmarch wind rattles the shutters while caravan hands trade news of ruined forts, dry ravines, and undead seen on the eastern roads."
	if city.city_id == "ironreach":
		return "The Marcher's Rest is crowded with traders, drovers, mercenaries, and travelers from across the Dreadmarch. Fort Dread is a frequent subject, but few speak Kazinov's name above a murmur."

	if inn_message != "":
		return inn_message

	var wine_state = quest_system.get_state("katys_special_vintage")

	match wine_state:
		"active":
			return (
				"The Wayfarer's Inn is warm, loud, and crowded. "
				+ "Behind the bar, the innkeeper gives your company a long look.\n\n"
				+ "\"Katy sent you about that bottle, didn't she? "
				+ "The old wine cellar hasn't been safe for a while.\""
			)
		"cellar_open", "wine_found":
			return (
				"The iron cellar door stands open behind the bar. "
				+ "Cold, sour air rises from the stairwell."
			)
		"completed":
			return "The innkeeper raises a mug to you. The cellar door remains firmly shut."

	return (
		"The Wayfarer's Inn is full of travelers, laborers, and locals. "
		+ "The innkeeper seems busy and has no work for you."
	)


func get_inn_prompt() -> String:

	if city.city_id != "thornwake":
		return "[ESC] LEAVE INN"

	var wine_state = quest_system.get_state("katys_special_vintage")

	if wine_state == "active":
		return "[ENTER] ASK ABOUT KATY'S WINE     [ESC] LEAVE"
	if wine_state == "cellar_open" or wine_state == "wine_found":
		return "[ENTER] ENTER WINE CELLAR     [ESC] LEAVE"

	return "[ESC] LEAVE INN"


# ============================================================
# PARTY QUEST ITEMS
# ============================================================

func add_quest_item(item_id: String) -> void:
	quest_items[item_id] = true


func has_quest_item(item_id: String) -> bool:
	return quest_items.get(item_id, false)


func remove_quest_item(item_id: String) -> void:
	quest_items.erase(item_id)


# ============================================================
# GENERAL STORE
# ============================================================

func enter_shop():
	if party.is_empty():
		city.set_message("You need a party before shopping.")
		return
	shop_mode = "buy"
	shop_page = 0
	shop_message = "Buy for the shared inventory; sell unequipped items."
	game_state = GameState.SHOP
	queue_redraw()

func get_shop_choices() -> Array:
	return shop_system.get_stock(shop_id) if shop_mode == "buy" else party_system.inventory

func clamp_shop_page():
	shop_page = clampi(shop_page, 0, maxi(0, int((get_shop_choices().size() - 1) / 9)))

func handle_shop_input(event):
	if game_state != GameState.SHOP or not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
		city.set_message("You leave the General Store.")
	elif event.keycode in [KEY_B, KEY_S]:
		shop_mode = "buy" if event.keycode == KEY_B else "sell"
		shop_page = 0
		shop_message = ""
	elif event.keycode in [KEY_PAGEUP, KEY_PAGEDOWN]:
		shop_page += -1 if event.keycode == KEY_PAGEUP else 1
		clamp_shop_page()
	else:
		var choice = number_key_to_roster_index(event.keycode)
		if choice < 0:
			return
		var index = shop_page * 9 + choice
		var choices = get_shop_choices()
		if index >= choices.size():
			return
		if shop_mode == "buy":
			shop_message = shop_system.buy_item(shop_id, {}, str(choices[index]), progression)
		else:
			shop_message = shop_system.sell_item(shop_id, {}, index, progression)
		clamp_shop_page()
	queue_redraw()


# ============================================================
# TRAINING HALL
# ============================================================

func enter_training_hall():
	training_pending_member = {}
	training_pending_hp_gain = 0
	training_pending_sp_gain = 0
	training_choosing_stat = false
	training_choosing_specialization = false
	training_message = "The masters examine your party."
	ensure_party_sp_fields()
	game_state = GameState.TRAINING_HALL
	queue_redraw()


func handle_training_hall_input(event):
	if not event.is_pressed() or event.is_echo():
		return

	if training_choosing_specialization:
		if event.keycode == KEY_1:
			training_pending_member["specialization"] = "tank"
			training_message = str(training_pending_member.get("name", "Warrior")) + " chooses the Tank specialization."
			training_pending_member = {}
			training_choosing_specialization = false
			queue_redraw()
		elif event.keycode == KEY_ESCAPE:
			training_message = "Choose specialization 1 to finish training."
			queue_redraw()
		return

	if training_choosing_stat:
		if event.keycode == KEY_ESCAPE:
			training_message = "Choose a stat to complete the level."
			queue_redraw()
			return

		var stat_choice = number_key_to_index(event.keycode)
		if stat_choice < 0 or stat_choice > 4:
			return

		complete_training_stat_choice(stat_choice)
		queue_redraw()
		return

	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
		city.set_message("You leave the Training Hall.")
		queue_redraw()
		return

	var choice = number_key_to_roster_index(event.keycode)
	if choice == -1 or choice >= party.size():
		return

	train_character(party[choice])
	queue_redraw()


func train_character(member: Dictionary):
	if not CharacterHealth.conscious(member):
		training_message = "Heal or resurrect this adventurer before training."
		return
	ensure_character_sp_fields(member)

	var required_xp = get_xp_required_for_next_level(member["level"])
	if member["xp"] < required_xp:
		training_message = (
			member["name"]
			+ " needs "
			+ str(required_xp - member["xp"])
			+ " more XP to advance."
		)
		return

	var gains = get_level_gains(member.get("class", ""))
	training_pending_member = member
	training_pending_hp_gain = gains["hp"]
	training_pending_sp_gain = gains["sp"]
	training_choosing_stat = true

	training_message = (
		member["name"]
		+ " is ready for level "
		+ str(member["level"] + 1)
		+ ". Choose a stat to increase."
	)


func complete_training_stat_choice(stat_choice: int):
	if training_pending_member.is_empty():
		training_choosing_stat = false
		return

	var stat_keys = ["str", "int", "dex", "con", "lck"]
	var stat_names = ["STR", "INT", "DEX", "CON", "LCK"]
	var stat_key = stat_keys[stat_choice]
	var stat_name = stat_names[stat_choice]
	var member = training_pending_member

	member["level"] += 1
	member["max_hp"] += training_pending_hp_gain
	member["max_sp"] += training_pending_sp_gain
	member[stat_key] += 1
	CharacterHealth.heal(member, int(member["max_hp"]))
	member["sp"] = member["max_sp"]

	training_message = (
		member["name"]
		+ " advances to level "
		+ str(member["level"])
		+ "!  HP +"
		+ str(training_pending_hp_gain)
		+ ", SP +"
		+ str(training_pending_sp_gain)
		+ ", "
		+ stat_name
		+ " +1."
	)

	if str(member.get("class", "")) in ["Warrior", "Paladin", "Berserker"] and int(member.get("level", 1)) >= 9 and str(member.get("specialization", "")) == "":
		training_pending_member = member
		training_choosing_specialization = true
		training_message = "Choose a " + str(member.get("class", "")) + " specialization to finish training."

	if not training_choosing_specialization:
		training_pending_member = {}
	training_pending_hp_gain = 0
	training_pending_sp_gain = 0
	training_choosing_stat = false


func get_level_gains(character_class: String) -> Dictionary:
	match character_class:
		"Warrior":
			return {"hp": 10, "sp": 2}
		"Paladin":
			return {"hp": 9, "sp": 4}
		"Berserker":
			return {"hp": 11, "sp": 1}
		"Hunter":
			return {"hp": 8, "sp": 3}
		"Rogue":
			return {"hp": 7, "sp": 3}
		"Bard":
			return {"hp": 6, "sp": 6}
		"Monk":
			return {"hp": 8, "sp": 4}
		"Shaman":
			return {"hp": 6, "sp": 7}
		"Druid":
			return {"hp": 8, "sp": 6}
		"Priest":
			return {"hp": 6, "sp": 8}
		"Conjurer":
			return {"hp": 5, "sp": 10}
		"Magician":
			return {"hp": 4, "sp": 11}
		"Warlock":
			return {"hp": 5, "sp": 10}

	return {"hp": 6, "sp": 4}


func ensure_character_sp_fields(member: Dictionary):
	if not member.has("max_sp"):
		member["max_sp"] = 10
	if not member.has("sp"):
		member["sp"] = member["max_sp"]


func ensure_party_sp_fields():
	for member in party:
		ensure_character_sp_fields(member)


func get_xp_required_for_next_level(current_level: int) -> int:
	match current_level:
		1:
			return 50
		2:
			return 125
		3:
			return 250
		4:
			return 450
		5:
			return 700
		6:
			return 1000
		7:
			return 1400
		8:
			return 1900
		9:
			return 2500

	# From level 10 onward, each next level costs 750 more total XP
	# than the previous threshold. This is intentionally simple for 1.0.
	return 2500 + (current_level - 9) * 750


# ============================================================
# CITY / DUNGEON TRANSITIONS
# ============================================================

func enter_dungeon(dungeon_id: String = "abandoned_warehouse"):

	if not dungeon.load_dungeon(dungeon_id):
		city.set_message("That dungeon is not available.")
		return

	reset_dungeon_for_adventure()
	game_state = GameState.DUNGEON
	queue_redraw()


func leave_dungeon(target_city_id: String = ""):

	clear_all_combat_flags()
	if target_city_id == "":
		target_city_id = str(dungeon.dungeon_data.get("town", "thornwake"))
	city.load_city(target_city_id)
	if target_city_id == "grayhaven":
		city.set_entry(Vector2i(7,9), 2, "You emerge from the Old Prison into Grayhaven.")
	else:
		city.set_message("You emerge back into Thornwake.")
	game_state = GameState.CITY
	queue_redraw()


# ============================================================
# DUNGEON INPUT
# ============================================================

func handle_dungeon_input(event):
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_L:
		dungeon.lantern_on = not dungeon.lantern_on
		dungeon.message = "Lantern lit. Visibility restored." if dungeon.lantern_on else "Lantern extinguished. Dark areas limit visibility."
		queue_redraw()
		return

	if (
		event.is_pressed()
		and not event.is_echo()
		and event.keycode == KEY_I
	):
		open_inventory(GameState.DUNGEON)
		return

	if event.is_action_pressed("ui_up"):

		if dungeon.move_forward():
			check_dungeon_tile()

		queue_redraw()

	elif event.is_action_pressed("ui_down"):

		if dungeon.move_backward():
			check_dungeon_tile()

		queue_redraw()

	elif event.is_action_pressed("ui_left"):
		dungeon.turn_left()
		queue_redraw()

	elif event.is_action_pressed("ui_right"):
		dungeon.turn_right()
		queue_redraw()

	elif (
		event.is_pressed()
		and not event.is_echo()
		and event.keycode == KEY_ENTER
	):
		activate_dungeon_transition()

	elif (
		event.is_pressed()
		and not event.is_echo()
		and event.keycode == KEY_G
	):
		if dungeon.dungeon_id == "abandoned_warehouse":
			leave_dungeon()


# ============================================================
# DUNGEON TRANSITIONS / ENCOUNTERS
# ============================================================

func check_dungeon_tile():
	# Resolve the entered tile before encounters; one-shot traps keep feedback visible.
	var trap = dungeon.get_interaction_at(dungeon.player_pos)
	if DungeonInteractions.trap_active(dungeon, trap):
		for member in party:
			if CharacterHealth.conscious(member):
				var result = DungeonInteractions.trigger_trap(dungeon, trap, member)
				dungeon.message = str(result["message"])
				if combat.party_defeated(party):
					combat_result_text = "THE PARTY HAS FALLEN.\n\nGame over. Reload the last save to continue."
					game_state = GameState.COMBAT_RESULT
				return

	var fixed_encounter = dungeon.get_current_fixed_encounter()

	if not fixed_encounter.is_empty():
		start_fixed_encounter(fixed_encounter)
		return

	if handle_current_dungeon_event():
		return

	var transition = dungeon.get_current_transition()

	if not transition.is_empty() and not transition.get("requires_interact", false):
		perform_dungeon_transition(transition)
		return

	check_for_encounter()


func activate_dungeon_transition():
	if game_state != GameState.DUNGEON:
		return
	var interaction = DungeonInteractions.interact(dungeon, quest_items)
	if bool(interaction.get("handled", false)):
		progression.add_gold(int(interaction.get("gold", 0)))
		dungeon.message = str(interaction["message"])
		queue_redraw()
		return
	if not dungeon.get_rogue_object().is_empty():
		open_rogue_skills()
		return

	if not dungeon.get_exploration_object().is_empty():
		open_class_skills()
		return
	var transition = dungeon.get_current_transition()

	if transition.is_empty():
		return

	perform_dungeon_transition(transition)


func perform_dungeon_transition(transition: Dictionary):
	var required = str(transition.get("requires_defeated", ""))
	if not required.is_empty() and not dungeon.is_fixed_encounter_defeated(dungeon.dungeon_id, required):
		dungeon.message = "The trapdoor is sealed. Defeat the guardian first."
		queue_redraw()
		return

	if transition.get("to_wilderness", false):
		clear_all_combat_flags()
		game_state = GameState.WILDERNESS
		wilderness.message = "You step out of the Broken Reliquary into the Ashenwood."
		queue_redraw()
		return

	if transition.get("to_city", false):
		leave_dungeon(str(transition.get("to_city_id", "")))
		return

	var target_id = transition.get("target_dungeon", "")

	if target_id == "":
		return

	if not dungeon.load_dungeon(target_id):
		return

	if transition.has("target_position"):
		dungeon.player_pos = transition["target_position"]

	if transition.has("target_facing"):
		dungeon.facing = transition["target_facing"]

	queue_redraw()


func handle_current_dungeon_event() -> bool:
	var event = dungeon.get_current_event()
	if event.is_empty():
		return false

	var event_type = str(event.get("type", "lore"))
	dungeon.message = str(event.get("message", ""))

	if event_type == "fountain":
		for member in party:
			if not bool(member.get("dead", false)):
				var hp_gain = max(1, int(ceil(float(member.get("max_hp", 1)) * 0.25)))
				CharacterHealth.heal(member, hp_gain)
				if member.has("sp") and member.has("max_sp"):
					var sp_gain = max(1, int(ceil(float(member["max_sp"]) * 0.25)))
					member["sp"] = min(int(member["max_sp"]), int(member["sp"]) + sp_gain)
		dungeon.message += " The party recovers 25% of maximum HP and SP."
		dungeon.consume_current_event(true)
		return true

	if event_type == "treasure":
		var gold = int(event.get("gold", 0))
		var item_id = str(event.get("item_id", ""))
		if item_id != "":
			var collected = add_item_to_shared_inventory(item_id)
			if collected:
				dungeon.message += " The item is added to the shared inventory."
			else:
				dungeon.message += " The item could not be collected, so the treasure remains here."
				return true
		if gold > 0:
			progression.add_gold(gold)
		dungeon.consume_current_event(false)
		return true

	dungeon.consume_current_event(false)
	return true


func add_item_to_shared_inventory(item_id: String) -> bool:
	return inventory_system.add_item({}, item_id)


func check_for_encounter():
	if dungeon.is_quiet_area() or dungeon.random_encounters_protected():
		return

	var chance = clampf(encounter_chance * float(dungeon.dungeon_data.get("random_encounter_multiplier", 1.0)), 0.0, 1.0)
	if randf() < chance:
		start_combat()


func start_combat():
	dungeon.reset_encounter_grace()

	current_combat_tag = ""

	var table = DungeonEncounterData.get_table(dungeon.dungeon_id)

	if table.is_empty():
		combat.start_encounter()
	else:
		var encounter = roll_dungeon_encounter(table)
		combat.start_specific_encounter(
			encounter["enemy_id"],
			randi_range(encounter["min_group"], encounter["max_group"])
		)

	prepare_combat_state()


func roll_dungeon_encounter(table: Array) -> Dictionary:

	var total_weight = 0

	for entry in table:
		total_weight += int(entry.get("weight", 1))

	var roll = randi_range(1, max(1, total_weight))
	var running = 0

	for entry in table:
		running += int(entry.get("weight", 1))
		if roll <= running:
			return entry

	return table[table.size() - 1]


func start_fixed_encounter(encounter: Dictionary):
	dungeon.reset_encounter_grace()

	current_combat_tag = encounter.get("tag", "")

	if encounter.has("groups"):
		combat.start_mixed_encounter(encounter["groups"], encounter.get("intro", ""))
	else:
		combat.start_specific_encounter(
			encounter["enemy_id"],
			encounter.get("count", 1),
			encounter.get("intro", "")
		)

	prepare_combat_state()


func prepare_combat_state():

	combat_character_index = 0
	clear_all_combat_flags()
	move_to_next_living_combat_character()
	game_state = GameState.COMBAT
	queue_redraw()


# The skill picker is scoped to the current combat actor.
var combat_skills_open: bool = false
var combat_target_open: bool = false
var combat_pending_action: String = ""
var combat_pending_ability: String = ""
var combat_target_page: int = 0

func combat_skill_needs_target(ability_id: String) -> bool:
	return ability_id in ["warrior_shield_bash", "warrior_taunt", "warrior_disarm", "paladin_shield_bash", "paladin_taunt", "berserker_taunt", "berserker_savage_intervention"]

func get_living_combat_targets() -> Array:
	var available: Array = []
	if combat_pending_ability == "berserker_savage_intervention" and combat_target_open:
		var actor: Dictionary = get_current_combat_character()
		for member in party:
			if member != actor and int(member.get("hp", 0)) > 0:
				available.append(member)
		return available
	var actor = get_current_combat_character()
	return combat.reachable_targets(actor, combat.enemies, combat.action_range(actor, combat_pending_action, combat_pending_ability))

func begin_combat_target_selection(action_name: String, ability_id: String = "") -> void:
	combat_pending_action = action_name
	combat_pending_ability = ability_id
	combat_target_page = 0
	combat_target_open = true
	combat_skills_open = false
	if get_living_combat_targets().is_empty():
		combat_target_open = false
		combat.add_log("No reachable targets. Reposition or choose another action.")
	queue_redraw()


func get_combat_skill_options(actor: Dictionary) -> Array:
	var options: Array = [{"name": get_class_ability_name(str(actor.get("class", ""))), "id": "", "cost": 0, "cooldown": 0, "shield": false}]
	var warrior_skills: Array = [
		[10, "Shield Bash", "warrior_shield_bash", 0, 0, true],
		[30, "Taunt", "warrior_taunt", 5, 4, false],
		[40, "Disarm", "warrior_disarm", 8, 5, false],
		[50, "Shield Wall", "warrior_shield_wall", 12, 6, true],
		[60, "Unbreakable Guardian", "warrior_unbreakable_guardian", 15, 8, true],
	]
	for entry in warrior_skills:
		if combat.warrior_tank_unlocked(actor, int(entry[0])):
			options.append({"name": entry[1], "id": entry[2], "cost": entry[3], "cooldown": entry[4], "shield": entry[5]})
	var paladin_skills: Array = [
		[10, "Shield Bash", "paladin_shield_bash", 0, 0, true],
		[30, "Taunt", "paladin_taunt", 5, 4, false],
		[50, "Divine Bulwark", "paladin_divine_bulwark", 20, 8, true],
		[60, "Chivalrous Intervention", "paladin_chivalrous_intervention", 30, 10, true],
	]
	for entry in paladin_skills:
		if combat.paladin_tank_unlocked(actor, int(entry[0])):
			options.append({"name": entry[1], "id": entry[2], "cost": entry[3], "cooldown": entry[4], "shield": entry[5]})
	var berserker_skills: Array = [
		[10, "Lunatic Howl", "berserker_lunatic_howl", 8, 4, false],
		[30, "Taunt", "berserker_taunt", 5, 4, false],
		[40, "Savage Intervention", "berserker_savage_intervention", 10, 5, false],
		[60, "Dance of Carnage", "berserker_dance_of_carnage", 25, 8, false],
	]
	for entry in berserker_skills:
		if combat.berserker_tank_unlocked(actor, int(entry[0])):
			options.append({"name": entry[1], "id": entry[2], "cost": entry[3], "cooldown": entry[4], "shield": entry[5]})
	return options


func combat_skill_unavailable_reason(actor: Dictionary, skill: Dictionary) -> String:
	var mode = combat.action_range(actor, "Ability", str(skill.get("id", "")))
	if mode != "magic" and combat.reachable_targets(actor, combat.enemies, mode).is_empty():
		return "no reachable targets"
	if str(skill.get("id", "")) in ["berserker_savage_intervention", "berserker_dance_of_carnage"] and not combat.berserker_has_melee_weapon(actor):
		return "melee weapon required"
	if bool(skill.get("shield", false)) and not combat.has_equipped_shield(actor):
		return "shield required"
	if int(actor.get("sp", 0)) < int(skill.get("cost", 0)):
		return "not enough SP"
	var ability_id: String = str(skill.get("id", ""))
	if ability_id != "":
		var remaining: int = combat.effects.cooldown_remaining(actor, ability_id)
		if remaining > 0:
			return "cooldown: " + str(remaining) + " rounds"
	return ""


# ============================================================
# COMBAT INPUT
# ============================================================

func handle_combat_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	var actor = get_current_combat_character()
	if actor.is_empty():
		return

	if combat_target_open:
		if event.keycode in [KEY_ESCAPE, KEY_BACKSPACE]:
			combat_target_open = false
			combat_skills_open = combat_pending_action == "Ability"
			queue_redraw()
			return
		var targets: Array = get_living_combat_targets()
		var pages: int = maxi(1, ceili(float(targets.size()) / 9.0))
		if event.keycode == KEY_N and combat_target_page < pages - 1:
			combat_target_page += 1
			queue_redraw()
			return
		if event.keycode == KEY_P and combat_target_page > 0:
			combat_target_page -= 1
			queue_redraw()
			return
		var choice: int = int(event.keycode) - int(KEY_1)
		var index: int = combat_target_page * 9 + choice
		if choice >= 0 and choice < 9 and index < targets.size():
			var chosen_target: Dictionary = targets[index]
			combat_target_open = false
			queue_current_action(combat_pending_action, combat_pending_ability, chosen_target)
		return

	if combat_skills_open:
		if event.keycode in [KEY_ESCAPE, KEY_BACKSPACE]:
			combat_skills_open = false
			queue_redraw()
			return
		var index: int = int(event.keycode) - int(KEY_1)
		var skills: Array = get_combat_skill_options(actor)
		if index >= 0 and index < mini(skills.size(), 9):
			var chosen: Dictionary = skills[index]
			if combat_skill_unavailable_reason(actor, chosen) != "":
				queue_redraw()
				return
			var skill_id: String = str(chosen["id"])
			if combat_skill_needs_target(skill_id):
				begin_combat_target_selection("Ability", skill_id)
			else:
				combat_skills_open = false
				queue_current_action("Ability", skill_id)
		return

	match event.keycode:
		KEY_1:
			begin_combat_target_selection("Attack")
		KEY_2:
			queue_current_action("Defend")
		KEY_3:
			combat_skills_open = true
			queue_redraw()
		KEY_4:
			attempt_party_escape()
		KEY_5:
			open_formation_menu()


# ============================================================
# COMBAT ACTION SELECTION
# ============================================================

func get_current_combat_character() -> Dictionary:

	if combat_character_index < 0:
		return {}

	if combat_character_index >= party.size():
		return {}

	return party[
		combat_character_index
	]


func queue_current_action(
	action_name: String,
	ability_id: String = "",
	target: Dictionary = {},
	target_slot: int = -1
):

	var actor = (
		get_current_combat_character()
	)

	if actor.is_empty():
		return

	if actor["hp"] <= 0:
		return

	combat_skills_open = false
	combat_target_open = false
	combat.queue_action(actor, action_name, ability_id, target, target_slot)

	combat_character_index += 1

	move_to_next_living_combat_character()

	if combat_character_index >= party.size():

		resolve_combat_round()

	queue_redraw()


func move_to_next_living_combat_character():

	while (
		combat_character_index
		< party.size()
	):

		if (
			party[combat_character_index]["hp"]
			> 0
		):
			break

		combat_character_index += 1


# ============================================================
# RESOLVE COMBAT ROUND
# ============================================================

func resolve_combat_round():

	combat.resolve_round(
		party
	)

	if combat.all_enemies_defeated() and not combat.party_defeated(party):

		handle_combat_victory()

		return

	if combat.party_defeated(
		party
	):

		combat_result_text = (
			"THE PARTY HAS FALLEN.\n\n"
			+ "Game over. Reload the last save to continue."
		)

		last_combat_rewards = {}

		clear_all_combat_flags()

		game_state = GameState.COMBAT_RESULT

		queue_redraw()

		return

	combat.cleanup_round(
		party
	)

	combat_character_index = 0

	move_to_next_living_combat_character()

	queue_redraw()
	
# ============================================================
# COMBAT VICTORY
# ============================================================

func handle_combat_victory():
	if combat.rewards_claimed or combat.enemies.is_empty() or not combat.all_enemies_defeated() or combat.party_defeated(party):
		return
	combat.rewards_claimed = true

	if current_combat_tag == "architect_chapel_boss":
		dungeon.mark_current_fixed_encounter_defeated()

	if current_combat_tag == "architect_archives_guardian":
		dungeon.mark_current_fixed_encounter_defeated()

	if current_combat_tag == "architect_nave_guardian":
		dungeon.mark_current_fixed_encounter_defeated()

	if current_combat_tag == "warehouse_rat_boss":
		dungeon.mark_current_fixed_encounter_defeated()
		quest_system.set_state("rats_in_the_warehouse", "boss_defeated")

	if current_combat_tag == "sewer_troll_boss":
		dungeon.mark_current_fixed_encounter_defeated()
		add_quest_item("katys_special_wine")
		quest_system.set_state("katys_special_vintage", "wine_found")

	if current_combat_tag == "onika_bandit_queen":
		dungeon.mark_current_fixed_encounter_defeated()
		add_quest_item("onikas_signet")
		quest_system.set_state("queen_of_the_old_prison", "onika_defeated")

	if current_combat_tag == "grave_sacristan":
		dungeon.mark_current_fixed_encounter_defeated()

	if current_combat_tag == "sisters_bella_gigi":
		dungeon.mark_current_fixed_encounter_defeated()

	if current_combat_tag == "bristle_aptarj":
		dungeon.mark_current_fixed_encounter_defeated()
		quest_system.set_state("purge_broken_reliquary", "bristle_defeated")

	last_combat_rewards = (
		progression.award_combat_rewards(
			party,
			combat.enemies
		)
	)

	var loot_result = loot_system.roll_combat_loot(
		combat.enemies,
		party
	)

	last_combat_rewards["loot"] = loot_result

	combat_result_text = (
		"VICTORY!\n\n"
		+ "XP EARNED: "
		+ str(
			last_combat_rewards["total_xp"]
		)
		+ "\n"
		+ "GOLD FOUND: "
		+ str(
			last_combat_rewards["gold"]
		)
		+ "\n\n"
		+ "EACH SURVIVING ADVENTURER RECEIVES "
		+ str(
			last_combat_rewards["xp_each"]
		)
		+ " XP."
		+ loot_system.get_result_text(loot_result)
	)

	clear_all_combat_flags()

	game_state = GameState.COMBAT_RESULT

	queue_redraw()
	
# ============================================================
# ESCAPE
# ============================================================

func attempt_party_escape():

	if randf() < 0.60:

		combat.add_log(
			"The party escapes!"
		)

		clear_all_combat_flags()

		game_state = GameState.WILDERNESS if current_combat_tag == "wilderness" else GameState.DUNGEON

	else:

		combat.add_log(
			"The party fails to escape!"
		)

		combat.resolve_failed_escape(party)

		if combat.party_defeated(
			party
		):

			combat_result_text = (
				"THE PARTY HAS FALLEN.\n\n"
				+ "Game over. Reload the last save to continue."
			)

			clear_all_combat_flags()

			game_state = GameState.COMBAT_RESULT

		else:

			combat.cleanup_round(
				party
			)

			combat_character_index = 0

			move_to_next_living_combat_character()

	queue_redraw()


# ============================================================
# COMBAT RESULT
# ============================================================

func handle_combat_result_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	if combat.party_defeated(party):
		if event.keycode == KEY_ENTER:
			if not load_game():
				combat_result_text = "GAME OVER. No valid save is available.\n\n[N] Start a new game."
		elif event.keycode == KEY_N:
			get_tree().reload_current_scene()
	else:
		if event.keycode != KEY_ENTER:
			return
		game_state = GameState.WILDERNESS if current_combat_tag == "wilderness" else GameState.DUNGEON
		current_combat_tag = ""
	queue_redraw()


# ============================================================
# TEMPORARY COMBAT FLAGS
# ============================================================

func clear_temporary_combat_flags(
	member: Dictionary
):

	member["defending"] = false
	member["guarded"] = false
	member["warded"] = false
	combat.effects.end_encounter(member)


func clear_all_combat_flags():

	for member in party:

		clear_temporary_combat_flags(
			member
		)


# ============================================================
# DRAW ROUTER
# ============================================================

func _draw():
	draw_rect(get_viewport_rect(), Color("#111118"))
	if class_skills_open:
		draw_class_skills()
		return
	if rogue_skills_open:
		draw_rogue_skills()
		return
	if formation_menu_open:
		draw_formation_menu()
		return

	match game_state:
		GameState.TEMPLE:
			draw_temple()

		GameState.GUILD:
			draw_guild()

		GameState.CREATE_RACE:
			draw_race_selection()

		GameState.CREATE_STATS:
			draw_stat_screen()

		GameState.CREATE_CLASS:
			draw_class_selection()

		GameState.CREATE_GENDER:
			draw_gender_selection()

		GameState.CREATE_NAME:
			draw_name_screen()

		GameState.CREATE_REVIEW:
			draw_review_screen()

		GameState.PARTY_SELECT:
			draw_party_selection()

		GameState.CITY:

			draw_city_view()
			draw_city_status()
			draw_city_map()
			draw_party_panel()

		GameState.WILDERNESS:

			draw_wilderness_view()
			draw_wilderness_status()
			draw_wilderness_map()
			draw_party_panel()

		GameState.TRAINING_HALL:

			draw_training_hall()
			draw_party_panel()

		GameState.SHOP:

			draw_shop()

		GameState.TOWN_HALL:

			draw_town_hall()
			draw_party_panel()

		GameState.WARDEN_KEEP:

			draw_warden_keep()
			draw_party_panel()

		GameState.INVENTORY:

			draw_inventory_screen()

		GameState.DUNGEON:

			draw_dungeon_view()
			if dungeon.visibility_limited():
				draw_rect(Rect2(40,40,700,400), Color("#08080d"))
				draw_rect(Rect2(40,40,700,400), Color("#555566"), false, 2)
				draw_string(ThemeDB.fallback_font, Vector2(220,240), "Too dark to see ahead. [L] Light lantern.")
			else:
				draw_dungeon_interaction()
			if bool(dungeon.dungeon_data.get("tracks_exploration_time", false)):
				var clock_text = "EXPLORATION: %d steps (1 per tile moved)" % dungeon.exploration_steps
				if int(dungeon.dungeon_data.get("encounter_grace_steps", 0)) > 0:
					clock_text += " | %d safe moves left" % dungeon.encounter_grace_remaining
				draw_string(ThemeDB.fallback_font, Vector2(60,425), clock_text)
			draw_status()
			draw_map()
			draw_party_panel()

		GameState.COMBAT:

			draw_combat_screen()
			draw_party_panel()

		GameState.COMBAT_RESULT:

			draw_combat_result()
			draw_party_panel()

	draw_developer_indicator()
	if game_state not in [GameState.COMBAT, GameState.COMBAT_RESULT]:
		draw_string(ThemeDB.fallback_font, Vector2(60, 625), "[F5] Save  [F9] Load  " + save_message, HORIZONTAL_ALIGNMENT_LEFT, 1000)
	if developer_menu_open:
		draw_developer_menu()


# ============================================================
# DEVELOPER MENU DRAWING
# ============================================================

func draw_developer_indicator():
	draw_string(
		ThemeDB.fallback_font,
		Vector2(1040, 24),
		"[DEV F12]",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14
	)


func draw_developer_menu():
	draw_rect(Rect2(40, 30, 1072, 588), Color(0.03, 0.03, 0.05, 0.97))
	draw_rect(Rect2(40, 30, 1072, 588), Color(0.55, 0.55, 0.65), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(70, 68), "DEVELOPER MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 28)

	var lines: Array = developer_menu.get_display_lines()
	var y: float = 105.0
	for line in lines:
		draw_string(ThemeDB.fallback_font, Vector2(70, y), str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		y += 22.0

	if developer_menu.message != "":
		draw_string(ThemeDB.fallback_font, Vector2(610, 570), developer_menu.message, HORIZONTAL_ALIGNMENT_LEFT, 460, 15)


# ============================================================
# COMMON HEADER
# ============================================================

func draw_header(
	title: String
):

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			70,
			65
		),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		28
	)

	draw_line(
		Vector2(
			70,
			85
		),
		Vector2(
			1080,
			85
		),
		Color("#777788"),
		2
	)


# ============================================================
# DRAW GUILD
# ============================================================

func draw_roster_page():
	clamp_roster_page()
	var start = roster_page * ROSTER_PAGE_SIZE
	for i in range(start, mini(start + ROSTER_PAGE_SIZE, roster.size())):
		var member: Dictionary = roster[i]
		var slot = party_system.slots.find(member["character_id"])
		var position = "Reserve" if slot < 0 else PartyScript.SLOT_NAMES[slot]
		var text = "%d) %s  %s  LV %d  [%s]" % [i - start + 1, member["name"], member["class"], member["level"], position]
		draw_string(ThemeDB.fallback_font, Vector2(80, 145 + (i - start) * 25), text)
	draw_string(ThemeDB.fallback_font, Vector2(80, 385), "[PgUp/PgDn] Roster page %d / %d" % [roster_page + 1, maxi(1, int(ceil(roster.size() / 9.0)))])


func draw_guild():
	draw_header("THE ADVENTURERS' GUILD")
	draw_roster_page()
	draw_string(ThemeDB.fallback_font, Vector2(80, 430), "[C] CREATE CHARACTER  [P] ASSEMBLE PARTY  [I] MANAGE  [K] SKILLS")
	draw_string(ThemeDB.fallback_font, Vector2(80, 465), "[D] DELETE LAST CHARACTER    [T] QUICK TEST PARTY")
	if party_system.can_adventure():
		draw_string(ThemeDB.fallback_font, Vector2(80, 500), "[L] LEAVE GUILD")


func draw_party_selection():
	draw_header("ASSEMBLE YOUR PARTY")
	draw_roster_page()
	for i in range(6):
		var member = party_system.find_character(party_system.slots[i])
		var label = PartyScript.SLOT_NAMES[i] + ": " + str(member.get("name", "Empty"))
		if i == selected_formation_slot:
			label = "> " + label
		draw_string(ThemeDB.fallback_font, Vector2(80 + (i % 3) * 230, 425 + int(i / 3) * 30), label)
	draw_string(ThemeDB.fallback_font, Vector2(80, 495), "[Left/Right] SLOT   [1-9] ASSIGN / SWAP   [Backspace] REMOVE")
	draw_string(ThemeDB.fallback_font, Vector2(80, 530), "PARTY %d/6   [Enter] ADVENTURE   [Esc] GUILD" % party.size())
	draw_string(ThemeDB.fallback_font, Vector2(80, 565), party_message)


# ============================================================
# DRAW RACE SELECTION
# ============================================================

func draw_race_selection():

	draw_header(
		"CHOOSE YOUR RACE"
	)

	var start = (
		race_page * PAGE_SIZE
	)

	var finish = min(
		start + PAGE_SIZE,
		races.size()
	)

	for i in range(
		start,
		finish
	):

		var local_number = (
			i - start + 1
		)

		var race = races[i]

		var y = (
			135
			+ (i - start) * 58
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				90,
				y
			),
			str(local_number)
			+ ") "
			+ race["name"]
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				270,
				y
			),
			format_modifiers(
				race["mods"]
			)
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				760,
				y
			),
			race["trait"]
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			580
		),
		"[1-7] SELECT   [N/P] PAGE   [ESC] RETURN TO GUILD"
	)


func format_modifiers(
	mods: Dictionary
) -> String:

	var text = ""

	for stat in [
		"str",
		"int",
		"dex",
		"con",
		"lck"
	]:

		var value = mods[stat]

		text += (
			stat.to_upper()
			+ " "
		)

		if value > 0:

			text += (
				"+"
				+ str(value)
			)

		elif value < 0:

			text += str(value)

		else:

			text += "--"

		text += "   "

	return text


# ============================================================
# DRAW STATS
# ============================================================

func draw_stat_screen():

	draw_header(
		"ROLL ATTRIBUTES — "
		+ character["race"].to_upper()
	)

	var mods = (
		races[selected_race_index]["mods"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			125
		),
		"ATTRIBUTE        ROLL       RACE       TOTAL"
	)

	draw_stat_row(
		"STRENGTH",
		"base_str",
		"str",
		mods["str"],
		175
	)

	draw_stat_row(
		"INTELLIGENCE",
		"base_int",
		"int",
		mods["int"],
		220
	)

	draw_stat_row(
		"DEXTERITY",
		"base_dex",
		"dex",
		mods["dex"],
		265
	)

	draw_stat_row(
		"CONSTITUTION",
		"base_con",
		"con",
		mods["con"],
		310
	)

	draw_stat_row(
		"LUCK",
		"base_lck",
		"lck",
		mods["lck"],
		355
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			425
		),
		"RACIAL TRAIT: "
		+ character["race_trait"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			510
		),
		"[R] REROLL"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			545
		),
		"[ENTER] KEEP ATTRIBUTES"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			580
		),
		"[ESC] CHOOSE ANOTHER RACE"
	)


func draw_stat_row(
	label: String,
	base_key: String,
	total_key: String,
	modifier: int,
	y: float
):

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			y
		),
		label
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			320,
			y
		),
		str(
			character[base_key]
		)
	)

	var mod_text = "--"

	if modifier > 0:

		mod_text = (
			"+"
			+ str(modifier)
		)

	elif modifier < 0:

		mod_text = str(
			modifier
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			430,
			y
		),
		mod_text
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			540,
			y
		),
		str(
			character[total_key]
		)
	)


# ============================================================
# DRAW CLASS SELECTION
# ============================================================

func draw_class_selection():

	draw_header(
		"CHOOSE YOUR CLASS"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			115
		),
		character["race"]
		+ "   STR "
		+ str(character["str"])
		+ "  INT "
		+ str(character["int"])
		+ "  DEX "
		+ str(character["dex"])
		+ "  CON "
		+ str(character["con"])
		+ "  LCK "
		+ str(character["lck"])
	)

	var start = (
		class_page * PAGE_SIZE
	)

	var finish = min(
		start + PAGE_SIZE,
		classes.size()
	)

	for i in range(
		start,
		finish
	):

		var class_data = (
			classes[i]
		)

		var local_number = (
			i - start + 1
		)

		var y = (
			160
			+ (i - start) * 57
		)

		var status = "AVAILABLE"

		if not qualifies_for_class(
			class_data
		):

			status = (
				"REQUIRES "
				+ get_requirement_text(
					class_data
				)
			)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				90,
				y
			),
			str(local_number)
			+ ") "
			+ class_data["name"]
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				280,
				y
			),
			class_data["role"]
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				610,
				y
			),
			status
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			580
		),
		"[1-7] SELECT   [N/P] PAGE   [ESC] BACK"
	)


# ============================================================
# DRAW GENDER
# ============================================================

func draw_gender_selection():

	draw_header(
		"CHOOSE GENDER"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			135
		),
		character["race"]
		+ " "
		+ character["class"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			110,
			210
		),
		"1) MALE"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			110,
			255
		),
		"2) FEMALE"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			110,
			300
		),
		"3) NONBINARY"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			550
		),
		"[1-3] SELECT   [ESC] CHOOSE ANOTHER CLASS"
	)


# ============================================================
# DRAW NAME
# ============================================================

func draw_name_screen():

	draw_header(
		"NAME YOUR CHARACTER"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			145
		),
		character["race"]
		+ " "
		+ character["class"]
		+ " — "
		+ character["gender"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			220
		),
		"NAME: "
		+ name_buffer
		+ "_"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			300
		),
		"Maximum 16 characters."
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			520
		),
		"[ENTER] CONTINUE"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			555
		),
		"[ESC] CHOOSE ANOTHER GENDER"
	)


# ============================================================
# DRAW REVIEW
# ============================================================

func draw_review_screen():

	draw_header(
		"REVIEW CHARACTER"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			135
		),
		character["name"],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		24
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			175
		),
		character["race"]
		+ " "
		+ character["class"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			205
		),
		"Gender: "
		+ character["gender"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			235
		),
		"Pronouns: "
		+ character["subject_pronoun"]
		+ "/"
		+ character["object_pronoun"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			265
		),
		"Racial Trait: "
		+ character["race_trait"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			320
		),
		"STR "
		+ str(character["str"])
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			355
		),
		"INT "
		+ str(character["int"])
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			390
		),
		"DEX "
		+ str(character["dex"])
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			260,
			320
		),
		"CON "
		+ str(character["con"])
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			260,
			355
		),
		"LCK "
		+ str(character["lck"])
	)

	var class_data = (
		classes[selected_class_index]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			440
		),
		"Role: "
		+ class_data["role"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			475
		),
		"Starting Ability: "
		+ class_data["ability"]
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			535
		),
		"[ENTER] ADD TO ROSTER"
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			90,
			570
		),
		"[ESC] CHANGE NAME"
	)



# ============================================================
# DRAW THORNWAKE TOWN HALL
# ============================================================

func draw_town_hall():

	draw_header("THORNWAKE TOWN HALL")

	var town_hall_npc = "KATY THORNWAKE"
	var rescue_state = quest_system.get_state("rescue_katy_thornwake")
	if rescue_state == "katy_missing" or rescue_state == "dreadmarch_unlocked":
		town_hall_npc = "CHIEF WARDEN RORIK FELD"

	draw_string(
		ThemeDB.fallback_font,
		Vector2(80, 125),
		town_hall_npc,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		22
	)

	var lines = get_katy_dialogue().split("\n")

	for i in range(lines.size()):
		draw_string(
			ThemeDB.fallback_font,
			Vector2(90, 175 + i * 28),
			lines[i]
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(80, 430),
		"QUEST: " + quest_system.get_display_status("rats_in_the_warehouse")
	)

	if quest_system.is_started("katys_special_vintage"):
		draw_string(
			ThemeDB.fallback_font,
			Vector2(80, 460),
			"NEW QUEST: A VERY PARTICULAR VINTAGE"
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(80, 555),
		get_katy_prompt()
	)



func draw_warden_keep():
	draw_header("WARDEN KEEP")
	draw_string(ThemeDB.fallback_font, Vector2(80,125), "WARDEN HARLIC DORN", HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	var lines = get_harlic_dialogue().split("\n")
	for i in range(lines.size()):
		draw_string(ThemeDB.fallback_font, Vector2(90,175 + i * 28), lines[i])
	draw_string(ThemeDB.fallback_font, Vector2(80,470), "QUEST: " + quest_system.get_display_status("queen_of_the_old_prison"))
	if quest_system.is_started("purge_broken_reliquary"):
		draw_string(ThemeDB.fallback_font, Vector2(80,495), "QUEST: " + quest_system.get_display_status("purge_broken_reliquary"))
	if quest_system.is_started("rescue_katy_thornwake"):
		draw_string(ThemeDB.fallback_font, Vector2(80,520), "NEW QUEST: " + quest_system.get_display_status("rescue_katy_thornwake"))
	draw_string(ThemeDB.fallback_font, Vector2(80,555), get_harlic_prompt())


func draw_inn():

	draw_string(
		ThemeDB.fallback_font,
		Vector2(80, 90),
		str(city.get_current_location().get("name", "Inn")).to_upper(),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		28
	)

	var lines = get_inn_dialogue().split("\n")
	var y = 145

	for line in lines:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(80, y),
			line,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			18
		)
		y += 28

	draw_string(
		ThemeDB.fallback_font,
		Vector2(80, 560),
		get_inn_prompt(),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18
	)

# ============================================================
# DRAW GENERAL STORE
# ============================================================

func draw_shop():
	draw_header(str(shop_system.get_shop(shop_id).get("name", "GENERAL STORE")).to_upper())
	draw_string(ThemeDB.fallback_font, Vector2(60, 120), "PARTY GOLD: " + str(progression.get_party_gold()) + "   SHARED ITEMS: " + str(party_system.inventory.size()))
	draw_string(ThemeDB.fallback_font, Vector2(60, 160), "MODE: " + shop_mode.to_upper() + "   Page " + str(shop_page + 1))
	clamp_shop_page()
	var choices = get_shop_choices()
	for i in range(shop_page * 9, mini(choices.size(), (shop_page + 1) * 9)):
		var item_id = choices[i]
		var item: Dictionary = ItemData.ITEMS.get(item_id, {})
		var price = shop_system.get_buy_price(item_id) if shop_mode == "buy" else shop_system.get_sell_price(shop_id, item_id)
		var text = "%d) %s  %dg" % [i % 9 + 1, item.get("name", item_id), price]
		if shop_mode == "buy":
			text += "  " + get_shop_item_details(item)
		draw_string(ThemeDB.fallback_font, Vector2(80, 210 + (i % 9) * 30), text)
	draw_string(ThemeDB.fallback_font, Vector2(60, 520), shop_message)
	draw_string(ThemeDB.fallback_font, Vector2(60, 560), "[B] Buy  [S] Sell  [PgUp/PgDn] Page  [1-9] Select")
	draw_string(ThemeDB.fallback_font, Vector2(60, 590), "[I] Party management  [Esc] City")


func get_shop_item_details(item: Dictionary) -> String:

	if item["type"] == "consumable":
		return "Consumable"

	if item.get("slot", "") == "weapon":
		var accuracy = int(float(item.get("accuracy", 0.0)) * 100.0)
		var accuracy_text = str(accuracy) + "%"
		if accuracy >= 0:
			accuracy_text = "+" + accuracy_text
		return (
			"DMG +" + str(item.get("damage_min", 0)) + "-" + str(item.get("damage_max", 0))
			+ " ACC " + accuracy_text
		)

	var avoidance = int(float(item.get("avoidance", 0.0)) * 100.0)
	var avoid_text = str(avoidance) + "%"
	if avoidance >= 0:
		avoid_text = "+" + avoid_text

	return "ABS " + str(item.get("absorption", 0)) + " AVOID " + avoid_text


# ============================================================
# DRAW INVENTORY
# ============================================================

func draw_inventory_screen():
	var members = get_management_members()
	if members.is_empty():
		return
	inventory_character_index = clampi(inventory_character_index, 0, members.size() - 1)
	var member = members[inventory_character_index]
	inventory_system.ensure_character_inventory(member)
	var slot = party_system.slots.find(member["character_id"])
	var position = "Guild reserve" if slot < 0 else PartyScript.SLOT_NAMES[slot]
	draw_header("PARTY — " + str(member["name"]).to_upper())
	draw_string(ThemeDB.fallback_font, Vector2(60, 110), "%s %s  LV %d  %s  [%s]" % [member.get("race", ""), member.get("class", ""), member.get("level", 1), member.get("specialization", ""), position])
	draw_string(ThemeDB.fallback_font, Vector2(60, 145), "HP %d/%d   SP %d/%d   XP %d   GOLD %d" % [member.get("hp", 0), member.get("max_hp", 0), member.get("sp", 0), member.get("max_sp", 0), member.get("xp", 0), progression.get_party_gold()])
	draw_string(ThemeDB.fallback_font, Vector2(60, 180), "[B] Shared bag   [E] Equipment   [D] Details   — " + inventory_mode.to_upper())
	if inventory_mode == "bag":
		clamp_inventory_page()
		var bag = party_system.inventory
		for i in range(inventory_page * 9, mini(bag.size(), (inventory_page + 1) * 9)):
			var item: Dictionary = ItemData.ITEMS.get(bag[i], {})
			var text = "%d) %s — %s" % [i % 9 + 1, item.get("name", bag[i]), item.get("type", "unknown")]
			if item.get("type", "") == "equipment" and not inventory_system.can_equip(member, item):
				text += " [class restricted]"
			draw_string(ThemeDB.fallback_font, Vector2(80, 220 + (i % 9) * 29), text)
		if bag.is_empty():
			draw_string(ThemeDB.fallback_font, Vector2(80, 220), "The shared inventory is empty.")
		draw_string(ThemeDB.fallback_font, Vector2(60, 495), "[1-9] Equip / use on selected character   [PgUp/PgDn] Page %d/%d" % [inventory_page + 1, maxi(1, ceili(bag.size() / 9.0))])
	elif inventory_mode == "equipment":
		for i in range(InventorySystem.EQUIPMENT_SLOTS.size()):
			var equipment_slot = InventorySystem.EQUIPMENT_SLOTS[i]
			var item_id = member["equipment"][equipment_slot]
			var name_text = str(ItemData.ITEMS.get(item_id, {}).get("name", "Empty"))
			draw_string(ThemeDB.fallback_font, Vector2(80, 220 + i * 29), "%d) %s: %s" % [i + 1, equipment_slot.replace("_", " ").capitalize(), name_text])
		draw_string(ThemeDB.fallback_font, Vector2(60, 495), "[1-9] Unequip to shared inventory")
	else:
		draw_character_details(member)
	draw_string(ThemeDB.fallback_font, Vector2(60, 530), inventory_message, HORIZONTAL_ALIGNMENT_LEFT, 680)
	draw_string(ThemeDB.fallback_font, Vector2(60, 565), "[Left/Right] Character   [K] Skills   [F] Formation   [Esc] Return")

func draw_character_details(member: Dictionary):
	draw_string(ThemeDB.fallback_font, Vector2(80, 220), "STR %d   INT %d   DEX %d   CON %d   LCK %d" % [member.get("str", 0), member.get("int", 0), member.get("dex", 0), member.get("con", 0), member.get("lck", 0)])
	draw_string(ThemeDB.fallback_font, Vector2(80, 250), inventory_system.get_combat_summary(member))
	var conditions: Array[String] = []
	if bool(member.get("dead", false)):
		conditions.append("Dead")
	elif int(member.get("hp", 0)) <= 0:
		conditions.append(CharacterHealth.status(member))
	for effect in member.get("effects", []):
		conditions.append(str(effect.get("id", "Effect")))
	draw_string(ThemeDB.fallback_font, Vector2(80, 280), "Conditions: " + ("None" if conditions.is_empty() else ", ".join(conditions)), HORIZONTAL_ALIGNMENT_LEFT, 650)
	draw_string(ThemeDB.fallback_font, Vector2(80, 310), "Race trait: " + str(member.get("race_trait", "None")), HORIZONTAL_ALIGNMENT_LEFT, 650)
	var skills = get_combat_skill_options(member)
	for i in range(mini(skills.size(), 7)):
		var skill = skills[i]
		draw_string(ThemeDB.fallback_font, Vector2(80, 345 + i * 22), "%s   SP %d   Cooldown %d" % [skill["name"], skill["cost"], skill["cooldown"]])


	draw_string(ThemeDB.fallback_font, Vector2(80, 495), "[K] " + ExplorationSkills.menu_name(str(member.get("class", ""))))

# ============================================================
# DRAW TRAINING HALL
# ============================================================

func draw_training_hall():
	draw_header("THE TRAINING HALL")

	if training_choosing_specialization and not training_pending_member.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(80, 155), str(training_pending_member.get("class", "")) + " SPECIALIZATION")
		draw_string(ThemeDB.fallback_font, Vector2(80, 205), "1) TANK - " + ("Sacred Guardian" if str(training_pending_member.get("class", "")) == "Paladin" else ("Unyielding Fury" if str(training_pending_member.get("class", "")) == "Berserker" else "Defender's Presence")))
		draw_string(ThemeDB.fallback_font, Vector2(80, 255), "More specializations will be available later.")
		draw_string(ThemeDB.fallback_font, Vector2(80, 355), training_message)
		return

	if training_choosing_stat and not training_pending_member.is_empty():
		var member = training_pending_member
		draw_string(ThemeDB.fallback_font, Vector2(80, 125), member["name"] + " is ready to advance.")
		draw_string(ThemeDB.fallback_font, Vector2(80, 165), "LEVEL " + str(member["level"]) + " -> " + str(member["level"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(80, 200), "MAX HP  +" + str(training_pending_hp_gain))
		draw_string(ThemeDB.fallback_font, Vector2(80, 230), "MAX SP  +" + str(training_pending_sp_gain))
		draw_string(ThemeDB.fallback_font, Vector2(80, 280), "CHOOSE A STAT TO INCREASE:")
		draw_string(ThemeDB.fallback_font, Vector2(100, 320), "1) STR   " + str(member["str"]) + " -> " + str(member["str"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(100, 350), "2) INT   " + str(member["int"]) + " -> " + str(member["int"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(100, 380), "3) DEX   " + str(member["dex"]) + " -> " + str(member["dex"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(100, 410), "4) CON   " + str(member["con"]) + " -> " + str(member["con"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(100, 440), "5) LCK   " + str(member["lck"]) + " -> " + str(member["lck"] + 1))
		draw_string(ThemeDB.fallback_font, Vector2(80, 500), training_message)
		draw_string(ThemeDB.fallback_font, Vector2(80, 555), "[1-5] CHOOSE STAT")
		return

	draw_string(ThemeDB.fallback_font, Vector2(80, 125), "Veteran instructors judge whether each adventurer is ready to advance.")

	for i in range(party.size()):
		var member = party[i]
		ensure_character_sp_fields(member)
		var required_xp = get_xp_required_for_next_level(member["level"])
		var status = "READY"
		if member["xp"] < required_xp:
			status = str(member["xp"]) + "/" + str(required_xp) + " XP"

		var text = (
			str(i + 1)
			+ ") " + member["name"]
			+ "   " + member["class"]
			+ "   LV " + str(member["level"])
			+ "   HP " + str(member["hp"]) + "/" + str(member["max_hp"])
			+ "   SP " + str(member["sp"]) + "/" + str(member["max_sp"])
			+ "   " + status
		)

		draw_string(ThemeDB.fallback_font, Vector2(100, 175 + i * 38), text)

	draw_string(ThemeDB.fallback_font, Vector2(80, 445), training_message)
	draw_string(ThemeDB.fallback_font, Vector2(80, 555), "[1-6] TRAIN CHARACTER     [ESC] RETURN TO CITY")



# ============================================================
# WILDERNESS VIEW
# ============================================================

func draw_wilderness_view():
	var view = Rect2(40, 40, 700, 400)
	draw_rect(view, Color("#182319"), true)
	draw_rect(view, Color("#7f9474"), false, 3)
	var frames = [Rect2(40,40,700,400), Rect2(150,100,480,280), Rect2(235,145,310,190), Rect2(300,180,180,120)]
	for depth in range(4):
		var pos = wilderness.get_relative_position(depth + 1)
		var outer = frames[depth]
		if wilderness.is_blocked(pos):
			draw_rect(outer, Color("#304b2f"), true)
			draw_rect(outer, Color("#6f8d62"), false, 3)
			break
		var inner = frames[depth + 1] if depth < 3 else Rect2(350,205,80,70)
		draw_line(outer.position, inner.position, Color("#8fa184"), 2)
		draw_line(Vector2(outer.end.x, outer.position.y), Vector2(inner.end.x, inner.position.y), Color("#8fa184"), 2)
		draw_line(Vector2(outer.position.x, outer.end.y), Vector2(inner.position.x, inner.end.y), Color("#8fa184"), 2)
		draw_line(outer.end, inner.end, Color("#8fa184"), 2)

func draw_wilderness_status():
	draw_string(ThemeDB.fallback_font, Vector2(780,70), wilderness.get_name().to_upper())
	draw_string(ThemeDB.fallback_font, Vector2(780,100), "FACING: " + wilderness.get_facing_name())
	draw_string(ThemeDB.fallback_font, Vector2(780,130), "POSITION: " + str(wilderness.player_pos))
	var loc = wilderness.get_current_location()
	if not loc.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(780,165), loc.get("name", "LANDMARK"))
		draw_string(ThemeDB.fallback_font, Vector2(780,195), "[ENTER] ENTER")
	draw_string(ThemeDB.fallback_font, Vector2(780,235), "[I] INVENTORY")
	if wilderness.message != "":
		draw_string(ThemeDB.fallback_font, Vector2(780,265), wilderness.message)

func draw_wilderness_map():
	var tile_size = 14
	var origin = Vector2(780, 300)
	for y in range(wilderness.get_height()):
		for x in range(wilderness.get_width()):
			var pos = Vector2i(x,y)
			var rect = Rect2(origin.x + x*tile_size, origin.y + y*tile_size, tile_size-1, tile_size-1)
			if pos == wilderness.player_pos:
				draw_rect(rect, Color("#ffd166"))
			elif wilderness.is_blocked(pos):
				draw_rect(rect, Color("#29472c"))
			elif wilderness.has_location(pos):
				draw_rect(rect, Color("#a67c52"))
			elif wilderness.get_tile(pos) == "=":
				draw_rect(rect, Color("#78684f"))
			else:
				draw_rect(rect, Color("#3d5f3c"))

# ============================================================
# CITY VIEW
# ============================================================

func draw_city_view():

	var view = Rect2(
		40,
		40,
		700,
		400
	)

	var wall_color = Color("#59636b")
	var edge_color = Color("#b5bec5")
	var street_color = Color("#151b20")

	draw_rect(
		view,
		street_color,
		true
	)

	draw_rect(
		view,
		Color("#7d8992"),
		false,
		3
	)

	var frames = [
		Rect2(40, 40, 700, 400),
		Rect2(150, 100, 480, 280),
		Rect2(235, 145, 310, 190),
		Rect2(300, 180, 180, 120)
	]

	for depth in range(4):

		var forward_pos = city.get_relative_position(
			depth + 1
		)

		var outer = frames[depth]

		if city.is_wall(forward_pos):

			draw_rect(
				outer,
				wall_color,
				true
			)

			draw_rect(
				outer,
				edge_color,
				false,
				3
			)

			break

		var inner: Rect2

		if depth < frames.size() - 1:
			inner = frames[depth + 1]
		else:
			inner = Rect2(350, 205, 80, 70)

		var left_pos = city.get_relative_position(
			depth + 1,
			-1
		)

		if city.is_wall(left_pos):

			var left_wall = PackedVector2Array([
				Vector2(outer.position.x, outer.position.y),
				Vector2(inner.position.x, inner.position.y),
				Vector2(inner.position.x, inner.end.y),
				Vector2(outer.position.x, outer.end.y)
			])

			draw_colored_polygon(
				left_wall,
				wall_color
			)

			draw_polyline(
				left_wall,
				edge_color,
				2
			)

		var right_pos = city.get_relative_position(
			depth + 1,
			1
		)

		if city.is_wall(right_pos):

			var right_wall = PackedVector2Array([
				Vector2(outer.end.x, outer.position.y),
				Vector2(inner.end.x, inner.position.y),
				Vector2(inner.end.x, inner.end.y),
				Vector2(outer.end.x, outer.end.y)
			])

			draw_colored_polygon(
				right_wall,
				wall_color
			)

			draw_polyline(
				right_wall,
				edge_color,
				2
			)

		draw_line(
			outer.position,
			inner.position,
			edge_color,
			2
		)

		draw_line(
			Vector2(outer.end.x, outer.position.y),
			Vector2(inner.end.x, inner.position.y),
			edge_color,
			2
		)

		draw_line(
			Vector2(outer.position.x, outer.end.y),
			Vector2(inner.position.x, inner.end.y),
			edge_color,
			2
		)

		draw_line(
			outer.end,
			inner.end,
			edge_color,
			2
		)


func draw_city_status():

	draw_string(
		ThemeDB.fallback_font,
		Vector2(780, 70),
		city.get_city_name().to_upper()
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(780, 100),
		"FACING: "
		+ city.get_facing_name()
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(780, 130),
		"POSITION: "
		+ str(city.player_pos)
	)

	var location = city.get_current_location()

	if not location.is_empty():

		draw_string(
			ThemeDB.fallback_font,
			Vector2(780, 165),
			location["name"]
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(780, 195),
			"[ENTER] ENTER"
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(780, 265),
		"[I] INVENTORY"
	)

	if city.message != "":

		draw_string(
			ThemeDB.fallback_font,
			Vector2(780, 235),
			city.message
		)


func draw_city_map():

	var tile_size = 18
	var origin = Vector2(800, 280)

	for y in range(city.get_height()):

		for x in range(city.get_width()):

			var rect = Rect2(
				origin.x + x * tile_size,
				origin.y + y * tile_size,
				tile_size - 1,
				tile_size - 1
			)

			var map_pos = Vector2i(x, y)

			if map_pos == city.player_pos:

				draw_rect(
					rect,
					Color("#ffd166")
				)

			elif city.is_wall(map_pos):

				draw_rect(
					rect,
					Color("#555566")
				)

			elif city.has_location(map_pos):

				draw_rect(
					rect,
					Color("#6f8f72")
				)

			else:

				draw_rect(
					rect,
					Color("#22222c")
				)


# ============================================================
# DUNGEON VIEW
# ============================================================

func draw_dungeon_view():

	var view = Rect2(
		40,
		40,
		700,
		400
	)

	var wall_color = Color(
		"#696977"
	)

	var edge_color = Color(
		"#aaaabb"
	)

	var darkness = Color(
		"#101018"
	)

	draw_rect(
		view,
		darkness,
		true
	)

	draw_rect(
		view,
		Color("#777788"),
		false,
		3
	)

	var frames = [
		Rect2(
			40,
			40,
			700,
			400
		),
		Rect2(
			150,
			100,
			480,
			280
		),
		Rect2(
			235,
			145,
			310,
			190
		),
		Rect2(
			300,
			180,
			180,
			120
		)
	]

	for depth in range(4):

		var forward_pos = (
			dungeon.get_relative_position(
				depth + 1
			)
		)

		var outer = frames[depth]

		if dungeon.is_wall(
			forward_pos
		):

			draw_rect(
				outer,
				wall_color,
				true
			)

			draw_rect(
				outer,
				edge_color,
				false,
				3
			)

			break

		var inner: Rect2

		if depth < frames.size() - 1:

			inner = frames[
				depth + 1
			]

		else:

			inner = Rect2(
				350,
				205,
				80,
				70
			)

		var left_pos = (
			dungeon.get_relative_position(
				depth + 1,
				-1
			)
		)

		if dungeon.is_wall(
			left_pos
		):

			var left_wall = PackedVector2Array([
				Vector2(
					outer.position.x,
					outer.position.y
				),
				Vector2(
					inner.position.x,
					inner.position.y
				),
				Vector2(
					inner.position.x,
					inner.end.y
				),
				Vector2(
					outer.position.x,
					outer.end.y
				)
			])

			draw_colored_polygon(
				left_wall,
				wall_color
			)

			draw_polyline(
				left_wall,
				edge_color,
				2
			)

		var right_pos = (
			dungeon.get_relative_position(
				depth + 1,
				1
			)
		)

		if dungeon.is_wall(
			right_pos
		):

			var right_wall = PackedVector2Array([
				Vector2(
					outer.end.x,
					outer.position.y
				),
				Vector2(
					inner.end.x,
					inner.position.y
				),
				Vector2(
					inner.end.x,
					inner.end.y
				),
				Vector2(
					outer.end.x,
					outer.end.y
				)
			])

			draw_colored_polygon(
				right_wall,
				wall_color
			)

			draw_polyline(
				right_wall,
				edge_color,
				2
			)

		draw_line(
			outer.position,
			inner.position,
			edge_color,
			2
		)

		draw_line(
			Vector2(
				outer.end.x,
				outer.position.y
			),
			Vector2(
				inner.end.x,
				inner.position.y
			),
			edge_color,
			2
		)

		draw_line(
			Vector2(
				outer.position.x,
				outer.end.y
			),
			Vector2(
				inner.position.x,
				inner.end.y
			),
			edge_color,
			2
		)

		draw_line(
			outer.end,
			inner.end,
			edge_color,
			2
		)


# ============================================================
# PARTY PANEL
# ============================================================

func draw_party_panel():

	var panel = Rect2(
		40,
		470,
		700,
		150
	)

	draw_rect(
		panel,
		Color("#20202a"),
		true
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			60,
			495
		),
		("PARTY     GOLD: " if game_state in [GameState.COMBAT, GameState.COMBAT_RESULT] else "PARTY [I: MANAGE] [K: SKILLS] [F: FORMATION]     GOLD: ")
		+ str(
			progression.get_party_gold()
		)
	)

	for i in range(
		party.size()
	):

		var member = party[i]

		var status = ""

		if member["hp"] <= 0:

			status = "  [DEAD]" if bool(member.get("dead", false)) else "  [DOWN: %d]" % int(member.get("death_rounds_remaining", 3))

		var text = (
			PartyScript.SLOT_NAMES[party_system.slots.find(member["character_id"])]
			+ ": "
			+ member["name"]
			+ "  "
			+ member["class"]
			+ "  LV "
			+ str(member["level"])
			+ "  HP "
			+ str(member["hp"])
			+ "/"
			+ str(member["max_hp"])
			+ "  XP "
			+ str(member["xp"])
			+ status
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				60,
				520 + i * 17
			),
			text
		)


# ============================================================
# DUNGEON STATUS
# ============================================================

func wrap_ui_text(text: String, max_chars: int) -> Array[String]:
	var lines: Array[String] = []
	var current = ""
	for word in text.split(" "):
		var candidate = word if current == "" else current + " " + word
		if candidate.length() > max_chars and current != "":
			lines.append(current)
			current = word
		else:
			current = candidate
	if current != "":
		lines.append(current)
	return lines

func draw_status():

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			780,
			70
		),
		dungeon.get_dungeon_name().to_upper()
		+ "   FACING: "
		+ dungeon.get_facing_name()
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			780,
			100
		),
		"POSITION: "
		+ str(
			dungeon.player_pos
		) + ("  [L] Light: ON" if dungeon.lantern_on else "  [L] Light: OFF")
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(780, 130),
		"[I] Items [K] Skills [R] Rogue" + ("  [G] Exit" if dungeon.dungeon_id == "abandoned_warehouse" else "")
	)

	var display_message = dungeon.message
	if display_message.is_empty():
		display_message = str(dungeon.get_current_transition().get("hint", ""))
	var interaction_hint = DungeonInteractions.describe(dungeon, quest_items)
	if not interaction_hint.is_empty():
		display_message = interaction_hint + (" " + display_message if not display_message.is_empty() else "")
	if display_message.is_empty() and not dungeon.get_exploration_object().is_empty():
		display_message = str(dungeon.get_exploration_object()["name"]) + ". [Enter] Skills."
	if display_message != "":
		var message_lines = wrap_ui_text(display_message, 44)
		for i in range(min(3, message_lines.size())):
			draw_string(
				ThemeDB.fallback_font,
				Vector2(780, 158 + i * 16),
				message_lines[i],
				HORIZONTAL_ALIGNMENT_LEFT,
				340,
				13
			)


# ============================================================
# DUNGEON MAP
# ============================================================

func draw_map():

	var tile_size = maxi(1, mini(18, mini(int(320.0 / maxi(1, dungeon.get_width())), int(400.0 / maxi(1, dungeon.get_height())))))

	var origin = Vector2(
		800,
		200
	)

	for y in range(
		dungeon.get_height()
	):

		for x in range(
			dungeon.get_width()
		):

			var rect = Rect2(
				origin.x
				+ x * tile_size,
				origin.y
				+ y * tile_size,
				tile_size - 1,
				tile_size - 1
			)

			var map_pos = Vector2i(
				x,
				y
			)
			if not dungeon.map_tile_visible(map_pos):
				draw_rect(rect, Color("#08080d"))
				continue

			if (
				map_pos
				== dungeon.player_pos
			):

				draw_rect(
					rect,
					Color("#ffd166")
				)

			elif DungeonInteractions.available(dungeon, dungeon.get_interaction_at(map_pos)):
				var object = dungeon.get_interaction_at(map_pos)
				var color = Color("#67a36c")
				var label = "L"
				if object["type"] == "key":
					color = Color("#d9b44a")
					label = "K"
				elif object["type"] == "puzzle_switch":
					label = "P"
				elif object["type"] == "trap":
					label = "T"
					color = Color("#d45d47") if DungeonInteractions.trap_active(dungeon, object) else Color("#438c88")
				elif DungeonInteractions.is_barrier(object):
					color = Color("#438c88") if DungeonInteractions.is_open(dungeon, object) else Color("#946440")
					label = "D" if object["type"] in ["door", "locked_door", "secret_door", "puzzle_door"] else "S"
				draw_rect(rect, color)
				draw_string(ThemeDB.fallback_font, rect.position + Vector2(2, mini(13, tile_size - 2)), label, HORIZONTAL_ALIGNMENT_LEFT, -1, mini(12, maxi(6, tile_size - 3)))

			elif dungeon.is_wall(
				map_pos
			):

				draw_rect(
					rect,
					Color("#555566")
				)

			else:

				draw_rect(
					rect,
					Color("#22222c")
				)


# ============================================================
# COMBAT DRAWING
# ============================================================

func draw_combat_screen():

	var area = Rect2(
		40,
		40,
		700,
		400
	)

	draw_rect(
		area,
		Color("#181820"),
		true
	)

	draw_rect(
		area,
		Color("#aa8888"),
		false,
		3
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			65,
			75
		),
		"COMBAT — ROUND "
		+ str(
			combat.round_number
		),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		24
	)

	draw_enemy_group()

	draw_combat_action_menu()

	draw_combat_log()


func draw_enemy_group():

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			65,
			115
		),
		"ENEMIES"
	)

	var row = 0

	for i in range(
		combat.enemies.size()
	):

		var enemy = (
			combat.enemies[i]
		)

		var status = ""

		if enemy["hp"] <= 0:
			status = " [DEFEATED]"

		var text = (
			str(i + 1)
			+ ". "
			+ enemy["name"]
			+ "   HP "
			+ str(enemy["hp"])
			+ "/"
			+ str(enemy["max_hp"])
			+ status
		)

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				80,
				145 + row * 24
			),
			text
		)

		row += 1


func draw_combat_action_menu():
	var actor = get_current_combat_character()
	if actor.is_empty():
		return
	draw_string(ThemeDB.fallback_font, Vector2(65, 270),
		"CHOOSE ACTION FOR: " + str(actor["name"]) + " — " + str(actor["class"]))
	if combat_target_open:
		draw_string(ThemeDB.fallback_font, Vector2(80, 300), "SELECT ALLY (ESC to go back)" if combat_pending_ability == "berserker_savage_intervention" else "SELECT TARGET (ESC to go back)")
		var targets: Array = get_living_combat_targets()
		for i in range(combat_target_page * 9, mini(targets.size(), (combat_target_page + 1) * 9)):
			var enemy: Dictionary = targets[i]
			draw_string(ThemeDB.fallback_font, Vector2(80, 325 + (i % 9) * 25),
				str(i % 9 + 1) + ") " + str(enemy.get("name", "Enemy")) + " — " + str(enemy.get("hp", 0)) + " HP")
		draw_string(ThemeDB.fallback_font, Vector2(80, 570), "N) Next page    P) Previous page")
		return
	if combat_skills_open:
		draw_string(ThemeDB.fallback_font, Vector2(80, 300), "SKILLS (ESC to go back)")
		var options: Array = get_combat_skill_options(actor)
		for i in range(mini(options.size(), 9)):
			var skill: Dictionary = options[i]
			var cost: int = int(skill["cost"])
			var suffix: String = " (" + str(cost) + " SP)" if cost > 0 else ""
			var reason: String = combat_skill_unavailable_reason(actor, skill)
			if reason != "":
				suffix += " [" + reason + "]"
			draw_string(ThemeDB.fallback_font, Vector2(80, 325 + i * 25),
				str(i + 1) + ") " + str(skill["name"]) + suffix)
		return
	draw_string(ThemeDB.fallback_font, Vector2(80, 300), "1) ATTACK")
	draw_string(ThemeDB.fallback_font, Vector2(80, 325), "2) DEFEND")
	draw_string(ThemeDB.fallback_font, Vector2(80, 350), "3) SKILLS")
	draw_string(ThemeDB.fallback_font, Vector2(80, 375), "4) RUN")
	draw_string(ThemeDB.fallback_font, Vector2(80, 400), "5) REPOSITION (uses action)")


func get_class_ability_name(
	character_class: String
) -> String:

	for class_data in classes:

		if (
			class_data["name"]
			== character_class
		):

			return class_data[
				"ability"
			]

	return "ABILITY"


func draw_combat_log():

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			400,
			115
		),
		"COMBAT LOG"
	)

	var start = max(
		0,
		combat.combat_log.size() - 10
	)

	var row = 0

	for i in range(
		start,
		combat.combat_log.size()
	):

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				400,
				145 + row * 24
			),
			combat.combat_log[i]
		)

		row += 1


# ============================================================
# COMBAT RESULT DRAWING
# ============================================================

func draw_combat_result():

	var area = Rect2(
		160,
		120,
		830,
		350
	)

	draw_rect(
		area,
		Color("#181820"),
		true
	)

	draw_rect(
		area,
		Color("#aaaaaa"),
		false,
		3
	)

	var lines = (
		combat_result_text.split("\n")
	)

	for i in range(
		lines.size()
	):

		draw_string(
			ThemeDB.fallback_font,
			Vector2(
				210,
				200 + i * 35
			),
			lines[i],
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			24
		)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(
			210,
			400
		),
		"[ENTER] RELOAD LAST SAVE   [N] NEW GAME" if combat.party_defeated(party) else "[ENTER] CONTINUE"
	)


# The overlay preserves the underlying location and never exposes reserves.
func open_formation_menu():
	formation_menu_open = true
	formation_source = -1
	queue_redraw()

func handle_formation_menu_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE:
		formation_menu_open = false
		formation_source = -1
		queue_redraw()
		return
	var slot = int(event.keycode) - int(KEY_1)
	if slot < 0 or slot >= 6:
		return
	if game_state == GameState.COMBAT:
		var actor = get_current_combat_character()
		if actor.is_empty() or not combat.can_act(actor):
			return
		if party_system.slots.find(str(actor.get("character_id", ""))) == slot:
			return
		formation_menu_open = false
		queue_current_action("Reposition", "", {}, slot)
	elif formation_source < 0:
		if party_system.slots[slot] != "":
			formation_source = slot
	else:
		party_system.reposition(party_system.slots[formation_source], slot)
		formation_source = -1
	queue_redraw()

func draw_formation_menu():
	draw_header("PARTY FORMATION")
	var instruction = "Choose a character [1-6], then a destination [1-6]."
	if game_state == GameState.COMBAT:
		instruction = "Choose destination [1-6] for " + str(get_current_combat_character().get("name", "")) + ". Uses their action."
	elif formation_source >= 0:
		instruction = "Choose destination [1-6] for " + str(party_system.find_character(party_system.slots[formation_source]).get("name", "")) + "."
	draw_string(ThemeDB.fallback_font, Vector2(60, 130), instruction)
	for i in range(6):
		var member = party_system.find_character(party_system.slots[i])
		var marker = "> " if i == formation_source else ""
		var text = marker + str(i + 1) + ") " + PartyScript.SLOT_NAMES[i] + ": " + str(member.get("name", "Empty"))
		draw_string(ThemeDB.fallback_font, Vector2(80, 185 + i * 40), text)
	draw_string(ThemeDB.fallback_font, Vector2(60, 470), "Occupied positions swap. Reserve characters stay at the Guild.")
	draw_string(ThemeDB.fallback_font, Vector2(60, 510), "[Esc] Back")


func stable_save_state() -> int:
	var state = inventory_return_state if game_state == GameState.INVENTORY else game_state
	if state in [GameState.GUILD, GameState.PARTY_SELECT]:
		return GameState.GUILD
	if state in [GameState.CITY, GameState.SHOP, GameState.TOWN_HALL, GameState.WARDEN_KEEP, GameState.INN, GameState.TEMPLE]:
		return GameState.CITY
	if state in [GameState.WILDERNESS, GameState.DUNGEON]:
		return state
	return -1

func capture_save() -> Dictionary:
	var state = stable_save_state()
	if state < 0 or (state != GameState.GUILD and combat.party_defeated(party)):
		return {}
	return {
		"version": 1, "state": state, "party": party_system.to_data(),
		"gold": progression.get_party_gold(), "quests": quest_system.quest_states.duplicate(true),
		"quest_items": quest_items.duplicate(true),
		"city": {"id": city.city_id, "position": city.player_pos, "facing": city.facing},
		"wilderness": {"id": wilderness.wilderness_id, "position": wilderness.player_pos, "facing": wilderness.facing},
		"dungeon": {"id": dungeon.dungeon_id, "position": dungeon.player_pos, "facing": dungeon.facing,
			"defeated": dungeon.defeated_fixed_encounters.duplicate(true),
			"permanent_events": dungeon.consumed_permanent_events.duplicate(true),
			"expedition_events": dungeon.consumed_expedition_events.duplicate(true),
			"rogue_attempts": dungeon.rogue_attempts.duplicate(true),
			"interaction_states": dungeon.interaction_states.duplicate(true), "lantern_on": dungeon.lantern_on, "exploration_steps": dungeon.exploration_steps,
			"encounter_grace_remaining": dungeon.encounter_grace_remaining, "encounter_grace_on_step": dungeon.encounter_grace_on_step}
	}

func save_game() -> bool:
	var data = capture_save()
	if data.is_empty():
		save_message = "Save outside combat and unfinished training."
		return false
	var ok = SaveGame.write(save_path, data)
	save_message = "Game saved." if ok else "Save failed; previous save retained."
	return ok

func load_game() -> bool:
	if game_state == GameState.COMBAT:
		return false
	if not restore_save(SaveGame.read(save_path)):
		save_message = "No valid save found; current game retained."
		return false
	save_message = "Game loaded."
	return true

func valid_saved_location(data: Dictionary, system) -> bool:
	if not data.get("position") is Vector2i or not data.get("facing") is int or data["facing"] < 0 or data["facing"] >= 4:
		return false
	if system is WildernessSystem:
		return not system.is_blocked(data["position"])
	return system.can_move_to(data["position"])

func restore_save(data: Dictionary) -> bool:
	# Stage every system before replacing live state; a bad save is atomic.
	if data.get("version") != 1 or data.get("state") not in [GameState.GUILD, GameState.CITY, GameState.WILDERNESS, GameState.DUNGEON]:
		return false
	for field in ["party", "quests", "quest_items", "city", "wilderness", "dungeon"]:
		if not data.get(field) is Dictionary:
			return false
	if not data.get("gold") is int or data["gold"] < 0:
		return false
	var restored_party = PartyScript.new()
	if not restored_party.restore(data["party"]):
		return false
	if data["state"] != GameState.GUILD and combat.party_defeated(restored_party.active_members()):
		return false
	var restored_city = CitySystem.new()
	var restored_wilderness = WildernessSystem.new()
	var restored_dungeon = DungeonSystem.new()
	if not restored_city.load_city(str(data["city"].get("id", ""))) or not restored_wilderness.load_wilderness(str(data["wilderness"].get("id", ""))) or not restored_dungeon.load_dungeon(str(data["dungeon"].get("id", ""))):
		return false
	# Apply the barrier overlay before validating a saved position on an open door.
	if not DungeonInteractions.valid_states(data["dungeon"].get("interaction_states", {})):
		return false
	if not data["dungeon"].get("lantern_on", false) is bool:
		return false
	var saved_steps = data["dungeon"].get("exploration_steps", 0)
	if not saved_steps is int or saved_steps < 0:
		return false
	var saved_grace = data["dungeon"].get("encounter_grace_remaining", restored_dungeon.encounter_grace_remaining)
	var grace_on_step = data["dungeon"].get("encounter_grace_on_step", restored_dungeon.encounter_grace_on_step)
	if not saved_grace is int or saved_grace < 0 or not grace_on_step is bool:
		return false
	restored_dungeon.encounter_grace_remaining = saved_grace
	restored_dungeon.encounter_grace_on_step = grace_on_step
	restored_dungeon.exploration_steps = saved_steps
	restored_dungeon.lantern_on = data["dungeon"].get("lantern_on", false)
	restored_dungeon.interaction_states = data["dungeon"].get("interaction_states", {}).duplicate(true)
	for entry in [[data["city"], restored_city], [data["wilderness"], restored_wilderness], [data["dungeon"], restored_dungeon]]:
		if not valid_saved_location(entry[0], entry[1]):
			return false
		entry[1].player_pos = entry[0]["position"]
		entry[1].facing = entry[0]["facing"]
	for field in ["defeated", "permanent_events", "expedition_events"]:
		if not data["dungeon"].get(field) is Dictionary:
			return false
	if not RogueSkills.valid_records(data["dungeon"].get("rogue_attempts", {})):
		return false
	restored_dungeon.rogue_attempts = data["dungeon"].get("rogue_attempts", {}).duplicate(true)
	restored_dungeon.defeated_fixed_encounters = data["dungeon"]["defeated"].duplicate(true)
	restored_dungeon.consumed_permanent_events = data["dungeon"]["permanent_events"].duplicate(true)
	restored_dungeon.consumed_expedition_events = data["dungeon"]["expedition_events"].duplicate(true)
	party_system = restored_party
	city = restored_city
	wilderness = restored_wilderness
	dungeon = restored_dungeon
	progression = ProgressionSystem.new()
	progression.add_gold(data["gold"])
	quest_system = QuestSystem.new()
	quest_system.quest_states = data["quests"].duplicate(true)
	quest_items = data["quest_items"].duplicate(true)
	combat = CombatSystem.new()
	bind_party_services()
	clear_all_combat_flags()
	game_state = data["state"]
	combat_character_index = 0
	current_combat_tag = ""
	last_combat_rewards = {}
	combat_result_text = ""
	combat_skills_open = false
	combat_target_open = false
	formation_menu_open = false
	rogue_skills_open = false
	class_skills_open = false
	class_skill_message = ""
	rogue_message = ""
	developer_menu_open = false
	inventory_character_index = 0
	roster_page = 0
	training_pending_member = {}
	queue_redraw()
	return true

func handle_temple_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE:
		game_state = GameState.CITY
	elif event.keycode in [KEY_LEFT, KEY_RIGHT] and not party.is_empty():
		temple_character_index = (temple_character_index + party.size() + (-1 if event.keycode == KEY_LEFT else 1)) % party.size()
	elif event.keycode == KEY_ENTER and not party.is_empty():
		temple_character_index = clampi(temple_character_index, 0, party.size() - 1)
		var member = party[temple_character_index]
		if CharacterHealth.resurrect(member):
			temple_message = str(member["name"]) + " returns to life with 1 HP. Other conditions remain."
		else:
			temple_message = "Only the dead require resurrection. Use ordinary healing for incapacitation."
	queue_redraw()

func draw_temple():
	draw_header("TEMPLE — RESURRECTION")
	if not party.is_empty():
		temple_character_index = clampi(temple_character_index, 0, party.size() - 1)
		var member = party[temple_character_index]
		draw_string(ThemeDB.fallback_font, Vector2(60, 150), str(member["name"]) + " — " + CharacterHealth.status(member))
	draw_string(ThemeDB.fallback_font, Vector2(60, 225), "Resurrection restores 1 HP. Service is free.")
	draw_string(ThemeDB.fallback_font, Vector2(60, 285), temple_message, HORIZONTAL_ALIGNMENT_LEFT, 1000)
	draw_string(ThemeDB.fallback_font, Vector2(60, 400), "[Left/Right] Character   [Enter] Resurrect   [Esc] City")


func get_active_rogues() -> Array:
	var rogues: Array = []
	for member in party:
		if str(member.get("class", "")) == "Rogue":
			rogues.append(member)
	return rogues

func open_rogue_skills():
	if game_state != GameState.DUNGEON:
		return
	rogue_skills_open = true
	rogue_character_index = 0
	rogue_selected_skill = "pick_lock"
	rogue_message = ""
	queue_redraw()

func handle_rogue_skills_input(event):
	if game_state != GameState.DUNGEON or not event.is_pressed() or event.is_echo():
		return
	var rogues = get_active_rogues()
	if event.keycode == KEY_ESCAPE:
		rogue_skills_open = false
	elif event.keycode in [KEY_LEFT, KEY_RIGHT] and not rogues.is_empty():
		rogue_character_index = (rogue_character_index + rogues.size() + (-1 if event.keycode == KEY_LEFT else 1)) % rogues.size()
		rogue_message = ""
	elif event.keycode in [KEY_1, KEY_2]:
		rogue_selected_skill = "pick_lock" if event.keycode == KEY_1 else "disarm_trap"
		rogue_message = ""
	elif event.keycode == KEY_ENTER and not rogues.is_empty():
		rogue_character_index = clampi(rogue_character_index, 0, rogues.size() - 1)
		var result = RogueSkills.attempt(party_system, dungeon, rogues[rogue_character_index], rogue_selected_skill)
		progression.add_gold(int(result.get("gold", 0)))
		rogue_message = str(result["message"])
		if int(result.get("gold", 0)) > 0:
			rogue_message += " +%d gold." % int(result["gold"])
		dungeon.message = rogue_message
		if combat.party_defeated(party):
			rogue_skills_open = false
			combat_result_text = "THE PARTY HAS FALLEN.\n\nGame over. Reload the last save to continue."
			game_state = GameState.COMBAT_RESULT
	queue_redraw()

func draw_rogue_skills():
	draw_header("ROGUE SKILLS")
	var rogues = get_active_rogues()
	var actor: Dictionary = {}
	if not rogues.is_empty():
		rogue_character_index = clampi(rogue_character_index, 0, rogues.size() - 1)
		actor = rogues[rogue_character_index]
	draw_string(ThemeDB.fallback_font, Vector2(60, 125), "Rogue: " + str(actor.get("name", "No active Rogue in the party")))
	var object = dungeon.get_skill_target()
	draw_string(ThemeDB.fallback_font, Vector2(60, 165), "Target: " + str(object.get("name", "No lock or trap on this tile")))
	draw_string(ThemeDB.fallback_font, Vector2(80, 225), ("> " if rogue_selected_skill == "pick_lock" else "  ") + "1) Pick Lock")
	draw_string(ThemeDB.fallback_font, Vector2(80, 265), ("> " if rogue_selected_skill == "disarm_trap" else "  ") + "2) Disarm Trap")
	var reason = RogueSkills.unavailable_reason(party_system, dungeon, actor, rogue_selected_skill)
	var preview = "Success chance: %d%%. One attempt per Rogue per object." % RogueSkills.SUCCESS_CHANCE
	if not reason.is_empty():
		preview = reason
	draw_string(ThemeDB.fallback_font, Vector2(60, 325), preview)
	var consequence = "Failure: lock stays shut; this Rogue cannot retry."
	if rogue_selected_skill == "disarm_trap":
		consequence = "Failure: selected Rogue takes %d damage and cannot retry." % int(object.get("failure_damage", 4))
	draw_string(ThemeDB.fallback_font, Vector2(60, 365), consequence)
	for i in range(wrap_ui_text(rogue_message, 90).size()):
		draw_string(ThemeDB.fallback_font, Vector2(60, 425 + i * 24), wrap_ui_text(rogue_message, 90)[i])
	draw_string(ThemeDB.fallback_font, Vector2(60, 540), "[Left/Right] Rogue   [1/2] Skill   [Enter] Attempt   [Esc] Back")


func open_class_skills():
	if game_state not in [GameState.GUILD, GameState.PARTY_SELECT, GameState.CITY, GameState.WILDERNESS, GameState.DUNGEON, GameState.INVENTORY, GameState.SHOP, GameState.TRAINING_HALL, GameState.TOWN_HALL, GameState.WARDEN_KEEP, GameState.INN, GameState.TEMPLE]:
		return
	class_character_index = 0
	if game_state == GameState.INVENTORY:
		var members = get_management_members()
		if not members.is_empty():
			class_character_index = maxi(0, get_party_index(members[clampi(inventory_character_index, 0, members.size() - 1)]))
	class_skill_index = 0
	class_skill_message = ""
	class_skills_open = true
	queue_redraw()

func handle_class_skills_input(event):
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE:
		class_skills_open = false
		queue_redraw()
		return
	if party.is_empty():
		return
	class_character_index = clampi(class_character_index, 0, party.size() - 1)
	if event.keycode in [KEY_LEFT, KEY_RIGHT]:
		class_character_index = (class_character_index + party.size() + (-1 if event.keycode == KEY_LEFT else 1)) % party.size()
		class_skill_index = 0
		class_skill_message = ""
	else:
		var actor = party[class_character_index]
		var skills = ExplorationSkills.skills_for_class(str(actor.get("class", "")))
		var choice = number_key_to_roster_index(event.keycode)
		if choice >= 0 and choice < skills.size():
			class_skill_index = choice
			class_skill_message = ""
		elif event.keycode == KEY_ENTER and not skills.is_empty():
			if stable_save_state() != GameState.DUNGEON:
				class_skill_message = "No matching exploration target here."
			else:
				class_skill_index = clampi(class_skill_index, 0, skills.size() - 1)
				var result = ExplorationSkills.attempt(party_system, dungeon, actor, skills[class_skill_index])
				progression.add_gold(int(result.get("gold", 0)))
				class_skill_message = str(result["message"])
				if int(result.get("gold", 0)) > 0:
					class_skill_message += " +%d gold." % int(result["gold"])
				dungeon.message = class_skill_message
				if combat.party_defeated(party):
					class_skills_open = false
					combat_result_text = "THE PARTY HAS FALLEN.\n\nGame over. Reload the last save to continue."
					game_state = GameState.COMBAT_RESULT
	queue_redraw()

func draw_class_skills():
	if party.is_empty():
		draw_header("CLASS SKILLS")
		draw_string(ThemeDB.fallback_font, Vector2(60, 150), "Assemble an active party to view class skills. [Esc] Back")
		return
	class_character_index = clampi(class_character_index, 0, party.size() - 1)
	var actor = party[class_character_index]
	var menu = ExplorationSkills.menu_name(str(actor.get("class", "")))
	draw_header(menu.to_upper())
	draw_string(ThemeDB.fallback_font, Vector2(60, 120), str(actor["name"]) + " — " + str(actor.get("class", "")) + " — " + CharacterHealth.status(actor))
	var skills = ExplorationSkills.skills_for_class(str(actor.get("class", "")))
	if skills.is_empty():
		var message = "No out-of-combat spells defined yet." if menu == "Cast Spell" else "No Bard songs defined yet."
		draw_string(ThemeDB.fallback_font, Vector2(60, 220), message)
		draw_string(ThemeDB.fallback_font, Vector2(60, 540), "[Left/Right] Character   [Esc] Back")
		return
	class_skill_index = clampi(class_skill_index, 0, skills.size() - 1)
	var object = dungeon.get_skill_target() if stable_save_state() == GameState.DUNGEON else {}
	draw_string(ThemeDB.fallback_font, Vector2(60, 165), "Target: " + str(object.get("name", "No exploration target here")))
	for i in range(skills.size()):
		draw_string(ThemeDB.fallback_font, Vector2(80, 225 + i * 40), ("> " if i == class_skill_index else "  ") + str(i + 1) + ") " + str(ExplorationSkills.SKILLS[skills[i]]["name"]))
	var reason = "No matching exploration target here." if stable_save_state() != GameState.DUNGEON else ExplorationSkills.unavailable_reason(party_system, dungeon, actor, skills[class_skill_index])
	draw_string(ThemeDB.fallback_font, Vector2(60, 325), reason if not reason.is_empty() else "Success chance: 70%. One attempt per character per object.")
	var damage = int(object.get("failure_damage", 4 if skills[class_skill_index] == "disarm_trap" else 0))
	draw_string(ThemeDB.fallback_font, Vector2(60, 365), "Failure: %d damage; this character cannot retry." % damage if damage > 0 else "Failure: no progress; this character cannot retry.")
	var lines = wrap_ui_text(class_skill_message, 90)
	for i in range(mini(lines.size(), 4)):
		draw_string(ThemeDB.fallback_font, Vector2(60, 415 + i * 24), lines[i])
	draw_string(ThemeDB.fallback_font, Vector2(60, 555), "[Left/Right] Character   [1/2] Skill   [Enter] Attempt   [Esc] Back")


func draw_dungeon_interaction():
	var position = dungeon.player_pos + dungeon.get_forward_direction()
	var barrier = dungeon.get_interaction_at(position)
	if DungeonInteractions.available(dungeon, barrier) and DungeonInteractions.is_barrier(barrier) and not DungeonInteractions.is_open(dungeon, barrier):
		var door = Rect2(210, 90, 360, 330)
		draw_rect(door, Color("#64452f"))
		draw_rect(door, Color("#cba776"), false, 4)
		draw_line(Vector2(390, 95), Vector2(390, 415), Color("#cba776"), 3)
		draw_circle(Vector2(440, 275), 9, Color("#d9b44a"))
		return
	var object = DungeonInteractions.target(dungeon)
	if object.get("type", "") == "puzzle_switch":
		draw_rect(Rect2(345, 200, 90, 100), Color("#37424b"))
		draw_circle(Vector2(390, 250), 24, Color("#d9b44a") if int(object.get("step", 1)) == 1 else Color("#a4b8d8"))
		draw_string(ThemeDB.fallback_font, Vector2(360, 330), str(object.get("name", "Switch")))
	elif object.get("type", "") == "trap":
		var color = Color("#d45d47") if DungeonInteractions.trap_active(dungeon, object) else Color("#438c88")
		draw_rect(Rect2(310, 350, 160, 35), color, false, 3)
		for x in range(325, 470, 30):
			draw_line(Vector2(x, 380), Vector2(x + 8, 355), color, 3)
	elif object.get("type", "") == "lever":
		draw_rect(Rect2(345, 180, 90, 140), Color("#37424b"))
		draw_line(Vector2(390, 285), Vector2(420, 215), Color("#d9b44a"), 8)
	elif object.get("type", "") == "key":
		draw_circle(Vector2(350, 260), 15, Color("#d9b44a"))
		draw_line(Vector2(350, 260), Vector2(420, 260), Color("#d9b44a"), 8)
		draw_line(Vector2(410, 260), Vector2(410, 278), Color("#d9b44a"), 8)
