extends Node

const Enemies: Dictionary = {
	"dino": {"path": "res://src/Characters/enemies/Dino/Dino.tscn", "pos": null}
}

onready var worldGen: Node = $WorldGenerator
onready var tileMap: TileMap = $Navigation2D/TileMap
onready var nav: Navigation2D = $Navigation2D
onready var currentSeed:= $CanvasLayer/Seed
onready var player:= $Player
onready var enemies:= $Enemies


var actionPause = 0


func _ready() -> void:
	setWorldOptions()
	startLevel()

func _debug():
	pass
	if enemies.get_children().size():
		$CanvasLayer/Line2D.points = nav.get_simple_path(enemies.get_child(0).position, player.position)
	
func _process(_delta: float) -> void:
	_debug()
	if (Input.is_action_just_pressed("ui_accept")):
		actionPause = 0
	if Input.is_action_pressed("ui_accept"):
		if actionPause:
			actionPause -= 1
			return
		actionPause = 10
		startLevel()	

func setWorldOptions(options = {}):
	worldGen.setOptions({
		"margins": [true, false, false, false],
		"largePaths": true,
		"levelSize": Vector2(50, 50),
		"numberOfRooms": 1,
		"startingRoom": Vector2(10, 10),
		"minRoom": Vector2(18, 18),
		"maxRoom": Vector2(18, 18),
		"autoTile": true
	})
	
	# set camera limits based on level size
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_right = (worldGen.options.levelSize.x - 1) * worldGen.options.tileSize
	cam.limit_bottom = (worldGen.options.levelSize.y - 1) * worldGen.options.tileSize
	
	
func startLevel():
	# clean scene and generate
	for enemy in enemies.get_children():
		enemy.queue_free()
	currentSeed.text = "Seed: %s" %worldGen.generateWorld(tileMap)
	yield(worldGen, "loaded")
	
	# set player position
	var startingRoomIndex = 0
	var startingRoom: Rect2 = worldGen.rooms[startingRoomIndex]
	
	player.set_position(tileMap.map_to_world(_getRoomPos(startingRoom)))
	preload("res://src/Characters/enemies/Dino/Dino.tscn")
	
	# set exit position
	var maxDist = 0
	var endingRoom: Rect2 
	for point in worldGen.roomGraph.get_points():
		var dist = worldGen.roomGraph.get_point_path(startingRoomIndex, point).size()
		if maxDist < dist:
			maxDist = dist
			endingRoom = worldGen.rooms[point]
	worldGen.drawTile(_getRoomPos(endingRoom, true), worldGen.Tile.EXIT)
	addEnemy("dino", _getRoomPos(endingRoom, true))

func _getRoomPos(room: Rect2, random: bool = false) -> Vector2:
	var pos = room.position
	if random:
		pos += Vector2(
			worldGen.randomizer.randi() % int(room.end.x - room.position.x - 4) + 3,
			worldGen.randomizer.randi() % int(room.end.y - room.position.y - 4) + 3
		)
	else: 
		pos += Vector2(int(room.size.x / 2), int(room.size.y / 2))
	return pos

func addEnemy(enemyType: String, pos: Vector2):
	var enemy = load(Enemies[enemyType].path).instance()
	enemy.setData(self)
	Enemies[enemyType].pos = pos
	enemies.add_child(enemy)
	enemy.set_position(tileMap.map_to_world(pos))

