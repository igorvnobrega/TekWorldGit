extends Area2D
class_name Cama

# Distância máxima (em pixéis) que o jogador pode estar para conseguir usar a cama
@export var distancia_maxima_interacao: float = 120.0

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# 1. Deteta o clique esquerdo do rato
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# 2. Procura o jogador na cena para medir a distância
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador:
			var distancia = global_position.distance_to(jogador.global_position)
			
			if distancia <= distancia_maxima_interacao:
				get_viewport().set_input_as_handled()
				usar_cama()
			else:
				print("❌ Demasiado longe para descansar!")
		else:
			print("⚠️ Alerta: Garante que o teu nó do Jogador está no grupo chamado 'Jogador'!")

func usar_cama() -> void:
	print("Cama: O jogador deitou-se para dormir...")
	
	# 1. Chamar a função de recarregar que já tens no DadosDoJogo!
	DadosDoJogo.recarregar_energia_total()
	
	# 2. 🪄 EFEITO VISUAL: Fazer a tela piscar (Fade to Black) para simular o tempo a passar
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.5), 0.4) # Escurece (noite)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.4) # Clareia (dia)
		# 2. 🌟 O GATILHO QUE FALTAVA: Faz o relógio global avançar 1 dia!
	DadosDoJogo.avancar_dia()
	
	# 3. (Opcional) Podes adicionar aqui um efeito visual, como escurecer o ecrã
	# com um Tween para simular a noite a passar!
	print("🌞 Bom dia! Energia recuperada e calendário atualizado.")
