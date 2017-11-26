function love.load(arg)
  sprites = {}
  sprites.player = love.graphics.newImage('sprites/player.png')
  sprites.bullet = love.graphics.newImage('sprites/bullet.png')
  sprites.zombie = love.graphics.newImage('sprites/zombie.png')
  sprites.background = love.graphics.newImage('sprites/background.png')

  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 180

  zombies = {}
  bullets = {}

  gameState = 2
  maxTime = 2
  timer = maxTime
  score = 0

  myFont = love.graphics.newFont(40)
end

function love.update(dt)
  if gameState == 2 then
    getPlayerMovementInput(dt)
  end
  moveZombieToPlayer(dt)
  bulletsManager(dt)
  garbageCollector()

  if gameState == 2 then
    timer = timer - dt
    if timer <= 0 then
      spawnZombie()
      maxTime = maxTime * 0.95
      timer = maxTime
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)

  if gameState == 1 then
    love.graphics.setFont(myFont)
    love.graphics.printf("Click anywhere to begin", 0, 50, love.graphics.getWidth(), "center")
  end
  love.graphics.setFont(myFont)
  love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

  love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

  for i, z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
  end

  for i, b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end
end

function getPlayerMovementInput(dt)
  if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
    player.y = player.y + player.speed * dt
  end

  if love.keyboard.isDown("w") and player.y > 0 then
    player.y = player.y - player.speed * dt
  end

  if love.keyboard.isDown("a") and player.x > 0 then
    player.x = player.x - player.speed * dt
  end

  if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
    player.x = player.x + player.speed * dt
  end
end

function love.mousepressed(x, y, button, isTouch)
  if button == 1 and gameState == 2 then -- left mouse click
    spawnBullet()
  end

  if gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
  end
end

function bulletsManager(dt)
  for i, b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end

  -- Delete bullets when they go off screen
  for i=#bullets,1,-1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      b.dead = true
    end
  end

  for i, z in ipairs(zombies) do
    for j, b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        z.dead = true
        b.dead = true
        score = score + 1
      end
    end
  end
end


function moveZombieToPlayer(dt)
  for i, z in ipairs(zombies) do
    z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt
    z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt

    if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
      for i, z in ipairs(zombies) do
        zombies[i] = nil
        gameState = 1
        player.x = love.graphics.getWidth()/2
        player.y = love.graphics.getHeight()/2
      end
    end
  end
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function playerMouseAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
  return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
  zombie = {}
  zombie.x = math.random(0, love.graphics.getWidth())
  zombie.y = math.random(0, love.graphics.getHeight())
  zombie.speed = 140
  zombie.dead = false

  -- Pick a side of the screen to spawn
  local side = math.random(1, 4)

  if side == 1 then -- Left
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then -- Top
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -30
  elseif side == 3 then -- Right
    zombie.x = love.graphics.getWidth() + 30
    zombie.y = math.random(0, love.graphics.getHeight())
  else  -- Bottom
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end

  table.insert(zombies, zombie)
end

function spawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = playerMouseAngle()
  bullet.dead = false

  table.insert(bullets, bullet)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "space" then spawnZombie() end
end

function garbageCollector()
  for i=#zombies, 1, -1 do
    local z = zombies[i]
    if z.dead == true then
      table.remove(zombies, i)
    end
  end

  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
      table.remove(bullets, i)
    end
  end
end
