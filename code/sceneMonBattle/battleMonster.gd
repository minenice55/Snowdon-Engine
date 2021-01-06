class_name BattleMonster
extends Node
var MonType = load("code/sceneMonBattle/typeEffectiveness.gd")

export (String) var monSpecies = "M0"
export (String) var monName = "ZZAZZ"
#either dex number or internal Id?
export (int) var monSpeciesId = 0

#level
export (int) var monLevel = 1
#evs
export (int) var monEffort = 0
#ivs
export (int) var monIndividual = 0
#avs lol
export (int) var monAwakening = 0

#used as a lookup into the type effectiveness table
export (int) var monType1 = MonType.typeId.NORMAL
export (int) var monType2 = MonType.typeId.UNDISCOVERED

#stats
export (int) var monHealth = 1
export (int) var monAttack = 1
export (int) var monDefense = 1
export (int) var monSpecial = 1
export (int) var monSpeed = 1
#in battle
#normalized (1.0 = 100%)
export (float) var monEvasion = 1
export (float) var monAccuracy = 1
#0 to 10
export (int) var monHype = 0
#caps at 255
export (int) var monAffection = 0
#caps at 3
var monCritRatio = 0

#TODO: current HP and stat modifier stages

#nature, 0 to 24, used in a lookup
export (int) var monNature = 0

#this will probably go somewhere else
export (ImageTexture) var picBack

func getLevel():
	return monLevel

func getAttack():
	return monAttack

func getSpecialAtk():
	return monSpecial

func getDefense():
	return monDefense

func getSpecialDef():
	return monSpecial

func getHealth():
	return monHealth

func getType1():
	return monType1

func getType2():
	return monType2
