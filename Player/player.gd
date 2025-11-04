extends CharacterBody2D

## === Inspector 参数 / Inspector parameters ===
@export var iso_ratio: float = 0.5        # 等距映射比：把纵向输入缩放到等距轴 / isometric y-scale
@export var deadzone: float = 0.15        # 死区 / input deadzone
@export var move_speed: float = 100.0     # 移动速度 / move speed

## === 节点引用 / Node refs ===
@onready var animation_tree: AnimationTree = $AnimationTree
# 如需：@onready var sprite: AnimatedSprite2D = $Sprite

## === 运行时状态 / Runtime state ===
var last_dir: Vector2 = Vector2.DOWN  # 记忆上一次非零方向 / remember last non-zero dir

func _ready() -> void:
	animation_tree.active = true
	_set_blend_position(last_dir)  # 初始化朝向 / init facing

func _physics_process(delta: float) -> void:
	print("raw=", Input.get_vector("walk_left","walk_right","walk_up","walk_down"))

	# 1) 读输入（按你项目的 Input Map：walk_left/right/up/down）
	var raw := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	# 2) 死区 + 等距缩放
	var move_dir := _iso_input_dir(raw)

	# 3) 速度与朝向
	if move_dir != Vector2.ZERO:
		last_dir = move_dir
		velocity = move_dir * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# 4) 把朝向喂给 BlendSpace2D
	_set_blend_position(last_dir)

## === 工具函数 / Helpers ===

# 应用死区与等距缩放 / apply deadzone and iso scaling
func _iso_input_dir(raw: Vector2) -> Vector2:
	var x := 0.0
	var y := 0.0

	if abs(raw.x) >= deadzone:
		x = signf(raw.x)
	if abs(raw.y) >= deadzone:
		y = signf(raw.y)

	var v := Vector2(x, y)

	if v != Vector2.ZERO and iso_ratio != 1.0:
		v.y *= iso_ratio

	return v.normalized() if v != Vector2.ZERO else Vector2.ZERO

# 写入 AnimationTree 的 BlendSpace2D blend_position
# Feed direction vector into AnimationTree's BlendSpace2D
func _set_blend_position(dir: Vector2) -> void:
	# 你提供的准确路径：parameters/blend_position
	var blend_dir := Vector2(dir.x, -dir.y)  # Godot BlendSpace2D uses +Y down; our data uses +Y up
	animation_tree["parameters/blend_position"] = blend_dir
