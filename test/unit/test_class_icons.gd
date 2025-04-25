@tool
extends EditorScript


const Results = preload("res://test/unit/results.gd")

const PROJECT_ICON = preload("res://icon.svg")
const PROJECT_ICON_2 = preload("res://icon2.svg")

const CLASS_UNION = {
	"type": TYPE_OBJECT,
	"class_name": "CanvasItemMaterial,ShaderMaterial",
}


static var results: Results

var null_object: Object
var null_array: Array
var with_icon_and_class_name: WithIconAndClassName
var node_2d: Node2D



func _run() -> void:
	print("Testing...")
	
	null_object = Object.new()
	null_object.free()
	results = Results.new()
	
	test_get_variant_icon()
	test_get_property_icon()
	
	results.union = AnyIcon.get_property_icon_from_dict(CLASS_UNION)
	if results.union != AnyIcon.get_property_icon_from_dict(CLASS_UNION):
		printerr("Union caching doesn't work!")
	
	if results.error_icons.is_empty():
		print("Success!")
	else:
		printerr("There were errors!")
	
	if "edit" in EditorInterface.get_inspector():
		EditorInterface.get_inspector().edit(results)
	
	ResourceSaver.save(results, "res://test/output/result.tres", ResourceSaver.FLAG_CHANGE_PATH)


func test_get_variant_icon() -> void:
	_test_get_variant_icon(true, &"bool")
	_test_get_variant_icon(0, &"int")
	_test_get_variant_icon(0.0, &"float")
	_test_get_variant_icon(null, &"Nil")
	_test_get_variant_icon([], &"Array")
	_test_get_variant_icon(null_object, &"Object")
	_test_get_variant_icon(null_array, &"Array")
	_test_get_variant_icon(Vector2i.ZERO, &"Vector2i")
	_test_get_variant_icon(PackedColorArray(), &"PackedColorArray")
	
	_test_get_variant_icon(Object.new(), &"Object")
	_test_get_variant_icon(TextureButton.new(), &"TextureButton")
	
	_test_from_script(load("res://test/data/no_icon.gd"), &"Node", "no icon")
	
	_test_from_script_with_icon(
		load("res://test/data/with_icon_and_class_name.gd"),
		PROJECT_ICON,
		"icon and class name"
	)
	_test_from_script_with_icon(
		load("res://test/data/inherithed_from_with_icon_and_class_name.gd"),
		PROJECT_ICON,
		"inherited from icon and class name"
	)
	_test_from_script_with_icon(
		load("res://test/data/with_icon.gd"),
		PROJECT_ICON,
		"with icon"
	)
	_test_from_script_with_icon(
		load("res://test/data/inherithed_and_override.gd"),
		PROJECT_ICON_2,
		"inherited override"
	)
	_test_from_script_with_icon(
		load("res://test/data/inherithed_with_class_name_and_override.gd"),
		PROJECT_ICON_2,
		"inherited with class name override"
	)


func test_get_property_icon() -> void:
	var property_map: Dictionary
	for property_dict in get_property_list():
		property_map[property_dict["name"]] = property_dict
	
	_assert_same_texture(
		AnyIcon.get_property_icon_from_dict(property_map["null_object"]),
		_get_editor_icon(&"Object"),
		"property/object",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon_from_dict(property_map["null_array"]),
		_get_editor_icon(&"Array"),
		"property/array",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon_from_dict(property_map["node_2d"]),
		_get_editor_icon(&"Node2D"),
		"property/node_2d",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon_from_dict(property_map["with_icon_and_class_name"]),
		PROJECT_ICON,
		"property/custom_class",
	)
	
	_assert_same_texture(
		AnyIcon.get_property_icon(self, "null_object"),
		_get_editor_icon(&"Object"),
		"property_fetching/object",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon(self, "null_array"),
		_get_editor_icon(&"Array"),
		"property_fetching/object",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon(self, "node_2d"),
		_get_editor_icon(&"Node2D"),
		"property_fetching/object",
	)
	_assert_same_texture(
		AnyIcon.get_property_icon(self, "with_icon_and_class_name"),
		PROJECT_ICON,
		"property_fetching/object",
	)
	
	#var expected: Dictionary[StringName, Texture2D] = {
	var expected: Dictionary = {
		&"null_object": _get_editor_icon(&"Object"),
		&"null_array": _get_editor_icon(&"Array"),
		&"node_2d": _get_editor_icon(&"Node2D"),
		&"with_icon_and_class_name": PROJECT_ICON,
	}
	#var got: Dictionary[StringName, Texture2D] = AnyIcon.get_all_property_icons(self)
	var got: Dictionary = AnyIcon.get_all_property_icons(self)
	if got.size() != 4:
		printerr("Wrong amount of propertu icons fetched.")
	for name: StringName in got:
		_assert_same_texture(
			got[name],
			expected.get(name, AnyIcon.icon_not_found),
			"all_properties/" + name
		)


func _test_from_script(variant: Variant, expected: StringName, msg: String = "") -> void:
	_test_from_script_with_icon(
		variant,
		EditorInterface.get_base_control().get_theme_icon(expected, &"EditorIcons"),
		msg,
	)


func _test_from_script_with_icon(variant: Variant, expected: Texture2D, msg: String = "") -> void:
	_test_get_variant_icon_with_icon(variant, expected, msg + " (Script)")
	_test_get_variant_icon_with_icon(variant.new(), expected, msg + " (Instance)")


func _test_get_variant_icon(variant: Variant, expected: StringName, msg: String = "") -> void:
	_test_get_variant_icon_with_icon(
		variant,
		_get_editor_icon(expected),
		msg
	)


func _test_get_variant_icon_with_icon(variant: Variant, expected: Texture2D, msg: String = "") -> void:
	var icon: Texture2D = AnyIcon.get_variant_icon(variant)
	
	if icon != expected:
		printerr(msg + ": Expected " + str(expected) + " for " + str(variant) + ", but got " + str(icon))
		results.error_icons.append(icon)
	else:
		results.success_icons.append(icon)
	
	if is_instance_valid(variant) and variant is Object and not variant is RefCounted:
		variant.free()


func _assert_same_texture(got: Texture2D, expected: Texture2D, msg: String) -> void:
	if got != expected:
		print(msg + ": Expected " + str(expected) + ", but got " + str(got))
		results.error_icons.append(got)
	else:
		results.success_icons.append(got)



func _get_editor_icon(name: StringName) -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon(name, &"EditorIcons")
