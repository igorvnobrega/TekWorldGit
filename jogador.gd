extends CharacterBody2D

# --- CONFIGURAÇÕES DO JOGADOR ---
@export var VELOCIDADE: float = 150.0
@export var ALCANCE_INTERACAO: float = 64.0

# 🌟 NOVO: Custo padrão de energia para cavar/plantar sementes no chão
@export var CUSTO_ENERGIA_PLANTAR: float = 1.0 

# --- CONFIGURAÇÕES DE CONSTRUÇÃO ---
@export var CUSTO_FLORES_FABRICA: int = 10  # 🌟 A fábrica custa 10 flores para ser construída
@export var CUSTO_SEMENTES_FABRICA: int = 10  # 🌟 A fábrica custa 10 flores para ser construída
@export var CUSTO_SOLAR_PANEL: int = 10

# --- PRE CARREGAMENTO ---
const CENA_PLANTA = preload("res://planta.tscn")
const CENA_FABRICA = preload("res://fabrica_flores.tscn")
const CENA_FABRICA_OLEO = preload("res://prensa_oleo.tscn")
const CENA_PAINEL_SOLAR = preload("res://solar_panel.tscn")
const CENA_TREE_OAK = preload("res://tree_oak.tscn") 
const CENA_PLANT_FIBER = preload("res://plant_string.tscn")

# --- NOVAS VARIÁVEIS PARA O PREVIEW ---
var maquina_selecionada_id: String = ""
var esta_a_construir: bool = false
var preview_fantasma: Node2D = null  # 👻 Guarda a referência visual do fantasma

# --- NOVAS VARIÁVEIS PARA as Animaçoes---

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

# Guardamos a última direção do movimento para saber para onde o boneco fica a olhar quando para
var ultima_direcao: Vector2 = Vector2.DOWN



func _ready() -> void:
	add_to_group("Jogador")

# ==========================================
# 🔄 PROCESSAMENTO DA FÍSICA
# ==========================================
func _physics_process(_delta: float) -> void:
	# 1. Captura o vetor de movimento puro (já normalizado por padrão)
	var direcao: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Aplica a velocidade baseada na direção do input
	if direcao != Vector2.ZERO:
		velocity = direcao * VELOCIDADE
		ultima_direcao = direcao # Memoriza a direção do último passo
		processar_estados_animacao(direcao, true)
	else:
		velocity = Vector2.ZERO
		processar_estados_animacao(ultima_direcao, false)
		
	# 3. Executa o movimento físico na grelha/mapa
	move_and_slide()

# ==========================================
# 🎬 CONTROLADOR VISUAL (ANIMAÇÕES)
# ==========================================
func processar_estados_animacao(direcao_foco: Vector2, esta_a_mover: bool) -> void:
	# Determinamos o eixo principal do olhar (se está mais focado na Horizontal ou Vertical)
	var olhar_horizontal: bool = abs(direcao_foco.x) > abs(direcao_foco.y)
	
	if esta_a_mover:
		# 🏃 CICLOS DE CAMINHAR (LOOP)
		if olhar_horizontal:
			if direcao_foco.x > 0:
				anim.play("andar_direita")
			else:
				anim.play("andar_esquerda")
		else:
			if direcao_foco.y > 0:
				anim.play("andar_frente")
			else:
				anim.play("andar_costas")
	else:
		# 🧍 POSES DE DESCANSO (IDLE - FICAR PARADO)
		# Em vez de fazer .stop() num frame qualquer a meio do passo, 
		# forçamos o sprite a fixar-se no frame ideal de repouso (o frame 0 de cada linha)!
		if olhar_horizontal:
			if direcao_foco.x > 0:
				sprite.frame = 12 # Primeiro frame da linha Olhar Direita
			else:
				sprite.frame = 8  # Primeiro frame da linha Olhar Esquerda
		else:
			if direcao_foco.y > 0:
				sprite.frame = 0  # Primeiro frame da linha Olhar Frente
			else:
				sprite.frame = 4  # Primeiro frame da linha Olhar Costas
		
		# Paramos a linha de tempo do AnimationPlayer para não interferir com o frame fixado
		anim.stop()

