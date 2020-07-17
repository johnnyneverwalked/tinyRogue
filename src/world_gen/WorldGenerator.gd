extends Node

const DefaultValues = {
	"levelSize": Vector2(100, 50),
	"numberOfRooms": 8,
	"startingRoom": null,
	"maxRoom": Vector2(18, 18),
	"minRoom": Vector2(10, 10),
	"autoTile": false,
	"tileSize": 16,
	"largePaths": false,
	"margins": [false, false, false, false]
}

var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()

signal loaded

const Tile = {
	"WALL": 0,
	"FLOOR": 1,
	"OUT": 2,
	"EXIT": 3
}

# Rect2
var rooms = []
var roomGraph: AStar2D

# Tile[][]
var map = []
var mapGraph: AStar2D

var tilemap: TileMap

# Dictionary with keys corresponding to DefaultValues keys
var options: Dictionary = DefaultValues.duplicate(true)

func setOptions(opts = {}):
	for key in opts.keys():
		if self.options.keys().has(key):
			self.options[key] = opts[key]

func resetOptions():
	self.options = DefaultValues.duplicate(true)			

func generateWorld(tilemap: TileMap, rng = null) -> int:
	randomizer.set_seed(rng) if rng else randomizer.randomize()
	
	self.tilemap = tilemap
	
	self.tilemap.clear()
	
	rooms.clear()
	map.clear()
	
	for x in range(self.options.levelSize.x):
		map.append([])
		for y in range(self.options.levelSize.y):
			map[x].append(Tile.OUT)			
	
	var empty_spaces = [Rect2((Vector2(4, 4)), self.options.levelSize - Vector2(8, 8))]
	
	# create numberOfRooms rooms
	var noOfRooms = options.numberOfRooms
	if options.startingRoom:
		noOfRooms += 1
		addRoom(empty_spaces, options.startingRoom, options.startingRoom)
	while !empty_spaces.empty():
		addRoom(empty_spaces, options.minRoom, options.maxRoom)
		if (rooms.size() == noOfRooms):
			break
	
	connectRooms()
	var pointIdx = 0
	mapGraph = AStar2D.new()
	for x in range(map.size() - 1):
		for y in range(map[x].size() - 1):
			var coords = Vector2(x, y)
			var tile = getTile(coords)
			
			if options.autoTile && tile == Tile.OUT:
				setTile(coords, Tile.WALL)
			
			elif tile == Tile.FLOOR:
				mapGraph.add_point(pointIdx, Vector2(x, y))
				
				var surrounding = getSurroundingTiles(coords)
				for i in range(4):
					if options.margins[i] && surrounding[i].type == Tile.WALL:
						mapGraph.add_point(coords.x * (map[x].size() - 1) + coords.y, coords)
						setTile(coords, -1)
						
				drawSurroundingTiles(Vector2(x, y), Tile.WALL, [Tile.OUT])
				
			drawTile(coords, getTile(coords))
			pointIdx += 1
	
	tilemap.update_bitmask_region()
			
	print("World generated")
	
	emit_signal("loaded")
	
	return randomizer.get_seed()


func addRoom(
	availableSpaces: Array, # Rect2[]
	minRoomize = DefaultValues.minRoom,
	maxRoomize = DefaultValues.maxRoom
):
	var emptySpace = availableSpaces[randomizer.randi() % availableSpaces.size()]
	
	
	var roomSize = Vector2(minRoomize.x, minRoomize.y)
	var startPos = Vector2(emptySpace.position.x, emptySpace.position.y)
	
	if emptySpace.size.x > minRoomize.x:
		roomSize.x += randomizer.randi() % int(emptySpace.size.x - minRoomize.x)
	roomSize.x = min(roomSize.x, maxRoomize.x)	
		
	if emptySpace.size.y > minRoomize.y:
		roomSize.y += randomizer.randi() % int(emptySpace.size.y - minRoomize.y)
	roomSize.y = min(roomSize.y, maxRoomize.y)	
	
	if emptySpace.size.x > roomSize.x:
		startPos.x += randomizer.randi() % int(emptySpace.size.x - roomSize.x)
		
	if emptySpace.size.y > roomSize.y:
		startPos.y += randomizer.randi() % int(emptySpace.size.y - roomSize.y)
		
	var newRoom = Rect2(startPos, roomSize)
	rooms.append(newRoom)
	
	var tileType
	for y in range(startPos.y, startPos.y + roomSize.y):
		for x in range(startPos.x, startPos.x + roomSize.x):
			tileType = Tile.WALL if (x == startPos.x
				|| y == startPos.y
				|| x == startPos.x + roomSize.x - 1
				|| y == startPos.y + roomSize.y - 1) else Tile.FLOOR
				
			setTile(Vector2(x, y), tileType)
	
	occupySpaces(availableSpaces, newRoom)

# emptySpaces: Rect2[]
func occupySpaces(emptySpaces: Array, spaceToOccupy: Rect2):
	var toOccupy = []
	var toFree = []
	
	for space in emptySpaces:
		if space.intersects(spaceToOccupy):
			toOccupy.append(space)
			
			var left = spaceToOccupy.position.x - space.position.x - 1
			var right = space.end.x - spaceToOccupy.end.x - 1
			var up = spaceToOccupy.position.y - space.position.y - 1
			var down = space.end.y - spaceToOccupy.end.y - 1

			if left >= options.minRoom.x:
				toFree.append(Rect2(space.position, Vector2(left, space.size.y)))
			if right >= options.minRoom.x:
				toFree.append(Rect2(Vector2(spaceToOccupy.end.x + 1, space.position.y), Vector2(right, space.size.y)))
			if up >= options.minRoom.y:
				toFree.append(Rect2(space.position, Vector2(space.size.x, up)))
			if down >= options.minRoom.y:
				toFree.append(Rect2(Vector2(space.position.x, spaceToOccupy.end.y + 1), Vector2(space.size.x, down)))

	for space in toOccupy:
		emptySpaces.erase(space)
	for space in toFree:
		emptySpaces.append(space)


