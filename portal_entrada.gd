extends Area2D
class_name PortalEntrada

@export var distancia_maxima_interacao: float = 120.0

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador:
			var distancia = global_position.distance_to(jogador.global_position)
			
			if distancia <= distancia_maxima_interacao:
				get_viewport().set_input_as_handled()
				abrir_quadro_viagem()
			else:
				print("❌ Demasiado longe do portão para ver as expedições!")

func abrir_quadro_viagem() -> void:
	# Procura o menu azul escondido no teu CanvasLayer
	# (🌟 Ajusta o caminho de nós se o teu menu estiver dentro de algum sub-container!)
	var menu = get_node_or_null("/root/Mundo/CanvasLayer/MenuExpedicoes")
	
	if menu:
		menu.visible = true
		print("📋 Menu de expedições aberto! Escolhe um destino.")
	else:
		print("⚠️ Erro: Não encontrei o nó 'MenuExpedicoes' no CanvasLayer do Mundo.")
