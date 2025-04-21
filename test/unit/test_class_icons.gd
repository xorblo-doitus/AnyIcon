@tool
extends EditorScript

const PROJECT_ICON = preload("res://icon.svg")
const PROJECT_ICON_2 = preload("res://icon2.svg")


static var results: Results



func _run() -> void:
	print("Testing...")
	
	#print(r"""@icon\s*?\((?:[^#]*?(?:)*?(?:#.*)*?)*?(?<delimiter>"+|'+)(?<path>.*?)\k<delimiter>(?:.|\n)*?\)""")
	#var match_ := RegEx.create_from_string(
		#r"""@icon\s*?\((?:[^#]*?(?:)*?(?:#.*)*?)*?(?<delimiter>"+|'+)(?<path>.*?)\k<delimiter>(?:.|\n)*?\)"""
	#).search("@icon(\"res://\")")
	#print(match_.get_string())
	#prints(match_.get_start(), "to", match_.get_end())
	#prints(match_.strings)
	#prints(match_.get_string("path"))
	#return
	
	results = Results.new()
	
	test_get_variant_icon()
	
	if results.error_icons.is_empty():
		print("Success!")
	else:
		print("There were errors!")
	
	EditorInterface.get_inspector().edit(results)


func test_get_variant_icon() -> void:
	_test_get_variant_icon(true, &"bool")
	_test_get_variant_icon(0, &"int")
	_test_get_variant_icon(0.0, &"float")
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
		EditorInterface.get_base_control().get_theme_icon(expected, &"EditorIcons"),
		msg
	)


func _test_get_variant_icon_with_icon(variant: Variant, expected: Texture2D, msg: String = "") -> void:
	var icon: Texture2D = ClassIcons.get_variant_icon(variant)
	
	if icon != expected:
		printerr(msg + ": Expected " + str(expected) + " for " + str(variant))
		results.error_icons.append(icon)
	else:
		results.success_icons.append(icon)
	
	if variant is Object and not variant is RefCounted:
		variant.free()



class Results extends Resource:
	@export var not_found := ClassIcons.icon_not_found
	@export var error_icons: Array[Texture2D] = []
	@export var success_icons: Array[Texture2D] = []
	@export var others: Dictionary[String, Texture2D] = {}
