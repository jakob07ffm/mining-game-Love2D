function love.load()
    love.window.setTitle("Advanced Mining Game")
    love.window.setMode(800, 600)

    gridSize = 25
    gridWidth = math.floor(love.graphics.getWidth() / gridSize)
    gridHeight = math.floor(love.graphics.getHeight() / gridSize)

    mine = {}
    biomes = {"forest", "desert", "mountain"}
    biomeColors = {
        forest = {0.3, 0.7, 0.3},
        desert = {0.9, 0.9, 0.5},
        mountain = {0.5, 0.5, 0.5}
    }
    blockTypes = {"stone", "coal", "gold", "diamond", "iron", "silver", "wood"}
    blockColors = {
        stone = {0.5, 0.5, 0.5},
        coal = {0.1, 0.1, 0.1},
        gold = {1, 0.84, 0},
        diamond = {0, 1, 1},
        iron = {0.8, 0.8, 0.8},
        silver = {0.75, 0.75, 0.75},
        wood = {0.55, 0.27, 0.07}
    }
    blockValues = {
        stone = 1,
        coal = 5,
        gold = 10,
        diamond = 20,
        iron = 8,
        silver = 15,
        wood = 2
    }
    blockDurability = {
        stone = 1,
        coal = 2,
        gold = 3,
        diamond = 5,
        iron = 3,
        silver = 4,
        wood = 1
    }

    tools = {"pickaxe", "shovel", "axe"}
    toolDurability = {pickaxe = 100, shovel = 100, axe = 100}
    craftingRecipes = {
        pickaxe = {stone = 5, wood = 2},
        shovel = {stone = 3, wood = 1},
        axe = {stone = 4, wood = 2}
    }
    player = {
        x = math.floor(gridWidth / 2),
        y = math.floor(gridHeight / 2),
        score = 0,
        miningPower = 1,
        health = 100,
        maxHealth = 100,
        hunger = 100,
        stamina = 100,
        inventory = {stone = 0, coal = 0, gold = 0, diamond = 0, iron = 0, silver = 0, wood = 0},
        equippedTool = "pickaxe",
        base = {built = false, x = 0, y = 0, level = 0},
        weapon = {type = "fist", damage = 5}
    }
    miningCooldown = 0.2
    miningTimer = 0

    upgradeCost = 50
    torchCost = 10
    torchRadius = 3
    playerTorches = {}

    enemies = {}
    rangedEnemies = {}
    spawnEnemyCooldown = 5
    spawnEnemyTimer = spawnEnemyCooldown

    dayTime = 0
    dayLength = 60
    isDay = true

    weatherTypes = {"clear", "rain", "storm"}
    currentWeather = "clear"
    weatherTimer = 0
    weatherDuration = love.math.random(20, 40)

    shop = {
        {name = "Increase Mining Power", cost = 100, effect = function() player.miningPower = player.miningPower + 1 end},
        {name = "Restore Health", cost = 50, effect = function() player.health = player.maxHealth end},
        {name = "Restore Stamina", cost = 30, effect = function() player.stamina = 100 end},
        {name = "Buy Wood", cost = 20, effect = function() player.inventory.wood = player.inventory.wood + 5 end},
        {name = "Upgrade Tool Durability", cost = 150, effect = function() toolDurability[player.equippedTool] = toolDurability[player.equippedTool] + 50 end}
    }

    quests = {
        {description = "Mine 10 stone blocks", condition = function() return player.inventory.stone >= 10 end, reward = function() player.score = player.score + 50 end},
        {description = "Build a base", condition = function() return player.base.built end, reward = function() player.health = player.health + 20 end},
        {description = "Defeat 5 enemies", condition = function() return player.kills >= 5 end, reward = function() player.weapon = {type = "sword", damage = 15} end}
    }
    currentQuest = 1
    player.kills = 0

    currentShopItem = 1
    generateMine()
end

