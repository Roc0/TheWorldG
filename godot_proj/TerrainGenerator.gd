extends Spatial

var threads : Array

var chunks := {}
var chunks_being_generated := {}

var noise : OpenSimplexNoise
export var material : Material

onready var player = Globals.player
var player_chunk_grid_position : Vector2

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 7.0
	noise.persistence = 0.2
	
	#var chunk := Chunk.new(Vector2(0, 0), noise, material)
	#chunk.generate()
	#add_child(chunk)
	
	player_chunk_grid_position = get_chunk_grid_position_for(player.translation)
	# generate chunk at the origin
	generate_chunk([Chunk.new(player_chunk_grid_position, noise, material), null])
	# generate the chunks arounf the origin
	generate_chunks_around(player_chunk_grid_position)
	
func _process(_delta):
	var old_player_chunk_grid_position = player_chunk_grid_position
	player_chunk_grid_position = get_chunk_grid_position_for(player.translation)
	if old_player_chunk_grid_position != player_chunk_grid_position:
		generate_chunks_around((player_chunk_grid_position))
		call_deferred("cleanup_old_chunks", player_chunk_grid_position)

func generate_chunks_around(grid_postion):
	start_generating_chunk(Vector2(grid_postion.x + 1, grid_postion.y + 0))
	start_generating_chunk(Vector2(grid_postion.x + 1, grid_postion.y + 1))
	start_generating_chunk(Vector2(grid_postion.x + 1, grid_postion.y + -1))
	start_generating_chunk(Vector2(grid_postion.x + 0, grid_postion.y + 1))
	start_generating_chunk(Vector2(grid_postion.x + -1, grid_postion.y + 0))
	start_generating_chunk(Vector2(grid_postion.x + -1, grid_postion.y + -1))
	start_generating_chunk(Vector2(grid_postion.x + -1, grid_postion.y + 1))
	start_generating_chunk(Vector2(grid_postion.x + 0, grid_postion.y + -1))
	
func start_generating_chunk(grid_position : Vector2) -> void:
	var chunk = Chunk.new(grid_position, noise, material)
	# Generate only if doesnt exist on the tree yet
	if not chunks.has(chunk.key) and not chunks_being_generated.has(chunk.key):
		var thread = Thread.new()
		chunks_being_generated[chunk.key] = chunk
#		print("Generating " + chunk.key)
		thread.start(self, "generate_chunk", [chunk, thread])
		threads.push_back(thread)
	
func generate_chunk(arr) -> void:
	var chunk = arr[0]
	var thread = arr[1]
	
	chunk.generate()
	call_deferred("finished_generating_chunk", thread, chunk)

func finished_generating_chunk(thread, chunk) -> void:
	chunks[chunk.key] = chunk
# warning-ignore:return_value_discarded
	chunks_being_generated.erase(chunk.key)
	
	chunk.create_collider()
	call_deferred("add_child", chunk)
	chunk.call_deferred("set_owner", self)
	
	if not thread:
		return
		
	thread.wait_to_finish()
	var index = threads.find(thread)
	if index != -1:
		threads.remove(index)
		
func cleanup_old_chunks(center_grid_position : Vector2):
	# Figure out which chunks to remove from the list
	# The only ones we're supposed to keep are the 9
	# we are currently using
	var valid_chunks = [
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y + 1]
	]
	var keys_to_erase = []
	for key in chunks.keys():
		if not valid_chunks.has(key):
			keys_to_erase.push_back(key)
	for key in keys_to_erase:
#		print("Removing " + key)
		chunks[key].queue_free()
		chunks.erase(key)

func get_chunk_grid_position_for(position : Vector3) -> Vector2:
	var start = Vector2(position.x, position.z)
	if start.x > 0:
		start.x += Globals.CHUNK_SIZE / 2.0
	if start.x < 0:
		start.x -= Globals.CHUNK_SIZE / 2.0
	if start.y > 0:
		start.y += Globals.CHUNK_SIZE / 2.0
	if start.y < 0:
		start.y -= Globals.CHUNK_SIZE / 2.0
	
	return Vector2(
		int(start.x / Globals.CHUNK_SIZE),
		int(start.y / Globals.CHUNK_SIZE)
	)
