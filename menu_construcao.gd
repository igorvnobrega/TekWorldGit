# MenuConstrucao.gd
extends CanvasLayer # 🌟 Atualizado para CanvasLayer porque agora controla a UI toda!

# Faz as ligações diretas aos dois painéis caso precises de os controlar
@onready var menu_sementes: VBoxContainer = $MenuSementes
@onready var menu_construcao: HBoxContainer = $MenuConstrucao


func _ready() -> void:
	# ==========================================================
	# 🛠️ 1. LIGAÇÃO DOS BOTÕES DE MÁQUINAS (Dentro do MenuConstrucao)
	# ==========================================================
	if has_node("MenuConstrucao/BotaoFabrica"):
		$MenuConstrucao/BotaoFabrica.pressed.connect(_on_botao_fabrica_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoFabrica dentro do MenuConstrucao!")
		
	if has_node("MenuConstrucao/BotaoOleo"):
		$MenuConstrucao/BotaoOleo.pressed.connect(_on_botao_oleo_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoOleo dentro do MenuConstrucao!")
		
	if has_node("MenuConstrucao/BotaoSolar"):
		$MenuConstrucao/BotaoSolar.pressed.connect(_on_botao_solar_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoSolar dentro do MenuConstrucao!")

	# ==========================================================
	# 🌱 2. LIGAÇÃO DOS BOTÕES DE SEMENTES (Dentro do MenuSementes)
	# ==========================================================
	if has_node("MenuSementes/BotaoFlor"):
		$MenuSementes/BotaoFlor.pressed.connect(_on_botao_flor_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoFlor dentro do MenuSementes!")
		
	if has_node("MenuSementes/BotaoTreeOak"):
		$MenuSementes/BotaoTreeOak.pressed.connect(_on_botao_tree_oak_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoTreeOak dentro do MenuSementes!")
		
		
	# Garante que ambos os menus começam bem visíveis no ecrã nas suas posições originais
	menu_sementes.visible = true
	menu_construcao.visible = true
func _on_botao_fabrica_pressed() -> void:
	print("Menu UI: Botão da Fábrica foi clicado!") # 🌟 Isto vai ajudar a testar na Consola!
	
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao("fabrica_flores")
	else:
		print("ERRO: Não encontrou o Jogador ou o Jogador não tem a função entrar_modo_construcao!")

func _on_botao_solar_pressed() -> void:
	print("Menu UI: Botão solar panel foi clicado!") # 🌟 Isto vai ajudar a testar na Consola!
	
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao("solar_panel")
	else:
		print("ERRO: Não encontrou o Jogador ou o Jogador não tem a função entrar_modo_construcao!")
		
func _on_botao_oleo_pressed() -> void:
	print("Menu UI: Botão da Fábrica foi clicado!") # 🌟 Isto vai ajudar a testar na Consola!
	
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao("prensa_oleo")
	else:
		print("ERRO: Não encontrou o Jogador ou o Jogador não tem a função entrar_modo_construcao!")
		
# Quando clicas no BotaoFlor
func _on_botao_flor_pressed() -> void:
	if DadosDoJogo.inventario_global["semente"] > 0:
		DadosDoJogo.item_selecionado = "semente"
		DadosDoJogo.modo_plantacao_ativo = true
		print("🌱 Flor amarela selecionada! Clica na relva para plantar.")
	else:
		print("❌ Não tens sementes comuns suficientes!")

# Quando clicas no BotaoTreeOak
func _on_botao_tree_oak_pressed() -> void:
	if DadosDoJogo.inventario_global["semente_tree_oak"] > 0:
		DadosDoJogo.item_selecionado = "semente_tree_oak"
		DadosDoJogo.modo_plantacao_ativo = true
		print("🌳 Carvalho selecionado! Clica na relva para plantar.")
	else:
		print("❌ Não tens sementes de carvalho suficientes!")
		
func enviar_ordem_construcao(id_maquina: String) -> void:
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao(id_maquina)
