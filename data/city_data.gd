class_name CityData
extends RefCounted

const Thornwake = preload("res://data/towns/thornwake.gd")
const Grayhaven = preload("res://data/towns/grayhaven.gd")
const Oldroot = preload("res://data/towns/oldroot.gd")
const Ironreach = preload("res://data/towns/ironreach.gd")

const CITIES = {
	"thornwake": Thornwake.DATA,
	"grayhaven": Grayhaven.DATA,
	"oldroot": Oldroot.DATA,
	"ironreach": Ironreach.DATA
}