func connectRooms():
	var graph = AStar2D.new()
	var point = 0
	for x in range(options.levelSize.x):
		for y in range(options.levelSize.y):
			if map[x][y] == Tile.OUT:
				# populate graph
				graph.add_point(point, Vector2(x, y))
				
				# connect with existing if not connected already
				if x && map[x - 1][y] == Tile.OUT:
					var left = graph.get_closest_point(Vector2(x - 1, y))
					graph.connect_points(point, left)
				if y && map[x][y - 1] == Tile.OUT:
					var left = graph.get_closest_point(Vector2(x, y - 1))
					graph.connect_points(point, left)
					
				point += 1		
	
	point = 0				
	roomGraph = AStar2D.new()
	for room in rooms:
			roomGraph.add_point(point, room.position + room.size / 2)
			point += 1

	while !isEverythingConnected(roomGraph):
		addRoomConnection(graph, roomGraph)

			
func addRoomConnection(graph: AStar2D, roomGraph: AStar2D):
	# find rooms to connect
	var startRoom = getLeastConnected(roomGraph)
	var endRoom = getNearestUnconnected(roomGraph, startRoom)
	
	# find places for the doors
	var startRoomDoor = pickDoorLocation(rooms[startRoom])
	var endRoomDoor = pickDoorLocation(rooms[endRoom])
	
	
	var startingPoint = graph.get_closest_point(startRoomDoor)
	var endingPoint = graph.get_closest_point(endRoomDoor)
	
	var path = graph.get_point_path(startingPoint, endingPoint)
	assert(path)
	
	graph.disconnect_points(startingPoint, endingPoint)
	
	# draw paths
	setTile(startRoomDoor, Tile.FLOOR)
	setTile(endRoomDoor, Tile.FLOOR)
	if (options.largePaths):
		drawSurroundingTiles(startRoomDoor, Tile.FLOOR)
		drawSurroundingTiles(endRoomDoor, Tile.FLOOR)
		
	for pos in path:
		setTile(pos, Tile.FLOOR)
		if options.largePaths:
			drawSurroundingTiles(pos, Tile.FLOOR, [Tile.OUT])
			if (getTile(Vector2(0, 1) + pos) == Tile.WALL && getTile(Vector2(0, -1) + pos) == Tile.WALL):
				drawTile(Vector2(0, 1) + pos, Tile.FLOOR)
				
		
	
	# connect rooms
	roomGraph.connect_points(startRoom, endRoom)	


func getLeastConnected(graph: AStar2D) -> int:
	var minConnections: int = 99999999 
	var minPoint: int
	for point in graph.get_points():
		var current: int = graph.get_point_connections(point).size()
		if minConnections >= current:
			minPoint = point if !minPoint || randomizer.randi() % 2 else minPoint
			minConnections = current
			
	return minPoint

		
func getNearestUnconnected(graph: AStar2D, target: int) -> int:
	var targetPos: Vector2 = graph.get_point_position(target)
	var nearest: int
	var nearestDist: int = 99999999
	
	for point in graph.get_points():
		if point == target || graph.get_point_path(point, target):
			continue
		
		var dist: int = (graph.get_point_position(point) - targetPos).length()
		if nearestDist >= dist:
			nearestDist = dist
			nearest = point if !nearest || randomizer.randi() % 2 else nearest
				
	return nearest


func pickDoorLocation(room: Rect2):
	var possible = []
	
	for x in range(room.position.x + 1, room.end.x - 2):
		possible.append(Vector2(x, room.position.y))
		possible.append(Vector2(x, room.end.y - 1))
		
	for y in range(room.position.y + 1, room.end.y - 2):
		possible.append(Vector2(room.position.x, y))
		possible.append(Vector2(room.end.x - 1, y))
	
	return possible[randomizer.randi() % possible.size()]	

	
func isEverythingConnected(graph: AStar2D):
	var points: = graph.get_points()
	var current: int = points.pop_back()
	for point in points:
		if !graph.get_point_path(current, point):
			return false
	return true		


func drawTile(coords: Vector2, type, tilemap = self.tilemap):
	if coords.x < map.size() && coords.y < map[coords.x].size():
		map[coords.x][coords.y] = type
		tilemap.set_cell(coords.x, coords.y, type)

func setTile(coords: Vector2, type):
	if coords.x < map.size() && coords.y < map[coords.x].size():
		map[coords.x][coords.y] = type

	
func drawSurroundingTiles(coords: Vector2, type: int, specificTypes = [], tilemap = self.tilemap):
	for tile in getSurroundingTiles(coords):
			if specificTypes.empty() || specificTypes.has(tile.type):
				drawTile(tile.position, type)

	
func getTile(coords: Vector2) -> int:
	return map[coords.x][coords.y] if map.size() > coords.x && map[coords.x].size() > coords.y else null
	
# {type: Tile, position: Vector2}	
func getSurroundingTiles(coords: Vector2) -> Dictionary:
	var tiles = []
	for vector in [
		Vector2.UP,
		Vector2.RIGHT, 
		Vector2.DOWN, 
		Vector2.LEFT, 
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(1, 1)
	]:
		tiles.push_back({
			"type": getTile(coords + vector), 
			"position": coords + vector
		})
	return tiles
