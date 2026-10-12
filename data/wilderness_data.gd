class_name WildernessData
extends RefCounted

const Ashenwood = preload("res://data/wilderness/ashenwood_wilderness.gd")
const Dreadmarch = preload("res://data/wilderness/dreadmarch_wilderness.gd")

const WILDERNESSES = {
	"ashenwood_wilderness": Ashenwood.DATA,
	"dreadmarch_wilderness": Dreadmarch.DATA
}
