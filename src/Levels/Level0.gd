extends Node2D

const GridDimensions = 8 # x=y=GridDimensions
const ObstaclesCount = 3 # when game starts
const DeckCardsCount = [0,0,0,0,6,6,6,6,6,6,6,1,1,2,2,2]

onready var TilesGrid = $TilesGrid
var Deck = []
var TopCard = Types.Tile.Rail_UD
func _ready():
	#load a random deck
	for cardType in Types.Tile.keys():
		for n in DeckCardsCount[Types.Tile[cardType]]:
			Deck.append(Types.Tile[cardType])
	randomize()
	Deck.shuffle()
	#load the grid
	TilesGrid.columns = GridDimensions
	var tileScene = load("res://src/Nodes/tiles/Tile.tscn")
	for j in range(GridDimensions):
		for i in range(GridDimensions):
			var tile = tileScene.instance()
			tile.coords = [i,j]
			$TilesGrid.add_child(tile)
			TilesGrid.tilesContent[tile.coords]=null
	#load the initial obstacles
	var obstacleScene = load("res://src/Nodes/tiles/Obstacle.tscn")
	var FreeTiles = TilesGrid.tilesContent.duplicate(true)
	for i in range(ObstaclesCount):
		var obstacle = obstacleScene.instance()
		randomize()
		var type = Types.Tile.values()[randi() % Types.ObstaclesCount]
		var coords = FreeTiles.keys()[randi() % FreeTiles.keys().size()]
		TilesGrid.tilesContent[coords] = type
		FreeTiles.erase(coords)
		obstacle.frame = type
		#place the obstacle in the corresponding tile
		TilesGrid.get_child(TilesGrid.CoordsToIndex(coords)).add_child(obstacle)

func ShowNextCard():
	TopCard = Deck[0]
	$Deck/TopCard.frame = Deck[0]