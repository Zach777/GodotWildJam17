extends GridContainer
var tilesContent = {} #{[x,y]:content}
var CitiesCoords = []
var Connections = []
func IsTileEmpty(tile):
	return tilesContent[tile]==null

func CoordsToIndex(coords):
	return (coords[0]+coords[1]*columns)
func CitiesAlreadyConnected(a,b):
	return ([a,b] in Connections) or ([b,a] in Connections)

func WhatsNearMeOnThe(direction,my_coords):#null when there's no tile or the tile is empty
	#Return the tile that is one tile away from me in the direction I specify.
	if direction == Types.Direction.Top:
		if my_coords[1]==0:return [null,null]
		else: 
			print(direction,my_coords,[tilesContent[[my_coords[0],my_coords[1]-1]],[my_coords[0],my_coords[1]-1]])
			return [tilesContent[[my_coords[0],my_coords[1]-1]],[my_coords[0],my_coords[1]-1]]
	elif direction == Types.Direction.Left:
		if my_coords[0]==0:return [null,null]
		else:
			print(direction,my_coords,[tilesContent[[my_coords[0]-1,my_coords[1]]],[my_coords[0]-1,my_coords[1]]])
			return [tilesContent[[my_coords[0]-1,my_coords[1]]],[my_coords[0]-1,my_coords[1]]]
	elif direction == Types.Direction.Right:
		if my_coords[0]==columns-1:return [null,null]
		
		else:
			print(direction,my_coords,[tilesContent[[my_coords[0]+1,my_coords[1]]],[my_coords[0]+1,my_coords[1]]])
			return [tilesContent[[my_coords[0]+1,my_coords[1]]],[my_coords[0]+1,my_coords[1]]]
	elif direction == Types.Direction.Down:
		if my_coords[1]==columns-1:return [null,null]
		else:
			print(direction,my_coords,[tilesContent[[my_coords[0],my_coords[1]+1]],[my_coords[0],my_coords[1]+1]])
			return [tilesContent[[my_coords[0],my_coords[1]+1]],[my_coords[0],my_coords[1]+1]]
func Opposite(direction):
	if direction == Types.Direction.Top:return Types.Direction.Down
	elif direction == Types.Direction.Down:return Types.Direction.Top
	elif direction == Types.Direction.Left:return Types.Direction.Right
	elif direction == Types.Direction.Right:return Types.Direction.Left
func Neighbor(direction):
	if direction==Types.Direction.Top: return Types.Direction.Left
	elif direction==Types.Direction.Left: return Types.Direction.Top
	elif direction==Types.Direction.Right: return Types.Direction.Down
	elif direction==Types.Direction.Down: return Types.Direction.Right
func DirToStr(type):
	match type:
		Types.Direction.Top: return 'U'
		Types.Direction.Left: return 'L'
		Types.Direction.Right: return 'R'
		Types.Direction.Down: return 'D'

func SortDir(a,b):
	var order=  ['U','L','R','D']
	return [order[min(order.find(a),order.find(b))],order[max(order.find(a),order.find(b))]]
func AreConnected(tile1,tile2, direction):#direction: tile2's position relative to tile1's
	var type1 = Types.TileStr[tile1]
	var type2=Types.TileStr[tile2]
	if Types.Tile.Buildings in [tile1,tile2]:return true
	elif Types.Tile.Rail_ULRD in [tile1,tile2]: return true
	elif '_' in type1:
		var x1 = type1.split('_')[1][0]
		var y1=type1.split('_')[1][1]
		var x2 = type2.split('_')[1][0]
		var y2=type2.split('_')[1][1]
		var dir = DirToStr(direction)
		if DirToStr(dir)==x1:
			print(type1,type2,direction, ([x2,y2] in [SortDir(x1,Opposite(x1)),SortDir(Neighbor(y1),Opposite(x1)),SortDir(Opposite(Neighbor(y1)),Opposite(x1))]))
			return ([x2,y2] in [SortDir(x1,Opposite(x1)),SortDir(Neighbor(y1),Opposite(x1)),SortDir(Opposite(Neighbor(y1)),Opposite(x1))])
		elif DirToStr(dir)==y1:
			print(type1,type2,direction,([x2,y2] in [SortDir(y1,Opposite(y1)),SortDir(Neighbor(x1),Opposite(y1)),SortDir(Opposite(Neighbor(x1)),Opposite(y1))]))
			return ([x2,y2] in [SortDir(y1,Opposite(y1)),SortDir(Neighbor(x1),Opposite(y1)),SortDir(Opposite(Neighbor(x1)),Opposite(y1))])

	else:return false
