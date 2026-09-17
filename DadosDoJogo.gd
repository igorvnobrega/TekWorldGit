# DadosDoJogo.gd (Script Global / Autoload)
extends Node

# --- SINAIS ---
signal recurso_alterado(nome_recurso: String, novo_valor: int)
signal energia_alterada(nova_energia: float, energia_maxima: float) # 🌟 Garante que este sinal existe!

var item_selecionado: String = ""
var modo_plantacao_ativo: bool = false

var a_carregar_jogo: bool = false
# --- VARIÁVEIS DE GRELHA ---
var celulas_ocupadas: Dictionary = {}
var esta_a_carregar_save: bool = false
# --- 🌟 VARIÁVEIS DE ENERGIA (As que provavelmente faltavam!) ---
var energia_maxima: float = 100.0
var energia_atual: float = 100.0
# Adiciona esta variável no topo do teu DadosDoJogo.gd (junto às outras variáveis globais):
var ja_esta_a_carregar: bool = false
var esta_carregar_save: bool = false
# ==========================================================
# 🗺️ CONFIGURAÇÕES DAS EXPEDIÇÕES / MINAS PROCEDIMENTAIS
# ==========================================================

# 🌟 A VARIÁVEL QUE FALTA NO TEU ERRO:
var expedicao_atual_selecionada: String = "mina_inicial"

# Dicionário que guarda o tamanho e as probabilidades de cada mapa
var expedicoes = {
	"mina_inicial": {
		"nome": "Mina de Pedra",
		"tamanho_grelha": Vector2i(20, 20),
		"chance_pedra_comum": 0.80,         # 80% de ser pedra normal
		"chance_ferro": 0.20                # 20% de ser ferro
	},
	"caverna_profunda": {
		"nome": "Caverna de Ferro",
		"tamanho_grelha": Vector2i(30, 30),
		"chance_pedra_comum": 0.40,
		"chance_ferro": 0.60
	}
}

# --- VARIÁVEIS DE INVENTÁRIO ---
# --- INVENTÁRIO ATUALIZADO ---
var inventario_global: Dictionary = {
	"flor_amarela": 20,
	"semente": 20,         # 🌟 Começa com algumas sementes para testar
	"oleo_vegetal": 50,     # 🌟 Novo recurso lubrificante
	"eletricidade": 100,     # 🌟 Novo recurso de rede (energia elétrica)
	"semente_tree_oak": 100,
	"madeira_oak": 100,
	"pedra": 0,
	"cristal": 0,
	"ore_iron": 110,
	"string": 0,
	"plant_string": 0,
	"seed_string": 10,
	"oak_plank": 0,
	"charcoal": 0,
	"ingot_iron": 0
	
}

# ==========================================================
# 🗣️ DICIONÁRIO DE TRADUÇÃO DE RECURSOS PARA O JOGADOR
# ==========================================================
func obter_nome_real_do_recurso(id_recurso: String) -> String:
	match id_recurso:
		"madeira_oak":
			return "Madeira Oak"
		"flor_amarela":
			return "Flor Amarela"
		"semente":
			return "Semente Flor"
		"seed_string":
			return "Semente de Fibra"
		"semente_tree_oak":
			return "Semente de Carvalho"
		"oleo_vegetal":
			return "Óleo Vegetal"
		"barra_ferro":
			return "Barra de Ferro"
		"energia":
			return "Energia"
		_:
			# Caso te esqueças de traduzir algum recurso, 
			# o Godot apenas embeleza o texto original como salvaguarda
			return id_recurso.capitalize().replace("_", " ")

# 🎒 A nossa mochila temporária para as expedições
var mochila_expedicao = {
	"pedra": 0,
	"cristal": 0,
	"ore_iron": 0  # Adiciona aqui outros recursos que nasçam na mina
}
# Função chamada quando o jogador escapa com vida pela escada
func descarregar_mochila_na_base() -> void:
	# Passamos os recursos da mochila para o inventário real da base
	for recurso in mochila_expedicao:
		inventario_global[recurso] += mochila_expedicao[recurso]
		# Emitimos o sinal para o teu painel do topo atualizar os novos números azuis!
		recurso_alterado.emit(recurso, inventario_global[recurso])
	
	# Limpamos a mochila para a próxima viagem
	limpar_mochila_expedicao()
	print("💰 Recursos guardados na base com segurança!")

# Função chamada quando o jogador entra na mina ou quando morre
func limpar_mochila_expedicao() -> void:
	for recurso in mochila_expedicao:
		mochila_expedicao[recurso] = 0


