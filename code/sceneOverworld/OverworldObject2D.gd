extends KinematicBody
class_name OverworldObject2D

var gridHelper = load("code/sceneOverworld/gridmapCollisionDef.gd")

var parent
var world

const FACING_TO_OFFSET = [
	Vector3(1,0,0),    #DOWN
	Vector3(0,0,1),    #LEFT
	Vector3(-1,0,0),   #UP
	Vector3(0,0,-1)    #RIGHT
]

enum FACING_VALUES {DOWN, LEFT, UP, RIGHT, INVALID}
const walkSpeed = 3
const runSpeed = walkSpeed*2
const quickTurnMargin = 0.25/3


#yeah
const FACING_INVERSE = [FACING_VALUES.UP, FACING_VALUES.RIGHT, FACING_VALUES.DOWN, FACING_VALUES.LEFT, FACING_VALUES.INVALID]

#last position in tile space
var posTileLast = Vector3(0, 0, 0)
#position in tile space
var posTile = Vector3(0, 0, 0)
#global velocity
var velTile = Vector3(0, 0, 0)
#object's current direction
var dirFacing = FACING_VALUES.UP
var lastDirFacing = FACING_VALUES.UP
#speed of movement in current direction
var moveVel = 0
#current "floor" in the map (also Y position in tile space
var yLayer = 0

var moveBlocked = false

#counter til reached next tile (normalized)
var moveTimer = 0

#counter for the "quick turn"
var quickTurnTimer = 0

func _ready():
	parent = get_parent_spatial()
	world = parent.get_node("GridMap")
	get_node("Sprite3D/AnimationPlayer").current_animation = str("Idle", dirFacing)
	pass

#check for valid tiles to move to
#if moving, and going uphill, slow the player down
func _process(delta):
	if moveTimer > 0 and quickTurnTimer <= 0:
		if Input.is_action_pressed("overworld_run"):
			get_node("Sprite3D/AnimationPlayer").current_animation = str("Run", dirFacing)
		else:
			get_node("Sprite3D/AnimationPlayer").current_animation = str("Walk", dirFacing)
	else:
		#we would check if the next move is valid here
		if hasPlayerInvokedMove():
			
			if Input.is_action_pressed("overworld_up"):
				dirFacing = FACING_VALUES.UP
			elif Input.is_action_pressed("overworld_down"):
				dirFacing = FACING_VALUES.DOWN
			elif Input.is_action_pressed("overworld_left"):
				dirFacing = FACING_VALUES.LEFT
			elif Input.is_action_pressed("overworld_right"):
				dirFacing = FACING_VALUES.RIGHT
			
			if isFacingTileSolid():
				if not moveBlocked:
					quickTurnTimer = quickTurnMargin
					get_node("soundPlayer").play()
					get_node("Sprite3D/AnimationPlayer").current_animation = str("Walk", dirFacing)
					moveBlocked = true
			
			if hasPlayerJustInvokedMove():
				if dirFacing != lastDirFacing:
					quickTurnTimer = quickTurnMargin
					get_node("Sprite3D/AnimationPlayer").current_animation = str("Walk", dirFacing)
			if quickTurnTimer <= 0:
				if not isFacingTileSolid():
					posTileLast = posTile
					posTile += FACING_TO_OFFSET[dirFacing]
					var celId = world.get_cell_item(posTile.x, posTile.y, posTile.z)
					if world.mesh_library.collisionType[celId] == gridHelper.TYPES.SLOPE:
						posTile.y += 1
					celId = world.get_cell_item(posTileLast.x, posTileLast.y - 1, posTileLast.z)
					if gridHelper.ORTHO_TO_INDEX[dirFacing] == world.get_cell_item_orientation(posTileLast.x, posTileLast.y-1, posTileLast.z) and world.mesh_library.collisionType[celId] == gridHelper.TYPES.SLOPE:
						posTile.y -= 1
					moveTimer = 1
			
		else:
			moveBlocked = false
			if quickTurnTimer <= 0:
				moveTimer = 0
				moveVel = 0
		
		if moveTimer <= 0 and quickTurnTimer <= 0:
			moveTimer = 0
			moveVel = 0
			get_node("Sprite3D/AnimationPlayer").current_animation = str("Idle", dirFacing)
		
	moveTimer -= delta * moveVel/1
	quickTurnTimer -= delta
	lastDirFacing = dirFacing
	
	var cam = get_node("CameraTest")
	if Input.is_action_pressed("ui_up"):
		cam.translation.x -= 0.5 * delta * 2
		cam.translation.y -= 0.35 * delta * 2
	if Input.is_action_pressed("ui_down"):
		cam.translation.x += 0.5 * delta * 2
		cam.translation.y += 0.35 * delta * 2
	if Input.is_action_pressed("ui_accept"):
		cam.translation.x = 2
		cam.translation.y = 1.5
	pass