func IsAPath(type):#whether the tile type can connect two cities
	return type in [Types.Tile.Rail_UD, Types.Tile.Rail_LR, Types.Tile.Rail_LD, Types.Tile.Rail_RD, Types.Tile.Rail_UL, Types.Tile.Rail_UR, Types.Tile.Rail_ULRD, Types.Tile.Station_UD, Types.Tile.Station_LR]

func PathEnd(tile,pos):
	#How does this work?
	var dirs = Types.TileDirs[tile].duplicate(true)
	if dirs.size()==2:
		dirs.erase(Opposite(pos))
		print(DirToStr(dirs[0]))
		return dirs[0]
	else:
		pass#TODO: Code for handling the Intersection tile, Park, Generator,and Repair tiles
	
func CheckForConnections():
	var score = 0
	
	#City tile that we check in each direction
	for citiesTile in CitiesCoords:
		
		#The directions we check in.
		var directions = [Types.Direction.Top, Types.Direction.Left, Types.Direction.Right, Types.Direction.Down]
		for init_dir in directions:
			
			#Initialize everything so we can begin.
			var curr_tile = citiesTile
			var curr_tile_type = Types.Tile.Buildings
			var railsCount = 0
			var dir = init_dir
			
			#Start from the initial dir and follow the path until
			#you reach the end or another city.
			while( WhatsNearMeOnThe(dir,curr_tile)[0] != null &&
					AreConnected(curr_tile_type, WhatsNearMeOnThe(dir,curr_tile)[0], dir) ):
				
				#Next tile on path
				var nearbyTile = WhatsNearMeOnThe(dir,curr_tile)
				
				#We have reached another city.
				if( nearbyTile[0] == Types.Tile.Buildings and 
						railsCount > 0 and 
						!CitiesAlreadyConnected(nearbyTile[1],curr_tile) ):
					score +=1
					Connections.append([citiesTile,nearbyTile[1]])
					break
				
				#We have not reached an end point yet.
				#Keep following the path.
				elif IsAPath(nearbyTile[0]):
					#If the tile we are on is not a cross section, change dir appropriately.
					if nearbyTile[0]!=Types.Tile.Rail_ULRD:
						dir = PathEnd(nearbyTile[0],dir)
					
					#We have followed one rail. 
					#Increment our rails followed count.
					railsCount+=1
					
					#Debug the path finding.
					print('+1')
					var testcolors = [Color.blue,Color.rebeccapurple,Color.red,Color.cornflower,Color.blue,Color.rebeccapurple,Color.red,Color.cornflower,Color.blue,Color.rebeccapurple,Color.red,Color.cornflower,Color.blue,Color.rebeccapurple,Color.red,Color.cornflower]
					get_child(CoordsToIndex(nearbyTile[1])).modulate = testcolors[CitiesCoords.find(citiesTile)]
					
					#Not sure what this does.
					var step_data = nearbyTile.duplicate(true)
					curr_tile_type = step_data[0]
					curr_tile = step_data[1]
				
				#We probably hit a city that has already been connected.
				else: break
				
				
	
	#Let the player know how many points they scored.
	OS.alert(str(score))
