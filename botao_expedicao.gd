extends Button

# Custo fixo para abrir o portal de expedição
const CUSTO_ENERGIA = 20.0
const CUSTO_OLEO = 5.0

func _pressed() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# 1. VALIDAÇÃO: O jogador tem recursos suficientes?
	if DadosDoJogo.energia_atual >= CUSTO_ENERGIA and inv["oleo_vegetal"] >= CUSTO_OLEO:
		
		# 2. COBRANÇA: Retira os recursos do inventário
		DadosDoJogo.energia_atual -= CUSTO_ENERGIA
		inv["oleo_vegetal"] -= CUSTO_OLEO
		
		# Atualiza a UI emitindo os sinais correspondentes
		DadosDoJogo.energia_alterada.emit(DadosDoJogo.energia_atual, DadosDoJogo.energia_maxima)
		DadosDoJogo.recurso_alterado.emit("oleo_vegetal", inv["oleo_vegetal"])
		
		print("🚪 Portal aberto! Recursos consumidos. A viajar...")
		
		# 3. Dispara um sinal para o script do Mundo tratar da troca de mapas
		var mundo = get_tree().get_first_node_in_group("Mundo")
		if mundo and mundo.has_method("viajar_para_expedicao"):
			mundo.viajar_para_expedicao()
	else:
		print("❌ Recursos insuficientes! Precisas de 20 de Energia e 5 de Óleo Vegetal.")
