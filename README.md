# Byte Kruncher

Godot plugin that **converts gdscript objects to bytes** and vice versa, to save bandwidth or disk space.

## Installation

**Asset Library**

See [this guide](https://docs.godotengine.org/en/stable/community/asset_library/using_assetlib.html) on how to install addons from the asset library.

**Manual**

* Download the latest ByteKruncher release
* Unzip it
* Copy the `addons/byte_kruncher/` folder to your godot project's `addons/` folder
* Open your godot **Project Settings > Plugins** and enable ByteKruncher

## Usage

### Simple example

Simply create your scripts as usual.
Then you register the data structure with ByteKruncher using `Bykr.register()`.

```gdscript
class_name PlayerData extends Resource

var level: int
var nickname: String
var is_cool_guy: bool

static var bykr := Bykr.register("PlayerData", PlayerData.new, {
	"level": Bykr.u8,
	"nickname": Bykr.string,
	"is_cool_guy": Bykr.boolean,
})
```

**Note:** The `Bykr.register()` call doesn't have to be in the same file, if you prefer to keep it separate.

Now you can convert it to bytes, i.e. for an RPC call.
```gdscript
func sync_player(data: PlayerData) -> void:
    var bytes: PackedByteArray = PlayerData.bykr.to_bytes(data)
    send_player_data.rpc(bytes)

@rpc
send_player_data(bytes: PackedByteArray) -> void:
    var data: PlayerData = PlayerData.bykr.from_bytes(bytes)
    // ...
```

### Nested data structures

ByteKruncher handles nested data, i.e. one of your properties is another custom class that you want to convert to bytes.

**player_data.gd**

```gdscript
class_name PlayerData extends Resource

var peer_id: int
var level: int
var money: int
var health: float
var nickname: String
var is_cool_guy: bool
var inventory: Inventory

static var bykr: Bykr.Mapper = Bykr.register("PlayerData", PlayerData.new, {
	"peer_id": Bykr.s64,
	"level": Bykr.u8,
	"money": Bykr.u32,
	"health": Bykr.float_,
	"nickname": Bykr.string,
	"is_cool_guy": Bykr.boolean,
	"inventory": Bykr.object("Inventory"),
})
```

**inventory.gd**

```gdscript
class_name Inventory extends Resource

var items: Array[Item]
var max_weight: int

static var bykr: Bykr.Mapper = Bykr.register("Inventory", Inventory.new, {
	"items": Bykr.array("Item"),
	"max_weight": Bykr.u16,
})
```

**item.gd**

```gdscript
class_name Item extends Resource

enum Type {NONE, SWORD, SHIELD, STAFF, WAND}

var type: Type
var amount: int

static var bykr: Bykr.Mapper = Bykr.register("Item", Item.new, {
	"type": Bykr.u8,
	"amount": Bykr.u16,
})
```

### Custom constructor

You can manually construct an object after ByteKruncher parses the bytes for you.

**item.gd**

```gdscript
class_name Item extends Resource

enum Type {NONE, SWORD, SHIELD, STAFF, WAND}

var type: Type
var amount: int

static var bykr: Bykr.Mapper = Bykr.register("Item", ItemFactory.create, {
	"type": Bykr.u8,
	"amount": Bykr.u16,
})
```

**item_factory.gd**

```gdscript
class_name ItemFactory extends Resource

static func create(type: Item.Type, amount: int) -> Item:
    var item := Item.new()
    item.type = type
    item.amount = amount
    if item.type == Item.Type.SWORD:
        item.set_script(preload("res://sword.gd"))
    return item
```

As you can see, ByteKruncher passes the arguments in the same order as you registered them.

## Advanced usage

### Get mapper dynamically

You can also get a mapper without referencing its class.

```gdscript
var data: PlayerData = ...
var mapper: Bykr.Mapper = Bykr.get_mapper("PlayerData")
var bytes: PackedByteArray = mapper.to_bytes(data)
```

### Register custom mapper

You can register custom mappers for types that aren't supported by ByteKruncher.

```gdscript
class_name MyCustomMappers extends Resource
# Just put it anywhere

class Rect2iMapper extends Bykr.Mapper:
    const byte_size: int = 8 + 8 + 8 + 8

	func _read_bytes_at(byte_offset: int, bytes: PackedByteArray) -> ReadResult:
        var position := Vector2i.new(
            bytes.decode_s64(byte_offset + 0),
            bytes.decode_s64(byte_offset + 8),
        )
        var size := Vector2i.new(
            bytes.decode_s64(byte_offset + 16),
            bytes.decode_s64(byte_offset + 24),
        )
        var value := Rect2i.new(position, size)
		return Bykr.ReadResult.new(byte_size, value)
	
	func _append_bytes_to(value: Variant, byte_offset: int, bytes: PackedByteArray) -> void:
        var rect2i := value as Rect2i
		bytes.resize(byte_offset + byte_size)
		bytes.encode_s64(byte_offset + 0, value.position.x)
		bytes.encode_s64(byte_offset + 8, value.position.y)
		bytes.encode_s64(byte_offset + 16, value.size.x)
		bytes.encode_s64(byte_offset + 24, value.size.y)

static func _static_init() -> void:
    Bykr.register_custom("Rect2i", Rect2iMapper.new())
```

Then you can use it like this.

```gdscript
class_name MyData extends Resource:

var some_rect: Rect2i

static var bykr := Bykr.register("MyData", MyData.new, {
    "some_rect": Bykr.custom("Rect2i"),
})
```

**Note:** Mappers should *never* keep state, because they're re-used.