func _physics_process(delta):
	var checkTile = posTile + Vector3(0,-1,0)
	var celId = world.get_cell_item(checkTile.x, checkTile.y, checkTile.z)
	checkTile = posTileLast + Vector3(0,-1,0)
	var lastCelId = world.get_cell_item(checkTile.x, checkTile.y, checkTile.z)
	#FIXME: USE A RAYCAST TO "SNAP" TO FLOOR POSITION INSTEAD OF LERPING TO ALLOW FOR ACCURATE COLLISION
	if moveTimer > 0 and quickTurnTimer <= 0:
		translation = (posTile + (Vector3.DOWN*world.mesh_library.tileHeight[celId])).linear_interpolate(posTileLast + (Vector3.DOWN*world.mesh_library.tileHeight[lastCelId]), moveTimer)*world.cell_size
		if Input.is_action_pressed("overworld_run"):
			moveVel = runSpeed
		else:
			moveVel = walkSpeed
	else:
		translation = (posTile + (Vector3.DOWN*world.mesh_library.tileHeight[celId]))*world.cell_size
	pass

func isFacingTileSolid():
	#check for walls
	var standingCel = world.get_cell_item(posTile.x, posTile.y - 1, posTile.z)
	var checkTile = posTile + FACING_TO_OFFSET[dirFacing]
	var celId = world.get_cell_item(checkTile.x, checkTile.y, checkTile.z)
	match world.mesh_library.collisionType[celId]:
		gridHelper.TYPES.INVALID:
			pass
		gridHelper.TYPES.SOLID:
			return true
		gridHelper.TYPES.SLOPE:
			#print(gridHelper.ORTHO_TO_INDEX[dirFacing])
			#print(world.get_cell_item_orientation(checkTile.x, checkTile.y, checkTile.z))
			if gridHelper.ORTHO_TO_INDEX[FACING_INVERSE[dirFacing]] != world.get_cell_item_orientation(checkTile.x, checkTile.y, checkTile.z):
				return true
	
	celId = world.get_cell_item(checkTile.x, checkTile.y - 1, checkTile.z)
	if world.mesh_library.collisionType[standingCel] == gridHelper.TYPES.SLOPE:
		if gridHelper.ORTHO_TO_INDEX[dirFacing] != world.get_cell_item_orientation(posTile.x, posTile.y - 1, posTile.z) and gridHelper.ORTHO_TO_INDEX[FACING_INVERSE[dirFacing]] != world.get_cell_item_orientation(posTile.x, posTile.y - 1, posTile.z):
			return true
	if world.mesh_library.collisionType[celId] == gridHelper.TYPES.SLOPE and gridHelper.ORTHO_TO_INDEX[dirFacing] != world.get_cell_item_orientation(checkTile.x, checkTile.y - 1, checkTile.z):
		return true
	var testOri = world.get_cell_item_orientation(posTile.x, posTile.y-1, posTile.z)
	var celIdForSlope = world.get_cell_item(checkTile.x, checkTile.y - 2, checkTile.z)
	if celId == -1:
		if world.mesh_library.collisionType[standingCel] == gridHelper.TYPES.SLOPE and gridHelper.ORTHO_TO_INDEX[dirFacing] == testOri and celIdForSlope != -1:
			return false
		else:
			return true
	return false
	pass

func hasPlayerInvokedMove():
	if Input.is_action_pressed("overworld_up") or Input.is_action_pressed("overworld_down") or Input.is_action_pressed("overworld_left") or Input.is_action_pressed("overworld_right"):
		return true
	return false
	pass
	
func hasPlayerJustInvokedMove():
	if (Input.is_action_just_pressed("overworld_up") or Input.is_action_just_pressed("overworld_down") or Input.is_action_just_pressed("overworld_left") or Input.is_action_just_pressed("overworld_right")) and quickTurnTimer <= 0 and moveTimer <= 0:
		return true
	return false
	pass