func entrar_modo_construcao(id_maquina: String) -> void:
	var dados = DadosDoJogo.dados_construcao[id_maquina]
	var inv = DadosDoJogo.inventario_global
	
	# 🌟 VALIDAR MÚLTIPLOS CUSTOS:
	var pode_construir = true
	
	# Verifica se a máquina usa o formato novo de lista de custos
	if "custos" in dados and dados["custos"] is Dictionary:
		for recurso in dados["custos"]:
			var qtd_necessaria = dados["custos"][recurso]
			# Se o jogador não tiver o recurso ou não tiver a quantidade necessária, chumba no teste
			if not recurso in inv or inv[recurso] < qtd_necessaria:
				pode_construir = false
				break # Para o ciclo imediatamente, não vale a pena continuar a verificar
	else:
		# Salvaguarda: Se ainda houver alguma máquina no formato antigo
		if inv[dados["custo_recurso"]] < dados["custo_quantidade"]:
			pode_construir = false

	# Se passou no teste de todos os recursos, ativa o modo de construção!
	if pode_construir:
		if preview_fantasma:
			preview_fantasma.queue_free()
			
		maquina_selecionada_id = id_maquina
		esta_a_construir = true
		
		# Criar o fantasma visual semitransparente
		preview_fantasma = dados["cena"].instantiate() as Node2D
		preview_fantasma.modulate.a = 0.5
		
		# Parar scripts internos para não fabricar em pleno ar
		preview_fantasma.set_process(false)
		preview_fantasma.set_physics_process(false)
		if preview_fantasma.has_node("TimerProducao"):
			preview_fantasma.get_node("TimerProducao").autostart = false
			preview_fantasma.get_node("TimerProducao").stop()
			
		get_parent().add_child(preview_fantasma)
		print("Jogador: Modo construção ativo para: ", dados["nome"])
	else:
		print("Jogador: Recursos insuficientes para construir esta máquina!")

func entrar_modo_plantacao() -> void:
	var semente_atual = DadosDoJogo.item_selecionado
	var inv = DadosDoJogo.inventario_global
	
	# Se já houver algum fantasma ativo no ecrã (de uma máquina ou planta antiga), limpamos
	if preview_fantasma:
		preview_fantasma.queue_free()
		preview_fantasma = null
		
	# Instancia dinamicamente com base nas tuas constantes de cenas já existentes
	if semente_atual == "semente_tree_oak":
		preview_fantasma = CENA_TREE_OAK.instantiate() as Node2D
	elif semente_atual == "semente":
		preview_fantasma = CENA_PLANTA.instantiate() as Node2D
	elif semente_atual == "seed_string":
		preview_fantasma = CENA_PLANT_FIBER.instantiate() as Node2D
	else:
		return # Não é uma semente válida ou nenhuma selecionada

	# Aplica a transparência de 50%
	preview_fantasma.modulate.a = 0.8
	
	# Congela os scripts internos para a planta não começar a crescer na mão do jogador
	preview_fantasma.set_process(false)
	preview_fantasma.set_physics_process(false)
	
	# Se a tua planta tiver algum Timer de crescimento ou produção interna, paramos
	if preview_fantasma.has_node("TimerCrescimento"):
		preview_fantasma.get_node("TimerCrescimento").stop()
		
	# Adiciona o fantasma ao mundo do jogo (pai do jogador)
	get_parent().add_child(preview_fantasma)
	DadosDoJogo.modo_plantacao_ativo = true
	esta_a_construir = false # Garante que não choca com o modo de construção
