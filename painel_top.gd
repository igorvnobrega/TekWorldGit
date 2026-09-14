# PainelTop.gd
extends GridContainer

# 🟢 SOLUÇÃO: Removemos a tipagem rígida para o Godot aceitar os nós de forma livre e sem erros de cache!
@onready var label_flores = $LabelFlores
@onready var label_sementes = $LabelSementes
@onready var label_oleo = $LabelOleo
@onready var label_eletricidade = $LabelEletricidade  # 🌟 Limpa o erro da linha 68!
@onready var label_energia = $LabelEnergia
@onready var label_madeira_oak = $LabelMadeiraOak
@onready var label_sapling_oak = $LabelTreeSapling
@onready var label_pedra = $LabelPedra
@onready var label_cristal = $LabelCristal
@onready var label_string = $LabelString
@onready var label_plant_string = $LabelPlantString
#@onready var label_ = $Label
@onready var label_charcoal = $LabelCharcoal
@onready var label_seed_string = $LabelSeedString
@onready var label_oak_plank = $LabelOakPlank
@onready var label_ore_iron = $LabelOreIron
@onready var label_ingot_iron = $LabelIngotIron
#@onready var label_ = $Label

const IMG_MADEIRA = "[img width=16 height=16]res://icones/Icon_wood.png[/img] "
const IMG_TREE_SAPLING = "[img width=16 height=16]res://icones/icon_tree_sapling.png[/img] "
const IMG_ENERGIA = "[img width=16 height=16]res://icones/icon_energia.png[/img] "
const IMG_ELECTRICIDADE = "[img width=16 height=16]res://icones/icon_electricidade.png[/img] "
const IMG_VEG_OIL = "[img width=16 height=16]res://icones/icon_vOil.png[/img] "
const IMG_SEED = "[img width=16 height=16]res://icones/icon_seed.png[/img] "
const IMG_FLOWER = "[img width=16 height=16]res://icones/icon_Flower.png[/img] "
const IMG_PEDRA = "[img width=16 height=16]res://icones/icon_stone.png[/img] "
const IMG_CRISTAL = "[img width=16 height=16]res://icones/icon_crystal.png[/img] "
const IMG_STRING = "[img width=16 height=16]res://icones/IconString.png[/img] "
const IMG_PLANT_STRING = "[img width=16 height=16]res://icones/IconPlantString.png[/img] "
const IMG_CHARCOAL = "[img width=16 height=16]res://icones/IconCharcoal.png[/img] "
const IMG_SEED_STRING = "[img width=16 height=16]res://icones/icon_string_seed.png[/img] "
const IMG_OAK_PLANK = "[img width=16 height=16]res://icones/IconPlank.png[/img] "
const IMG_ORE_IRON = "[img width=16 height=16]res://icones/IconIronOre.png[/img] "
const IMG_INGOT_IRON = "[img width=16 height=16]res://icones/IconIronIngot.png[/img] "
#const IMG_ = "[img width=16 height=16]res://icones/Icon.png[/img] "
#const IMG_ = "[img width=16 height=16]res://icones/Icon.png[/img] "
#const IMG_ = "[img width=16 height=16]res://icones/Icon.png[/img] "


func _ready() -> void:
	# 1. Atualiza os textos com os valores que começam no DadosDoJogo
	atualizar_todos_os_valores()
	
	# 2. Conecta o sinal global para atualizar a UI sempre que algum recurso mudar
	DadosDoJogo.recurso_alterado.connect(_on_recurso_alterado)
	
	# 3. 🌟 Conecta o teu sinal específico de energia!
	DadosDoJogo.energia_alterada.connect(_on_energia_alterada)
	
	# 4. 📦 Organiza as labels dentro das caixas pretas automáticas!
	organizar_recursos_em_caixas()


