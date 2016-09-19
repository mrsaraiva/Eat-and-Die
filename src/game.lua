----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------
require("src.globals")
require("src.resources")
require("src.powerup")
local composer = require( "composer" )
local scene = composer.newScene()

-- Varáveis locais
local bgm = audio.loadStream(bgm_main)
local highScore
local highScoreFilename = file_highscore
local mainMenu
local physics
local score
local sfxGameover
local sfxAte
local sfxPowerup


-- Usado para controlar o tempo entre as chamadas da função de animação 
local tPrevious = system.getTimer()

-- Todas as funções são declaradas antes da implementação, assim podem ser usadas em qualquer parte do código
local animate
local createPlayer
local gameOver
local generateMenu
local limitScreenBoundary
local loadScore
local onTouch
local onCollision
local saveScore
local showMainMenu
local showTutorial
local spawn
local startGame

-- Funções
-- Carrega os escores de um arquivo. Retorna o escore e o recorde, nessa ordem.
loadScore = function()
	local scores = {}
	local str = ""
	local n = 1
		 
	local path = system.pathForFile(highScoreFilename, system.DocumentsDirectory)

	local file = io.open(path, "r") 
	if (file == nil) then 
		return 0, 0 
	end

	
	local contents = file:read("*a")
	file:close() 

	for i = 1, string.len(contents) do
		local char = string.char(string.byte(contents, i))
  
		if (char ~= "|") then
			str = str .. char
		else
			scores[n] = tonumber(str)
			n = n + 1
			str = ""
		end
	end

	return scores[1], scores[2]
end

-- Armazena os escores em um arquivo. Recebe dois parâmetros: o último escore e maior escore já alcançado.
saveScore = function(sc, hs)
	local path = system.pathForFile(highScoreFilename, system.DocumentsDirectory)

	local file = io.open(path, "w")

	local contents = tostring(sc) .. "|" .. tostring(hs) .. "|"
	file:write(contents)

	file:close() 
end

-- Cria e retorna um novo jogador
createPlayer = function(x, y, xScale, yScale, rotation, visible)
	local physicsData = require (body_char_comecome).physicsData(xScale)
	local playerCollisionFilter = { categoryBits = 1, maskBits = 2 }
	local playerBodyElement = { filter=playerCollisionFilter, shape=pentagonShape }

	--  Inicializa propriedades do jogador
	-- local sheetInfo = require("mysheet")
	-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
	local pSheetInfo = require(ssheet_char_comecome)
	local imageSheetP = graphics.newImageSheet( imagesheet_char_comecome, pSheetInfo:getSheet() )
	-- Create player animation-- Create player animation
	local animSeqP = {
		-- consecutive frames sequence
		{
			name = "eating",
			start = 1,
			count = 6,
			time = 900,
			loopCount = 0,
			loopDirection = "forward"
		}
	}

	-- local p = display.newImage(image_char_comecome, x, y)
	


	-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
	local p = display.newSprite(imageSheetP, animSeqP)
	p:play()
	p.x = x
	p.y = y
	p.xScale = xScale
	p.yScale = yScale
	-- p:setReferencePoint(display.CenterReferencePoint)
	p.anchorX = 0.5
	p.anchorY = 0.5
	p:setFillColor(255/255, 255/255, 255/255)
	p.isBullet = true
	p.objectType = "player"
	physics.addBody(p, "dynamic", physicsData:get("comecome_05"))
	p.isVisible = visible
	p.rotation = rotation
	p.resize = false
	p.isSleepingAllowed = false
	
	return p
end

-- Exibe / oculta o menu principal
showMainMenu = function(showMenu)
	if (showMenu) then
		--mainMenu.isVisible = true
		mainMenu.lbl_lastScore.text = "last score " .. score
		mainMenu.lbl_lastScore.x = display.viewableContentWidth / 2
		mainMenu.lbl_highScore.text = "highest score " .. highScore
		mainMenu.lbl_highScore.x = display.viewableContentWidth / 2
		transition.to(mainMenu, { y=0 })
	else
		transition.to(mainMenu, { y=-display.viewableContentHeight })
	end
end