#endregion
func _process(delta: float) -> void:
	# LÓGICA ATUAL DO FANTASMA DE CONSTRUÇÃO OU PLANTAÇÃO
	if (esta_a_construir or DadosDoJogo.modo_plantacao_ativo) and is_instance_valid(preview_fantasma):
		var pos_rato = get_global_mouse_position()
		
		# Faz exatamente a mesma conta matemática que usas na tua função plantar_com_o_rato!
		var x_grelha = int(floor(pos_rato.x / 16.0))
		var y_grelha = int(floor(pos_rato.y / 16.0))
		
		# Posiciona o fantasma exatamente a meio do quadrado de 16x16 da tua grelha
		preview_fantasma.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)
		
		# [EXTRA VISUAL]: Deixa o fantasma vermelho se o chão estiver ocupado!
		var coordenada_grelha = Vector2i(x_grelha, y_grelha)
		if DadosDoJogo.esta_celula_livre(coordenada_grelha):
			preview_fantasma.modulate = Color(1, 1, 1, 0.5) # Cor normal semitransparente
		else:
			preview_fantasma.modulate = Color(1, 0, 0, 0.5) # Vermelho (bloqueado)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var pos_rato = get_global_mouse_position()
		
		# ==========================================
		# 🟢 CLIQUE ESQUERDO
		# ==========================================
		if event.button_index == MOUSE_BUTTON_LEFT:
			if esta_a_construir:
				executar_construcao(pos_rato)
				get_viewport().set_input_as_handled()
				
			# 🌟 A SOLUÇÃO: Só intercepta o clique se o modo de plantação estiver LIGADO pelo menu!
			# Se o modo estiver desligado, o script do jogador IGNERA o clique, permitindo
			# que ele desça com 100% de prioridade para a Cama e para a Flor!
			elif DadosDoJogo.modo_plantacao_ativo and DadosDoJogo.item_selecionado != "":
				plantar_com_o_rato(pos_rato)
				get_viewport().set_input_as_handled()
				
			else:
				# Deixa o clique passar limpo para o motor de física do Godot ler a Cama/Flor!
				pass

		# ==========================================
		# 🔴 CLIQUE DIREITO (Cancelar Modos)
		# ==========================================
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if esta_a_construir:
				cancelar_construcao()
				get_viewport().set_input_as_handled()
			elif DadosDoJogo.modo_plantacao_ativo:
				# 1. Desativa os estados no DadosDoJogo
				DadosDoJogo.modo_plantacao_ativo = false
				DadosDoJogo.item_selecionado = ""
				print("🚫 Modo de plantação desativado.")
				
				# 2. 🌟 AJUSTE CRÍTICO: Apaga o fantasma da semente imediatamente!
				if is_instance_valid(preview_fantasma):
					preview_fantasma.queue_free()
					preview_fantasma = null
					
				get_viewport().set_input_as_handled()
			else:
				# 🌟 AJUSTE: Tenta interagir com a máquina se os outros modos estiverem desligados
				if tentar_interagir_com_objeto(pos_rato):
					get_viewport().set_input_as_handled()
		# Se carregares na tecla F5, o jogo grava!
		# 🌟 SEGURANÇA 1: Só deteta se for o exato momento em que carregas na tecla,
	# ignorando o sinal se ficares a segurar o botão com o dedo (is_echo)!
	if event is InputEventKey and event.pressed and not event.is_echo():
		match event.keycode:
			KEY_F4: # Ou KEY_R
				print("Atalho: Tecla Novo Jogo detectada.")
				DadosDoJogo.novo_jogo()
				get_tree().reload_current_scene()
				
			KEY_F5: # Ou KEY_G
				print("Atalho: Tecla Gravar detectada.")
				DadosDoJogo.gravar_jogo()
				
			KEY_F9: # Ou KEY_C
				# 🌟 SEGURANÇA 2: Consumimos o input para o Godot saber que ele morreu aqui 
				# e não o passar para o frame seguinte!
				get_viewport().set_input_as_handled()
				DadosDoJogo.carregar_jogo()
func cancelar_construcao() -> void:
	esta_a_construir = false
	if preview_fantasma:
		preview_fantasma.queue_free()
		preview_fantasma = null
	print("Jogador: Construção cancelada.")