func organizar_recursos_em_caixas() -> void:
	# 🌟 CORREÇÃO DE SEPARAÇÃO: Remove as linhas antigas de margin_left/right que não funcionavam aqui
	add_theme_constant_override("h_separation", 0) 
	add_theme_constant_override("v_separation", 0)

	# 1. Criamos o estilo da caixa (fundo transparente com bordas pretas de 1px)
	var estilo_caixa = StyleBoxFlat.new()
	estilo_caixa.bg_color = Color(0, 0, 0, 0) # Fundo transparente
	
	estilo_caixa.set_border_width_all(1)
	estilo_caixa.border_color = Color.GRAY # A cor preta das tuas linhas
		# 🌟 ADICIONA ESTAS LINHAS PARA ARREDONDAR OS CANTOS:
	# Define o raio em píxeis para cada um dos 4 cantos (Top Left, Top Right, Bottom Right, Bottom Left)
	estilo_caixa.set_corner_radius_all(3) 
	# 🌟 AJUSTE CRÍTICO DE MARGEM: Aumentamos ligeiramente a margem esquerda e direita 
	# das caixas para garantir que nenhum ícone toca ou fica cortado pela borda do ecrã!
	estilo_caixa.content_margin_left = 1   # Aumentado de 6 para 10 (empurra o 1º ícone para a direita)
	estilo_caixa.content_margin_right = 1 # Aumentado de 6 para 10
	estilo_caixa.content_margin_top = 1
	estilo_caixa.content_margin_bottom = 1
	
	# 2. Guardamos as tuas labels originais de recursos
	var labels = get_children()
	
	# 3. Removemos temporariamente para as envelopar nas caixas
	for child in labels:
		remove_child(child)
		
	# 4. Colocamos cada recurso dentro do seu próprio PanelContainer (Caixa)
	for i in range(labels.size()):
		var caixa = PanelContainer.new()
		caixa.add_theme_stylebox_override("panel", estilo_caixa)
		
		# 🌟 CORREÇÃO AQUI: Removemos o SIZE_EXPAND!
		# Ao usar apenas SIZE_FILL, a caixa encolhe até "abraçar" o conteúdo de forma justa.
		caixa.size_flags_horizontal = Control.SIZE_FILL
		caixa.size_flags_vertical = Control.SIZE_FILL
		
		# Adiciona a tua label como filha da caixa, e a caixa como filha do topo
		caixa.add_child(labels[i])
		add_child(caixa)
			
func atualizar_todos_os_valores() -> void:
	var inv = DadosDoJogo.inventario_global
	
	label_flores.text = IMG_FLOWER + str(inv["flor_amarela"])
	label_flores.tooltip_text = "Flower"
	
	
	label_sementes.text = IMG_SEED + str(inv["semente"])
	label_sementes.tooltip_text = "Seeds"
	
	label_oleo.text = IMG_VEG_OIL + str(int(inv["oleo_vegetal"]))
	label_oleo.tooltip_text = "Oleo Vegetal"
	
	label_eletricidade.text = IMG_ELECTRICIDADE + str(int(inv["eletricidade"]))
	label_eletricidade.tooltip_text = "Electricidade"
	
	label_madeira_oak.text = IMG_MADEIRA + str(int(inv["madeira_oak"]))
	label_madeira_oak.tooltip_text = "Madeira"
	
	label_sapling_oak.text = IMG_TREE_SAPLING + str(int(inv["semente_tree_oak"]))
	label_sapling_oak.tooltip_text = "Oak Sapling"
	
	label_cristal.text = IMG_CRISTAL + str(int(inv["cristal"]))
	label_cristal.tooltip_text = "Cristal"
	
	label_pedra.text = IMG_PEDRA + str(int(inv["pedra"]))
	label_pedra.tooltip_text = "Pedra"
	
	label_string.text = IMG_STRING + str(int(inv["string"]))
	label_string.tooltip_text = "String"
	
	label_plant_string.text = IMG_PLANT_STRING + str(int(inv["plant_string"]))
	label_plant_string.tooltip_text = "Fiber"
	
	label_charcoal.text = IMG_CHARCOAL + str(int(inv["charcoal"]))
	label_charcoal.tooltip_text = "Charcoal"
		
	label_seed_string.text = IMG_SEED_STRING + str(int(inv["seed_string"]))
	label_seed_string.tooltip_text = "Fiber Seeds"	
	
	label_oak_plank.text = IMG_OAK_PLANK + str(int(inv["oak_plank"]))
	label_oak_plank.tooltip_text = "Oak Plank"	
	
	label_ore_iron.text = IMG_ORE_IRON + str(int(inv["ore_iron"]))
	label_ore_iron.tooltip_text = "Iron Ore"
		
	label_ingot_iron.text = IMG_INGOT_IRON + str(int(inv["ingot_iron"]))
	label_ingot_iron.tooltip_text = "Iron Ingot"	
	
	
		#label_.text = IMG_ + str(int(inv[""]))
	#label_.tooltip_text = ""	
		#label_.text = IMG_ + str(int(inv[""]))
	#label_.tooltip_text = ""	
		#label_.text = IMG_ + str(int(inv[""]))
	#label_.tooltip_text = ""	
	
	
	
	# 🌟 Mostra o valor inicial da energia assim que o jogo começa
	label_energia.text = IMG_ENERGIA + str(int(DadosDoJogo.energia_atual)) + "/" + str(int(DadosDoJogo.energia_maxima))
	label_energia.tooltip_text = "Energia"
		