-- Inicia uma nova rodada, resetando algumas propriedades antes de começar
startGame = function()
	showMainMenu(false)
	spawnConstraint = "no"

	player.xScale = 1.0
	player.yScale = 1.0
	player.x = display.viewableContentWidth / 2
	player.y = display.viewableContentHeight / 2
	player.anchorX = 0.5
	player.anchorY = 0.5
	player.resize = true
	speedFactor = 1
	score = 0
	lbl_currentScore.text = tostring(score)
	isGameOver = false
	player.isVisible = true
	lbl_currentScore.isVisible = true
	for _, object in pairs(objectTable) do
		-- Remove todos os objetos de cena para forçar nova geração
		object.isVisible = false
	end
end

-- Cria um menu e o retorna como um objeto de grupo de display 
generateMenu = function() 
	local mainMenu = display.newGroup()
	local mainMenuBackground = display.newRect(mainMenu, 240,(display.viewableContentHeight) / 2, 480, 230)
	mainMenuBackground:setFillColor(45/255, 80/255, 180/255, 30/255)

	local title = display.newText(mainMenu, "Eat and Die", 0, 0, fnt_karmatic, 46)
	title.x = display.contentWidth / 2
	title.y = (display.contentHeight / 2) - 60
	title:setFillColor(180/255, 45/255, 98/255)

	local startButton = display.newText(mainMenu, "start", 0, 0, fnt_inversionz, 45)
	startButton.x = display.contentWidth / 2
	startButton.y = (display.contentHeight / 2)
	startButton:setFillColor(255/255, 255/255, 255/255, 255/255)

	-- Anima o botão "start", aumentando e diminuindo sua escala
	local function startButtonAnimation()
		local scaleUp = function()
			startButtonTween = transition.to(startButton, { xScale=1, yScale=1, onComplete=startButtonAnimation })
		end
			
		startButtonTween = transition.to(startButton, { xScale=0.9, yScale=0.9, onComplete=scaleUp })
	end
	startButtonAnimation()

	-- Função executada quando o botão "start" é pressionado
	local function onStartButtonTouch(event)
		if "began" == event.phase then
			startButton.isFocus = true
        elseif "ended" == event.phase and startButton.isFocus then
			startButton.isFocus = false
			startGame()
        end
 
        return true
	end
	startButton:addEventListener("touch", onStartButtonTouch) -- Adiciona a função listener acima ao objeto que representa o botão "start" 

	local lbl_lastScore = display.newText(mainMenu, "last score " .. score, 0, 0, fnt_digital7, 15)
	lbl_lastScore.x = display.viewableContentWidth / 2
	lbl_lastScore.y = startButton.y + startButton.height + 15
	lbl_lastScore:setFillColor(0/255, 255/255, 0/255, 100/255)
	mainMenu.lbl_lastScore = lbl_lastScore
	
	local lbl_highScore = display.newText(mainMenu, "highest score " .. highScore, 0, 0, fnt_digital7, 15)
	lbl_highScore.x = display.viewableContentWidth / 2
	lbl_highScore.y = lbl_lastScore.y + lbl_lastScore.height
	lbl_highScore:setFillColor(0, 255/255, 0/255, 100/255)
	mainMenu.lbl_highScore = lbl_highScore

	local imgTutorial = display.newImageRect(image_misc_tutorial, 480, 320)
	imgTutorial.alpha = 0
	imgTutorial.x = display.contentCenterX
	imgTutorial.y = display.contentCenterY
	imgTutorial.xScale = 0.8
	imgTutorial.yScale = 0.8
	local btn_help
	btn_help = display.newImageRect(mainMenu, image_btn_help, 24, 24)
	btn_help.x = lbl_highScore.x + 150
	btn_help.y = lbl_highScore.y
	local function onHelpButtonTouch(event)
		if "began" == event.phase then
			btn_help.isFocus = true
			print("Botão help pressionado")
			print(imgTutorial.alpha)
			if (imgTutorial.alpha == 1) then
				imgTutorial.alpha = 0
			else
				imgTutorial.alpha = 1
			end
        end
 
        return true
	end
	btn_help:addEventListener("touch", onHelpButtonTouch)
	imgTutorial:addEventListener("touch", onHelpButtonTouch)
	mainMenu.btn_help = btn_help
	mainMenu.imgTutorial = imgTutorial
	
	local btn_music_off = display.newImageRect(mainMenu, image_btn_music_off, 24, 24)
	btn_music_off.x = btn_help.x + 30
	btn_music_off.y = btn_help.y
	local btn_music_on = display.newImageRect(mainMenu, image_btn_music_on, 24, 24)
	btn_music_on.x = btn_help.x + 30
	btn_music_on.y = btn_help.y
	if (musicEnabled) then
		btn_music_off.alpha = 0
	else
		musicEnabled = off
		btn_music_on.alpha = 1
	end
	local function onMusicButtonTouch(event)
		if "began" == event.phase then
			btn_help.isFocus = true
			print("Botão music pressionado")
			if (musicEnabled) then
				btn_music_off.alpha = 1
				btn_music_on.alpha = 0
				audio.setVolume( 0, { channel=musicAudioChannel } )
				musicEnabled = false
				print("Music desabilitado")
			else
				btn_music_on.alpha = 1
				btn_music_off.alpha = 0
				audio.setVolume( 1, { channel=musicAudioChannel } )
				musicEnabled = true
				print("Music habilitado")
			end
        end
		
        return true
	end
	btn_music_off:addEventListener("touch", onMusicButtonTouch)
	btn_music_on:addEventListener("touch", onMusicButtonTouch)
	mainMenu.btn_music_off = btn_music_off
	mainMenu.btn_music_on = btn_music_on

	local btn_sfx_off = display.newImageRect(mainMenu, image_btn_sfx_off, 24, 24)
	btn_sfx_off.x = btn_help.x + 60
	btn_sfx_off.y = btn_help.y
	local btn_sfx_on = display.newImageRect(mainMenu, image_btn_sfx_on, 24, 24)
	btn_sfx_on.x = btn_help.x + 60
	btn_sfx_on.y = btn_help.y
	if (sfxEnabled) then
		btn_sfx_off.alpha = 0
	else
		sfxEnabled = off
		btn_sfx_on.alpha = 1
	end
	local function onSfxButtonTouch(event)
		if "began" == event.phase then
			btn_help.isFocus = true
			print("Botão sfx pressionado")
			if (sfxEnabled) then
				btn_sfx_off.alpha = 1
				btn_sfx_on.alpha = 0
				sfxEnabled = false
				audio.setVolume( 0, { channel=sfxAudioChannel } )
				print("Sfx desabilitado")
			else
				btn_sfx_on.alpha = 1
				btn_sfx_off.alpha = 0
				sfxEnabled = true
				print("Sfx habilitado")
				audio.setVolume( 1, { channel=sfxAudioChannel } )
			end
        end
		
        return true
	end
	btn_sfx_off:addEventListener("touch", onSfxButtonTouch)
	btn_sfx_on:addEventListener("touch", onSfxButtonTouch)
	mainMenu.btn_sfx_off = btn_sfx_off
	mainMenu.btn_sfx_on = btn_sfx_on

	return mainMenu

