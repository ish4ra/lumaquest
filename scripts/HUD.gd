extends CanvasLayer

func bind_player(player):
    player.connect("health_changed", self, "_on_health_changed")
    player.connect("shards_changed", self, "_on_shards_changed")
    _on_health_changed(player.health, player.max_health)
    _on_shards_changed(player.shards)

func _on_health_changed(value, maximum):
    var hearts := ""
    for i in range(maximum):
        hearts += "♥ " if i < value else "♡ "
    $Health.text = hearts

func _on_shards_changed(value):
    $Shards.text = "Luma Shards: %d" % value
