class_name QuestData
extends RefCounted

const ThornwakeQuests = preload("res://data/quests/thornwake_quests.gd")
const GrayhavenQuests = preload("res://data/quests/grayhaven_quests.gd")

const QUESTS = {
	"rats_in_the_warehouse": ThornwakeQuests.QUESTS["rats_in_the_warehouse"],
	"katys_special_vintage": ThornwakeQuests.QUESTS["katys_special_vintage"],
	"queen_of_the_old_prison": GrayhavenQuests.QUESTS["queen_of_the_old_prison"]
}
