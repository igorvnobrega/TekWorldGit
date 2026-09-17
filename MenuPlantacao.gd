# MenuPlantacao.gd
extends Control # Ajusta para PanelContainer se o teu nó principal for PanelContainer

func _ready() -> void:
	
	# Começa fechado por padrão
	visible = false
	
	# Força tamanhos mínimos em toda a árvore interna para que nada colapse para 0px
	
	
	# Conecta automaticamente todas as sementes que meteste na grelha
	conectar_botoes_da_grelha(get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Sementes/GridSementes"))
	estilizar_barra_scroll()
	
	DadosDoJogo.recurso_alterado.connect(func(_nome, _qtd):
		# 🌟 Se o jogo estiver a fazer Load, ignora o sinal e não corre a função!
		if DadosDoJogo.a_carregar_jogo: 
			return
		if visible:
			atualizar_disponibilidade_sementes()
	)
func conectar_botoes_da_grelha(grelha: GridContainer) -> void:
	if grelha:
		for botao in grelha.get_children():
			if botao is Button:
				botao.pressed.connect(_on_botao_semente_pressed.bind(botao))

# ==========================================================
# 🎯 INTERCEPTOR CENTRAL DE CLIQUES DE SEMENTES
# ==========================================================
func _on_botao_semente_pressed(botao_clicado: Button) -> void:
	if not "id_maquina" in botao_clicado or botao_clicado.id_maquina == "":
		return
		
	var id = botao_clicado.id_maquina
	var inv = DadosDoJogo.inventario_global
	
	# Validamos de forma estrita se o jogador tem a semente clicada no inventário
	if inv.has(id) and inv[id] > 0:
		DadosDoJogo.item_selecionado = id
		DadosDoJogo.modo_plantacao_ativo = true
		print("Menu UI: Semente selecionada para plantação -> ", id)
		
		# Avisa o teu jogador para ativar o fantasma semitransparente
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador and jogador.has_method("entrar_modo_plantacao"):
			jogador.entrar_modo_plantacao()
	else:
		print("❌ Não tens sementes suficientes para equipar!")

# ==========================================================
# 🌫️ CONTROLO VISUAL DE DISPONIBILIDADE (GREYED OUT)
# ==========================================================
func atualizar_disponibilidade_sementes() -> void:
	var inv = DadosDoJogo.inventario_global
	var grelha = get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Sementes/GridSementes")
	
	if grelha:
		for botao in grelha.get_children():
			if botao is Button and "id_maquina" in botao:
				var id = botao.id_maquina
				
				# Se o jogador tiver pelo menos 1 semente, o botão acende, se tiver 0 fica cinzento
				if inv.has(id) and inv[id] > 0:
					botao.modulate = Color(1.0, 1.0, 1.0, 1.0)
					botao.disabled = false
				else:
					botao.modulate = Color(0.35, 0.35, 0.35, 0.7)
					botao.disabled = true

# ==========================================================
# 🪟 FUNÇÃO PARA ABRIR / FECHAR A JANELA (TOOGLE)
# ==========================================================
func alternar_visibilidade_menu() -> void:
	visible = !visible
	if visible:
		print("🪟 Menu de Plantação ABERTO.")
		
		# 🌟 COMENTA temporariamente a linha da posição abaixo para o menu abrir 
		# exatamente no meio do ecrã onde o arrastaste com o rato no editor!
		# position = Vector2(100, -80 - 32)
		
		# Atualiza as cores e o estado ativo dos botões
		atualizar_disponibilidade_sementes()
		
		# Força o painel de construções a fechar
		var menu_const = get_parent().get_node_or_null("MenuConstrucao")
		if menu_const: 
			menu_const.visible = false
			
		if has_node("JanelaScroll"):
			$JanelaScroll.scroll_horizontal = 0
	else:
		print("🪟 Menu de Plantação FECHADO.")
func estilizar_barra_scroll() -> void:
	var janela_scroll = get_node_or_null("JanelaScroll")
	if janela_scroll:
		janela_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		var h_scrollbar = janela_scroll.get_h_scroll_bar()
		h_scrollbar.custom_minimum_size.y = 4
		
		var estilo_botao = StyleBoxFlat.new()
		estilo_botao.bg_color = Color(0.4, 0.4, 0.4)
		estilo_botao.set_corner_radius_all(2)
		h_scrollbar.add_theme_stylebox_override("grabber", estilo_botao)
		h_scrollbar.add_theme_stylebox_override("grabber_highlight", estilo_botao)
		
		var estilo_trilho = StyleBoxFlat.new()
		estilo_trilho.bg_color = Color(0.15, 0.15, 0.15)
		estilo_trilho.set_corner_radius_all(2)
		h_scrollbar.add_theme_stylebox_override("scroll", estilo_trilho)
		
		janela_scroll.add_theme_constant_override("scrollbar_thickness", 4)



func _on_botao_plant_principal_pressed() -> void:
	alternar_visibilidade_menu()
