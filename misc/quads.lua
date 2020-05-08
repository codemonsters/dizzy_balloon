local quads = {
	circle = {quad = love.graphics.newQuad(0, 0, 210, 210, atlas:getDimensions()), width = 210, height = 210},
	boot_fast = {quad = love.graphics.newQuad(0, 210, 20, 20, atlas:getDimensions()), width = 20, height = 20},
	balloon = {quad = love.graphics.newQuad(0, 230, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	cloud = {quad = love.graphics.newQuad(0, 270, 100, 79, atlas:getDimensions()), width = 100, height = 79},
	egg_00 = {quad = love.graphics.newQuad(20, 210, 14, 16, atlas:getDimensions()), width = 14, height = 16},
	egg_01 = {quad = love.graphics.newQuad(34, 210, 14, 16, atlas:getDimensions()), width = 14, height = 16},
	egg_02 = {quad = love.graphics.newQuad(40, 226, 14, 16, atlas:getDimensions()), width = 14, height = 16},
	egg_03 = {quad = love.graphics.newQuad(48, 210, 14, 16, atlas:getDimensions()), width = 14, height = 16},
	egg_04 = {quad = love.graphics.newQuad(40, 242, 14, 16, atlas:getDimensions()), width = 14, height = 16},
	enemy_basic_00 = {quad = love.graphics.newQuad(54, 226, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_01 = {quad = love.graphics.newQuad(94, 210, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_02 = {quad = love.graphics.newQuad(0, 349, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_03 = {quad = love.graphics.newQuad(0, 389, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_04 = {quad = love.graphics.newQuad(0, 429, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_05 = {quad = love.graphics.newQuad(0, 469, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	enemy_basic_06 = {quad = love.graphics.newQuad(0, 509, 40, 40, atlas:getDimensions()), width = 40, height = 40},
	explosion_01 = {quad = love.graphics.newQuad(0, 549, 46, 45, atlas:getDimensions()), width = 46, height = 45},
	explosion_02 = {quad = love.graphics.newQuad(40, 349, 56, 60, atlas:getDimensions()), width = 56, height = 60},
	explosion_03 = {quad = love.graphics.newQuad(40, 409, 63, 68, atlas:getDimensions()), width = 63, height = 68},
	explosion_04 = {quad = love.graphics.newQuad(40, 477, 66, 72, atlas:getDimensions()), width = 66, height = 72},
	explosion_05 = {quad = love.graphics.newQuad(100, 250, 70, 75, atlas:getDimensions()), width = 70, height = 75},
	explosion_06 = {quad = love.graphics.newQuad(100, 325, 75, 80, atlas:getDimensions()), width = 75, height = 80},
	explosion_07 = {quad = love.graphics.newQuad(170, 210, 78, 85, atlas:getDimensions()), width = 78, height = 85},
	explosion_08 = {quad = love.graphics.newQuad(210, 0, 80, 86, atlas:getDimensions()), width = 80, height = 86},
	explosion_09 = {quad = love.graphics.newQuad(210, 86, 82, 89, atlas:getDimensions()), width = 82, height = 89},
	explosion_10 = {quad = love.graphics.newQuad(0, 594, 84, 90, atlas:getDimensions()), width = 84, height = 90},
	explosion_11 = {quad = love.graphics.newQuad(0, 684, 84, 91, atlas:getDimensions()), width = 84, height = 91},
	explosion_12 = {quad = love.graphics.newQuad(0, 775, 84, 90, atlas:getDimensions()), width = 84, height = 90},
	explosion_13 = {quad = love.graphics.newQuad(0, 865, 84, 91, atlas:getDimensions()), width = 84, height = 91},
	explosion_14 = {quad = love.graphics.newQuad(0, 956, 86, 93, atlas:getDimensions()), width = 86, height = 93},
	explosion_15 = {quad = love.graphics.newQuad(290, 0, 78, 84, atlas:getDimensions()), width = 78, height = 84},
	explosion_16 = {quad = love.graphics.newQuad(84, 549, 75, 80, atlas:getDimensions()), width = 75, height = 80},
	explosion_17 = {quad = love.graphics.newQuad(106, 405, 75, 80, atlas:getDimensions()), width = 75, height = 80},
	explosion_18 = {quad = love.graphics.newQuad(175, 295, 79, 79, atlas:getDimensions()), width = 79, height = 79},
	gamepad = {quad = love.graphics.newQuad(84, 629, 210, 210, atlas:getDimensions()), width = 210, height = 210},
	heart = {quad = love.graphics.newQuad(175, 374, 20, 20, atlas:getDimensions()), width = 20, height = 20},
	player_jumping = {quad = love.graphics.newQuad(210, 175, 17, 18, atlas:getDimensions()), width = 17, height = 18},
	bomb = {quad = love.graphics.newQuad(40, 258, 12, 12, atlas:getDimensions()), width = 12, height = 12},
	player_standing = {quad = love.graphics.newQuad(227, 175, 18, 18, atlas:getDimensions()), width = 18, height = 18},
	player_walking_01 = {quad = love.graphics.newQuad(134, 210, 20, 18, atlas:getDimensions()), width = 20, height = 18},
	player_walking_02 = {quad = love.graphics.newQuad(134, 228, 18, 18, atlas:getDimensions()), width = 18, height = 18},
	player_walking_03 = {quad = love.graphics.newQuad(245, 175, 20, 18, atlas:getDimensions()), width = 20, height = 18},
	radish = {quad = love.graphics.newQuad(152, 228, 12, 18, atlas:getDimensions()), width = 12, height = 18},
	skate = {quad = love.graphics.newQuad(46, 549, 20, 20, atlas:getDimensions()), width = 20, height = 20},
	spring = {quad = love.graphics.newQuad(46, 569, 20, 20, atlas:getDimensions()), width = 20, height = 20},
	limit = {quad = love.graphics.newQuad(52, 258, 1, 1, atlas:getDimensions()), width = 1, height = 1},
}

return quads
