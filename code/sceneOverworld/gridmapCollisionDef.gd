class_name GridmapCollisionHelper

enum TYPES {NONSOLID, SOLID, SLOPE, SLOPE_CORNER, INVALID}

export var collisionType = []
export var tileHeight = []
enum FACING_VALUES {DOWN, LEFT, UP, RIGHT, INVALID}

#what the fuck is a basis
const orthogonal_angles = [
	Vector3(0, 0, 0),    #DOWN
	Vector3(0, 0, PI/2),
	Vector3(0, 0, PI),
	Vector3(0, 0, -PI/2),
	Vector3(PI/2, 0, 0),
	Vector3(PI, -PI/2, -PI/2),
	Vector3(-PI/2, PI, 0),
	Vector3(0, -PI/2, -PI/2),
	Vector3(-PI, 0, 0),
	Vector3(PI, 0, -PI/2),
	Vector3(0, PI, 0),    #UP
	Vector3(0, PI, -PI/2),
	Vector3(-PI/2, 0, 0),
	Vector3(0, -PI/2, PI/2),
	Vector3(PI/2, 0, PI),
	Vector3(0, PI/2, -PI/2),
	Vector3(0, PI/2, 0),    #RIGHT
	Vector3(-PI/2, PI/2, 0),
	Vector3(PI, PI/2, 0),
	Vector3(PI/2, PI/2, 0),
	Vector3(PI, -PI/2, 0),
	Vector3(-PI/2, -PI/2, 0),
	Vector3(0, -PI/2, 0),    #LEFT
	Vector3(PI/2, -PI/2, 0)
]

#why the fuck is this like this
const FACING_TO_ORTHO = [
	Vector3(0, 0, 0),     #DOWN
	Vector3(0, -PI/2, 0), #LEFT
	Vector3(0, PI, 0),    #UP
	Vector3(0, PI/2, 0),  #RIGHT
]

#I hate this
const INDEX_TO_FACING = [
	FACING_VALUES.DOWN,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.UP,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.RIGHT,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.INVALID,
	FACING_VALUES.LEFT,
	FACING_VALUES.INVALID,
]

const INDEX_IS_SLOPE = [
	true,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	true,
	false,
	false,
	false,
	false,
	false,
	true,
	false,
	false,
	false,
	false,
	false,
	true,
	false,
]

const ORTHO_TO_INDEX = [
	0,
	22,
	10,
	16
]
