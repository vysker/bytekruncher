class_name Bykr extends Resource
## The main ByteKruncher (Bykr) interface.

static var _REGISTRY: Dictionary = {} # Class => Mapper

static var _BOOLEAN_MAPPER := BooleanMapper.new()
static var _DOUBLE_MAPPER := DoubleMapper.new()
static var _FLOAT_MAPPER := FloatMapper.new()
static var _HALF_MAPPER := HalfMapper.new()
static var _S8_MAPPER := S8Mapper.new()
static var _S16_MAPPER := S16Mapper.new()
static var _S32_MAPPER := S32Mapper.new()
static var _S64_MAPPER := S64Mapper.new()
static var _U8_MAPPER := U8Mapper.new()
static var _U16_MAPPER := U16Mapper.new()
static var _U32_MAPPER := U32Mapper.new()
static var _U64_MAPPER := U64Mapper.new()
static var _VEC3_MAPPER := Vec3Mapper.new()
static var _VEC3I_MAPPER := Vec3iMapper.new()
static var _STRING_MAPPER := StringMapper.new()

static func boolean() -> Mapper: return _BOOLEAN_MAPPER
static func double() -> Mapper: return _DOUBLE_MAPPER
static func float_() -> Mapper: return _FLOAT_MAPPER
static func half() -> Mapper: return _HALF_MAPPER
static func s8() -> Mapper: return _S8_MAPPER
static func s16() -> Mapper: return _S16_MAPPER
static func s32() -> Mapper: return _S32_MAPPER
static func s64() -> Mapper: return _S64_MAPPER
static func u8() -> Mapper: return _U8_MAPPER
static func u16() -> Mapper: return _U16_MAPPER
static func u32() -> Mapper: return _U32_MAPPER
static func u64() -> Mapper: return _U64_MAPPER
static func vec3() -> Mapper: return _VEC3_MAPPER
static func vec3i() -> Mapper: return _VEC3I_MAPPER
static func string() -> Mapper: return _STRING_MAPPER

static func _static_init() -> void:
	_REGISTRY["double"] = _DOUBLE_MAPPER
	_REGISTRY["float"] = _FLOAT_MAPPER
	_REGISTRY["half"] = _HALF_MAPPER
	_REGISTRY["s8"] = _U8_MAPPER
	_REGISTRY["s16"] = _U16_MAPPER
	_REGISTRY["s32"] = _U32_MAPPER
	_REGISTRY["s64"] = _U64_MAPPER
	_REGISTRY["u8"] = _U8_MAPPER
	_REGISTRY["u16"] = _U16_MAPPER
	_REGISTRY["u32"] = _U32_MAPPER
	_REGISTRY["u64"] = _U64_MAPPER
	_REGISTRY["vec3"] = _VEC3_MAPPER
	_REGISTRY["vec3i"] = _VEC3I_MAPPER
	_REGISTRY["string"] = _STRING_MAPPER


static func object(type: StringName) -> Callable:
	return func() -> Mapper:
		return _REGISTRY[type.to_lower()]


static func custom(type: StringName) -> Callable:
	return func() -> Mapper:
		return _REGISTRY[type.to_lower()]


static func array(subtype: StringName) -> Callable:
	return func() -> Mapper:
		return ArrayMapper.new(_REGISTRY[subtype.to_lower()] as Mapper)


static func register(type: StringName, constructor: Callable, properties: Dictionary) -> Mapper:
	var mapper: Mapper = ObjectMapper.new(properties, constructor)
	_REGISTRY[type.to_lower()] = mapper
	return mapper


static func register_custom(type: String, mapper: Mapper) -> void:
	_REGISTRY[type.to_lower()] = mapper


static func unregister(type: StringName) -> void:
	_REGISTRY.erase(type)


class ReadResult:
	var bytes_read: int
	var value: Variant
	
	func _init(bytes_read_: int, value_: Variant) -> void:
		bytes_read = bytes_read_
		value = value_


class Mapper:
	func from_bytes(bytes: PackedByteArray) -> Variant:
		return _read_bytes_at(0, bytes).value
	
	func to_bytes(value: Variant) -> PackedByteArray:
		var bytes: PackedByteArray = []
		_append_bytes_to(value, 0, bytes)
		return bytes
	
	func _read_bytes_at(_byte_offset: int, _bytes: PackedByteArray) -> ReadResult:
		assert(false, "Unimplemented function; override it")
		return null
	
	func _append_bytes_to(_value: Variant, _byte_offset: int, _bytes: PackedByteArray) -> void:
		assert(false, "Unimplemented function; override it")


class BooleanMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(1, bytes.decode_u8(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 1)
		bytes.encode_u8(byte_offset, value as bool)


class DoubleMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(8, bytes.decode_double(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 8)
		bytes.encode_double(byte_offset, value as float)


class FloatMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(4, bytes.decode_float(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 4)
		bytes.encode_float(byte_offset, value as float)


class HalfMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(2, bytes.decode_half(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 2)
		bytes.encode_half(byte_offset, value as float)


class S8Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(1, bytes.decode_s8(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 1)
		bytes.encode_s8(byte_offset, value as int)


class S16Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(2, bytes.decode_s16(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 2)
		bytes.encode_s16(byte_offset, value as int)


class S32Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(4, bytes.decode_s32(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 4)
		bytes.encode_s32(byte_offset, value as int)


class S64Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(8, bytes.decode_s64(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 8)
		bytes.encode_s64(byte_offset, value as int)


class U8Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(1, bytes.decode_u8(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 1)
		bytes.encode_u8(byte_offset, value as int)


class U16Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(2, bytes.decode_u16(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 2)
		bytes.encode_u16(byte_offset, value as int)


class U32Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(4, bytes.decode_u32(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 4)
		bytes.encode_u32(byte_offset, value as int)


class U64Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		return ReadResult.new(8, bytes.decode_u64(byte_offset))
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 8)
		bytes.encode_u64(byte_offset, value as int)


class Vec3Mapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		var value := Vector3(
			bytes.decode_float(byte_offset + 0),
			bytes.decode_float(byte_offset + 4),
			bytes.decode_float(byte_offset + 8))
		return ReadResult.new(4 + 4 + 4, value)
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		var vec := value as Vector3
		bytes.resize(byte_offset + 4 + 4 + 4)
		bytes.encode_float(byte_offset + 0, vec.x)
		bytes.encode_float(byte_offset + 4, vec.y)
		bytes.encode_float(byte_offset + 8, vec.z)


class Vec3iMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		var value := Vector3i(
			bytes.decode_s64(byte_offset + 0),
			bytes.decode_s64(byte_offset + 8),
			bytes.decode_s64(byte_offset + 16))
		return ReadResult.new(8 + 8 + 8, value)
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		var vec := value as Vector3i
		bytes.resize(byte_offset + 8 + 8 + 8)
		bytes.encode_s64(byte_offset + 0, vec.x)
		bytes.encode_s64(byte_offset + 8, vec.y)
		bytes.encode_s64(byte_offset + 16, vec.z)


class StringMapper extends Mapper:
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		var string_size: int = bytes.decode_u16(byte_offset)
		var value: String = bytes.slice(byte_offset + 2, byte_offset + 2 + string_size).get_string_from_utf8()
		return ReadResult.new(2 + string_size, value)
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		var string := value as String
		var utf8_buffer: PackedByteArray = string.to_utf8_buffer()
		bytes.resize(byte_offset + 2)
		bytes.encode_u16(byte_offset, utf8_buffer.size())
		bytes.append_array(utf8_buffer)


class ObjectMapper extends Mapper:
	var properties: Dictionary
	var constructor: Callable
	
	func _init(properties_: Dictionary, constructor_: Callable) -> void:
		properties = properties_
		constructor = constructor_
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		bytes.resize(byte_offset + 1)
		if value == null:
			bytes.encode_u8(byte_offset, 1)
			return
		else:
			bytes.encode_u8(byte_offset, 0)
		byte_offset += 1
		
		var object := value as Object
		for key: StringName in properties:
			var mapper_constructor := properties[key] as Callable
			var mapper := mapper_constructor.call() as Mapper
			mapper._append_bytes_to(object.get(key), byte_offset, bytes)
			byte_offset = bytes.size()
	
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		assert(constructor != null, "Expected constructor for object")
		if bytes.decode_u8(byte_offset) == 1:
			return ReadResult.new(1, null)
		
		var setter: Callable
		var collector: Variant
		if constructor.get_argument_count() == 0:
			# If no-arg constructor: just instantiate the object and set properties on it directly
			collector = constructor.call()
			setter = _set_object_property
		else:
			# If constructor with args: we'll gather all the args first, and then call the constructor
			collector = []
			setter = _append_constructor_argument
	
		byte_offset += 1
		var bytes_read: int = 1
		for key: StringName in properties:
			var mapper_constructor := properties[key] as Callable
			var mapper := mapper_constructor.call() as Mapper
			var result: ReadResult = mapper._read_bytes_at(byte_offset, bytes)
			setter.call(collector, key, result.value)
			byte_offset += result.bytes_read
			bytes_read += result.bytes_read
		
		if collector is Array:
			return ReadResult.new(bytes_read, constructor.callv(collector as Array))
		else:
			return ReadResult.new(bytes_read, collector)
	
	func _set_object_property(object: Object, key: StringName, value: Variant) -> void:
		if object.get(key) is Array:
			(object.get(key) as Array).assign(value as Array)
		else:
			object.set(key, value)
	
	func _append_constructor_argument(args: Array, _key: StringName, value: Variant) -> void:
		args.append(value)


class ArrayMapper extends Mapper:
	var subtype_mapper: Mapper
	
	func _init(subtype_mapper_: Mapper) -> void:
		subtype_mapper = subtype_mapper_
	
	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
		var count: int = bytes.decode_u8(byte_offset)
		var array: Array = []
		array.resize(count)
		byte_offset += 1
		var bytes_read: int = 1
		for i: int in count:
			var result: ReadResult = subtype_mapper._read_bytes_at(byte_offset, bytes)
			array[i] = result.value
			byte_offset += result.bytes_read
			bytes_read += result.bytes_read
		return ReadResult.new(bytes_read, array)
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
		var array := value as Array
		bytes.resize(byte_offset + 1)
		bytes.encode_u8(byte_offset, array.size())
		byte_offset += 1
		for element: Variant in array:
			subtype_mapper._append_bytes_to(element, byte_offset, bytes)
			byte_offset = bytes.size()
