function love.load()
    love.window.setTitle("Advanced Mining Game")
    love.window.setMode(800, 600)

    gridSize = 25
    gridWidth = math.floor(love.graphics.getWidth() / gridSize)
    gridHeight = math.floor(love.graphics.getHeight() / gridSize)

    mine = {}
    blockTypes = {"stone", "coal", "gold", "diamond"}
    blockColors = {
        stone = {0.5, 0.5, 0.5},
        coal = {0.1, 0.1, 0.1},
        gold = {1, 0.84, 0},
        diamond = {0, 1, 1}
    }
    blockValues = {
        stone = 1,
        coal = 5,
        gold = 10,
        diamond = 20
    }
    blockDurability = {
        stone = 1,
        coal = 2,
        gold = 3,
        diamond = 5
    }

    for y = 1, gridHeight do
        mine[y] = {}
        for x = 1, gridWidth do
            local r = love.math.random()
            if r < 0.6 then
                mine[y][x] = {type = "stone", durability = blockDurability.stone}
            elseif r < 0.85 then
                mine[y][x] = {type = "coal", durability = blockDurability.coal}
            elseif r < 0.97 then
                mine[y][x] = {type = "gold", durability = blockDurability.gold}
            else
                mine[y][x] = {type = "diamond", durability = blockDurability.diamond}
            end
        end
    end

    player = {
        x = math.floor(gridWidth / 2),
        y = math.floor(gridHeight / 2),
        score = 0,
        miningPower = 1,
        inventory = {stone = 0, coal = 0, gold = 0, diamond = 0}
    }
    miningCooldown = 0.2
    miningTimer = 0

    upgradeCost = 50
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
            block.durability = block.durability - player.miningPower
            if block.durability <= 0 then
                player.score = player.score + blockValues[block.type]
                player.inventory[block.type] = player.inventory[block.type] + 1
                mine[player.y][player.x] = nil
            end
            miningTimer = miningCooldown
        end
    end

    if love.keyboard.isDown("u") and player.score >= upgradeCost then
        player.miningPower = player.miningPower + 1
        player.score = player.score - upgradeCost
        upgradeCost = upgradeCost * 2
    end
end

function love.draw()
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local block = mine[y][x]
            if block then
                love.graphics.setColor(blockColors[block.type])
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
    love.graphics.print("Mining Power: " .. player.miningPower, 10, 30)
    love.graphics.print("Upgrade Cost: " .. upgradeCost, 10, 50)
    love.graphics.print("Inventory: Stone: " .. player.inventory.stone .. " Coal: " .. player.inventory.coal .. " Gold: " .. player.inventory.gold .. " Diamond: " .. player.inventory.diamond, 10, 70)
end
