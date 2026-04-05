@tool
extends Node3D

@export var dir_light: DirectionalLight3D

@onready var mesh: MeshInstance3D = $"娜娜莉1_0/娜娜莉1_0_arm/Skeleton3D/娜娜莉1_0_mesh"

var material:ShaderMaterial
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = mesh.get_active_material(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if material:
		material.set_shader_parameter("head_forward",global_transform.basis.z.normalized())
		material.set_shader_parameter("head_right",-global_transform.basis.x.normalized())
		if dir_light:
			material.set_shader_parameter("light_direction",dir_light.global_transform.basis.z.normalized())
