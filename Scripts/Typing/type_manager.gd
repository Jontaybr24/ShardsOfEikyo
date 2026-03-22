extends Node

enum ELEMENTS {
	NONE,
	INK,
	WOOD,
	SHARD,
	FIRE
}

# [Attacking Type, Defending Type]
var matchups = {
	[ELEMENTS.INK  , ELEMENTS.SHARD]: {"Scalar": 2.0, "SFX": ""},
	[ELEMENTS.INK  , ELEMENTS.WOOD ]: {"Scalar": 0.5, "SFX": ""},
	[ELEMENTS.SHARD, ELEMENTS.INK  ]: {"Scalar": 2.0, "SFX": ""},
	[ELEMENTS.SHARD, ELEMENTS.WOOD ]: {"Scalar": 0.5, "SFX": ""},
	[ELEMENTS.SHARD, ELEMENTS.SHARD]: {"Scalar": 1.0, "SFX": ""},
	[ELEMENTS.WOOD , ELEMENTS.INK  ]: {"Scalar": 2.0, "SFX": ""},
	[ELEMENTS.WOOD , ELEMENTS.SHARD]: {"Scalar": 0.5, "SFX": ""},
	[ELEMENTS.FIRE , ELEMENTS.WOOD ]: {"Scalar": 2.5, "SFX": ""},
}

var DEFAULT = {"Scalar": 1.0, "SFX": ""}

func get_matchup(atk_type, def_type):
	return matchups.get([atk_type, def_type], DEFAULT)

func get_scalar(atk_type, def_type):
	return matchups.get([atk_type, def_type])["Scalar"]

func get_SFX(atk_type, def_type):
	return matchups.get([atk_type, def_type])["SFX"]