end

-- Função executada quando o jogador perde.
gameOver = function()
	isGameOver = true
	audio.play(sfxGameover, { channel=sfxAudioChannel })
	if score > highScore then
		highScore = score
	end
	saveScore(score, highScore) -- Salva os escores

	showMainMenu(true) -- Exibe o menu principal
	
	lbl_powerUp.alpha = 0
	pbar_powerUp.isVisible = false
	lbl_powerDown.alpha = 0
	pbar_powerDown.isVisible = false
	
	player.isVisible = false
	lbl_currentScore.isVisible = false
	for _, object in pairs(objectTable) do
		object.alpha = isGameOver and 20/255 or 255/255
	end
end

-- Força o objeto que representa o jogador a ficar dentro dos limites visíveis da tela.
limitScreenBoundary = function(object)
	if (object.x < object.width/2) then
		object.x = object.width/2
	end
	if (object.x > (display.viewableContentWidth - (object.width/2))) then
		object.x = display.viewableContentWidth - (object.width/2)
	end
	if (object.y < (object.height + (object.height/2))) then
		object.y = object.height + (object.height/2)
	end
	if (object.y > (display.viewableContentHeight)) then
		object.y = display.viewableContentHeight
	end
end
	
-- Processa os eventos de toque no background e move o personagem de acordo
onTouch = function(event)
	if isGameOver then
		return
	end
	
	if (event.phase == "began") then
		player.isFocus = true

		player.x0 = event.x - player.x
		player.y0 = event.y - player.y
        elseif player.isFocus then
			if (event.phase  == "moved") then
                        player.x = event.x - player.x0
                        player.y = event.y - player.y0
                        limitScreenBoundary(player)
                elseif (phase == "ended" or phase == "cancelled") then
                        player.isFocus = false
                end
        end
 
        -- Retorna verdadeiro se o evento de toque foi tratado
        return true
