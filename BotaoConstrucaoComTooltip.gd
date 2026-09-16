extends Button

# Aqui vamos arrastar a cena visual que criámos no Passo 1
@export var cena_tooltip: PackedScene

# Aqui vamos escrever o ID da máquina no Inspector (ex: "fabrica_flores")
@export var id_maquina: String = ""


# Esta função roda SOZINHA no Godot sempre que o rato passa por cima do botão!
func _make_custom_tooltip(for_text: String) -> Object:
	if id_maquina == "" or not id_maquina in DadosDoJogo.dados_construcao:
		return null
	if not cena_tooltip:
		return null
		
	var tooltip_instancia = cena_tooltip.instantiate()
	var container_lista = tooltip_instancia.get_node("ListaCustos") as VBoxContainer
	var dados = DadosDoJogo.dados_construcao[id_maquina]
	
	# --- SEÇÃO 1: CUSTO DE CONSTRUÇÃO ---
	gerar_titulo_seccao(container_lista, "Custo:")
	if dados.has("custos") and dados["custos"] is Dictionary:
		for recurso in dados["custos"]:
			gerar_linha_de_custo(container_lista, recurso, dados["custos"][recurso], "", Color.WHITE)
			
	# --- SEÇÃO 2: CONSUMO E PRODUÇÃO (UNIFICADOS EM CONSUMPTION) ---
	var tem_input = dados.has("input") and dados["input"] is Dictionary and not dados["input"].is_empty()
	var tem_output = dados.has("output") and dados["output"] is Dictionary and not dados["output"].is_empty()
	
	if tem_input or tem_output:
		gerar_titulo_seccao(container_lista, "Consumption:")
		
		# 🔴 Inputs com "-" Vermelho
		if tem_input:
			for recurso in dados["input"]:
				gerar_linha_de_custo(container_lista, recurso, dados["input"][recurso], "- ", Color(1.0, 0.3, 0.3))
				
		# 🟢 Outputs com "+" Verde
		if tem_output:
			for recurso in dados["output"]:
				gerar_linha_de_custo(container_lista, recurso, dados["output"][recurso], "+ ", Color(0.3, 1.0, 0.3))

	# ==========================================================
	# 🧹 TRUQUE DO PAI NATIVO DO GODOT 4 (Limpa a Sombra do Sistema)
	# ==========================================================
	# Conectamos uma função temporária que roda assim que a tooltip nasce no ecrã.
	# Ela vai buscar o Painel invisível do Godot (o pai) e desativa o fundo dele!
	tooltip_instancia.tree_entered.connect(func():
		var popup_pai = tooltip_instancia.get_parent()
		if popup_pai and popup_pai is PopupPanel:
			var estilo_invisivel = StyleBoxEmpty.new()
			popup_pai.add_theme_stylebox_override("panel", estilo_invisivel)
	)

	return tooltip_instancia

# Função auxiliar para criar títulos bonitos das seções dentro da tooltip
# ==========================================================
# 🛠️ FUNÇÕES AUXILIARES DE SUPORTE (Garante que aceitam os 5 argumentos!)
# ==========================================================

func gerar_titulo_seccao(container_pai: VBoxContainer, texto_titulo: String) -> void:
	var label = Label.new()
	label.text = texto_titulo
	
	var minha_fonte = load("res://Fonts/m5x7.ttf") # Ajusta para o teu caminho real!
	if minha_fonte:
		label.add_theme_font_override("font", minha_fonte)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color.GOLD)
		label.add_theme_constant_override("h_separation", 0)
		label.add_theme_constant_override("v_separation", 0)
	container_pai.add_child(label)
	

# 🌟 GARANTE QUE ESTA LINHA TEM EXATAMENTE ESTES 5 ARGUMENTOS DECORADOS:
func gerar_linha_de_custo(container_pai: VBoxContainer, nome_recurso: String, qtd: int, sinal_prefixo: String, cor_texto: Color) -> void:
	var linha = HBoxContainer.new()
	linha.add_theme_constant_override("h_separation", 0)
	linha.add_theme_constant_override("v_separation", 0)
	var icone = TextureRect.new()
	icone.custom_minimum_size = Vector2(16, 16)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if DadosDoJogo.has_method("get_icone_do_recurso"):
		icone.texture = DadosDoJogo.get_icone_do_recurso(nome_recurso)
	
	var label = Label.new()
	
	# Puxa o nome traduzido e limpo (ex: "Óleo Vegetal")
	var nome_exibicao = nome_recurso
	if DadosDoJogo.has_method("obter_nome_real_do_recurso"):
		nome_exibicao = DadosDoJogo.obter_nome_real_do_recurso(nome_recurso)
	else:
		nome_exibicao = nome_recurso.capitalize().replace("_", " ")
		
	# Junta o prefixo: Concatena o "- " ou "+ " antes do texto do material
	label.text = sinal_prefixo + nome_exibicao + " x" + str(qtd)
	
	var minha_fonte = load("res://Fonts/m5x7.ttf") # Ajusta para o teu caminho!
	if minha_fonte:
		label.add_theme_font_override("font", minha_fonte)
		label.add_theme_font_size_override("font_size", 16) 
		
	# Aplica a cor customizada (Branco para custo, Vermelho para consumo, Verde para produção)
	label.add_theme_color_override("font_color", cor_texto)
	
	label.custom_minimum_size.y = 16
	linha.custom_minimum_size.y = 16
	
	linha.add_child(icone)
	linha.add_child(label)
	container_pai.add_child(linha)
