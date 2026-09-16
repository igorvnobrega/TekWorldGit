# MenuConstrucao.gd
extends PanelContainer # Ou PanelContainer, dependendo do tipo do teu nó principal MenuConstrucao

func _ready() -> void:
	
		# 🌟 FORÇA O MENU A COMEÇAR FECHADO
	visible = false
	# ==========================================================
	# 🤖 LIGAÇÃO AUTOMÁTICA EM MÚLTIPLAS GRELHAS DE TIERS
	# ==========================================================
	# O código vai procurar e conectar todos os botões dentro das respetivas grelhas
	conectar_botoes_da_grelha(get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier1/GridTier1"))
	conectar_botoes_da_grelha(get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier2/GridTier2"))
	conectar_botoes_da_grelha(get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier3/GridTier3"))
# ==========================================================
	# 🎨 ESTILIZAR A BARRA DE SCROLL (HORIZONTAL SCROLLBAR)
	# ==========================================================
	var janela_scroll = get_node_or_null("JanelaScroll")
	if janela_scroll:
		# 🌟 TRUQUE DA VISIBILIDADE: Força o modo de exibição sempre ativo
		janela_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		
		# Vamos buscar a barra horizontal interna
		var h_scrollbar = janela_scroll.get_h_scroll_bar()
		
		# 🌟 FORÇAR A BARRA A REAPARECER (Tamanho Mínimo)
		# Se a barra estiver com 0px de altura por causa de algum bug de layout, 
		# forçamos a barra a ter 4 píxeis de altura mínima para saltar à vista!
		h_scrollbar.custom_minimum_size.y = 4
		
		# 2. Criamos o estilo para o "Grabber" (o botão cinzento que desliza)
		var estilo_botao = StyleBoxFlat.new()
		estilo_botao.bg_color = Color(0.4, 0.4, 0.4) # Cinzento um pouco mais claro para se ver bem
		estilo_botao.set_corner_radius_all(2)
		
		h_scrollbar.add_theme_stylebox_override("grabber", estilo_botao)
		h_scrollbar.add_theme_stylebox_override("grabber_highlight", estilo_botao)
		
		# 3. Criamos o estilo para o "Scroll" (o trilho/fundo)
		var estilo_trilho = StyleBoxFlat.new()
		estilo_trilho.bg_color = Color(0.15, 0.15, 0.15) # Fundo escuro para contrastar
		estilo_trilho.set_corner_radius_all(2)
		h_scrollbar.add_theme_stylebox_override("scroll", estilo_trilho)
		
		# 4. 📏 DEFINIR A ESPESSURA NO CONTAINER
		janela_scroll.add_theme_constant_override("scrollbar_thickness", 4)
		
		# 🌟 MARGEM DE SEGURANÇA: Se o teu contentor estiver a cortar o fundo,
		# adicionamos uma margem extra na base da ListaDeTiers para a barra ter espaço para nascer!
		var lista_tiers = get_node_or_null("JanelaScroll/ListaDeTiers")
		if lista_tiers:
			# Dá 6 píxeis de "ar" abaixo dos botões para a barra não ficar sobreposta a eles
			lista_tiers.custom_minimum_size.y = lista_tiers.get_minimum_size().y + 6
			
			
			
	# 🌟 ADICIONA ESTA LINHA NO FIM DO _READY:
	# Sempre que o inventário global mudar, o menu atualiza os botões sozinho!
	DadosDoJogo.recurso_alterado.connect(func(_nome, _qtd): 
		if visible: 
			atualizar_disponibilidade_botoes() )
			
# Função auxiliar para conectar os cliques de forma automática
func conectar_botoes_da_grelha(grelha: GridContainer) -> void:
	if grelha:
		for botao in grelha.get_children():
			if botao is Button:
				# Liga o clique à nossa função central inteligente
				botao.pressed.connect(_on_botao_menu_pressed.bind(botao))

# ==========================================================
# 🎯 INTERCEPTOR CENTRAL DE CLIQUES
# ==========================================================
func _on_botao_menu_pressed(botao_clicado: Button) -> void:
	if not "id_maquina" in botao_clicado or botao_clicado.id_maquina == "":
		print("⚠️ Aviso: Botão sem 'id_maquina' configurado no Inspector: ", botao_clicado.name)
		return
		
	var id = botao_clicado.id_maquina
	var inv = DadosDoJogo.inventario_global

	# Se for uma máquina registada nos dados de construção
	if id in DadosDoJogo.dados_construcao:
		print("Menu UI: Botão de Máquina clicado -> ", id)
		enviar_ordem_construcao(id)
	else:
		print("⚠️ Erro: O ID '", id, "' não foi reconhecido no dados_construcao.")

# ==========================================================
# 📡 ENVIAR ORDENS PARA O JOGADOR
# ==========================================================
func enviar_ordem_construcao(id_maquina: String) -> void:
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao(id_maquina)
	else:
		print("ERRO: Não encontrou o Jogador ou falta a função entrar_modo_construcao!")

# ==========================================================
# 🪟 FUNÇÃO PARA ABRIR / FECHAR A JANELA (TOOGLE)
# ==========================================================
# Esta função vai ser chamada pelo teu botão grande "Build" do HUD principal
func alternar_visibilidade_menu() -> void:
	visible = !visible
	if visible:
		print("🪟 Menu de Construção ABERTO.")
		# 🌟 CHAMA O EFEITO AQUI: Atualiza as cores assim que o painel aparece!
		atualizar_disponibilidade_botoes()
		# Opcional: Garante que faz reset ao scroll para o início ao abrir
		if has_node("JanelaScroll"):
			$JanelaScroll.scroll_horizontal = 0
	else:
		print("🪟 Menu de Construção FECHADO.")


func _on_botao_build_principal_pressed() -> void:
	# Como este código já corre dentro do MenuConstrucao, 
	# basta chamar a função diretamente!
	alternar_visibilidade_menu()
# ==========================================================
# 🌫️ CONTROLO VISUAL DE DISPONIBILIDADE (GREYED OUT)
# ==========================================================
func atualizar_disponibilidade_botoes() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# Criamos uma lista com os caminhos das tuas 3 grelhas de Tiers
	var grelhas = [
		get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier1/GridTier1"),
		get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier2/GridTier2"),
		get_node_or_null("JanelaScroll/ListaDeTiers/Coluna_Tier3/GridTier3")
	]
	
	for grelha in grelhas:
		if not grelha: 
			continue
			
		for botao in grelha.get_children():
			if botao is Button and "id_maquina" in botao:
				var id = botao.id_maquina
				
				# Se o botão for de uma máquina registada nos custos
				if id in DadosDoJogo.dados_construcao:
					var dados = DadosDoJogo.dados_construcao[id]
					var tem_recursos_suficientes = true
					
					# Valida se o jogador tem a quantidade certa de CADA material exigido
					if "custos" in dados and dados["custos"] is Dictionary:
						for recurso in dados["custos"]:
							var qtd_necessaria = dados["custos"][recurso]
							if not recurso in inv or inv[recurso] < qtd_necessaria:
								tem_recursos_suficientes = false
								break # Falhou num recurso, não precisa de testar o resto
					
					# Aplica o efeito visual (Greyed Out) e tranca o botão
					if tem_recursos_suficientes:
						botao.modulate = Color(1.0, 1.0, 1.0, 1.0) # Cor original brilhante
						botao.disabled = false                     # Permite o clique
					else:
						# Escurece o botão a 35% e dá-lhe alguma transparência (0.7)
						botao.modulate = Color(0.35, 0.35, 0.35, 0.7) 
						botao.disabled = true                      # Tranca o clique
