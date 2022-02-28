extends CanvasLayer

var _score: int = 0


func set_score(score: int):
	_score = score
	$Score.text = "Score: " + str(_score)
