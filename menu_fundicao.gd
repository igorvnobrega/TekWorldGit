extends Control

# Referência ao nó dropdown do editor
@onready var seletor: OptionButton = $SeletorReceitas

# Guarda a máquina que está aberta neste momento
var maquina_alvo: Node2D = null

# Lista interna para converter o número da linha selecionada de volta para Texto
var ID_LINHAS = ["nenhuma", "ingot_iron", "cobre", "ouro", "fechar"]

func _ready() -> void:
	# 🌟 GARANTIA: Fecha o menu imediatamente quando o jogo começa!
	visible = false
	
	# 1. Configura as opções do dropdown logo no arranque do jogo
	seletor.clear() # Limpa lixo antigo
	seletor.add_item("❌ Nenhuma Selecionada")      # Linha 0
	seletor.add_item("🔥 Iron Ingot (3 Ores)")  # Linha 1
	seletor.add_item("⚡ Barra de Cobre (3 Ores)")  # Linha 2
	seletor.add_item("✨ Barra de Ouro (3 Ores)")   # Linha 3
	seletor.add_item("🚪 Fechar Menu") 
	# 2. Liga o sinal do dropdown a este script automaticamente por código!
	seletor.item_selected.connect(_on_receita_selecionada)

# Dentro de menu_fundicao.gd

func abrir_menu(maquina: Node2D) -> void:
	maquina_alvo = maquina
	visible = true
	
	# 🌟 A MAGIA DA POSIÇÃO FLUTUANTE:
	if is_instance_valid(maquina_alvo):
		# 1. Converte a posição 2D da máquina para a coordenada exata de pixéis do ecrã
		var posicao_ecra = maquina_alvo.get_global_transform_with_canvas().origin
		
		# 2. OPÇÃO A: Abrir no TOPO da máquina
		# Subtraímos no eixo Y (ex: -40 pixéis) para empurrar o menu para cima do desenho da fábrica
		# E subtraímos metade da largura do teu menu no X (ex: -50) para ele ficar bem centrado
		global_position = Vector2(posicao_ecra.x - 50, posicao_ecra.y - 40)
		
		# 3. OPÇÃO B: Se preferires abrir ao LADO DIREITO, usa esta linha em vez da de cima:
		# global_position = Vector2(posicao_ecra.x + 20, posicao_ecra.y - 10)
		
		print("🛠️ Menu da Fundição posicionado dinamicamente em: ", global_position)
		
		# Conforto: sincroniza o dropdown com a receita antiga (teu código atual...)
		var receita_atual = maquina_alvo.receita_atual_id
		var indice = ID_LINHAS.find(receita_atual)
		if indice != -1:
			seletor.select(indice)

# 🌟 A FUNÇÃO MÁGICA: É chamada automaticamente quando clicas numa linha do dropdown!
func _on_receita_selecionada(index: int) -> void:
	# 🌟 SEGREDO 1: Fechamos o menu IMEDIATAMENTE no primeiro milissegundo!
	visible = false
	
	# Segurança: garante que o índice existe no nosso array
	if index < 0 or index >= ID_LINHAS.size():
		return
		
	var id_receita = ID_LINHAS[index]
	
	# 🚪 Se for a opção de fechar, o menu já foi escondido, por isso basta sair
	if id_receita == "fechar":
		return
		
	# 🏭 Se for uma receita válida, tenta aplicar à máquina
	if is_instance_valid(maquina_alvo):
		# Usamos o 'set' por segurança para não quebrar se houver erro de digitação na variável
		maquina_alvo.receita_atual_id = id_receita 
		print("🏭 Fundição configurada para produzir: ", id_receita)

# Botão Fechar normal (Sinal pressed() ligado no editor)
func _on_btn_fechar_pressed() -> void:
	visible = false
