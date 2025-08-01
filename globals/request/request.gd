extends Node2D

func _ready() -> void:
	%HTTPRequestGetSeed.request_completed.connect(_on_get_seed_completed)
	%HTTPRequestGetLeaderboard.request_completed.connect(_on_get_leaderboard_completed)
	%HTTPRequestGetRank.request_completed.connect(_on_get_rank_completed)
	%HTTPRequestSubmit.request_completed.connect(_on_submit_completed)

func get_seed():
	%HTTPRequestGetSeed.request("http://laby.arkanyota.com/get_seed")

func submit(pseudo="Pseudo", score=1000):
	var data_to_send = {
		"pseudo": pseudo,
		"score": score,
		"seed": GameGlobal.rng_seed
	}
	var json = JSON.stringify(data_to_send)
	var headers = ["Content-Type: application/json"]
	%HTTPRequestSubmit.request("http://laby.arkanyota.com/submit", headers, HTTPClient.METHOD_POST, json)

func get_leaderboard():
	%HTTPRequestGetLeaderboard.request("http://laby.arkanyota.com/leaderboard")

func get_rank(pseudo="Pseudo"):
	%HTTPRequestGetLeaderboard.request("http://laby.arkanyota.com/rank/"+pseudo)

func _on_get_seed_completed(result, response_code, headers, body):
	if response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	GameGlobal.rng_seed = json["seed"]

func _on_get_leaderboard_completed(result, response_code, headers, body):
	if response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	GameGlobal.leaderboard = json


func _on_get_rank_completed(result, response_code, headers, body):
	if response_code == 404:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json["error"] == 'Pseudo not found':
			return
		return
	if response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json["score"])

func _on_submit_completed(result, response_code, headers, body):
	if response_code != 200:
		return
	print("OK")
