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

# --- 🌟 VARIÁVEIS DE ENERGIA (As que provavelmente faltavam!) ---
var energia_maxima: float = 100.0
var energia_atual: float = 100.0


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
	# Se usas um dicionário para guardar as coordenadas ocupadas nas minas,
	# vamos limpá-lo por completo para o arranque do próximo mapa!
	if has_node("celulas_ocupadas") or typeof(celulas_ocupadas) == TYPE_DICTIONARY:
		celulas_ocupadas.clear()
	print("🧹 Grelha de ocupação limpa para evitar colisões fantasmas na base!")




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
func gravar_jogo() -> void:
	var pos_jogador = Vector2.ZERO
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador:
		pos_jogador = jogador.global_position

	var dados_para_salvar: Dictionary = {
		"dia_atual": dia_atual,
		"dia_da_semana": dia_da_semana,
		"semana_atual": semana_atual,
		"energia_atual": energia_atual,
		"energia_maxima": energia_maxima,
		"inventario_global": inventario_global,
		"expedicao_atual_selecionada": expedicao_atual_selecionada,
		"jogador_pos_x": pos_jogador.x,
		"jogador_pos_y": pos_jogador.y,
		"celulas_ocupadas": converter_celulas_para_salvar()
	}
	
	var ficheiro = FileAccess.open(CAMINHO_SAVE, FileAccess.WRITE)
	if ficheiro:
		var json_texto = JSON.stringify(dados_para_salvar)
		ficheiro.store_string(json_texto)
		ficheiro.close()
		print("💾 Jogo gravado com sucesso!")

# 📖 FUNÇÃO PARA CARREGAR O JOGO
# 📖 FUNÇÃO PARA CARREGAR O JOGO (VERSÃO ULTRA-OTIMIZADA)
# 📖 FUNÇÃO PARA CARREGAR O JOGO (VERSÃO COM DETETORES DE CONGELAMENTO)
func carregar_jogo() -> void:
	print("🔍 [RASTREIO 1] Iniciou a função carregar_jogo()")
	
	if not FileAccess.file_exists(CAMINHO_SAVE):
		print("🔍 [RASTREIO 2] Nenhum ficheiro encontrado. A abortar.")
		return
		
	var ficheiro = FileAccess.open(CAMINHO_SAVE, FileAccess.READ)
	if ficheiro:
		var json_texto = ficheiro.get_as_text()
		ficheiro.close()
		print("🔍 [RASTREIO 3] Ficheiro lido com sucesso do disco.")
		
		var json = JSON.new()
		var erro = json.parse(json_texto)
		
		if erro == OK:
			var dados_carregados = json.data as Dictionary
			print("🔍 [RASTREIO 4] Parse do JSON feito com sucesso.")
			
			# Restaurar variáveis na memória
			if "dia_atual" in dados_carregados: dia_atual = int(dados_carregados["dia_atual"])
			if "dia_da_semana" in dados_carregados: dia_da_semana = int(dados_carregados["dia_da_semana"])
			if "semana_atual" in dados_carregados: semana_atual = int(dados_carregados["semana_atual"])
			if "energia_atual" in dados_carregados: energia_atual = float(dados_carregados["energia_atual"])
			if "energia_maxima" in dados_carregados: energia_maxima = float(dados_carregados["energia_maxima"])
			if "expedicao_atual_selecionada" in dados_carregados: expedicao_atual_selecionada = dados_carregados["expedicao_atual_selecionada"]
			print("🔍 [RASTREIO 5] Variáveis numéricas restauradas na memória.")
			
			if "inventario_global" in dados_carregados:
				var inv_salvo = dados_carregados["inventario_global"] as Dictionary
				for recurso in inv_salvo:
					inventario_global[recurso] = inv_salvo[recurso]
			print("🔍 [RASTREIO 6] Inventário restaurado na memória.")
			
			if "celulas_ocupadas" in dados_carregados:
				restaurar_celulas_carregadas(dados_carregados["celulas_ocupadas"])
			print("🔍 [RASTREIO 7] Grelha de células ocupadas restaurada na memória.")
			
			# Disparo dos sinais de interface básicos
			print("🔍 [RASTREIO 8] A disparar sinal energia_alterada...")
			energia_alterada.emit(energia_atual, energia_maxima)
			
			print("🔍 [RASTREIO 9] A disparar sinal dia_alterado...")
			dia_alterado.emit(dia_atual, get_nome_do_dia())
			
			print("🔍 [RASTREIO 10] A agendar o call_deferred para os recursos...")
			call_deferred("atualizar_hud_recursos_pos_load")
			
			print("🔍 [RASTREIO 11] A agendar o call_deferred para o jogador/mundo...")
			call_deferred("finalizar_carregamento_seguro", dados_carregados)
			
			print("🔍 [RASTREIO 12] Fim do bloco principal de carregar_jogo(). A aguardar os frames adiados...")
		else:
			print("❌ Erro ao ler a estrutura do ficheiro JSON!")

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

# ==========================================================
# 🔄 FUNÇÃO PARA REINICIAR TUDO (NEW GAME)
# ==========================================================
func novo_jogo() -> void:
	print("🔄 A iniciar um Novo Jogo... A limpar dados antigos nos bastidores.")
	
	# 1. Apaga fisicamente o ficheiro de save antigo do teu disco
	if FileAccess.file_exists(CAMINHO_SAVE):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("savegame.json")
			print("🗑️ Ficheiro savegame.json antigo eliminado do disco.")

	# 2. Reseta o calendário e o tempo global
	dia_atual = 1
	dia_da_semana = 1
	semana_atual = 1
	
	# 3. Reseta a tua energia para os valores iniciais
	energia_maxima = 100.0
	energia_atual = 100.0
	
	# 4. Limpa por completo a grelha de ocupações da base
	celulas_ocupadas.clear()
	
	# 5. Reseta o controlo de expedições e limpa a mochila temporária
	expedicao_atual_selecionada = "mina_inicial"
	limpar_mochila_expedicao()

	# 6. REPOE AS QUANTIDADES INICIAIS DO TEU INVENTÁRIO GLOBAL
	inventario_global = {
		"flor_amarela": 20,
		"semente": 20,
		"oleo_vegetal": 50,
		"eletricidade": 100,
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

	# 7. 🔥 SINCRONIZAÇÃO COMPLETA DA INTERFACE (HUD)
	# Forçamos todos os teus menus e contadores a lerem os números de reset
	for recurso in inventario_global:
		recurso_alterado.emit(recurso, inventario_global[recurso])
		
	energia_alterada.emit(energia_atual, energia_maxima)
	dia_alterado.emit(dia_atual, get_nome_do_dia())
	
	# 8. Sorteia um novo objetivo fresco para a primeira semana do jogo
	gerar_nova_taxa_semanal()
	
	print("🎮 Novo Jogo inicializado com sucesso!")

# Função auxiliar que reconstrói os objetos no mapa com base no save
func recriar_mundo_pos_load() -> void:
	var cena_raiz = get_tree().current_scene
	if not cena_raiz: return
	
	# 1. Limpar objetos antigos do chão
	for no_antigo in get_tree().get_nodes_in_group("ObjetosDoMundo"):
		no_antigo.queue_free()
		
	# 2. Vamos ler o ficheiro JSON outra vez apenas para extrair as fases de crescimento
	if not FileAccess.file_exists(CAMINHO_SAVE): return
	var ficheiro = FileAccess.open(CAMINHO_SAVE, FileAccess.READ)
	var dados_json = JSON.parse_string(ficheiro.get_as_text())
	ficheiro.close()
	
	if not dados_json or not "celulas_ocupadas" in dados_json: return
	var celulas_salvas = dados_json["celulas_ocupadas"] as Dictionary
	
	# 3. Reconstruir o mundo aplicando os estágios salvos
	for chave_texto in celulas_salvas:
		var partes = chave_texto.split(",")
		var coord = Vector2i(int(partes[0]), int(partes[1]))
		
		var dados_item = celulas_salvas[chave_texto]
		if not dados_item is Dictionary: continue
		
		var id = dados_item["id"]
		var fase = int(dados_item["fase"])
		
		if id == "pedra_mina" or id == "ferro_mina" or id == "portal":
			continue
			
		# Se for uma Máquina
		if id in dados_construcao:
			var nova_maquina = dados_construcao[id]["cena"].instantiate()
			nova_maquina.global_position = Vector2((coord.x * 16) + 8, (coord.y * 16) + 8)
			nova_maquina.add_to_group("ObjetosDoMundo")
			cena_raiz.add_child(nova_maquina)
			
		# Se for uma Planta (Semente)
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
					
					# 🌟 INJETA A MEMÓRIA DA FASE:
					# Passamos o estágio exato guardado ANTES de adicionar à árvore,
					# cortando qualquer bug ou loop infinito no _ready() da planta!
					if nova_planta.has_method("carregar_estagio"):
						nova_planta.carregar_estagio(fase)
					elif "estagio_crescimento" in nova_planta:
						nova_planta.estagio_crescimento = fase
						
					nova_planta.add_to_group("ObjetosDoMundo")
					cena_raiz.add_child(nova_planta)

# ==========================================================
# 🔄 FUNÇÕES AUXILIARES DE CONVERSÃO DE DADOS (VECTOR2I PARA STRING)
# ==========================================================

func converter_celulas_para_salvar() -> Dictionary:
	var dicionario_texto = {}
	for coord in celulas_ocupadas:
		var id_objeto = celulas_ocupadas[coord]
		
		if typeof(id_objeto) == TYPE_STRING and id_objeto != "":
			# Procuramos se existe o nó real no mundo para ler a fase dele
			var fase_atual = 0
			
			# Fazemos uma busca rápida no mapa para encontrar a planta desta coordenada
			for no in get_tree().get_nodes_in_group("ObjetosDoMundo"):
				if "coordenada_chao" in no and no.coordenada_chao == coord:
					if "estagio_crescimento" in no:
						fase_atual = no.estagio_crescimento
						break
			
			# Guardamos a coordenada apontando para um dicionário com o ID e a Fase!
			var chave_texto = str(coord.x) + "," + str(coord.y)
			dicionario_texto[chave_texto] = {
				"id": id_objeto,
				"fase": fase_atual
			}
	return dicionario_texto

func restaurar_celulas_carregadas(dicionario_texto: Dictionary) -> void:
	celulas_ocupadas.clear()
	for chave_texto in dicionario_texto:
		var partes = chave_texto.split(",")
		if partes.size() == 2:
			var x = int(partes[0])
			var y = int(partes[1])
			var coord_vector = Vector2i(x, y)
			
			# Lemos o formato novo de dicionário interno do JSON
			var dados_objeto = dicionario_texto[chave_texto]
			if dados_objeto is Dictionary:
				celulas_ocupadas[coord_vector] = dados_objeto["id"]
				# Guardamos a fase temporariamente na memória global para o reconstrutor ler a seguir
				# Criamos um dicionário auxiliar dinâmico no DadosDoJogo se precisares, ou tratamos direto no recriar!

#endregion