end

-- A variável objectType pode ser "comida", "inimigo", "bonus", or "penalidade" 
spawn = function(objectType, xVelocity, yVelocity)
	local object
	local specialObj
	local sizeXY = math.random(10, 20)
	local startX
	local startY
	
	-- Funções utilizadas para definir posição inicial do objeto de acordo com eixo de movimento
	if (xVelocity == 0)  then
		-- Objeto irá se move no eixo y	
		startX = math.random(sizeXY, display.contentWidth - sizeXY)
	end
	if xVelocity < 0 then
		-- Objeto irá se mover para esquerda
		startX = display.contentWidth
	end
	if xVelocity > 0 then
		-- Objeto irá se mover para direita
		startX = -sizeXY
	end

	if (yVelocity == 0 ) then
		-- Objeto irá se mover no eixo x
		startY = math.random(sizeXY, display.contentHeight - sizeXY)
	end
	if yVelocity < 0 then
		-- Objeto irá se mover para cima
		startY = display.contentHeight
	end
	if yVelocity > 0 then
		-- Objeto irá se mover para baixo
		startY = -sizeXY
	end
		
	local collisionFilter = { categoryBits = 2, maskBits = 1 } -- Filtra as colisões para que o objeto só possa interagir com o jogador
	local body = { filter=collisionFilter, isSensor=true } -- Os objetos colidem, mas não há interação de força entre eles
	if (objectType == "comida")  then
		-- object = display.newRect(startX, startY, sizeXY, sizeXY)
		object = display.newImageRect(image_item_hamburguer, sizeXY, sizeXY)
		-- object.sizeXY = sizeXY
		object.x = startX
		object.y = startY
		object.sizeXY = sizeXY
	elseif (objectType == "inimigo") then
		-- object = display.newRect(startX, startY, sizeXY, sizeXY)
		object = display.newImageRect(image_item_alface, sizeXY, sizeXY)
		-- object.sizeXY = sizeXY
		object.x = startX
		object.y = startY
		object.sizeXY = sizeXY
	end
	if ((objectType == "bonus") or (objectType == "penalidade")) then
		specialObj = createSpecialItem(objectType)
		-- object = display.newCircle(startX, startY, 15)
		print("\n\nSpawning special item")
		print("specialItem name: " .. specialObj.name)
		print("specialItem image: " .. specialObj.image)
		object = display.newImageRect(specialObj.image, 32, 32)
		object.x = startX
		object.y = startY
		object.specialObj = specialObj
		object.sizeXY = 30
	end
	-- if (objectType == "comida") then
	--	object:setFillColor(255, (isGameOver and 100 or 255))
	-- elseif (objectType == "bonus") then
	-- 	object:setFillColor(0, 0, 255,(isGameOver and 100 or 255))
	-- else
	--	object:setFillColor(255, 0, 0,(isGameOver and 100 or 255))
	-- end
	object:setFillColor(255/255, (isGameOver and 100/255 or 255/255))
	object.objectType = objectType
	object.xVelocity = xVelocity
	object.yVelocity = yVelocity
	physics.addBody(object, body)
	object.isFixedRotation = true
	table.insert(objectTable,  object)
end