# 🌟 Esta nova função vai correr sempre que a tua energia mudar (quando gastas ou quando usas a cama!)
func _on_energia_alterada(atual: float, maxima: float) -> void:
	label_energia.text = IMG_ENERGIA + str(int(atual)) + "/" + str(int(maxima))
	
	
func _on_recurso_alterado(nome_recurso: String, novo_valor: int) -> void:
	# Quando o sinal global avisa que algo mudou, atualizamos apenas o texto correto
	match nome_recurso:
		"flor_amarela":
			label_flores.text = IMG_FLOWER + str(novo_valor)
		"semente":
			label_sementes.text = IMG_SEED + str(novo_valor)
		"oleo_vegetal":
			label_oleo.text = IMG_VEG_OIL + str(int(novo_valor))
		"eletricidade":
			label_eletricidade.text = IMG_ELECTRICIDADE + str(int(novo_valor))
		# 🌟 Adiciona este bloco para atualizar o texto no exato momento em que gastas energia ou usas a cama:
		"energia":
			label_energia.text = IMG_ENERGIA + str(novo_valor)
		"madeira_oak":
			label_madeira_oak.text = IMG_MADEIRA + str(novo_valor)
		"semente_tree_oak":
			label_sapling_oak.text = IMG_TREE_SAPLING + str(novo_valor)
		"pedra":
			label_pedra.text = IMG_PEDRA + str(novo_valor)
		"cristal":
			label_cristal.text = IMG_CRISTAL + str(novo_valor)
		"string":
			label_string.text = IMG_STRING + str(novo_valor)
		"plant_string":
			label_plant_string.text = IMG_PLANT_STRING + str(novo_valor)
		"charcoal":
			label_charcoal.text = IMG_CHARCOAL + str(novo_valor)
						
		"seed_string":
			label_seed_string.text = IMG_SEED_STRING + str(novo_valor)
						
		"oak_plank":
			label_oak_plank.text = IMG_OAK_PLANK + str(novo_valor)
						
		"ore_iron":
			label_ore_iron.text = IMG_ORE_IRON + str(novo_valor)
						
		"ingot_iron":
			label_ingot_iron.text = IMG_INGOT_IRON + str(novo_valor)
			#"":
			#label_.text = IMG_ + str(novo_valor)
			#"":
			#label_.text = IMG_ + str(novo_valor)
			#"":
			#label_.text = IMG_ + str(novo_valor)
			#"":
			#label_.text = IMG_ + str(novo_valor)
						
