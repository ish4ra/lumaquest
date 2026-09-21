extends Node2D

func _draw():
    # Sky gradient-like bands
    draw_rect(Rect2(0, 0, 1800, 480), Color("#132b46"))
    draw_rect(Rect2(0, 145, 1800, 335), Color("#173b4b"))
    # Distant mountains
    var mountains = PoolVector2Array([Vector2(0,300),Vector2(150,165),Vector2(260,285),Vector2(410,125),Vector2(570,285),Vector2(760,155),Vector2(930,300),Vector2(1100,170),Vector2(1300,300),Vector2(1500,150),Vector2(1800,300)])
    draw_colored_polygon(mountains, Color("#284f59"))
    # Far forest
    for x in range(0, 1800, 38):
        var h = 35 + int((x * 17) % 65)
        draw_colored_polygon(PoolVector2Array([Vector2(x,355),Vector2(x+18,355-h),Vector2(x+36,355)]), Color("#163c36"))
    # Waterfall / river landmarks
    draw_rect(Rect2(1070,205,34,155), Color("#69b7c9"))
    draw_rect(Rect2(1078,205,8,155), Color("#b8e7e8"))
    # Sunlit mist
    draw_circle(Vector2(920,100), 55, Color(0.85,0.92,0.82,0.08))

func _ready():
    update()
