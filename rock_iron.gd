extends Area2D
class_name PedraFerroRecurso

enum Estado { INTEIRA, RACHADA, QUASE_DESTRUIDA }
var estado_atual: Estado = Estado.INTEIRA

@onready var sprite: Sprite2D = $Sprite2D
@export var distancia_maxima_interacao: float = 200.0

func _ready() -> void:
	# Garante que começa grande (Frame 0)
	atualizar_visual()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador:
			# Lemos as posições globais brutas do mundo
			var distancia = global_position.distance_to(jogador.global_position)
			
			if distancia <= distancia_maxima_interacao:
				viewport.set_input_as_handled()
				colher()
			else:
				print("❌ Precisas de te aproximar desta pedra! Distância: ", distancia)

func colher() -> void:
	# 🌟 AGORA APONTAMOS PARA A MOCHILA TEMPORÁRIA!
	var mochila = DadosDoJogo.mochila_expedicao
	
	# 1. Dá os recursos à mochila em vez do inventário global
	mochila["ferro"] += 1
	
	# ⚠️ NOTA DE UI: Como o teu PainelTop atual lê o 'inventario_global',
	# os números no ecrã não vão subir enquanto minas (o que faz sentido, estão na mochila!).
	# Se quiseres ver os números da mochila a subir na UI da mina, 
	# criaremos depois um sinal específico como 'recurso_mochila_alterado'.
	
	print("⛏️ Picaste a ferro! Tens ", mochila["ferro"], " na mochila.")

	# 2. Avança o estado baseado no clique (código de ifs/elifs que já tens...)
	if estado_atual == Estado.INTEIRA:
		estado_atual = Estado.RACHADA
		atualizar_visual()
	elif estado_atual == Estado.RACHADA:
		estado_atual = Estado.QUASE_DESTRUIDA
		atualizar_visual()
	elif estado_atual == Estado.QUASE_DESTRUIDA:
		if randf() <= 0.20:
			mochila["cristal"] += 1
			print("✨ cristal guardada na mochila!")
			
		print("💥 A pedra foi completamente destruída!")
		queue_free()


func atualizar_visual() -> void:
	match estado_atual:
		Estado.INTEIRA:
			sprite.frame = 0 # Pedra inteira e grande
		Estado.RACHADA:
			sprite.frame = 1 # Pedra com rachas (média)
		Estado.QUASE_DESTRUIDA:
			sprite.frame = 2 # Apenas um pedaço pequeno de pedra
