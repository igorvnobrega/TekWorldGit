# MenuConstrucao.gd
extends HBoxContainer 

# 🌟 CORREÇÃO 1: Mantemos apenas o MenuSementes que é teu filho real. 
# Removemos a linha do $MenuConstrucao que crashava o jogo!
@onready var menu_sementes = $MenuSementes

func _ready() -> void:
	# ==========================================================
	# 🛠️ 1. LIGAÇÃO DOS BOTÕES DE MÁQUINAS (Filhos diretos)
	# ==========================================================
	if has_node("BotaoFabrica"):
		$BotaoFabrica.pressed.connect(_on_botao_fabrica_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoFabrica!")
		
	if has_node("BotaoOleo"):
		$BotaoOleo.pressed.connect(_on_botao_oleo_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoOleo!")
		
	if has_node("BotaoSolar"):
		$BotaoSolar.pressed.connect(_on_botao_solar_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoSolar!")

	# ==========================================================
	# 🌱 2. LIGAÇÃO DOS BOTÕES DE SEMENTES (Filhos do MenuSementes interno)
	# ==========================================================
	# 🌟 CORREÇÃO 2: Removida a aspa dupla solta ($") que causava erros de sintaxe
	if has_node("MenuSementes/BotaoFlor"):
		$MenuSementes/BotaoFlor.pressed.connect(_on_botao_flor_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoFlor!")
		
	if has_node("MenuSementes/BotaoTreeOak"):
		$MenuSementes/BotaoTreeOak.pressed.connect(_on_botao_tree_oak_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoTreeOak!")

# ==========================================================
# 🌱 FUNÇÕES DOS BOTÕES DE PLANTAÇÃO
# ==========================================================
func _on_botao_flor_pressed() -> void:
	if DadosDoJogo.inventario_global["semente"] > 0:
		DadosDoJogo.item_selecionado = "semente"
		DadosDoJogo.modo_plantacao_ativo = true
		print("🌱 Flor amarela selecionada para plantar!")
	else:
		print("❌ Não tens sementes comuns suficientes!")

func _on_botao_tree_oak_pressed() -> void:
	if DadosDoJogo.inventario_global["semente_tree_oak"] > 0:
		DadosDoJogo.item_selecionado = "semente_tree_oak"
		DadosDoJogo.modo_plantacao_ativo = true
		print("🌳 Carvalho selecionado para plantar!")
	else:
		print("❌ Não tens sementes de carvalho suficientes!")

# ==========================================================
# 🛠️ FUNÇÕES DOS BOTÕES DE MÁQUINAS
# ==========================================================
func _on_botao_fabrica_pressed() -> void:
	print("Menu UI: Botão da Fábrica foi clicado!")
	enviar_ordem_construcao("fabrica_flores")

func _on_botao_solar_pressed() -> void:
	print("Menu UI: Botão solar panel foi clicado!")
	enviar_ordem_construcao("solar_panel")
		
func _on_botao_oleo_pressed() -> void:
	print("Menu UI: Botão da Prensa de Óleo foi clicado!")
	enviar_ordem_construcao("prensa_oleo")

func enviar_ordem_construcao(id_maquina: String) -> void:
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao(id_maquina)
	else:
		print("ERRO: Não encontrou o Jogador ou o Jogador não tem a função entrar_modo_construcao!")