# --- FUNÇÕES DE RECURSOS ---
func adicionar_recurso(nome_recurso: String, quantidade: int) -> void:
	if inventario_global.has(nome_recurso):
		inventario_global[nome_recurso] += quantidade
		recurso_alterado.emit(nome_recurso, inventario_global[nome_recurso])

# --- FUNÇÕES DE ENERGIA ---
func gastar_energia(quantidade: float) -> bool:
	if energia_atual >= quantidade:
		energia_atual -= quantidade
		energia_alterada.emit(energia_atual, energia_maxima)
		print("Global: Energia gasta! Atual: ", energia_atual)
		return true # Tinha energia e gastou com sucesso
	else:
		print("Global: Sem energia suficiente!")
		return false # Bloqueia a ação por falta de energia

func recarregar_energia_total() -> void:
	energia_atual = energia_maxima
	energia_alterada.emit(energia_atual, energia_maxima)
	print("Global: Energia totalmente recarregada após o sono!")

# --- FUNÇÕES DE CONTROLO DE CÉLULAS ---
# --- FUNÇÕES DE CONTROLO DE CÉLULAS ATUALIZADAS ---
func esta_celula_livre(coordenada_grelha: Vector2i) -> bool:
	return not celulas_ocupadas.has(coordenada_grelha)

# Agora passamos o ID do objeto (ex: "fabrica_flores" ou "semente") em vez de um booleano!
func definir_ocupacao_celula(coordenada_grelha: Vector2i, id_objeto: String) -> void:
	if id_objeto != "":
		celulas_ocupadas[coordenada_grelha] = id_objeto
	else:
		if celulas_ocupadas.has(coordenada_grelha):
			celulas_ocupadas.erase(coordenada_grelha)

# Dentro do teu DadosDoJogo.gd
func limpar_todas_as_ocupacoes_da_expedicao() -> void:
	print("🧹 DadosDoJogo: A limpar apenas os recursos da expedição da memória...")
	
	# Criamos uma lista temporária com as coordenadas que pertencem à mina
	var chaves_para_remover = []
	for coord in celulas_ocupadas:
		var id = celulas_ocupadas[coord]
		if id == "pedra_mina" or id == "ferro_mina" or id == "portal":
			chaves_para_remover.append(coord)
			
	# Removemos apenas essas chaves, deixando as sementes e máquinas da base salvas!
	for coord in chaves_para_remover:
		celulas_ocupadas.erase(coord)