function generateMine()
    for y = 1, gridHeight do
        mine[y] = {}
        for x = 1, gridWidth do
            local r = love.math.random()
            local biome = biomes[love.math.random(#biomes)]
            mine[y][x] = {type = "stone", durability = blockDurability.stone, biome = biome}

            if biome == "forest" then
                if r < 0.5 then
                    mine[y][x].type = "stone"
                elseif r < 0.75 then
                    mine[y][x].type = "coal"
                elseif r < 0.9 then
                    mine[y][x].type = "iron"
                else
                    mine[y][x].type = "gold"
                end
            elseif biome == "desert" then
                if r < 0.5 then
                    mine[y][x].type = "sand"
                elseif r < 0.75 then
                    mine[y][x].type = "silver"
                else
                    mine[y][x].type = "diamond"
                end
            elseif biome == "mountain" then
                if r < 0.6 then
                    mine[y][x].type = "stone"
                elseif r < 0.8 then
                    mine[y][x].type = "coal"
                elseif r < 0.95 then
                    mine[y][x].type = "iron"
                else
                    mine[y][x].type = "diamond"
                end
            end

            mine[y][x].durability = blockDurability[mine[y][x].type] or 1
        end
    end
    generateCaves()
end

function generateCaves()
    for i = 1, 15 do
        local caveX = love.math.random(1, gridWidth)
        local caveY = love.math.random(1, gridHeight)
        mine[caveY][caveX] = nil
    end
end

function spawnEnemy()
    local enemy = {
        x = love.math.random(1, gridWidth),
        y = love.math.random(1, gridHeight),
        health = 50,
        damage = 10,
        range = love.math.random(1, 3)
    }
    table.insert(enemies, enemy)
    if love.math.random() > 0.5 then
        table.insert(rangedEnemies, enemy)
    end
end

function love.update(dt)
    if miningTimer > 0 then
        miningTimer = miningTimer - dt
    end

    player.hunger = player.hunger - dt * 0.5
    player.stamina = math.max(0, player.stamina - dt * 0.5)

    if player.hunger <= 0 or player.stamina <= 0 then
        player.health = player.health - dt * 5
        if player.health <= 0 then
            love.load()
        end
    end

    if love.keyboard.isDown("up") then
        player.y = math.max(1, player.y - 1)
        player.stamina = player.stamina - 0.5
    elseif love.keyboard.isDown("down") then
        player.y = math.min(gridHeight, player.y + 1)
        player.stamina = player.stamina - 0.5
    elseif love.keyboard.isDown("left") then
        player.x = math.max(1, player.x - 1)
        player.stamina = player.stamina - 0.5
    elseif love.keyboard.isDown("right") then
        player.x = math.min(gridWidth, player.x + 1)
        player.stamina = player.stamina - 0.5
    end

    if love.keyboard.isDown("space") and miningTimer <= 0 then
        local block = mine[player.y][player.x]
        if block and block.durability > 0 then
            block.durability = block.durability - player.miningPower
            toolDurability[player.equippedTool] = toolDurability[player.equippedTool] - 1

            if block.durability <= 0 then
                player.inventory[block.type] = player.inventory[block.type] + 1
                player.score = player.score + blockValues[block.type]
                mine[player.y][player.x] = nil
            end

            miningTimer = miningCooldown
        end

        if toolDurability[player.equippedTool] <= 0 then
            player.equippedTool = "fist"
            toolDurability[player.equippedTool] = 0
        end
    end

    spawnEnemyTimer = spawnEnemyTimer - dt
    if spawnEnemyTimer <= 0 then
        spawnEnemy()
        spawnEnemyTimer = spawnEnemyCooldown
    end

    for i, enemy in ipairs(enemies) do
        local distance = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
        if distance < 1.5 then
            player.health = player.health - enemy.damage * dt
            if player.health <= 0 then
                love.load()
            end
        end
    end

    for i, enemy in ipairs(rangedEnemies) do
        local distance = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
        if distance < enemy.range then
            player.health = player.health - (enemy.damage / enemy.range) * dt
            if player.health <= 0 then
                love.load()
            end
        end
    end

    weatherTimer = weatherTimer + dt
    if weatherTimer > weatherDuration then
        weatherTimer = 0
        weatherDuration = love.math.random(20, 40)
        currentWeather = weatherTypes[love.math.random(#weatherTypes)]
    end

    if currentWeather == "storm" then
        player.health = player.health - dt * 1
        if player.health <= 0 then
            love.load()
        end
    end

    if player.base.built then
        if player.x == player.base.x and player.y == player.base.y then
            player.health = math.min(player.maxHealth, player.health + dt * 5)
            player.hunger = math.min(100, player.hunger + dt * 2)
            player.stamina = math.min(100, player.stamina + dt * 3)
        end
    end

    if quests[currentQuest].condition() then
        quests[currentQuest].reward()
        currentQuest = currentQuest + 1
    end

    dayTime = dayTime + dt
    if dayTime > dayLength then
        isDay = not isDay
        dayTime = 0
    end
end

function love.draw()
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            local block = mine[y][x]
            if block then
                love.graphics.setColor(biomeColors[block.biome])
                love.graphics.rectangle("fill", (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
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

    if not isDay then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        for _, torch in ipairs(playerTorches) do
            for y = torch.y - torchRadius, torch.y + torchRadius do
                for x = torch.x - torchRadius, torch.x + torchRadius do
                    if x > 0 and x <= gridWidth and y > 0 and y <= gridHeight then
                        local distance = math.sqrt((x - torch.x)^2 + (y - torch.y)^2)
                        if distance <= torchRadius then
                            love.graphics.setColor(1, 1, 0.5, 0.5 - distance / torchRadius)
                            love.graphics.rectangle("fill", (x-1)*gridSize, (y-1)*gridSize, gridSize, gridSize)
                        end
                    end
                end
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. player.score, 10, 10)
    love.graphics.print("Mining Power: " .. player.miningPower, 10, 30)
    love.graphics.print("Upgrade Cost: " .. upgradeCost, 10, 50)
    love.graphics.print("Health: " .. math.floor(player.health) .. "/" .. player.maxHealth, 10, 70)
    love.graphics.print("Hunger: " .. math.floor(player.hunger) .. "/100", 10, 90)
    love.graphics.print("Stamina: " .. math.floor(player.stamina) .. "/100", 10, 110)
    love.graphics.print("Torch Cost (Coal): " .. torchCost, 10, 130)
    love.graphics.print("Inventory: Stone: " .. player.inventory.stone .. " Coal: " .. player.inventory.coal .. " Gold: " .. player.inventory.gold .. " Diamond: " .. player.inventory.diamond .. " Iron: " .. player.inventory.iron .. " Silver: " .. player.inventory.silver .. " Wood: " .. player.inventory.wood, 10, 150)

    local dayNightText = isDay and "Day" or "Night"
    love.graphics.print("Time: " .. dayNightText, 10, 170)
    love.graphics.print("Weather: " .. currentWeather, 10, 190)

    love.graphics.print("Shop: " .. shop[currentShopItem].name .. " (Cost: " .. shop[currentShopItem].cost .. ")", 10, 210)

    if player.base.built then
        love.graphics.print("Base Level: " .. player.base.level, 10, 230)
    end

    love.graphics.print("Quest: " .. quests[currentQuest].description, 10, 250)
end

function love.keypressed(key)
    if key == "tab" then
        currentShopItem = currentShopItem % #shop + 1
    elseif key == "c" then
        craftItem()
    elseif key == "b" then
        buildBase()
    elseif key == "space" and player.weapon.type ~= "fist" then
        attack()
    end
end

function craftItem()
    local recipe = craftingRecipes[player.equippedTool]
    local canCraft = true

    for material, amount in pairs(recipe) do
        if player.inventory[material] < amount then
            canCraft = false
        end
    end

    if canCraft then
        for material, amount in pairs(recipe) do
            player.inventory[material] = player.inventory[material] - amount
        end
        toolDurability[player.equippedTool] = 100
    end
end

function buildBase()
    if not player.base.built and player.inventory.wood >= 10 then
        player.base.built = true
        player.base.x = player.x
        player.base.y = player.y
        player.inventory.wood = player.inventory.wood - 10
        player.base.level = 1
    elseif player.base.built and player.inventory.wood >= 20 then
        player.base.level = player.base.level + 1
        player.inventory.wood = player.inventory.wood - 20
    end
end

function attack()
    for i, enemy in ipairs(enemies) do
        local distance = math.sqrt((player.x - enemy.x)^2 + (player.y - enemy.y)^2)
        if distance < 1.5 then
            enemy.health = enemy.health - player.weapon.damage
            if enemy.health <= 0 then
                table.remove(enemies, i)
                player.kills = player.kills + 1
            end
        end
    end
end