func executar_construcao(pos_rato: Vector2) -> void:
	var x_grelha = int(floor(pos_rato.x / 16.0))
	var y_grelha = int(floor(pos_rato.y / 16.0))
	var coordenada_grelha = Vector2i(x_grelha, y_grelha)
	
	if not DadosDoJogo.esta_celula_livre(coordenada_grelha):
		print("Jogador: Espaço ocupado!")
		return
		
	var dados = DadosDoJogo.dados_construcao[maquina_selecionada_id]
	var inv = DadosDoJogo.inventario_global
	
	# 🌟 1. SEGUNDA VALIDAÇÃO DE SEGURANÇA (Garante que ainda tem os recursos)
	var pode_construir = true
	if "custos" in dados and dados["custos"] is Dictionary:
		for recurso in dados["custos"]:
			var qtd_necessaria = dados["custos"][recurso]
			if not recurso in inv or inv[recurso] < qtd_necessaria:
				pode_construir = false
				break
	else:
		if inv[dados["custo_recurso"]] < dados["custo_quantidade"]:
			pode_construir = false

	# 🌟 2. SE PASSOU NO TESTE, REALIZA A CONSTRUÇÃO E GASTA OS RECURSOS
	if pode_construir:
		# Remove o fantasma semitransparente do ecrã
		if preview_fantasma:
			preview_fantasma.queue_free()
			preview_fantasma = null
			
		# 🌟 CONSUMIR TODOS OS RECURSOS DA LISTA:
		if "custos" in dados and dados["custos"] is Dictionary:
			for recurso in dados["custos"]:
				var qtd_necessaria = dados["custos"][recurso]
				# Subtrai o valor (passando um número negativo para a tua função)
				DadosDoJogo.adicionar_recurso(recurso, -qtd_necessaria)
		else:
			# Compatibilidade com o formato antigo
			DadosDoJogo.adicionar_recurso(dados["custo_recurso"], -dados["custo_quantidade"])
			
		# Regista a ocupação da célula na tua grelha do mapa
		DadosDoJogo.definir_ocupacao_celula(coordenada_grelha, maquina_selecionada_id)
		
		# Instancia a máquina real no mundo de jogo
		var nova_maquina = dados["cena"].instantiate()
		nova_maquina.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)
		get_parent().add_child(nova_maquina)
		nova_maquina.add_to_group("ObjetosDoMundo")

		esta_a_construir = false
		print("Jogador: Máquina construída com sucesso e recursos debitados!")
	else:
		print("Jogador: Recursos esgotaram-se no último segundo!")
		cancelar_construcao()

# --- INTERAÇÕES TRADICIONAIS (Mantém o teu código base de busca) ---
func tentar_interagir_com_objeto(posicao_clique: Vector2) -> bool:
	# 1. Verifica plantas colhíveis (Teu código base)
	var objetos = get_tree().get_nodes_in_group("Colhiveis")
	for obj in objetos:
		if obj is Area2D and obj.global_position.distance_to(posicao_clique) < 12.0:
			var dist = global_position.distance_to(obj.global_position)
			if dist <= ALCANCE_INTERACAO and obj is PlantaCrescente and obj.frame_atual == obj.frame_final:
				var custo = obj.custo_energia_colheita if "custo_energia_colheita" in obj else 1.0
				if DadosDoJogo.gastar_energia(custo):
					obj.colher_planta()
					DadosDoJogo.criar_texto_energia(custo, obj.global_position)
				return true
				
	# 2. Verifica móveis/camas interagíveis (Teu código base)
	var interagiveis = get_tree().get_nodes_in_group("Interagiveis")
	for obj in interagiveis:
		if obj is Area2D and obj.global_position.distance_to(posicao_clique) < 16.0:
			if global_position.distance_to(obj.global_position) <= ALCANCE_INTERACAO and obj.has_method("usar_cama"):
				obj.usar_cama()
				return true

# 🗺️ 3. INTERAÇÃO COM MÁQUINAS (ON/OFF E RECEITAS!)
	var maquinas = get_tree().get_nodes_in_group("Maquinas")
	for maq in maquinas:
		# Verifica se o clique do rato atingiu o raio da máquina (16 pixéis)
		if maq is Area2D and maq.global_position.distance_to(posicao_clique) < 16.0:
			# Verifica se o teu personagem está perto o suficiente para tocar nela
			if global_position.distance_to(maq.global_position) <= ALCANCE_INTERACAO:
				
				# 🌟 TRAVA DE SEGURANÇA: Garante que NÃO é uma planta (procura por variáveis de plantas como coordenada_chao)
				if "coordenada_chao" in maq or maq.is_in_group("Plantas"):
					continue # Salta este objeto e continua a procurar por máquinas reais!
				
				# 🌟 NOVO ENCAIXE: Se for a Fundição (ou seja, tem a variável receita_atual_id), abre o menu de receitas!
				if "receita_atual_id" in maq:
					var menu_fun = get_node_or_null("/root/Mundo/CanvasLayer/MenuFundicao")
					if menu_fun:
						menu_fun.abrir_menu(maq) # Abre o menu e passa esta máquina específica para ser configurada
						return true
				
				# 🟢 SE NÃO FOR UMA FUNDIÇÃO: Corre o interruptor normal On/Off que já tinhas!
				if maq.has_method("alternar_estado"):
					maq.alternar_estado() 
					return true
					
	return false


