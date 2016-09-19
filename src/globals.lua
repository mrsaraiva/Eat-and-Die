-- Tabela de objetos que armazena todos os objetos animados, exceto o jogador e o menu 
objectTable = {}

isGameOver = true
bg_main = nil
lbl_currentScore = nil
lbl_powerUp = nil
lbl_powerDown = nil
pbar_powerUp = nil
pbar_powerDown = nil

musicAudioChannel = 1
musicEnabled = true
sfxAudioChannel = 2
sfxEnabled = true

-- Google Play Games
app_id = "684999218580"
achievementFirstSandwich = "CgkIlKuK6fcTEAIQAg"
achievement30Sandwiches = "CgkIlKuK6fcTEAIQAw"
achievement100Sandwiches = "CgkIlKuK6fcTEAIQBA"
achievement500Sandwiches = "CgkIlKuK6fcTEAIQBQ"
achievement999Sandwiches = "CgkIlKuK6fcTEAIQBg"
leaderboardHighScores = "CgkIlKuK6fcTEAIQAA"

-- Usado para controlar os diferentes modos de jogo, de acordo com o power up ou power down coletado pelo jogador 
spawnConstraint = "no" -- Controla se há alguma restrição para criação de um novo objeto
player = nil

-- Fator para regular velocidade dos objetos, que podem ser: 
-- Velocidade normal, Maracugina e Cafeína
speedFactor = 1

-- Retorna um valor randômico para velocidade
randomSpeed = function()
	return math.random(1, 2) / 10 * speedFactor
end

-- Percorre a tabela de objetos e ajusta a velocidade de cada um
calculateNewVelocity = function(objTable)
	for _, object in pairs(objTable) do
		object.xVelocity = object.xVelocity * speedFactor
		object.yVelocity = object.yVelocity * speedFactor
	end
end