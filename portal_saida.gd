extends Area2D
class_name PortalSaida

# Distância máxima em pixéis para o jogador conseguir interagir
@export var distancia_maxima_interacao: float = 120.0

func _ready() -> void:
	# Conecta o sinal de input_event a este próprio script por código por segurança!
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador:
			var distancia = global_position.distance_to(jogador.global_position)
			
			# 🌟 DEBUG: Mostra no painel a distância real calculada pelo motor
			print("🔍 Posição Portal: ", global_position, " | Posição Jogador: ", jogador.global_position)
			print("📏 Distância calculada pelo Godot: ", distancia, " pixéis. (Máximo permitido: ", distancia_maxima_interacao, ")")
			
			if distancia <= distancia_maxima_interacao:
				get_viewport().set_input_as_handled()
				voltar_para_base()
			else:
				print("❌ Precisas de te aproximar da escada para conseguir subir!")

func voltar_para_base() -> void:
	print("🧗 A subir a escada... A transferir os recursos da mochila para a base!")
	
	# 🌟 A MAGIA ACONTECE AQUI: 
	# Pega em tudo o que minaste e soma definitivamente ao teu inventário real!
	DadosDoJogo.descarregar_mochila_na_base()
	
	# 3. Comunica com o gestor do Mundo para desligar o mapa da mina
	var mundo = get_tree().get_first_node_in_group("Mundo")
	if mundo and mundo.has_method("voltar_para_a_base"):
		mundo.voltar_para_a_base()
	else:
		print("⚠️ Erro: Não encontrei o nó do Mundo no grupo 'Mundo' para regressar.")