func plantar_com_o_rato(pos_rato: Vector2) -> void:
	var inv = DadosDoJogo.inventario_global
	var semente_atual = DadosDoJogo.item_selecionado 
	
	if inv[semente_atual] <= 0:
		DadosDoJogo.modo_plantacao_ativo = false
		DadosDoJogo.item_selecionado = ""
		print("🫙 Acabou este tipo de semente!")
		return

	var x_grelha = int(floor(pos_rato.x / 16.0))
	var y_grelha = int(floor(pos_rato.y / 16.0))
	var coordenada_grelha = Vector2i(x_grelha, y_grelha)
	
	# ==========================================================
	# 🌾 LISTA DE TODAS AS TUAS TERRAS ARADAS INICIAIS
	# ==========================================================
	# Adiciona aqui as coordenadas de todas as terras limpas onde se pode plantar
	var solos_validos: Array[Vector2i] = [
		Vector2i(0, 0),  # Terra Arada normal (a tua antiga!)
		Vector2i(2, 0),  # Exemplo: Nova Terra Arada Escura do teu novo Tileset
		Vector2i(3, 0),
		Vector2i(4, 0),  # Terra Arada normal (a tua antiga!)
		Vector2i(5, 0),
		Vector2i(6, 0),
		Vector2i(0, 1),  # Terra Arada normal (a tua antiga!)
		Vector2i(1, 1),
		Vector2i(2, 1),  # Terra Arada normal (a tua antiga!)
		Vector2i(3, 1),
		Vector2i(4, 1),  # Terra Arada normal (a tua antiga!)
		Vector2i(5, 1),  # Exemplo: Nova Terra com Adubo
		Vector2i(6, 1)
	]
	
	var chao = get_parent().get_node("Chao") as TileMapLayer
	if not chao:
		print("Erro: Não encontrou o nó Chao!")
		return
		
	# Lemos que tipo de terra limpa está debaixo do rato agora
	var solo_original = chao.get_cell_atlas_coords(coordenada_grelha)
	
	# 🔍 IMPRESSÃO DE DIAGNÓSTICO (Caso não consigas plantar, olha para a consola!)
	print("Jogador: Clicou no Solo com as coordenadas do Atlas: ", solo_original)
	
	# Só avança se a célula estiver livre de objetos E for um solo válido E gastar energia
	if DadosDoJogo.esta_celula_livre(coordenada_grelha) and solo_original in solos_validos and DadosDoJogo.gastar_energia(CUSTO_ENERGIA_PLANTAR):
		
		inv[semente_atual] -= 1
		DadosDoJogo.recurso_alterado.emit(semente_atual, inv[semente_atual])
		
		# 🌟 REGRA AUTOMÁTICA DE SEMENTE:
		# Avança uma linha para baixo (Y + 1) para mostrar o grafismo com a semente por cima.
		var solo_com_semente = Vector2i(solo_original.x, solo_original.y + 1)
				# 🌟 CORREÇÃO AQUI: Força o chão a mudar SEMPRE para o teu tile (1, 0)
		chao.set_cell(coordenada_grelha, 0, Vector2i(1, 0))
		
		
		var nova_planta = null
		if semente_atual == "semente_tree_oak":
			nova_planta = CENA_TREE_OAK.instantiate()
		elif semente_atual == "semente":
			nova_planta = CENA_PLANTA.instantiate()
		elif semente_atual == "seed_string":
			nova_planta = CENA_PLANT_FIBER.instantiate()
		else:
			print("⚠️ Erro: Semente desconhecida na mão: ", semente_atual)
			return
	
		nova_planta.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)
		
		# Passa as coordenadas para a planta
		if "coordenada_chao" in nova_planta:
			nova_planta.coordenada_chao = coordenada_grelha
			
		# 🌟 TRUQUE DE MEMÓRIA DA PLANTA:
		# Guardamos o solo_original dentro da planta para que ela saiba exatamente 
		# que tipo de terra tem de repor quando for colhida!
		if "solo_original" in nova_planta:
			nova_planta.solo_original = solo_original
			
		if nova_planta.has_method("definir_posicao_na_grelha"):
			nova_planta.definir_posicao_na_grelha(coordenada_grelha)
			
		DadosDoJogo.definir_ocupacao_celula(coordenada_grelha, semente_atual)
		DadosDoJogo.criar_texto_energia(CUSTO_ENERGIA_PLANTAR, nova_planta.global_position)
		get_parent().add_child(nova_planta)
		nova_planta.add_to_group("ObjetosDoMundo")
		
		if inv[semente_atual] <= 0:
			DadosDoJogo.modo_plantacao_ativo = false
			DadosDoJogo.item_selecionado = ""
