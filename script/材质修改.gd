@tool
extends EditorScript
const TOON = preload("res://shader/toon_body.gdshader")
const OUTLINE = preload("uid://bomfbmamodfhc")


func _run() -> void:
	for node in get_all_children(get_scene()):
		if node is MeshInstance3D:
			var mesh:Mesh = node.mesh
			var count :int= mesh.get_surface_count()
			for i in range(count):
				var material  = mesh.surface_get_material(i)
				if mesh.surface_get_material(i) is StandardMaterial3D:
					var old_material :StandardMaterial3D= mesh.surface_get_material(i)
					var new_material :ShaderMaterial = ShaderMaterial.new()
					new_material.set_shader_parameter("base_tex",old_material.albedo_texture)
					new_material.shader = TOON
					mesh.surface_set_material(i,new_material)
				if mesh.surface_get_material(i) is ShaderMaterial:
					var old_material : ShaderMaterial = mesh.surface_get_material(i)
					old_material.next_pass = OUTLINE
					
				

func get_all_children(in_node, children_acc = []):
	children_acc.push_back(in_node)
	for child in in_node.get_children():
		children_acc = get_all_children(child, children_acc)
	return children_acc
