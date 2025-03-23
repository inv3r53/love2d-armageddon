-- Game objects and state
local player = {
    x = 400,
    y = 300,
    radius = 15,
    rotation = 0,
    speed = 200,
    bullets = {},
    lives = 3,
    thrust = false  -- New variable to track if thrust is active
}

local asteroids = {}
local score = 0
local gameOver = false
local spawnTimer = 0
local spawnInterval = 2 -- seconds between asteroid spawns

-- Load game assets
function love.load()
    love.window.setMode(800, 600)
    -- Set random seed for asteroid generation
    math.randomseed(os.time())
end

-- Create a new asteroid
function createAsteroid()
    local side = math.random(1, 4) -- 1: top, 2: right, 3: bottom, 4: left
    local x, y
    
    if side == 1 then -- top
        x = math.random(0, 800)
        y = -50
    elseif side == 2 then -- right
        x = 850
        y = math.random(0, 600)
    elseif side == 3 then -- bottom
        x = math.random(0, 800)
        y = 650
    else -- left
        x = -50
        y = math.random(0, 600)
    end
    
    local asteroid = {
        x = x,
        y = y,
        radius = math.random(20, 40),
        dx = (400 - x) / math.random(200, 400), -- Move towards center
        dy = (300 - y) / math.random(200, 400)
    }
    table.insert(asteroids, asteroid)
end

-- Shoot bullet
function shoot()
    -- Calculate the vertex position from the tip of the rocket
    local vertexX = player.x - math.cos(player.rotation + math.pi/2) * 20  -- Negate the offset to move to the tip
    local vertexY = player.y - math.sin(player.rotation + math.pi/2) * 20
    
    local bullet = {
        x = vertexX,
        y = vertexY,
        speed = 500,
        rotation = player.rotation - math.pi/2,  -- Subtract pi/2 instead of adding to reverse direction
        lifetime = 1 -- seconds
    }
    table.insert(player.bullets, bullet)
end

-- Draw the rocket sprite
function drawRocket()
    -- Main body
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon('fill', 0, -20, -8, 20, 8, 20)  -- Main triangle
    
    -- Cockpit
    love.graphics.setColor(0.4, 0.8, 1)
    love.graphics.polygon('fill', 0, -10, -4, 5, 4, 5)
    
    -- Wings
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.polygon('fill', -8, 20, -15, 15, -8, 10)  -- Left wing
    love.graphics.polygon('fill', 8, 20, 15, 15, 8, 10)    -- Right wing
    
    -- Draw thrust when moving forward
    if player.thrust then
        love.graphics.setColor(1, 0.5, 0)
        local flicker = love.math.random() * 4
        love.graphics.polygon('fill',
            -4, 20,  -- Left point
            4, 20,   -- Right point
            0, 30 + flicker  -- Bottom point
        )
    end
end

function love.update(dt)
    if gameOver then
        if love.keyboard.isDown('r') then
            -- Reset game
            player.lives = 3
            score = 0
            asteroids = {}
            player.bullets = {}
            gameOver = false
        end
        return
    end

    -- Player movement
    if love.keyboard.isDown('left') then
        player.rotation = player.rotation - 5 * dt
    end
    if love.keyboard.isDown('right') then
        player.rotation = player.rotation + 5 * dt
    end
    
    -- Update thrust state
    player.thrust = love.keyboard.isDown('up')
    
    if player.thrust then
        player.x = player.x - math.cos(player.rotation + math.pi/2) * player.speed * dt  -- Negate the direction
        player.y = player.y - math.sin(player.rotation + math.pi/2) * player.speed * dt  -- Negate the direction
    end

    -- Keep player in bounds
    player.x = math.max(0, math.min(player.x, 800))
    player.y = math.max(0, math.min(player.y, 600))

    -- Update bullets
    for i = #player.bullets, 1, -1 do
        local bullet = player.bullets[i]
        bullet.x = bullet.x + math.cos(bullet.rotation) * bullet.speed * dt
        bullet.y = bullet.y + math.sin(bullet.rotation) * bullet.speed * dt
        bullet.lifetime = bullet.lifetime - dt
        
        -- Remove bullets that are off-screen or expired
        if bullet.lifetime <= 0 or
           bullet.x < 0 or bullet.x > 800 or
           bullet.y < 0 or bullet.y > 600 then
            table.remove(player.bullets, i)
        end
    end

    -- Spawn asteroids
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        createAsteroid()
        spawnTimer = 0
    end

    -- Update asteroids
    for i = #asteroids, 1, -1 do
        local asteroid = asteroids[i]
        asteroid.x = asteroid.x + asteroid.dx * dt * 100
        asteroid.y = asteroid.y + asteroid.dy * dt * 100

        -- Check collision with player
        local dist = math.sqrt((player.x - asteroid.x)^2 + (player.y - asteroid.y)^2)
        if dist < (player.radius + asteroid.radius) then
            player.lives = player.lives - 1
            table.remove(asteroids, i)
            if player.lives <= 0 then
                gameOver = true
            end
            break
        end

        -- Check collision with bullets
        for j = #player.bullets, 1, -1 do
            local bullet = player.bullets[j]
            local bulletDist = math.sqrt((bullet.x - asteroid.x)^2 + (bullet.y - asteroid.y)^2)
            if bulletDist < asteroid.radius then
                table.remove(asteroids, i)
                table.remove(player.bullets, j)
                score = score + 100
                break
            end
        end
    end
end

function love.draw()
    if gameOver then
        love.graphics.print("GAME OVER! Score: " .. score, 350, 250)
        love.graphics.print("Press 'R' to restart", 350, 280)
        return
    end

    -- Draw player (rocket)
    love.graphics.push()
    love.graphics.translate(player.x, player.y)
    love.graphics.rotate(player.rotation)
    drawRocket()
    love.graphics.pop()

    -- Draw bullets
    love.graphics.setColor(1, 1, 0)
    for _, bullet in ipairs(player.bullets) do
        love.graphics.circle('fill', bullet.x, bullet.y, 2)
    end

    -- Draw asteroids
    love.graphics.setColor(0.7, 0.7, 0.7)
    for _, asteroid in ipairs(asteroids) do
        love.graphics.circle('line', asteroid.x, asteroid.y, asteroid.radius)
    end

    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Lives: " .. player.lives, 10, 30)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        shoot()
    end
end