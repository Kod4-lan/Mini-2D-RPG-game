extends CharacterBody2D
@export var iso_ratio: float = 0.5
@export var deadzone: float = 0.15

const SPEED : float = 100.0
const JUMP_VELOCITY = -400.0

var input_vec: = Vector2.ZERO
var last_dir: = Vector2.DOWN

func iso_input_dir(raw: Vector2) -> Vector2:
	# ✅ 用 Python 风格三目
	var x := 0.0 if abs(raw.x) < deadzone else signf(raw.x)
	var y := 0.0 if abs(raw.y) < deadzone else signf(raw.y)
	var q := Vector2(x, y)

	if q == Vector2.ZERO:
		return Vector2.ZERO

	# 直轴保持不变
	if q == Vector2(0, -1): return Vector2(0, -1)      # W ↑
	if q == Vector2(0,  1): return Vector2(0,  1)      # S ↓
	if q == Vector2(-1, 0): return Vector2(-1, 0)      # A ←
	if q == Vector2( 1, 0): return Vector2( 1, 0)      # D →

	# 对角映射到等距轴，并归一化保证等速
	if q == Vector2(-1, -1): return Vector2(-1, -iso_ratio).normalized()  # WA ↖
	if q == Vector2( 1, -1): return Vector2( 1, -iso_ratio).normalized()  # WD ↗
	if q == Vector2(-1,  1): return Vector2(-1,  iso_ratio).normalized()  # SA ↙
	if q == Vector2( 1,  1): return Vector2( 1,  iso_ratio).normalized()  # SD ↘


	return q.normalized()  # 兜底

func _physics_process(delta: float) -> void:
	var raw_vec := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var dir := iso_input_dir(raw_vec)            # ✅ 满足你的需求的方向

	if dir != Vector2.ZERO:
		last_dir = dir
		velocity = dir * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()  
