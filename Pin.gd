extends Area2D

signal hit_pin


func _on_Pin_body_entered(body):
	if body.is_in_group("ball"):
		print("hit the pin")
		emit_signal("hit_pin")
		$RichTextLabel.visible = true
