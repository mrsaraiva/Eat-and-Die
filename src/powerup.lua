require("src.globals")
require("src.resources")
require("src.shaders.corona_shader_glsl.core").Register()

local qtyBonus = 3
local qtyPenalty = 4

-- Função para criar powerups
createSpecialItem = function(objectType)
	local specialItem = {}

	local randomInt

	if (objectType == "bonus") then
		randomInt = math.random(1, qtyBonus)
	else
		randomInt = math.random(2, qtyPenalty)
	end

	if (objectType == "bonus") then
		if (randomInt == 1) then
			specialItem.name = "nanicolina"
			specialItem.label = "Pílula de Nanicolina! O o ."
			specialItem.image = image_item_nanicolina
		elseif (randomInt == 2) then
			specialItem.name = "cometudo"
			specialItem.image = image_item_cupom
			specialItem.label = "Coma à vontade! :D"
		elseif (randomInt == 3) then
			specialItem.name = "maracugina"
			specialItem.image = image_item_maracugina
			specialItem.label = "Maracugina! zzzZzZZ..."
		end
	else
		if (randomInt == 1) then
			specialItem.name = "aumentapeso"
			specialItem.label = "Engordou instantâneamente! :'('"
			specialItem.image = image_item_pizza
		elseif (randomInt == 2) then
			specialItem.name = "comidaestragada"
			specialItem.image = image_item_salada
			specialItem.label = "Comida estragada! :("
		elseif (randomInt == 3) then
			specialItem.name = "comidaenvenenada"
			specialItem.image = image_item_maca
			specialItem.label = "Comida enveneada! :("
		elseif (randomInt == 4) then
			specialItem.name = "cafeina"
			specialItem.image = image_item_cafe
			specialItem.label = "Overdose de cafeína! >.<"
		end
	
	end

	return specialItem
end

-- Função para aplicar powerups, que alternam a mecânica do jogo
applySpecialItem = function(obj)
	local objectType = obj.objectType
	local specialItem = obj.specialObj
	print("\n\nSpecial item time!")
	print("objectType: " .. objectType)
	print("Special item name: " .. specialItem.name)

	-- Escolhe a ação dependendo do bonus ou penalidade			
	if (objectType == "bonus") then
		
		if (specialItem.name == "nanicolina") then
			-- Diet pill - Reduz o tamanho do jogador
			player.xScale = 0.5
			player.yScale = 0.5
			player.resize = true
			lbl_powerUp.text = specialItem.label
			lbl_powerUp.alpha = 0.25
			transition.to(lbl_powerUp, { time=1000, alpha=0, delay=3000 })
		elseif (specialItem.name == "cometudo") then
			-- Rodízio - É possível comer todos os inimigos
			lbl_powerUp.text = specialItem.label
			lbl_powerUp.alpha = 0.25
			transition.to(lbl_powerUp, { time=500, alpha=0, delay=4500 })
			pbar_powerUp.isVisible = true
			spawnConstraint = "cometudo"
			local closure = function()
				spawnConstraint = "no"
				pbar_powerUp.width = 280
				pbar_powerUp.isVisible = false
			end
			transition.to(pbar_powerUp, { time=5000, width=0, onComplete=closure })
		elseif (specialItem.name == "maracugina") then
			-- Maracujina - todos os objetos movem-se com metade da velocidade normal 
			if speedFactor ~= 1 then -- Ignora o powerup, pois o player está cafeinado
				return
			end
			lbl_powerUp.text = specialItem.label
			lbl_powerUp.alpha = 0.25
			transition.to(lbl_powerUp, { time=500, alpha=0, delay=4500 })
			speedFactor = 0.5
			calculateNewVelocity(objectTable)
			pbar_powerUp.isVisible = true
			local closure = function()
				speedFactor = 2
				calculateNewVelocity(objectTable)
				speedFactor = 1
				pbar_powerUp.width = 280
				pbar_powerUp.isVisible = false
			end
			transition.to(pbar_powerUp, { time=5000, width=0, onComplete=closure })
		end
	elseif (objectType == "penalidade") then
		if (specialItem.name == "aumentapeso") then
			-- Aumento de peso - tamanho do jogador aumenta
			player.xScale = 3.0
			player.yScale = 3.0
			player.resize = true
			lbl_powerDown.text = specialItem.label
			lbl_powerDown.alpha = 0.25
			transition.to(lbl_powerDown, { time=1000, alpha=0, delay=3000 })
		elseif (specialItem.name == "comidaestragada") then
			-- Comida estragada - distorce a tela
			lbl_powerDown.text = specialItem.label
			lbl_powerDown.alpha = 0.25
			transition.to(lbl_powerDown, { time=500, alpha=0, delay=4500 })
			pbar_powerDown.isVisible = true
			local kernel = require "src.shaders.haze_basic"
			print(kernel)
			graphics.defineEffect( kernel )
			bg_main.fill.effect = "filter.heat.basic"
			bg_main.fill.effect.frequency = 1
			bg_main.fill.effect.extend = 70

			print("Stub - Tela balançando")
			local closure = function()
				print("Fim da tela balançando")
				bg_main.fill.effect = ""
			end
			transition.to(pbar_powerDown, { time=5000, width=0, onComplete=closure })
		elseif (specialItem.name == "comidaenvenenada") then
			-- Comida envenenada - todos os objetos são danosos ao jogador
			lbl_powerDown.text = specialItem.label
			lbl_powerDown.alpha = 0.25
			transition.to(lbl_powerDown, { time=500, alpha=0, delay=4500 })
			pbar_powerDown.isVisible = true
			spawnConstraint = "comidaestragada"
			local closure = function()
				spawnConstraint = "no"
				pbar_powerDown.width = 280
				pbar_powerDown.isVisible = false;
			end
			transition.to(pbar_powerDown, { time=5000, width=0, onComplete=closure })
		elseif (specialItem.name == "cafeina") then
			-- Cafeína - todos os objetos se movem com o dobro da velocidade normal
			if (speedFactor ~= 1) then -- Ignora esse powerup, pois o jogador está sob efeito da Maracugina
				return
			end
			lbl_powerDown.text = specialItem.label
			lbl_powerDown.alpha = 0.25
			transition.to(lbl_powerDown, { time=500, alpha=0, delay=4500 })
			speedFactor = 2
			calculateNewVelocity(objectTable)
			pbar_powerDown.isVisible = true
			local closure = function()
				speedFactor = 0.5
				calculateNewVelocity(objectTable)
				speedFactor = 1
				pbar_powerDown.width = 280
				pbar_powerDown.isVisible = false;
			end
			transition.to(pbar_powerDown, { time=5000, width=0, onComplete=closure })
		end
	end
	lbl_powerUp.x = display.viewableContentWidth / 2
	lbl_powerDown.x = display.viewableContentWidth / 2
end