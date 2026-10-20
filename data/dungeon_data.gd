class_name DungeonData
extends RefCounted

const AbandonedWarehouse = preload("res://data/dungeons/abandoned_warehouse.gd")
const WineCellar = preload("res://data/dungeons/wine_cellar.gd")
const ThornwakeSewersUpper = preload("res://data/dungeons/thornwake_sewers_upper.gd")
const ThornwakeSewersLower = preload("res://data/dungeons/thornwake_sewers_lower.gd")
const OldPrisonBarracks = preload("res://data/dungeons/old_prison_barracks.gd")
const OldPrisonHolding = preload("res://data/dungeons/old_prison_holding.gd")
const OldPrisonTorture = preload("res://data/dungeons/old_prison_torture.gd")
const OldPrisonMorgue = preload("res://data/dungeons/old_prison_morgue.gd")
const BrokenReliquaryChurch = preload("res://data/dungeons/broken_reliquary_church.gd")
const BrokenReliquaryArchives = preload("res://data/dungeons/broken_reliquary_archives.gd")
const BrokenReliquaryCatacombsUpper = preload("res://data/dungeons/broken_reliquary_catacombs_upper.gd")
const BrokenReliquaryCatacombsLower = preload("res://data/dungeons/broken_reliquary_catacombs_lower.gd")
const BrokenReliquaryChapel = preload("res://data/dungeons/broken_reliquary_chapel.gd")

const ArchitectTestNave = preload("res://data/dungeons/architect_test_church_nave.gd")

const ArchitectTestArchives = preload("res://data/dungeons/architect_test_archives.gd")

const DUNGEONS = {
	"architect_test_archives": ArchitectTestArchives.DATA,
	"architect_test_church_nave": ArchitectTestNave.DATA,
	"abandoned_warehouse": AbandonedWarehouse.DATA,
	"wine_cellar": WineCellar.DATA,
	"thornwake_sewers_upper": ThornwakeSewersUpper.DATA,
	"thornwake_sewers_lower": ThornwakeSewersLower.DATA,
	"old_prison_barracks": OldPrisonBarracks.DATA,
	"old_prison_holding": OldPrisonHolding.DATA,
	"old_prison_torture": OldPrisonTorture.DATA,
	"old_prison_morgue": OldPrisonMorgue.DATA,
	"broken_reliquary_church": BrokenReliquaryChurch.DATA,
	"broken_reliquary_archives": BrokenReliquaryArchives.DATA,
	"broken_reliquary_catacombs_upper": BrokenReliquaryCatacombsUpper.DATA,
	"broken_reliquary_catacombs_lower": BrokenReliquaryCatacombsLower.DATA,
	"broken_reliquary_chapel": BrokenReliquaryChapel.DATA
}
