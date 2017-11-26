function love.load(arg)
  button = {}
  button.x = 200
  button.y = 200
  button.radius = 50

  score = 0
  totalClicks = 0
  timer = 10
  gameState = 1   -- 1 = Main Menu, 2 = in game
  accuracy = -1
  myFont = love.graphics.newFont(40)
end

function love.update(dt)
  if gameState == 2 then
    if timer > 0 then
      timer = timer - dt
    end

    if timer < 0 then
      accuracy = (score / totalClicks) * 100
      finalScore = score
      gameState = 1   -- Set game state to menu
      timer = 0       -- Reset timer
      totalClicks = 0 -- Reset Total C
    end
  end
end

function love.draw()
  if gameState == 2 then
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("fill", button.x, button.y, button.radius)
  end

  love.graphics.setFont(myFont)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Score: " .. score)
  love.graphics.print("Timer: " .. math.ceil(timer), 300, 0)

  if accuracy ~= -1 and gameState == 1 then
    love.graphics.printf("Accuracy: " .. math.ceil(accuracy) .. "%", 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
  end

  if gameState == 1 then
    love.graphics.printf("Press SPACE to begin", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
  end
end

-- When left click is pressed
function love.mousepressed(x, y, key, isTouch)
  if key == 1 and gameState == 2 then
    if getDistance(button.x, button.y, love.mouse.getX(), love.mouse.getY()) < button.radius then
      score = score + 1
      totalClicks = totalClicks + 1
      if button.radius > 5 then
        button.radius = button.radius - 3
      end
      button.x = math.random(0, love.graphics.getWidth() - button.radius)
      button.y = math.random(0, love.graphics.getHeight() - button.radius)
    else
      totalClicks = totalClicks + 1
    end
  end
end

-- When Space Bar is pressed, begin game
function love.keypressed(key)
   if key == "space" and gameState == 1 then
     gameState = 2
     score = 0
     timer = 10
     totalClicks = 0
     button.radius = 50
   end
end

-- Distance formula, used to get distance between mouse and circle
function getDistance(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end
