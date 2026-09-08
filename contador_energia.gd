# ContadorEnergia.gd
extends Label

func _ready() -> void:
	# 1. Configura o texto inicial assim que o jogo começa
	atualizar_texto(DadosDoJogo.energia_atual, DadosDoJogo.energia_maxima)
	
	# 2. Conecta o sinal global para "ouvir" sempre que gastas energia
	DadosDoJogo.energia_alterada.connect(_on_energia_alterada)

func _on_energia_alterada(nova_energia: float, max_energia: float) -> void:
	# Quando o sinal é disparado, atualizamos o texto no ecrã
	atualizar_texto(nova_energia, max_energia)

func atualizar_texto(atual: float, maxima: float) -> void:
	text = "⚡ Energia: " + str(int(atual)) + " / " + str(int(maxima))
	
	# Se a energia for crítica (menos de 10), o texto fica vermelho!
	if atual <= 10.0:
		modulate = Color(1.0, 0.3, 0.3) # Vermelho suave
	else:
		modulate = Color(1.0, 1.0, 1.0) # Branco normal
