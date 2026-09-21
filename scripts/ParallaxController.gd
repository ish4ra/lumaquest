extends Node2D

# Layered Green Fields backdrop. This is the composition controller;
# raster pixel-art layers are attached below this node as assets arrive.
export var camera_path = NodePath("")
var camera = null

func _ready():
    if camera_path != NodePath(""):
        camera = get_node(camera_path)

func _process(_delta):
    if camera == null:
        return
    var x = camera.global_position.x
    $Skyline.position.x = x * 0.08
    $Mountains.position.x = x * 0.14
    $FarForest.position.x = x * 0.22
    $MidForest.position.x = x * 0.34
