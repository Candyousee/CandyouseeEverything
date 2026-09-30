--!strict
-- Every kit-built pet: body plan, blocky proportions (studs), colours and trick.
-- Read by the game (animation measurements) and by build/rigs/Kit.luau (the blocks).
-- Cat and Dog are hand-built (Pets/Cat.luau, Pets/Dog.luau).
--
-- Colours: main, accent (muzzle/belly/paws), dark (ears, marks, tail tip), plus
-- optional nose, eye, leg, paw, head, ear, tail, mane, horn, beak, wing, fin.

local W, K = { 246, 244, 238 }, { 30, 30, 34 }
local PINK = { 255, 160, 180 }

local list = {
	-------------------------------------------------------------- big cats
	{ Name = "Lion", Plan = "Quadruped", body = { 2.2, 1.6, 3.6 }, legH = 1.4, head = { 2.4, 1.8, 1.8 }, snout = { 1.3, 0.7, 0.5 }, jaw = true,
		ears = "round", earSize = 0.6, tail = "tuft", mane = true, trick = "Roar",
		colors = { main = { 226, 170, 84 }, accent = { 242, 218, 166 }, dark = { 150, 84, 34 }, nose = { 120, 60, 50 } } },
	{ Name = "Tiger", Plan = "Quadruped", body = { 2.2, 1.6, 3.8 }, legH = 1.4, head = { 2.6, 1.8, 1.8 }, snout = { 1.3, 0.7, 0.5 }, jaw = true,
		ears = "round", earSize = 0.6, tail = "long", markings = "stripes", trick = "Roar",
		colors = { main = { 238, 132, 40 }, accent = W, dark = K, nose = { 200, 110, 110 } } },
	{ Name = "Cheetah", Plan = "Quadruped", body = { 1.8, 1.3, 3.6 }, legH = 1.7, legW = 0.7, head = { 2.2, 1.5, 1.6 }, snout = { 1.1, 0.6, 0.4 },
		ears = "round", earSize = 0.5, tail = "long", markings = "spots", trick = "Stretch", anim = { runSwing = 48 },
		colors = { main = { 234, 196, 104 }, accent = W, dark = K, nose = K } },
	{ Name = "Leopard", Plan = "Quadruped", body = { 2, 1.4, 3.6 }, legH = 1.4, head = { 2.4, 1.6, 1.7 }, snout = { 1.2, 0.6, 0.4 },
		ears = "round", earSize = 0.55, tail = "long", markings = "spots", trick = "Stretch",
		colors = { main = { 226, 174, 88 }, accent = { 246, 230, 196 }, dark = { 70, 45, 30 }, nose = { 200, 120, 110 } } },
	{ Name = "Panther", Plan = "Quadruped", body = { 2, 1.4, 3.6 }, legH = 1.4, head = { 2.4, 1.6, 1.7 }, snout = { 1.2, 0.6, 0.4 }, jaw = true,
		ears = "round", earSize = 0.55, tail = "long", trick = "Roar",
		colors = { main = { 38, 38, 46 }, accent = { 62, 62, 74 }, dark = { 20, 20, 24 }, nose = { 20, 20, 24 }, eye = { 250, 205, 60 } } },
	-------------------------------------------------------------- dogs & co
	{ Name = "Wolf", Plan = "Quadruped", body = { 2, 1.5, 3.6 }, legH = 1.5, head = { 2.2, 1.6, 1.7 }, snout = { 1.1, 0.7, 0.9 }, jaw = true,
		ears = "perky", earSize = 0.9, tail = "fluffy", trick = "Roar",
		colors = { main = { 128, 134, 146 }, accent = { 222, 224, 230 }, dark = { 70, 74, 84 }, nose = K } },
	{ Name = "Fox", Plan = "Quadruped", body = { 1.8, 1.3, 3.2 }, legH = 1.2, head = { 2.2, 1.5, 1.6 }, snout = { 0.9, 0.6, 0.8 },
		ears = "perky", earSize = 1.0, tail = "fluffy", trick = "Spin",
		colors = { main = { 228, 112, 40 }, accent = W, dark = K, nose = K, paw = K } },
	-------------------------------------------------------------- bears
	{ Name = "Bear", Plan = "Quadruped", body = { 2.6, 1.8, 3.4 }, legH = 1.1, legW = 1.0, head = { 2.4, 1.8, 1.8 }, snout = { 1.2, 0.7, 0.6 },
		ears = "round", earSize = 0.6, tail = "stub", trick = "Rear",
		colors = { main = { 122, 80, 50 }, accent = { 190, 150, 110 }, dark = { 80, 52, 32 }, nose = K } },
	{ Name = "PolarBear", Plan = "Quadruped", body = { 2.6, 1.8, 3.6 }, legH = 1.2, legW = 1.0, head = { 2.2, 1.7, 1.9 }, snout = { 1.1, 0.7, 0.7 },
		ears = "round", earSize = 0.5, tail = "stub", trick = "Rear",
		colors = { main = { 238, 240, 242 }, accent = { 250, 250, 250 }, dark = { 210, 212, 216 }, nose = K } },
	{ Name = "Panda", Plan = "Quadruped", body = { 2.6, 1.8, 3.2 }, legH = 1.0, legW = 1.0, head = { 2.6, 1.9, 1.9 }, snout = { 1.1, 0.6, 0.4 },
		ears = "round", earSize = 0.7, tail = "stub", markings = "panda", trick = "Spin",
		colors = { main = W, accent = W, dark = K, nose = K, leg = K, paw = K, ear = K } },
	{ Name = "RedPanda", Plan = "Quadruped", body = { 1.8, 1.3, 3 }, legH = 1.0, head = { 2.4, 1.6, 1.6 }, snout = { 1.0, 0.6, 0.4 },
		ears = "perky", earSize = 0.7, tail = "fluffy", tailRings = true, markings = "cheeks", trick = "Rear",
		colors = { main = { 196, 84, 40 }, accent = W, dark = { 90, 40, 24 }, nose = K, leg = { 60, 30, 20 }, paw = { 60, 30, 20 } } },
	{ Name = "Raccoon", Plan = "Quadruped", body = { 1.8, 1.3, 3 }, legH = 1.0, head = { 2.4, 1.6, 1.6 }, snout = { 0.9, 0.6, 0.5 },
		ears = "round", earSize = 0.55, tail = "fluffy", tailRings = true, markings = "mask", trick = "Spin",
		colors = { main = { 138, 138, 144 }, accent = { 220, 220, 222 }, dark = { 40, 40, 46 }, nose = K, paw = { 60, 60, 66 } } },
	-------------------------------------------------------------- farm
	{ Name = "Pig", Plan = "Quadruped", body = { 2.2, 1.6, 3.2 }, legH = 0.9, head = { 2.4, 1.8, 1.6 }, snout = { 1.2, 0.8, 0.4 }, nostrils = true,
		ears = "round", earSize = 0.6, tail = "curly", trick = "Spin",
		colors = { main = { 246, 172, 184 }, accent = { 236, 140, 158 }, dark = { 210, 110, 130 }, paw = { 210, 110, 130 } } },
	{ Name = "Cow", Plan = "Quadruped", body = { 2.4, 1.8, 3.8 }, legH = 1.4, legW = 0.9, head = { 2.2, 1.8, 1.8 }, snout = { 1.6, 0.8, 0.5 }, nostrils = true,
		ears = "side", earSize = 0.7, horns = "bull", tail = "tuft", tailPitch = -55, tail2Pitch = -80, markings = "patches", trick = "Roar",
		colors = { main = W, accent = PINK, dark = K, paw = K, horn = { 240, 230, 200 } } },
	{ Name = "Horse", Plan = "Quadruped", body = { 2.2, 1.8, 4 }, legH = 2.0, legW = 0.8, head = { 1.6, 1.6, 2.2 }, snout = { 1.4, 1.0, 0.8 }, nostrils = true,
		neck = 1.6, ears = "tall", earSize = 0.7, tail = "hang", tailPitch = -40, tail2Pitch = -75, maneStrip = true, trick = "Rear",
		colors = { main = { 150, 94, 56 }, accent = { 120, 74, 44 }, dark = { 50, 34, 26 }, paw = { 50, 34, 26 } } },
	{ Name = "Zebra", Plan = "Quadruped", body = { 2.2, 1.8, 3.8 }, legH = 1.9, legW = 0.8, head = { 1.6, 1.6, 2.1 }, snout = { 1.4, 1.0, 0.8 }, nostrils = true,
		neck = 1.4, ears = "tall", earSize = 0.8, tail = "tuft", tailPitch = -40, tail2Pitch = -75, maneStrip = true, markings = "zebra", trick = "Rear",
		colors = { main = W, accent = K, dark = K, paw = K } },
	{ Name = "Donkey", Plan = "Quadruped", body = { 2.2, 1.7, 3.6 }, legH = 1.5, legW = 0.8, head = { 1.6, 1.6, 2 }, snout = { 1.4, 0.9, 0.7 }, nostrils = true,
		neck = 1.0, ears = "tall", earSize = 1.3, tail = "tuft", tailPitch = -40, tail2Pitch = -75, maneStrip = true, trick = "Roar",
		colors = { main = { 140, 132, 128 }, accent = { 220, 216, 210 }, dark = { 60, 56, 54 }, paw = { 60, 56, 54 } } },
	{ Name = "Unicorn", Plan = "Quadruped", body = { 2.2, 1.8, 3.8 }, legH = 1.9, legW = 0.8, head = { 1.6, 1.6, 2.1 }, snout = { 1.4, 1.0, 0.8 }, nostrils = true,
		neck = 1.5, ears = "tall", earSize = 0.7, horns = "unicorn", tail = "hang", tailPitch = -40, tail2Pitch = -75, maneStrip = true, trick = "Rear",
		colors = { main = W, accent = { 255, 214, 236 }, dark = { 190, 120, 230 }, paw = { 230, 190, 90 }, horn = { 250, 205, 70 }, mane = { 190, 120, 230 }, tail = { 190, 120, 230 } } },
	{ Name = "Sheep", Plan = "Quadruped", body = { 2.6, 2.0, 3.2 }, legH = 1.0, legW = 0.6, head = { 1.6, 1.6, 1.4 }, snout = { 1.2, 0.6, 0.3 },
		ears = "side", earSize = 0.6, tail = "stub", wool = true, trick = "Spin",
		colors = { main = W, accent = { 60, 56, 60 }, dark = K, head = { 60, 56, 60 }, leg = { 60, 56, 60 }, paw = K, nose = { 230, 150, 160 } } },
	{ Name = "Goat", Plan = "Quadruped", body = { 2, 1.6, 3.2 }, legH = 1.4, legW = 0.7, head = { 1.8, 1.6, 1.8 }, snout = { 1.2, 0.8, 0.6 }, nostrils = true,
		ears = "side", earSize = 0.6, horns = "goat", beard = true, tail = "stub", trick = "Rear",
		colors = { main = { 236, 232, 222 }, accent = { 210, 200, 186 }, dark = { 110, 96, 84 }, horn = { 150, 130, 110 } } },
	{ Name = "Deer", Plan = "Quadruped", body = { 2, 1.6, 3.6 }, legH = 1.9, legW = 0.6, head = { 1.8, 1.6, 1.8 }, snout = { 1.0, 0.7, 0.7 },
		neck = 0.8, neckW = 0.9, ears = "side", earSize = 0.8, horns = "antlers", tail = "stub", markings = "fawn", trick = "Rear",
		colors = { main = { 176, 112, 62 }, accent = W, dark = { 90, 60, 36 }, nose = K, horn = { 110, 80, 50 } } },
	-------------------------------------------------------------- safari
	{ Name = "Giraffe", Plan = "Quadruped", body = { 2, 1.8, 3.4 }, legH = 2.6, legW = 0.7, head = { 1.4, 1.4, 1.9 }, snout = { 1.1, 0.8, 0.6 }, nostrils = true,
		neck = 3.4, neckW = 0.9, ears = "side", earSize = 0.6, horns = "ossicones", tail = "tuft", tailPitch = -50, tail2Pitch = -75,
		markings = "giraffe", maneStrip = true, trick = "Spin",
		colors = { main = { 240, 196, 96 }, accent = { 250, 226, 170 }, dark = { 150, 90, 40 }, mane = { 150, 90, 40 }, horn = { 150, 90, 40 } } },
	{ Name = "Elephant", Plan = "Quadruped", body = { 3, 2.4, 4 }, legH = 1.5, legW = 1.2, head = { 2.4, 2.2, 1.8 }, snout = { 1.0, 0.8, 0.4 },
		ears = "elephant", trunk = true, tusks = true, tail = "tuft", tailPitch = -55, tail2Pitch = -80, trick = "Trumpet",
		colors = { main = { 150, 154, 166 }, accent = { 170, 174, 186 }, dark = { 110, 114, 126 }, paw = { 120, 124, 136 }, horn = W } },
	{ Name = "Rhino", Plan = "Quadruped", body = { 2.6, 2.0, 4 }, legH = 1.2, legW = 1.0, head = { 2, 1.6, 2.2 }, snout = { 1.6, 1.0, 0.8 },
		ears = "tall", earSize = 0.6, horns = "rhino", tail = "tuft", tailPitch = -55, tail2Pitch = -80, trick = "Roar",
		colors = { main = { 140, 140, 146 }, accent = { 160, 160, 166 }, dark = { 90, 90, 96 }, paw = { 100, 100, 106 }, horn = { 220, 214, 200 } } },
	{ Name = "Hippo", Plan = "Quadruped", body = { 2.8, 2.0, 3.8 }, legH = 0.9, legW = 1.0, head = { 2.6, 1.6, 2.2 }, snout = { 2.4, 0.8, 0.6 }, jaw = true, nostrils = true,
		ears = "round", earSize = 0.4, tail = "stub", trick = "Roar",
		colors = { main = { 150, 122, 150 }, accent = { 230, 170, 180 }, dark = { 110, 86, 110 } } },
	{ Name = "Camel", Plan = "Quadruped", body = { 2, 1.6, 3.6 }, legH = 2.2, legW = 0.7, head = { 1.4, 1.2, 1.8 }, snout = { 1.2, 0.8, 0.6 }, nostrils = true,
		neck = 1.8, neckW = 0.9, ears = "round", earSize = 0.35, hump = 2, tail = "tuft", tailPitch = -50, tail2Pitch = -75, trick = "Spin",
		colors = { main = { 214, 170, 110 }, accent = { 234, 204, 160 }, dark = { 150, 110, 64 } } },
	{ Name = "Llama", Plan = "Quadruped", body = { 2, 1.8, 3.2 }, legH = 1.8, legW = 0.7, head = { 1.4, 1.4, 1.6 }, snout = { 1.0, 0.7, 0.5 },
		neck = 2.0, neckW = 1.0, ears = "tall", earSize = 0.9, tail = "stub", wool = true, trick = "Spin",
		colors = { main = { 244, 236, 220 }, accent = { 250, 246, 236 }, dark = { 120, 100, 80 }, nose = K } },
	{ Name = "Crocodile", Plan = "Quadruped", body = { 2.2, 1.0, 4 }, legH = 0.6, legW = 0.7, head = { 1.8, 1.0, 1.4 }, snout = { 1.2, 0.5, 1.8 }, jaw = true,
		ears = "none", tail = "croc", tailPitch = 8, tail2Pitch = -6, tailW = 0.9, tailLen = { 1.8, 1.6 }, markings = "scutes", trick = "Roar",
		anim = { sitPitch = 12, jumpHeight = 0.8, walkSwing = 28, walkTail = { 0, 0 }, runTail = { -4, 0 }, jumpTailScale = 0,
			sitTailDirs = { { -0.25, 0, 1 }, { -0.35, 0, 0.94 } }, sleepTailDirs = { { -0.3, -0.05, 1 }, { -0.5, 0, 0.87 } } },
		colors = { main = { 80, 140, 60 }, accent = { 190, 210, 130 }, dark = { 50, 96, 40 }, nose = { 50, 96, 40 }, eye = { 240, 210, 60 } } },
	-------------------------------------------------------------- small
	{ Name = "Mouse", Plan = "Quadruped", body = { 1.4, 1.0, 2 }, legH = 0.6, legW = 0.5, head = { 1.8, 1.3, 1.3 }, snout = { 0.7, 0.5, 0.4 },
		ears = "round", earSize = 0.9, tail = "long", tailW = 0.18, tailLen = { 1.4, 1.2 }, tailPitch = 10, trick = "Stretch",
		anim = { sitTailDirs = { { -0.5, -0.1, 0.85 }, { -0.55, 0.05, -0.8 } }, sleepTailDirs = { { -0.55, -0.2, 0.8 }, { -0.4, 0, -0.9 } } },
		colors = { main = { 170, 170, 176 }, accent = { 240, 236, 236 }, dark = PINK, nose = PINK, ear = { 170, 170, 176 }, tail = PINK } },
	{ Name = "Bunny", Plan = "Quadruped", body = { 1.8, 1.4, 2.4 }, legH = 0.7, legW = 0.6, head = { 2, 1.6, 1.6 }, snout = { 0.8, 0.5, 0.3 },
		ears = "tall", earSize = 1.6, tail = "puff", trick = "Spin",
		colors = { main = W, accent = { 250, 250, 250 }, dark = PINK, nose = PINK } },

	-------------------------------------------------------------- flyers
	{ Name = "Parrot", Plan = "Flyer", body = { 1.4, 1.5, 1.8 }, head = { 1.5, 1.3, 1.3 }, beak = "hook", crest = true, wingSpan = 1.8, tail = "long", flapPeriod = 0.4,
		colors = { main = { 220, 40, 40 }, accent = { 250, 210, 50 }, dark = { 40, 90, 210 }, beak = { 60, 60, 66 }, wing = { 40, 150, 220 } } },
	{ Name = "Owl", Plan = "Flyer", body = { 1.8, 1.8, 1.6 }, head = { 2, 1.5, 1.4 }, headOnTop = true, beak = "small", tufts = true, eyeRing = true,
		wingSpan = 2.0, tail = "short", flapPeriod = 0.5,
		colors = { main = { 150, 110, 70 }, accent = { 226, 200, 160 }, dark = { 100, 70, 44 }, beak = { 230, 170, 60 }, eye = { 30, 30, 34 } } },
	{ Name = "Eagle", Plan = "Flyer", body = { 1.5, 1.5, 2.2 }, head = { 1.4, 1.3, 1.4 }, beak = "hook", wingSpan = 2.6, tail = "long", flapPeriod = 0.5, flapAmp = 38,
		colors = { main = { 100, 66, 40 }, accent = W, dark = { 60, 40, 26 }, beak = { 250, 200, 50 }, head = W, leg = { 250, 200, 50 } } },
	{ Name = "Bat", Plan = "Flyer", body = { 1.2, 1.2, 1.2 }, head = { 1.5, 1.2, 1.1 }, alwaysFly = true, bigEars = true, fangs = true, wingSpan = 2.0, wingChord = 1.4,
		tail = "none", flapPeriod = 0.25, flapAmp = 55,
		colors = { main = { 70, 60, 80 }, accent = { 110, 96, 120 }, dark = { 40, 34, 48 }, wing = { 50, 42, 58 }, nose = PINK } },
	{ Name = "Bee", Plan = "Flyer", body = { 1.3, 1.3, 1.6 }, head = { 1.3, 1.2, 1.0 }, alwaysFly = true, antennae = true, stinger = true, stripes = true,
		wingSpan = 1.2, wingChord = 0.8, wingTop = true, tail = "none", flapPeriod = 0.1, flapAmp = 40, hover = 2.2,
		colors = { main = { 250, 200, 40 }, accent = { 250, 220, 90 }, dark = K, wing = { 200, 230, 250 } } },
	{ Name = "Butterfly", Plan = "Flyer", body = { 0.6, 0.6, 1.8 }, head = { 0.8, 0.8, 0.7 }, alwaysFly = true, antennae = true,
		wingSpan = 2.0, wingChord = 2.0, wingTop = true, wingSpots = true, tail = "none", flapPeriod = 0.5, flapAmp = 60, hover = 2.4,
		colors = { main = { 50, 40, 60 }, accent = { 250, 220, 90 }, dark = K, wing = { 150, 90, 230 } } },
	{ Name = "Dragon", Plan = "Flyer", body = { 1.8, 1.6, 2.8 }, head = { 1.6, 1.4, 1.6 }, legH = 0.9, beak = "snout", jaw = true, dragonHorns = true, spikes = true,
		wingSpan = 2.6, wingChord = 1.6, tail = "dragon", flapPeriod = 0.8, flapAmp = 40,
		colors = { main = { 70, 170, 90 }, accent = { 230, 210, 120 }, dark = { 40, 110, 60 }, wing = { 50, 130, 70 }, horn = { 240, 230, 200 }, eye = { 250, 200, 40 } } },

	-------------------------------------------------------------- swimmers
	{ Name = "Whale", Plan = "Swimmer", body = { 2.4, 2.2, 3.6 }, head = { 2.3, 2.1, 1.6 }, kick = "vertical", blowhole = true, belly = true, trick = "Flip",
		colors = { main = { 70, 110, 190 }, accent = { 200, 220, 240 }, dark = { 40, 70, 140 } } },
	{ Name = "Shark", Plan = "Swimmer", body = { 1.6, 1.6, 3.6 }, head = { 1.5, 1.5, 1.4 }, dorsal = true, belly = true, gills = true, teeth = true, trick = "Spin",
		colors = { main = { 130, 146, 164 }, accent = W, dark = { 90, 104, 120 } } },
	{ Name = "Dolphin", Plan = "Swimmer", body = { 1.4, 1.5, 3.2 }, head = { 1.3, 1.3, 1.2 }, beak = true, dorsal = true, belly = true, kick = "vertical", trick = "Flip",
		colors = { main = { 120, 160, 200 }, accent = { 220, 232, 244 }, dark = { 90, 124, 164 } } },
	{ Name = "Clownfish", Plan = "Swimmer", body = { 1.0, 1.6, 2.0 }, head = { 0.95, 1.5, 0.9 }, bands = true, trick = "Spin", swimPeriod = 0.5,
		colors = { main = { 250, 120, 30 }, accent = W, dark = K, fin = { 250, 140, 50 } } },
	{ Name = "Pufferfish", Plan = "Swimmer", body = { 2.0, 2.0, 1.8 }, head = { 1.9, 1.9, 0.8 }, spikes = true, trick = "Spin", swimPeriod = 0.5,
		colors = { main = { 240, 210, 90 }, accent = { 250, 240, 200 }, dark = { 170, 130, 50 } } },
	{ Name = "Narwhal", Plan = "Swimmer", body = { 1.8, 1.6, 3.4 }, head = { 1.7, 1.5, 1.3 }, kick = "vertical", tusk = true, belly = true, spots = true, trick = "Spin", anim = { leapPitch = 0.35 },
		colors = { main = { 150, 160, 176 }, accent = { 220, 226, 234 }, dark = { 100, 110, 126 }, horn = { 240, 234, 210 } } },

	-------------------------------------------------------------- two legs
	{ Name = "Penguin", Plan = "Biped", body = { 1.6, 1.9, 1.4 }, head = { 1.5, 1.3, 1.3 }, legH = 0.4, legW = 0.5, beak = "small", arms = "flippers", belly = true,
		tail = "short", waddle = 10, trick = "Dance",
		colors = { main = { 40, 44, 56 }, accent = W, dark = K, beak = { 250, 160, 40 }, leg = { 250, 160, 40 } } },
	{ Name = "Chicken", Plan = "Biped", body = { 1.5, 1.4, 1.8 }, head = { 1.1, 1.2, 1.1 }, headFront = true, legH = 0.8, legW = 0.3, beak = "small", comb = true,
		arms = "wings", tail = "feathers", trick = "Dance",
		colors = { main = W, accent = { 246, 240, 226 }, dark = { 220, 40, 40 }, beak = { 250, 190, 50 }, leg = { 250, 190, 50 } } },
	{ Name = "Duck", Plan = "Biped", body = { 1.5, 1.3, 2.0 }, head = { 1.2, 1.2, 1.2 }, headFront = true, legH = 0.5, legW = 0.3, beak = "bill",
		arms = "wings", tail = "feathers", waddle = 9, trick = "Dance",
		colors = { main = { 250, 220, 80 }, accent = { 252, 234, 140 }, dark = { 230, 180, 40 }, beak = { 250, 140, 40 }, leg = { 250, 140, 40 } } },
	{ Name = "Monkey", Plan = "Biped", body = { 1.6, 1.6, 1.2 }, head = { 1.9, 1.6, 1.4 }, legH = 0.9, legW = 0.5, face = true, ears = "sideRound", arms = "long",
		tail = "monkey", trick = "Dance",
		colors = { main = { 130, 84, 50 }, accent = { 230, 190, 150 }, dark = { 90, 56, 34 } } },
	{ Name = "TRex", Plan = "Biped", body = { 1.8, 1.8, 2.6 }, head = { 1.6, 1.4, 2.2 }, headFront = true, headUp = 0.8, legH = 1.2, legW = 0.8, legZ = 0.4, jaw = true, teeth = true,
		arms = "tiny", tail = "rex", waddle = 3, trick = "Roar", anim = { sitTail = -12 },
		colors = { main = { 110, 160, 80 }, accent = { 200, 220, 150 }, dark = { 70, 110, 50 } } },
}

local byName = {}
local order = {}
for _, entry in list do
	byName[entry.Name] = entry
	table.insert(order, entry.Name)
end

return { ByName = byName, Order = order }
