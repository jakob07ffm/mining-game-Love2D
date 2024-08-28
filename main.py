function love.load()
    love.window.setTitle("Enhanced Mining Game")
    love.window.setMode(800, 600)

    gridSize = 25
    gridWidth = math.floor(love.graphics.getWidth() / gridSize)
    gridHeight = math.floor(love.graphics.getHeight() / gridSize)

    mine = {}
    blockTypes = {"stone", "coal", "gold"}
    blockColors = {
        stone = {0.5, 0.5, 0.5},
        coal = {0.1, 0.1, 0.1},
        gold = {1, 0.84, 0}
    }
    blockValues = {
        stone = 1,
        coal = 5,
        gold = 10
    }

    for y = 1, gridHeight do
        mine[y] = {}
        for x = 1, gridWidth do
            local r = love.math.random()
            if r < 0.7 then
                mine[y][x] = "stone"
            elseif r < 0.9 then
                mine[y][x] = "coal"
            else
                mine[y][x] = "gold"
            end
        end
    end

    player = {x = math.floor(gridWidth / 2), y = math.floor(gridHeight / 2), score = 0}
    inventory = {stone = 0, coal = 0, gold = 0}
    miningCooldown = 0.2
    miningTimer = 0
end

function love.update(dt)
    if miningTimer > 0 then
        miningTimer = miningTimer - dt
    end

    if love.keyboard.isDown("up") then
        player.y = math.max(1, player.y - 1)
    elseif love.keyboard.isDown("down") then
        player.y = math.min(gridHeight, player.y + 1)
    elseif love.keyboard.isDown("left") then
        player.x = math.max(1, player.x - 1)
    elseif love.keyboard.isDown("right") then
        player.x = math.min(gridWidth, player.x + 1)
    end

    if love.keyboard.isDown("space") and miningTimer <= 0 then
        local block = mine[player.y][player.x]
        if block then
            player.score = player.score + blockValues[block]
            inventory[block] = inventory[block] + 1
            mine[player.y][player.x] = nil
            miningTimer = miningCooldown
        end
    end
end

function love.draw()
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local block = mine[y][x]
            if block then
                love.graphics.setColor(blockColors[block])
                love.graphics.rectangle("fill", (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
            else
                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("fill", (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
            end
        end
    end

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", (player.x-1)*gridSize, (player.y-1)*gridSize, gridSize, gridSize)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. player.score, 10, 10)
    love.graphics.print("Stone: " .. inventory.stone, 10, 30)
    love.graphics.print("Coal: " .. inventory.coal, 10, 50)
    love.graphics.print("Gold: " .. inventory.gold, 10, 70)
end
