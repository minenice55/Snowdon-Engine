class_name MonType
extends Node
#var BattleMove = load("code/sceneMonBattle/battleMove.gd")
#var BattleMonster = load("code/sceneMonBattle/battleMonster.gd")

enum typeId {NORMAL, FIGHT, FLYING, POISON, GROUND, ROCK, BUG, GHOST, STEEL,
			FIRE, WATER, GRASS, ELECTRIC, PSYCHIC, ICE, DRAGON, DARK, FAIRY,
			#??? type, used as a no-typing indicator
			UNDISCOVERED}

#type effectiveness chart, translated from bulbapedia
#1 is super effective, -1 is not very effective, -64 is ineffective
#0 is normal effectiveness
#here we fucking gooooo
#shift of -64 should be treated as setting damage to 0
const typeTable = [
	[0, 0, 0, 0, 0, -1, 1, -64, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0], #Normal
	[1, 0, -1, -1, 0, 1, -1, -64, 1, 0, 0, 0, 0, -1, 1, 0, 1, -1], #Fighting
	[0, 1, 0, 0, 0, -1, 1, 0, -1, 0, 0, 1, -1, 0, 0, 0, 0, 0], #Flying
	[0, 0, 0, -1, -1, -1, 0, -1, -64, 0, 0, 1, 0, 0, 0, 0, 0, 1], #Poison
	[0, 0, -64, 1, 0, 1, -1, 0, 1, 1, 0, -1, 1, 0, 0, 0, 0, 0], #Ground
	[0, -1, 1, 0, 1, 0, -1, 1, 0, 0, 0, 0, 1, 0, 0, 0], #Rock
	[0, -1, -1, -1, 0, 0, 0, -1, -1, -1, 0, 1, 0, 1, 0, 0, 1, -1], #Bug
	[-64, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -1, 0], #Ghost
	[0, 0, 0, 0, 0, 1, 0, 0 -1, -1, -1, 0, -1, 0, 1, 0, 0, 1], #Steel
	[0, 0, 0, 0, 0, -1, 1, 0, 1, -1, -1, 1, 0, 0, 1, -1, 0, 0], #Fire
	[0, 0, 0, 0, 1, 1, 0, 0, 0, 1, -1, -1, 0, 0, 0, -1, 0, 0], #Water
	[0, 0, -1, -1, 1, 1, -1, 0, -1, -1, 1, -1, 0, 0, 0, -1, 0, 0], #Grass
	[0, 0, 1, 0, -64, 0, 0, 0, 0, 0, 1, -1, -1, 0, 0, -1, 0, 0], #Electric
	[0, 1, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, -64, 0], #Psychic
	[0, 0, 1, 0, 1, 0, 0, 0, -1, -1, -1, 1, 0, 0, -1, 1, 0, 0], #Ice
	[0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, -64], #Dragon
	[0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -1, -1], #Dark
	[0, 1, 0, -1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 0, 0, 1, 1, 0], #Fairy
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], #???
]

static func getShiftAmount(move: BattleMove, defender: BattleMonster):
	var attackingType = move.getType()
	var defendType1 = defender.getType1()
	var defendType2 = defender.getType2()
	var attackingTable = typeTable[attackingType]
	
	if (attackingTable[defendType1] == -64
		or attackingTable[defendType2] == -64):
			return -64
	var shift = attackingTable[defendType1] + attackingTable[defendType2]
	return shift

static func calcEffectiveDamage(damage: int, move: BattleMove, defender: BattleMonster):
	var shift = getShiftAmount(move, defender)
	if shift == -64:
		return 0
	else:
		return damage << shift
