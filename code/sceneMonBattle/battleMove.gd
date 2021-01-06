class_name BattleMove
extends Node
var MonType = load("code/sceneMonBattle/typeEffectiveness.gd")

#outside of battle, only move Id and PP should be saved
#as all data can be derived from that

export (String) var moveName = "-"
export (int) var moveId = 0
export (int) var movePp = 0

#0 = physical, 1 = special, 2 = status
export (int) var moveCategory = 0

export (int) var movePower = 0
export (int) var moveAccuracy = 0
#-7 to +5 according to bulbapedia
export (int) var movePriority = 0

#used as a lookup into the type effectiveness table
export (int) var moveType = 0

var movePpInstance = movePp

func _ready():
	pass

func getType():
	return moveType

#fuckin game freak be like
static func pokeRound(double):
	if (double - floor(double)) >= 0.5:
		return floor(double)
	else:
		return ceil(double)

#calculates attack base damage
#can be overriden for moves that do direct damage
func calcBaseDamage(monAttacker: BattleMonster, monTarget: BattleMonster):
	var aMultiplier = 1
	var dMultiplier = 1
	match moveCategory:
		0:
			aMultiplier = monAttacker.getAttack()
			dMultiplier = monTarget.getDefense()
		1:
			aMultiplier = monAttacker.getSpecialAtk()
			dMultiplier = monTarget.getSpecialDef()
	#this is a mess
	#gonna clean this up eventually cause fuck
	var damage = floor(floor(floor(2*monAttacker.getLevel()/5 + 2) * aMultiplier
				/ dMultiplier) / 50) + 2
	return damage

static func getRandomFactor(currentDamage):
	var damageArray = [] #just in case we wanna do a range preview
	for i in 15:
		damageArray.append(floor(currentDamage * (100 - i) / 100))
	randomize()
	damageArray.shuffle()
	return damageArray[0]

#calculates the attack final damage, with all multipliers applied
func calcFinalDamage(monAttacker: BattleMonster, monTarget: BattleMonster,
					numTargets: int):
	var baseDamage = calcBaseDamage(monAttacker, monTarget)
	#add all multipliers together *then* divide by 4096
	#time for hell
	var multiplierStack = 4096
	if numTargets > 1:
		multiplierStack -= (3072-4096)
	#TODO: parental bond
	#TODO: weather
	#TODO: crits (what the fuck)
	var rDamage = getRandomFactor(baseDamage)
	#TODO: STAB
	rDamage = MonType.calcEffectiveDamage(rDamage, self, monTarget)
	#TODO: burn
	var finalDamage = pokeRound(rDamage * (multiplierStack/4096))
	if finalDamage == 0:
		finalDamage = 1
	#we're not doing the 65535 damage modulation wtf
	if finalDamage > monTarget.getHealth():
		return monTarget.getHealth()
	return finalDamage