# --- EFEITOS VISUAIS (Adicionar no fim do DadosDoJogo.gd) ---
func criar_texto_energia(quantidade: float, posicao_mundo: Vector2) -> void:
	# Cria um nó de texto dinamicamente
	var label = Label.new()
	label.text = "-" + str(int(quantidade))
	
	# Cor vermelha/laranja para indicar gasto de energia
	label.modulate = Color(1.0, 0.35, 0.35) 
	label.global_position = posicao_mundo - Vector2(8, 16) # Centraliza sobre o clique
	
	# Garante que o texto fica por cima de tudo no Mundo
	var arvore_atual = Engine.get_main_loop() as SceneTree
	if arvore_atual and arvore_atual.current_scene:
		arvore_atual.current_scene.add_child(label)
	
	# Animação fluida com Tween (Sobe e desaparece)
	var tween = label.create_tween().set_parallel(true)
	# Sobe 25 píxeis em 0.5 segundos
	tween.tween_property(label, "global_position:y", label.global_position.y - 25, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Desvanece a opacidade até sumir
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	# Remove o nó da memória do Godot assim que terminar a animação
	tween.chain().tween_callback(label.queue_free)


# --- BASE DE DADOS DE CONSTRUÇÃO ---
# --- BASE DE DADOS DE CONSTRUÇÃO EXPANDIDA ---
var dados_construcao: Dictionary = {
	"fabrica_flores": {
		"nome": "Fábrica de Flores",
		"custos": { "flor_amarela": 10, "madeira_oak": 5 },
		"input": { "oleo_vegetal": 1 },
		"output": { "flor_amarela": 1 }, 
		"cena": preload("res://fabrica_flores.tscn")
	},
	"prensa_oleo": {
		"nome": "Prensa de Óleo",
		"custos": { "semente": 15 },
		"input": { "semente": 2 },
		"output": { "oleo_vegetal": 1 },
		"cena": preload("res://prensa_oleo.tscn")
	},
	"solar_panel": {
		"nome": "Painel Solar",
		"custos": { "oleo_vegetal": 15, "ingot_iron": 2 },
		"input": {}, # Sem input (energia grátis!)
		"output": { "energia": 5 },
		"cena": preload("res://solar_panel.tscn")
	},
	"wind_farm": {
		"nome": "Wind Farm",
		"custos": {"madeira_oak": 15},
		"input": {"oleo_vegetal": 1}, # Sem input (energia grátis!)
		"output": { "energia": 5 },
		"cena": preload("res://wind_farm.tscn")
	},
	"fundicao": {
		"nome": "Smelter",
		"custos": {"oleo_vegetal": 15},
		"input": {"ore": 2}, # Sem input (energia grátis!)
		"output": {},
		"cena": preload("res://fundicao.tscn")
	}
}
# 2. O Banco de Dados de Receitas da Fundição
var receitas_fundicao = {
	"nenhuma": {
		"nome_ui": "Nenhuma Selecionada",
		"ingrediente": "",
		"resultado": "",
		"quantidade_ingrediente": 0,
		"quantidade_resultado": 0
	},
	"ingot_iron": {
		"nome_ui": "Iron Ingot",
		"ingrediente": "ore_iron",
		"resultado": "ingot_iron",
		"quantidade_ingrediente": 3, # Precisa de 3 minérios
		"quantidade_resultado": 1    # Dá 1 barra
	},
	"cobre": {
		"nome_ui": "Barra de Cobre",
		"ingrediente": "minerio_cobre",
		"resultado": "barra_cobre",
		"quantidade_ingrediente": 3,
		"quantidade_resultado": 1
	},
	"ouro": {
		"nome_ui": "Barra de Ouro",
		"ingrediente": "minerio_ouro",
		"resultado": "barra_ouro",
		"quantidade_ingrediente": 3,
		"quantidade_resultado": 1
	}
}
#region Configuração Semanais
# Dentro do DadosDoJogo.gd

# 📅 SISTEMA DE TEMPO GLOBAL
var dia_atual: int = 1
var dia_da_semana: int = 1 # 1 = Segunda, 2 = Terça ... 7 = Domingo
var semana_atual: int = 1  # 🌟 Controla o multiplicador de dificuldade

signal dia_alterado(novo_dia: int, nome_dia: String)
signal nova_taxa_anunciada(texto_missao: String) # 🌟 Sinal para avisar o jogador no ecrã!
signal jogo_terminado(vitoria: bool)

# 💰 GRUPOS DE RECURSOS PARA O SORTEIO
var RECURSOS_TIER_1 = ["pedra", "oleo_vegetal", "flor_amarela", "semente", "madeira_oak"]
var RECURSOS_TIER_2 = ["minerio_ferro", "barra_ferro", "componente_eletronico", "barra_cobre"]

# Onde vamos guardar as exigências da semana atual
var taxa_semanal_ativa = {}

func _ready() -> void:
	# 🌟 Gera o primeiro objetivo mal o jogo arranca!
	gerar_nova_taxa_semanal()

func avancar_dia() -> void:
	dia_atual += 1
	dia_da_semana += 1
	
	dia_alterado.emit(dia_atual, get_nome_do_dia())
	
	if dia_da_semana > 7:
		processar_fim_de_semana()

func get_nome_do_dia() -> String:
	match dia_da_semana:
		1: return "Segunda-feira"
		2: return "Terça-feira"
		3: return "Quarta-feira"
		4: return "Quinta-feira"
		5: return "Sexta-feira"
		6: return "Sábado"
		7: return "Domingo"
		_: return "Dia Provisório"

# 🎲 A MATEMÁTICA DO SORTEIO DINÂMICO:
func gerar_nova_taxa_semanal() -> void:
	taxa_semanal_ativa.clear()
	
	# Escolhe o Tier e a quantidade de itens com base na semana
	var lista_para_sorteio = RECURSOS_TIER_1
	var quantidade_recursos = 1
	
	# MÊS 1, SEMANA 1 a 4: Sobe a quantidade de itens do Tier 1
	if semana_atual <= 4:
		lista_para_sorteio = RECURSOS_TIER_1
		quantidade_recursos = semana_atual # Semana 1 = 1 item, Semana 2 = 2 itens...
	# MÊS 2, SEMANA 5 a 8: Passa para o Tier 2!
	else:
		lista_para_sorteio = RECURSOS_TIER_2
		quantidade_recursos = semana_atual - 4 # Semana 5 = 1 item Tier 2, Semana 6 = 2 itens...

	# Embaralha a lista para o sorteio ser mesmo aleatório
	var copia_lista = lista_para_sorteio.duplicate()
	copia_lista.shuffle()
	
	# Monta o dicionário de cobrança final e calcula as quantidades
	for i in range(min(quantidade_recursos, copia_lista.size())):
		var recurso_sorteado = copia_lista[i]
		
		# Define uma quantidade base justa multiplicada pela semana atual para dar escala
		var quantidade_exigida = 0
		if lista_para_sorteio == RECURSOS_TIER_1:
			quantidade_exigida = (i + 1) * 15 + (semana_atual * 5) # Ex: entre 20 e 40
		else:
			quantidade_exigida = (i + 1) * 5 + ((semana_atual - 4) * 3) # Tier 2 pede menos unidades
			
		taxa_semanal_ativa[recurso_sorteado] = quantidade_exigida

	# Cria uma mensagem de texto limpa para enviar para a tua UI
	var texto_anuncio = "📋 OBJETIVO DA SEMANA " + str(semana_atual) + ":\n"
	for rec in taxa_semanal_ativa:
		texto_anuncio += "- " + rec.capitalize().replace("_", " ") + ": " + str(taxa_semanal_ativa[rec]) + "\n"
		
	nova_taxa_anunciada.emit(texto_anuncio)
	print(texto_anuncio)

func processar_fim_de_semana() -> void:
	print("💰 O cobrador chegou! A validar os recursos aleatórios...")
	var cumpriu_objetivo = true
	
	for recurso in taxa_semanal_ativa:
		if inventario_global[recurso] < taxa_semanal_ativa[recurso]:
			cumpriu_objetivo = false
			break
			
	if cumpriu_objetivo:
		print("🥳 Renda paga com sucesso!")
		# Cobra as taxas do teu inventário global
		for recurso in taxa_semanal_ativa:
			inventario_global[recurso] -= taxa_semanal_ativa[recurso]
			recurso_alterado.emit(recurso, inventario_global[recurso])
			
		# Avança para a próxima semana e reseta a Segunda-feira
		semana_atual += 1
		dia_da_semana = 1
		
		# 🎲 SORTEIA AS NOVAS REGRAS MAIS DIFÍCEIS:
		gerar_nova_taxa_semanal()
	else:
		print("💀 GAME OVER!")
		jogo_terminado.emit(false)

#endregion

#region Save Game 💾 
# ==========================================================
# 💾 SISTEMA DE SAVE / LOAD GAME (Formato JSON)
# ==========================================================
const CAMINHO_SAVE = "user://savegame.json"

# 📝 FUNÇÃO PARA GRAVAR O JOGO
# 📝 FUNÇÃO PARA GRAVAR O JOGO

# 📖 FUNÇÃO PARA CARREGAR O JOGO (MÉTODO LIMPO POR MUDANÇA DE CENA)


func atualizar_hud_recursos_pos_load() -> void:
	print("🔍 [RASTREIO 13] Iniciou atualizar_hud_recursos_pos_load()")
	for recurso in inventario_global:
		recurso_alterado.emit(recurso, inventario_global[recurso])
	print("🔍 [RASTREIO 14] Fim de atualizar_hud_recursos_pos_load() - Sinais enviados.")

func finalizar_carregamento_seguro(dados_carregados: Dictionary) -> void:
	print("🔍 [RASTREIO 15] Iniciou finalizar_carregamento_seguro()")
	var jogador = get_tree().get_first_node_in_group("Jogador")
	
	if jogador and "jogador_pos_x" in dados_carregados:
		print("🔍 [RASTREIO 16] A mover a posição do jogador...")
		jogador.global_position = Vector2(dados_carregados["jogador_pos_x"], dados_carregados["jogador_pos_y"])
		
	print("🔍 [RASTREIO 17] A chamar recriar_mundo_pos_load()...")
	recriar_mundo_pos_load()
	print("🔍 [RASTREIO 18] Fim absoluto do carregamento de jogo!")
	# 🌟 DESTRANCA A TRAVA AQUI: O jogo está seguro e pronto para receber novos inputs!
	ja_esta_a_carregar = false 
# ==========================================================
# 🔄 FUNÇÃO PARA REINICIAR TUDO (NEW GAME)
# ==========================================================
func novo_jogo() -> void:
	print("🔄 A iniciar um Novo Jogo... A limpar dados antigos nos bastidores.")
	
	# 1. Apaga fisicamente o ficheiro de save antigo do teu disco
	if FileAccess.file_exists(CAMINHO_SAVE_RES):
		DirAccess.remove_absolute(CAMINHO_SAVE_RES)
		
		print("🗑️ Ficheiro savegame.json antigo eliminado do disco.")



#endregion
# No final do teu DadosDoJogo.gd
const CAMINHO_SAVE_RES = "user://savegame.tres"

# 📝 GRAVAR JOGO NATIVO (SAVE)
func gravar_jogo() -> void:
	var save = DadosGuardados.new()
	
	# Copiamos as variáveis numéricas diretas
	save.dia_atual = dia_atual
	save.dia_da_semana = dia_da_semana
	save.semana_atual = semana_atual
	save.energia_atual = energia_atual
	save.energia_maxima = energia_maxima
	save.expedicao_atual_selecionada = expedicao_atual_selecionada
	
	# Guardamos os dicionários nativos (O Godot 4 aceita o Vector2i direto aqui!)
	save.inventario_global = inventario_global.duplicate()
	save.celulas_ocupadas = celulas_ocupadas.duplicate()
	
	# Guardamos a posição do jogador
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador:
		save.jogador_pos = jogador.global_position

	# O comando mágico do Godot que grava o ficheiro binário ultra-rápido
	var erro = ResourceSaver.save(save, CAMINHO_SAVE_RES)
	if erro == OK:
		print("💾 Jogo gravado com sucesso nativo (.tres)!")
	else:
		print("❌ Erro ao gravar o Resource: ", erro)

# 📖 CARREGAR JOGO NATIVO (LOAD)
func carregar_jogo() -> void:
	if not ResourceLoader.exists(CAMINHO_SAVE_RES):
		print("⚠️ Nenhum savegame nativo encontrado.")
		return
		
	# Carrega o objeto inteiro para a memória de uma só vez
	var save = ResourceLoader.load(CAMINHO_SAVE_RES) as DadosGuardados
	if not save:
		print("❌ Erro ao carregar o ficheiro .tres!")
		return
		
	# Restauramos as variáveis numéricas
	dia_atual = save.dia_atual
	dia_da_semana = save.dia_da_semana
	semana_atual = save.semana_atual
	energia_atual = save.energia_atual
	energia_maxima = save.energia_maxima
	expedicao_atual_selecionada = save.expedicao_atual_selecionada
	
	# Restauramos os dicionários intactos
	inventario_global = save.inventario_global.duplicate()
	celulas_ocupadas = save.celulas_ocupadas.duplicate()
	
	# Avisamos o sistema para atualizar os gráficos do HUD
	energia_alterada.emit(energia_atual, energia_maxima)
	dia_alterado.emit(dia_atual, get_nome_do_dia())
	for recurso in inventario_global:
		recurso_alterado.emit(recurso, inventario_global[recurso])
		
	# Reiniciamos a cena principal para limpar fantasmas e recriar o mundo de forma nativa e passiva!
	get_tree().reload_current_scene()
	print("📖 Jogo carregado na memória. A reiniciar a cena para aplicar...")

# 🏗️ RECONSTRUTOR PASSIVO (Para rodar quando o mapa nasce limpo)
func recriar_mundo_pos_load() -> void:
	var cena_raiz = get_tree().current_scene
	if not cena_raiz: return
	
	print("🏗️ A repor objetos no chão baseando na grelha carregada...")
	
	for coord in celulas_ocupadas:
		var id = celulas_ocupadas[coord]
		
		# Ignora dados residuais das minas
		if typeof(id) != TYPE_STRING or id == "pedra_mina" or id == "ferro_mina" or id == "portal" or id == "":
			continue
			
		# Recria as Máquinas
		if id in dados_construcao:
			var nova_maquina = dados_construcao[id]["cena"].instantiate()
			nova_maquina.global_position = Vector2((coord.x * 16) + 8, (coord.y * 16) + 8)
			nova_maquina.add_to_group("ObjetosDoMundo")
			cena_raiz.add_child(nova_maquina)
			
		# Recria as Sementes/Plantas
		elif id == "semente" or id == "semente_tree_oak" or id == "seed_string":
			var chao_base = cena_raiz.get_node_or_null("Chao") as TileMapLayer
			if chao_base: chao_base.set_cell(coord, 0, Vector2i(1, 0))
			
			var jogador = get_tree().get_first_node_in_group("Jogador")
			if jogador:
				var nova_planta = null
				if id == "semente" and "CENA_PLANTA" in jogador: nova_planta = jogador.CENA_PLANTA.instantiate()
				elif id == "semente_tree_oak" and "CENA_TREE_OAK" in jogador: nova_planta = jogador.CENA_TREE_OAK.instantiate()
				elif id == "seed_string" and "CENA_PLANT_FIBER" in jogador: nova_planta = jogador.CENA_PLANT_FIBER.instantiate()
				
				if nova_planta:
					nova_planta.global_position = Vector2((coord.x * 16) + 8, (coord.y * 16) + 8)
					if "coordenada_chao" in nova_planta: nova_planta.coordenada_chao = coord
					nova_planta.add_to_group("ObjetosDoMundo")
					cena_raiz.add_child(nova_planta)
