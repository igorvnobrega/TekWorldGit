extends Control

# Ligamos os botões ligando os sinais "pressed" no editor a estas funções:

func _on_bot_mina_pedra_pressed() -> void:
	# 🪨 Configuração para a Mina de Pedra Inicial
	var custo_energia = 20.0
	var custo_oleo = 5.0
	
	if validar_e_cobrar(custo_energia, custo_oleo):
		# Avisa a base de dados que o gerador deve desenhar o mapa inicial
		DadosDoJogo.expedicao_atual_selecionada = "mina_inicial"
		viajar()

func _on_bot_caverna_ferro_pressed() -> void:
	# ⛓️ Configuração para a Caverna de Ferro (Mais cara!)
	var custo_energia = 40.0
	var custo_oleo = 15.0
	
	if validar_e_cobrar(custo_energia, custo_oleo):
		# Avisa a base de dados que o gerador deve desenhar o segundo mapa
		DadosDoJogo.expedicao_atual_selecionada = "caverna_profunda"
		viajar()

func _on_bot_fechar_pressed() -> void:
	# Apenas fecha a janela se o jogador clicar no "X"
	visible = false

# 🛠️ FUNÇÃO AUXILIAR: Verifica o inventário global e faz a cobrança
func validar_e_cobrar(energia: float, oleo: float) -> bool:
	var inv = DadosDoJogo.inventario_global
	
	if DadosDoJogo.energia_atual >= energia and inv["oleo_vegetal"] >= oleo:
		# Deduz as taxas
		DadosDoJogo.energia_atual -= energia
		inv["oleo_vegetal"] -= oleo
		
		# Emite os sinais para atualizar os números azuis no teu painel do topo
		DadosDoJogo.energia_alterada.emit(DadosDoJogo.energia_atual, DadosDoJogo.energia_maxima)
		DadosDoJogo.recurso_alterado.emit("oleo_vegetal", inv["oleo_vegetal"])
		return true
	else:
		print("❌ Recursos insuficientes! Precisas de ", energia, " Energia e ", oleo, " Óleo.")
		return false

# 🛠️ FUNÇÃO AUXILIAR: Esconde o menu e ativa a transição de sub-cenas do Mundo
func viajar() -> void:
	visible = false # Esconde o menu pop-up do ecrã
	
	# Procura o teu nó raiz do Mundo para fazer a troca dos mapas
	var mundo = get_tree().get_first_node_in_group("Mundo")
	if mundo and mundo.has_method("viajar_para_expedicao"):
		mundo.viajar_para_expedicao()