-- Função de tratamento dos eventos de colisão
onCollision = function(event)
	if isGameOver then
		return
	end
	
	if (event.phase == "began") then
		local obj
		local objType
		if (event.object1.objectType == "player") then
			obj = event.object2
			objType = event.object2.objectType
		else
			obj = event.object1
			objType = event.object1.objectType
		end
		if ((objType == "comida" and spawnConstraint == "no") or (spawnConstraint == "cometudo")) then
			-- O objeto que colidiu é comida, então o escore é incrementado 
			score = score + 1
			lbl_currentScore.text = tostring(score)
			audio.play(sfxAte, { channel=sfxAudioChannel })
			-- Chico Tripa come, Chico Tripa engorda
			if (player.xScale < 3.0) then
				-- O Corona não suporta o redimensionamento de objetos com física, portanto, precisamos criar um novo jogador
				player.xScale = player.xScale + 0.05
				player.yScale = player.yScale + 0.05
				player.resize = true
			end
			obj.isVisible = false
		elseif ((objType == "inimigo") or (spawnConstraint == "comidaestragada")) then
			gameOver()
		elseif ((objType == "bonus") or (objType == "penalidade")) then
			-- Tipo do objeto é "bonus" or "penalidade"
			audio.play(sfxPowerup, { channel=sfxAudioChannel })
			obj.isVisible = false
			applySpecialItem(obj)
		end
	end
end

-- Anima todos os objetos
animate = function(event)
	-- print("Enter animate event!")
    local tDelta = event.time - tPrevious
    tPrevious = event.time

	for _, object in pairs(objectTable) do
        local xDelta = object.xVelocity * tDelta

        local yDelta= object.yVelocity * tDelta
        local xPos = xDelta + object.x 
        local yPos = yDelta + object.y
        
		if(yPos > display.contentHeight + object.sizeXY) or(yPos < -object.sizeXY) or
				(xPos > display.contentWidth + object.sizeXY) or(xPos < -object.sizeXY) then
			object.isVisible = false
		end
 
        object:translate(xDelta, yDelta)
	end
	
	-- O redimensionamento do personagem do jogador é uma gambiarra. Quando um objeto é redimensionado, isso não se reflete no mecanismo de física.
	-- Sendo assim, um novo objeto é criado, com as mesmas propriedades, mas com tamanho diferente, e o objeto antigo é removido.
	if (player.resize) then
		local player2 = createPlayer(player.x - player.width / 2, player.y - player.height / 2, player.xScale, player.yScale, player.rotation, player.isVisible)
		if player.isFocus then
			player2.isFocus = player.isFocus
			player2.x0 = player.x0
			player2.y0 = player.y0
		end
		player2.resize = false
		player:removeSelf()
		player = player2
	end
	
	for key, object in pairs(objectTable) do
		if (object.isVisible == false) then
			local xVelocity = 0
			local yVelocity = 0
			if (object.objectType == "comida" or object.objectType == "inimigo") then
				-- O novo objeto deve se mover na mesma direção do que o que será removido
				if object.xVelocity < 0 then
					xVelocity = - randomSpeed()
				elseif object.xVelocity > 0 then
					xVelocity = randomSpeed()
				end
				if object.yVelocity < 0 then
					yVelocity = - randomSpeed()
				elseif object.yVelocity > 0 then
					yVelocity = randomSpeed()
				end
				-- Cria novos objetos de comida / inimigos instantâneamente
				spawn(object.objectType, xVelocity, yVelocity)
			else
				-- Cria novos objetos de bônus e penalide em um intervalo pseudo-randomizado
				local sign = {1, -1}
				if (math.random(1, 2) == 1) then
					-- Move o objeto no eixo x, da esquerda para direita ou da esquerda para direita
					xVelocity = randomSpeed() * sign[math.random(1, 2)]
				else
					-- Move o objeto no eixo y, de cima para baixo ou de baixo para cima
					yVelocity = randomSpeed() * sign[math.random(1, 2)]
				end
				local bombshell
				-- Bonus e penalidades serão criados de forma rotatória
				if (object.objectType == "bonus") then
					bombshell = "penalidade"
				else
					bombshell = "bonus"
				end
			local closure = function() return spawn(bombshell, xVelocity, yVelocity) end
				timer.performWithDelay(math.random(6, 12) * 1000, closure, 1)
			end
			object:removeSelf()
			table.remove(objectTable, key)
		end
	end

end

-- Inicio do jogo

-- Esconde a barra de status
-- display.setStatusBar(display.HiddenStatusBar)




