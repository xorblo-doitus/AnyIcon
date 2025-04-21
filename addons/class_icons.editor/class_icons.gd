@tool
class_name ClassIcons
extends Object


## A singleton providing easy access to icons representing class and types.
##
## Use [method get_variant_icon] for the highest abstraction.


## Shortcut for [method EditorInterface.get_base_control].
static var base_control: Control = EditorInterface.get_base_control()
## The icon displayed when no valid icon is found.
static var icon_not_found: Texture2D = base_control.get_theme_icon(&"")


#static func _static_init() -> void:
	#_deferred_static_init.call_deferred()
#
#
#static func _deferred_static_init() -> void:
	#base_control = EditorInterface.get_base_control()
	#icon_not_found = base_control.get_theme_icon(&"")

static func get_variant_icon(variant: Variant, fallback: StringName = &"") -> Texture2D:
	var type: Variant.Type = typeof(variant)
	if type == TYPE_OBJECT:
		return get_object_icon(variant, fallback)
	
	return get_type_icon(type, fallback)


static func get_object_icon(object: Object, fallback: StringName = &"") -> Texture2D:
	if object is Script:
		return get_script_icon(object, fallback)
	
	var script: Script = object.get_script()
	if script:
		return get_script_icon(script, fallback)
		# I don't know what I had in mind while writing this duplicated code.
		#var search_for: Script = script
		#while true:
			#for class_ in ProjectSettings.get_global_class_list():
				#if class_["path"] == search_for.resource_path:
					#return get_class_icon(class_["class"], fallback)
			#if search_for.get_base_script():
				#search_for = search_for.get_base_script()
			#else:
				#return get_builtin_class_icon(search_for.get_instance_base_type())
	
	return get_builtin_class_icon(object.get_class())



static func get_script_icon(script: Script, fallback: StringName = &"") -> Texture2D:
	var current_script: Script = script
	while current_script:
		if current_script.get_global_name():
			return get_class_icon(current_script.get_global_name(), fallback)
		
		# TODO MAYBE Read first line for @icon
		
		current_script = current_script.get_base_script()
	
	return get_builtin_class_icon(script.get_instance_base_type())
	


## See also [method get_custom_class_icon], [method get_builtin_class_icon]
## and [method get_type_icon].
static func get_class_icon(name: StringName, fallback: StringName = &"") -> Texture2D:
	if ClassDB.class_exists(name):
		return get_builtin_class_icon(name, fallback)
	
	return get_custom_class_icon(name, fallback)



## See also [method get_class_icon]
static func get_custom_class_icon(name: StringName, fallback: StringName = &"") -> Texture2D:
	var base_name = name
	var found: bool = true
	var global_class_list := ProjectSettings.get_global_class_list()
	
	while found:
		found = false
		
		for class_ in global_class_list:
			if class_["class"] == name:
				if class_["icon"]:
					return load(class_["icon"])
				else:
					name = class_["base"]
					
					if ClassDB.class_exists(name):
						return get_builtin_class_icon(name, fallback)
						
					found = true
					break # break the for
	
	# This can happen for invlaid name, such as a type union
	# (ex: "CanvasItemMaterial,ShaderMaterial")
	return get_icon(fallback)


## [b]Note:[/b] Return the Variant icon for [constant @GlobalScope.TYPE_NIL].
static func get_type_icon(type: Variant.Type, fallback: StringName = &"") -> Texture2D:
	if type == TYPE_NIL:
		return get_icon(&"Variant")
	
	if 0 <= type and type < TYPE_MAX:
		return  get_icon(type_string(type))
	
	return get_icon(fallback)


## See also [method get_class_icon]
static func get_builtin_class_icon(class_name_: StringName, fallback: StringName = &"") -> Texture2D:
	var result: Texture2D = get_icon(class_name_)
	while result == icon_not_found and class_name_ != &"":
		class_name_ = ClassDB.get_parent_class(class_name_)
		result = get_icon(class_name_)
	
	if result == icon_not_found and fallback:
		return get_icon(fallback)
	
	return result




## Like [method TypeAndClassIcons.get_icon], but returns the [param fallback]
## if no icon is found.
static func try_get_icon(name: StringName, fallback: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	var result: Texture2D = get_icon(name, theme_type)
	if result == icon_not_found:
		return get_icon(fallback, theme_type)
	return result



## Returns an icon of the EditorTheme. See [method Control.get_theme_icon].
static func get_icon(name: StringName, theme_type: StringName = &"EditorIcons") -> Texture2D:
	return base_control.get_theme_icon(name, theme_type)



func _init() -> void:
	push_error("Can't instantiate TypeAndClassIcons. This class is a singleton.")
	free()
