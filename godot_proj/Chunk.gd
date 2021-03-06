extends MeshInstance
class_name Chunk

var position : Vector2
var grid_position : Vector2
var key : String
var noise : OpenSimplexNoise
var material : Material

var vertices = []
var uvs = []

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(grid_position : Vector2, noise : OpenSimplexNoise, material : Material):
	self.grid_position = grid_position
	self.position = Vector2(
		grid_position.x * Globals.CHUNK_SIZE - Globals.CHUNK_SIZE / 2.0,
		grid_position.y * Globals.CHUNK_SIZE - Globals.CHUNK_SIZE / 2.0
	)
	self.key = "TerrainChunk_%d_%d" % [grid_position.x, grid_position.y]
	self.noise = noise
	self.material = setup_material(material)

# warning-ignore:shadowed_variable
func setup_material(material : Material) -> Material:
	if material:
		return material
	
	var mat := SpatialMaterial.new()
	mat.albedo_color = Color(1.0, 1.0, 0.0)
	return mat

# warning-ignore:unused_variable
func generate():
	var st := SurfaceTool.new()
	
	for x in range(Globals.CHUNK_QUAD_COUNT):
		for z in range(Globals.CHUNK_QUAD_COUNT):
			generate_quad(
				Vector3(position.x + x * Globals.QUAD_SIZE, 0, position.y + z * Globals.QUAD_SIZE),	# angolo in basso a sinistra del quad
				Vector2(Globals.QUAD_SIZE, Globals.QUAD_SIZE)
			)

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	for i in range(vertices.size()):
		st.add_uv(uvs[i])
		st.add_vertex(vertices[i])
		
	st.generate_normals()
	var mesh = st.commit()

	self.set_name(key)
	self.mesh = mesh
	self.cast_shadow = 1

func create_collider():
	var shape = ConcavePolygonShape.new()
	shape.set_faces(PoolVector3Array(vertices))
	
	var cs = CollisionShape.new()
	cs.set_shape(shape)
	
	var sb = StaticBody.new()
	sb.collision_layer = 1 # Terrain
	sb.collision_mask = 2 # Player
	sb.add_child(cs)
	
	add_child(sb)

# warning-ignore:shadowed_variable
func generate_quad(position : Vector3, size : Vector2) -> void:
	vertices.push_back(create_vertex(position.x, position.z + size.y))
	vertices.push_back(create_vertex(position.x, position.z))
	vertices.push_back(create_vertex(position.x + size.x, position.z))
	
	vertices.push_back(create_vertex(position.x, position.z + size.y))
	vertices.push_back(create_vertex(position.x + size.x, position.z))
	vertices.push_back(create_vertex(position.x + size.x, position.z + size.y))
	
	uvs.push_back(Vector2(0, 0))
	uvs.push_back(Vector2(0, 1))
	uvs.push_back(Vector2(1, 1))

	uvs.push_back(Vector2(0, 0))
	uvs.push_back(Vector2(1, 1))
	uvs.push_back(Vector2(1, 0))
	
func create_vertex(x : float, z : float) -> Vector3:
	var y : float = noise.get_noise_2d(x, z) * 3
	return Vector3(x, y, z)
