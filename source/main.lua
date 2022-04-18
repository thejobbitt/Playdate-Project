import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local playerSprite = nil
local playerSpeed = 4

local playTimer = nil
local playTime = 30 * 1000

local moneyImageTable
local moneyAnim
local moneySprite
local score = 0
local highScore = 0

local randX
local randY

local function resetTimer()
    playTimer = playdate.timer.new(playTime, playTime, 0 , playdate.easingFunctions.linear)
end

local function updateHighScore()
    if score > highScore then
        highScore = score
    end
end

local function moveCoin()
    randX = math.random(40, 360)
    randY = math.random(40, 200)
    if moneySprite == nil then
        moneySprite = gfx.sprite.addEmptyCollisionSprite(randX, randY, 32, 32)
        
    else
        moneySprite:moveTo(randX+16, randY+16)
    end
end

local function initialize()
    math.randomseed(playdate.getSecondsSinceEpoch())
    local playerImage = gfx.image.new("images/player_cash")
    playerSprite = gfx.sprite.new(playerImage)
    playerSprite:moveTo(200, 120)
    playerSprite:setCollideRect(0, 0, playerSprite:getSize())
    playerSprite:add()

    moneyImageTable, error = gfx.imagetable.new('images/money/money')
    assert(moneyImageTable, error)

    moneyAnim = gfx.animation.loop.new(80, moneyImageTable)

    moveCoin()

    local backgroundImage = gfx.image.new("images/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function (x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0,0)
            gfx.clearClipRect()
        end
    )

    sample = snd.sampleplayer.new("sounds/cowbell")

    resetTimer()
end

initialize()

function playdate.update()
    gfx.clear()

    if playTimer.value == 0 then
        if playdate.buttonJustPressed(playdate.kButtonA) then
            resetTimer()
            moveCoin()
            score = 0
        end
        updateHighScore()
    else
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            playerSprite:moveBy(0, -playerSpeed)
        end
        if playdate.buttonIsPressed(playdate.kButtonRight) then
            playerSprite:moveBy(playerSpeed, 0)
        end
        if playdate.buttonIsPressed(playdate.kButtonDown) then
            playerSprite:moveBy(0, playerSpeed)
        end
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            playerSprite:moveBy(-playerSpeed, 0)
        end

        local collisions = moneySprite:overlappingSprites()
        if #collisions >= 1 then
            sample:play()
            moveCoin()
            score += 1
        end
    end
    playdate.timer.updateTimers()
	gfx.sprite.update()
    moneyAnim:draw(randX, randY)

    gfx.drawText("Time: " .. math.ceil(playTimer.value/1000), 5, 5)
    gfx.drawText("Money: " .. score, 320, 5)
    gfx.drawTextAligned("HIGHEST SCORE: " .. highScore, 200, 218, kTextAlignment.center)
    gfx.drawTextAligned("CASH QUEST", 200, 5, kTextAlignment.center)
end