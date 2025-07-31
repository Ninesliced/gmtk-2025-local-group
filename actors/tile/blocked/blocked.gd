extends Tile
@export var timer_before_unblock: float = 1.0
var timer: Timer

func _ready():
    super()
    timer = Timer.new()
    timer.wait_time = timer_before_unblock
    timer.one_shot = true
    add_child(timer)


func _on_timer_timeout():
    if is_inside_tree():
        get_tree().call_group("blocked_tiles", "unblock_tile", self)
