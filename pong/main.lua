-- libraries
---@class love
local love = require("love")
-- https://github.com/Ulydev/push
local push = require("external.push")

-- game classes
local Paddle = require("classes.Paddle")
local Ball = require("classes.Ball")

-- game constants
local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720
local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243
local PADDLE_SPEED = 200

-- game variables
local fonts = {}
local sounds = {}
local player1
local player2
local ball
local player1_score
local player2_score
local serving_player
local winning_player
local game_state

-- game init state
function love.load()
	-- no filtering of pixels, which is important for a nice crisp, 2D look
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- set the title of our application window
	love.window.setTitle("Pong")

	-- seed the RNG so that calls to random are always random
	math.randomseed(os.time())

	-- initialize text fonts
	fonts.small = love.graphics.newFont("assets/font.ttf", 8)
	fonts.large = love.graphics.newFont("assets/font.ttf", 16)
	fonts.score = love.graphics.newFont("assets/font.ttf", 32)
	love.graphics.setFont(fonts.small)

	-- set up sound effects
	sounds.paddle_hit = love.audio.newSource("assets/paddle_hit.wav", "static")
	sounds.score = love.audio.newSource("assets/score.wav", "static")
	sounds.wall_hit = love.audio.newSource("assets/wall_hit.wav", "static")

	-- initialize virtual resolution
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true,
	})

	-- initialize player paddles
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	-- initialize a ball in the middle of the screen
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- initialize score variables
	player1_score = 0
	player2_score = 0

	-- either going to be 1 or 2
	serving_player = 1

	-- player who won the game
	winning_player = 0

	-- the state of our game; can be any of the following:
	-- 1. 'start' (the beginning of the game, before first serve)
	-- 2. 'serve' (waiting on a key press to serve the ball)
	-- 3. 'play' (the ball is in play, bouncing between paddles)
	-- 4. 'done' (the game is over, with a victor, ready for restart)
	game_state = "start"
end

-- window resize handling
function love.resize(w, h)
	push:resize(w, h)
end

-- update game state
function love.update(dt)
	if game_state == "serve" then
		-- before switching to play, initialize ball's velocity based
		-- on player who last scored
		ball.dy = math.random(-50, 50)
		if serving_player == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif game_state == "play" then
		-- detect ball collision with paddles, reversing dx if true and
		-- slightly increasing it, then altering the dy based on the position
		-- at which it collided, then playing a sound effect
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5

			-- keep velocity going in the same direction, but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds.paddle_hit:play()
		end
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			-- keep velocity going in the same direction, but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds.paddle_hit:play()
		end

		-- detect upper and lower screen boundary collision, playing a sound
		-- effect and reversing dy if true
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds.wall_hit:play()
		end

		-- -4 to account for the ball's size
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds.wall_hit:play()
		end

		-- if we reach the left edge of the screen, go back to serve
		-- and update the score and serving player
		if ball.x < 0 then
			serving_player = 1
			player2_score = player2_score + 1
			sounds.score:play()

			-- if we've reached a score of 10, the game is over; set the
			-- state to done so we can show the victory message
			if player2_score == 10 then
				winning_player = 2
				game_state = "done"
			else
				game_state = "serve"
				-- places the ball in the middle of the screen, no velocity
				ball:reset(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2)
			end
		end

		-- if we reach the right edge of the screen, go back to serve
		-- and update the score and serving player
		if ball.x > VIRTUAL_WIDTH then
			serving_player = 2
			player1_score = player1_score + 1
			sounds.score:play()

			-- if we've reached a score of 10, the game is over; set the
			-- state to done so we can show the victory message
			if player1_score == 10 then
				winning_player = 1
				game_state = "done"
			else
				game_state = "serve"
				-- places the ball in the middle of the screen, no velocity
				ball:reset(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2)
			end
		end
	end

	-- player 1
	if love.keyboard.isDown("w") then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown("s") then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- "player 2"
	if game_state == "play" then
		local player2_middle_point = player2.y + player2.height / 2

		if ball.x > 2 * VIRTUAL_WIDTH / 3 then
			-- follow ball
			if ball.y > player2_middle_point then
				player2.dy = PADDLE_SPEED
			elseif ball.y < player2_middle_point then
				player2.dy = -PADDLE_SPEED
			else
				player2.dy = 0
			end
		else
			-- go back to the center
			if player2_middle_point > VIRTUAL_HEIGHT / 2 then
				player2.dy = -PADDLE_SPEED
			elseif player2_middle_point < VIRTUAL_HEIGHT / 2 then
				player2.dy = PADDLE_SPEED
			else
				player2.dy = 0
			end
		end
	end

	-- update our ball based on its DX and DY only if we're in play state;
	-- scale the velocity by dt so movement is framerate-independent
	if game_state == "play" then
		ball:update(dt)
	end

	player1:update(dt, 0, VIRTUAL_HEIGHT)
	player2:update(dt, 0, VIRTUAL_HEIGHT)
end

-- keyboard callback handler
function love.keypressed(key)
	-- exit action
	if key == "escape" then
		love.event.quit()

	-- if we press enter during either the start or serve phase, it should
	-- transition to the next appropriate state
	elseif key == "enter" or key == "return" then
		if game_state == "start" then
			game_state = "serve"
		elseif game_state == "serve" then
			game_state = "play"
		elseif game_state == "done" then
			-- game is simply in a restart phase here, but will set the serving
			-- player to the opponent of whomever won for fairness!
			game_state = "serve"

			-- reset game
			ball:reset(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2)
			player1_score = 0
			player2_score = 0

			-- decide serving player as the opposite of who won
			if winning_player == 1 then
				serving_player = 2
			else
				serving_player = 1
			end
		end
	end
end

-- draw game elements
function love.draw()
	-- begin drawing with push, in our virtual resolution
	push:apply("start")

	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

	-- render different UI messages depending on which part of the game we're in
	if game_state == "start" then
		love.graphics.setFont(fonts.small)
		love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to begin!", 0, 20, VIRTUAL_WIDTH, "center")
	elseif game_state == "serve" then
		love.graphics.setFont(fonts.small)
		love.graphics.printf("Player " .. tostring(serving_player) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.printf("Press Enter to serve!", 0, 20, VIRTUAL_WIDTH, "center")
	elseif game_state == "done" then
		love.graphics.setFont(fonts.large)
		love.graphics.printf("Player " .. tostring(winning_player) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
		love.graphics.setFont(fonts.small)
		love.graphics.printf("Press Enter to restart!", 0, 30, VIRTUAL_WIDTH, "center")
	end

	-- show the score before ball is rendered so it can move over the text
	love.graphics.setFont(fonts.score)
	love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

	-- render game objects
	player1:render(love)
	player2:render(love)
	ball:render(love)

	push:apply("end")
end
