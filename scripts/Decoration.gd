extends Node2D

export var variant := 0

func _draw():
    if variant == 0:
        # Ancient tree
        draw_rect(Rect2(-18,-95,36,100), Color("#533d29"))
        draw_colored_polygon(PoolVector2Array([Vector2(-70,-70),Vector2(-42,-125),Vector2(0,-145),Vector2(55,-120),Vector2(82,-70),Vector2(55,-38),Vector2(-50,-35)]), Color("#1d5134"))
        draw_circle(Vector2(-35,-85),35,Color("#2d7040"))
        draw_circle(Vector2(25,-105),42,Color("#347b43"))
        draw_circle(Vector2(52,-72),32,Color("#28673a"))
    elif variant == 1:
        # Mossy ruin pillar
        draw_rect(Rect2(-18,-82,36,82), Color("#667060"))
        draw_rect(Rect2(-23,-88,46,10), Color("#7d8068"))
        draw_rect(Rect2(-20,-55,40,8), Color("#3d6943"))
        draw_circle(Vector2(-10,-52),7,Color("#4f8b49"))
    elif variant == 2:
        # Sign
        draw_rect(Rect2(-3,-42,6,42), Color("#624326"))
        draw_rect(Rect2(-38,-46,76,22), Color("#7b552d"))
        draw_string(null, Vector2(-30,-31), "RUINS  ->", Color("#f1dfb1"))
