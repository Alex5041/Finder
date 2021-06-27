extends Node

var arcade:bool = true
var right_action = 0
var game_over:bool = false
var loaded:bool = false
var image
var record:int = 0
var prev_round_score:int = 0

const upgrades = [#{"text":" always right", "image":"res://resources/titleImages/keepoldrequests.png", "num":0},
{"text":"keep old requests",
"image":"res://resources/powerups/keepOldRequests.png", "num":1},
{"text":"double points next round",
"image":"res://resources/powerups/doublePoints.png", "num":2},
{"text":"additional time",
"image":"res://resources/powerups/additionalTime.png", "num":3},
{"text":"less requests",
"image":"res://resources/powerups/lessRequests.png","num":4},
{"text":"no errors, less time next round",
"image":"res://resources/powerups/noErrors.png","num":5},
{"text":"double time bonuses and penalties next round",
"image":"res://resources/powerups/doubleTime.png","num":6}]

const upg_cost = [5, 5, 10, 10, 5, 5, 10]

const names_male = ["William", "John", "Thomas", "George", "James", "Henry",
 "Charles", "Joseph", "Robert", "Edward", "Richard", "Samuel", "Alfred",
 "Frederick", "David", "Arthur", "Walter", "Edwin", "Benjamin", "Francis",
 "Albert", "Daniel", "Isaac", "Peter", "Harry", "Stephen", "Edmund", "Frank",
 "Tom", "Michael", "Matthew", "Herbert", "Abraham", "Alexander"]
const names_female = ["Mary", "Elizabeth", "Sarah", "Ann", "Jane", "Emma",
 "Eliza", "Ellen", "Margaret", "Hannah", "Emily", "Martha", "Alice",
 "Harriet", "Maria", "Louisa", "Fanny", "Charlotte", "Caroline",
 "Catherine", "Frances", "Isabella", "Anne", "Lucy", "Amelia",
 "Susan", "Esther", "Rebecca", "Susannah", "Eleanor", "Matilda",
 "Clara", "Agnes", "Julia"]

const education_place = ["School", "College", "University"]

#@ - one or "__ and __"
const likes = ["I like @",
"Lovin' @!!",
"I adore @ very much",
"Prefer @",
"I'm into @.",
"I want @.",
"How can anyone hate @?!",
"enjoy @!",
"had good experience with @",
"Nothing's better than @."]

const dislikes = ["can't stand @",
"hate @! ",
"don't think I prefer @",
"Not really into @",
"I find @ boring",
"@ is not for me.",
"how can anyone like @?!",
"had bad experience with @",
"dislike @",
"I really detest @.",
"Nothing is worse than @.",
"despise @.",]

const items = ["carrots",
"apples",
"tea",
"coffee",
"bikes",
"bicycles",
"microphone",
"skates",
"tomatoes",
"potatoes",
"bananas",
"football",
"cats",
"rats",
"dogs",
"parrots",
"myself",
"you",]

const actions = ["skating",
"eating",
"sleeping",
"jumping",
"watching movies",
"programming",
"drawing",
"writing poems",
"reading short stories",
"singing",
"dancing",
"working",
"studying",
"walking in the park",
"running",
"jogging",
"laughing",
"joking around",
"playing videogames",
"table tennis",
"listening music",
"wasting time",]

const jobs = ["programmer",
"artist",
"HR",
"director",
"CEO",
"techician",
"pilot",
"janitor",
"cook",
"plumber",
"manager",
"teacher",
"doctor",
"scientist",
"cashier",
"lawyer",
"security guard",
"administrator",
"bookkeeper",
"designer",
"actor",
"politician",
"journalist",
"philosopher",
"streamer",
"driver"]

const companies = ["Googol",
"Yandeks",
"insurance company",
"hospital",
"school",
"university",
"streets",
"pet shop",
"supermarket",
"grocery store",
"pharmacy",
"bank",
"TV",
"newspaper"]

const cities = ["Moscow",
"London",
"Saint Petersburg",
"Berlin",
"Paris",
"Chicago",
"New York",
"Cambridge",
"Amsterdam",
"Edinburgh",
"Oxford",
"Zurich",
"Munich",
"Copenhagen",
"Manchester",
"Prague",
"Oslo",
"Stockholm",
"Rome",
"Vienna"]

func save(p:Person, _r):
	erase_game()
	var game = File.new()
	game.open("user://arcade.save" if arcade else "user://zen.save", File.WRITE)
	var data = {"f":p.f,"face":p.face,"likes":p.likes,"dislikes":p.dislikes,
	"type":p.type}
	game.store_line(to_json(data))
	#for i in r:
		#data = {"f":i.f,}
		#game.store_line(to_json())
	game.close()
	pass

func can_load():
	var game = File.new()
	if !game.file_exists("user://arcade.save" if arcade else "user://zen.save"):
		return null
	else:
		 return 1

func erase_game():
	var dir = Directory.new()
	if dir.file_exists("user://arcade.save" if arcade else "user://zen.save"):
		dir.remove("user://arcade.save" if arcade else "user://zen.save")

func load_game():
	var game = File.new()
	if !game.file_exists("user://arcade.save" if arcade else "user://zen.save"):
		return null
	game.open("user://arcade.save" if arcade else "user://zen.save",File.READ)
	var data = parse_json(game.get_line())
	game.close()
	return data