function scene:create( event )
    local sceneGroup = self.view
	
	-- Carrega os sons
	sfxGameover = audio.loadSound(sfx_gameover)
	sfxAte = audio.loadSound(sfx_ate)
	sfxPowerup = audio.loadSound(sfx_powerup)
	
	-- Carrega imagem de background
	bg_main = display.newImageRect(image_bggame, 480, 320)
	-- Apenas o background pode receber eventos de toque
	bg_main:addEventListener("touch", onTouch)
	sceneGroup:insert(bg_main)
	
	-- Centraliza os labels
	lbl_currentScore = display.newText("aa", 0, 0, fnt_digital7, 80)
	lbl_currentScore:setFillColor(128/255, 128/255, 128/255, 70/255)
	lbl_currentScore.isVisible = false
	sceneGroup:insert(lbl_currentScore)
		
	lbl_powerUp = display.newText("penalidade", 0, 0, fnt_octovetica, 20)
	lbl_powerUp:setFillColor(255/255, 255/255, 255/255, 1)
	lbl_powerUp.alpha = 0
	sceneGroup:insert(lbl_powerUp)
	
	lbl_powerDown = display.newText("penalidade", 0, 0, fnt_octovetica, 30)
	lbl_powerDown:setFillColor(255/255, 0/255, 0/255, 1)
	lbl_powerDown.alpha = 0
	sceneGroup:insert(lbl_powerDown)

	pbar_powerUp = display.newRect(display.viewableContentWidth / 2, 80, 280, 30)
	pbar_powerUp:setFillColor(0/255, 50/255, 255/255, 50/255)
	pbar_powerUp.isVisible = false
	sceneGroup:insert(pbar_powerUp)

	pbar_powerDown = display.newRect(display.viewableContentWidth / 2, (display.viewableContentHeight-70), 280, 30)
	pbar_powerDown:setFillColor(255/255, 0/255, 255/255, 50/255)
	pbar_powerDown.isVisible = false
	sceneGroup:insert(pbar_powerDown)

	-- Carrega o escore da última partida e o maior escore
	score, highScore = loadScore()
	print(score)
	print(highScore)
	
	-- Inicializa a física
	physics = require("physics")
	physics.start()

	physics.setScale(60)
	--physics.setDrawMode("hybrid") -- Útil para realizar debug da física

	-- Configura gravidade dos eixos x e y. Como se trata de uma perspectiva vista "de cima", não há gravidade em nenhum dos eixos.
	physics.setGravity(0, 0)

	-- Cria o jogador
	player = createPlayer(display.contentCenterX, display.contentCenterY, 1.0, 1.0, 0, false)
	Runtime:addEventListener("enterFrame", function() player.rotation = player.rotation + 1; end)
	sceneGroup:insert(player)

	-- Listener de eventos de colisão
	Runtime:addEventListener("collision", onCollision)

	-- Inicia a animação de todos os objetos, exceto o jogador
	Runtime:addEventListener("enterFrame", animate);

	print("Display Width: " .. display.viewableContentWidth)
	print("Display Height: " .. display.viewableContentHeight .. "\n\n")

	mainMenu = generateMenu()
	sceneGroup:insert(mainMenu)
end
 
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
		bg_main.x = display.contentCenterX
		bg_main.y = display.contentCenterY
		
		lbl_currentScore.x = display.viewableContentWidth / 2 - 5
		lbl_currentScore.y = display.viewableContentHeight / 2 + 4

		
		lbl_powerUp.x = display.viewableContentWidth / 2
		lbl_powerUp.y = 80
		
		lbl_powerDown.x = display.viewableContentWidth / 2
		lbl_powerDown.y = display.viewableContentHeight - 70
				
		spawn("comida", 0, randomSpeed())
		spawn("comida", 0, -randomSpeed())
		spawn("comida", randomSpeed(), 0)
		spawn("comida", -randomSpeed(), 0)
		spawn("inimigo", 0, randomSpeed())
		spawn("inimigo", 0, -randomSpeed())
		spawn("inimigo", randomSpeed(), 0)
		spawn("inimigo", -randomSpeed(), 0)
		spawn("bonus", randomSpeed(), 0)
    elseif ( phase == "did" ) then
		-- Ponto de partida do jogo
		audio.play(bgm, { channel=musicAudioChannel, loops = -1 } )
    end
end
 
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view
end
 
---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene