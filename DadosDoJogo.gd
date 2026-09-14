# DadosDoJogo.gd (Script Global / Autoload)
extends Node

# --- SINAIS ---
signal recurso_alterado(nome_recurso: String, novo_valor: int)
signal energia_alterada(nova_energia: float, energia_maxima: float) # 🌟 Garante que este sinal existe!

var item_selecionado: String = ""
var modo_plantacao_ativo: bool = false


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
func esta_celula_livre(coordenada_grelha: Vector2i) -> bool:
	return not celulas_ocupadas.has(coordenada_grelha)

func definir_ocupacao_celula(coordenada_grelha: Vector2i, ocupado: bool) -> void:
	if ocupado:
		celulas_ocupadas[coordenada_grelha] = true
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
		"custo_recurso": "flor_amarela",
		"custo_quantidade": 10,
		"cena": preload("res://fabrica_flores.tscn")
	},
	"prensa_oleo": {
		"nome": "Prensa de Óleo",
		"custo_recurso": "semente",
		"custo_quantidade": 15,
		"cena": preload("res://prensa_oleo.tscn") # 🌟 Nova máquina!
	},
	
	"solar_panel": {
	"nome": "Painel Solar",
	"custo_recurso": "oleo_vegetal",
	"custo_quantidade": 15,
	"cena": preload("res://solar_panel.tscn") # 🌟 Nova máquina!
	},
		"wind_farm": {
	"nome": "Wind Farm",
	"custo_recurso": "oleo_vegetal",
	"custo_quantidade": 15,
	"cena": preload("res://wind_farm.tscn") # 🌟 Nova máquina!
	},
	
	"fundicao": {
	"nome": "Smelter",
	"custo_recurso": "oleo_vegetal",
	"custo_quantidade": 15,
	"cena": preload("res://fundicao.tscn") # 🌟 Nova máquina!
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
