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
const CENA_TREE_OAK = preload("res://semente_sapling.tscn") 

# --- NOVAS VARIÁVEIS PARA O PREVIEW ---
var maquina_selecionada_id: String = ""
var esta_a_construir: bool = false
var preview_fantasma: Node2D = null  # 👻 Guarda a referência visual do fantasma


# --- REFERÊNCIAS ---
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("Jogador")

func _physics_process(_delta: float) -> void:
	var direcao: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direcao != Vector2.ZERO:
		velocity = direcao * VELOCIDADE
		if direcao.x < 0:
			sprite.flip_h = true
		elif direcao.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func entrar_modo_construcao(id_maquina: String) -> void:
	var dados = DadosDoJogo.dados_construcao[id_maquina]
	
	if DadosDoJogo.inventario_global[dados["custo_recurso"]] >= dados["custo_quantidade"]:
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
		print("Jogador: Modo construção ativo.")
	else:
		print("Jogador: Recursos insuficientes!")

func _process(_delta: float) -> void:
	# Faz o fantasma seguir o rato na grelha 16x16
	if esta_a_construir and preview_fantasma:
		var pos_rato = get_global_mouse_position()
		var x_grelha = int(floor(pos_rato.x / 16.0))
		var y_grelha = int(floor(pos_rato.y / 16.0))
		preview_fantasma.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var pos_rato = get_global_mouse_position()
		
		# ==========================================
		# 🟢 CLIQUE ESQUERDO: Interações e Plantação
		# ==========================================
		if event.button_index == MOUSE_BUTTON_LEFT:
			if esta_a_construir:
				executar_construcao(pos_rato)
			
			# 🌟 NOVO FILTRO: Se o modo de plantação estiver ativo pelo menu,
			# tentamos primeiro colher. Se não colher nada, planta a semente!
			elif DadosDoJogo.modo_plantacao_ativo and DadosDoJogo.item_selecionado != "":
				var colheu_objeto = tentar_interagir_com_objeto(pos_rato)
				if not colheu_objeto:
					plantar_com_o_rato(pos_rato)
					
			# 🌟 FLUXO NORMAL: Se NÃO estiver a plantar nem a construir, 
			# interage normalmente com as camas, prensas ou colheitas padrão.
			else:
				tentar_interagir_com_objeto(pos_rato)
					
		# ==========================================
		# 🔴 CLIQUE DIREITO: Cancelar Modos Ativos
		# ==========================================
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if esta_a_construir:
				cancelar_construcao()
			# 🌟 Se o modo de plantação contínua estiver ativo, limpa o estado
			elif DadosDoJogo.modo_plantacao_ativo:
				DadosDoJogo.modo_plantacao_ativo = false
				DadosDoJogo.item_selecionado = ""
				print("🚫 Modo de plantação contínua desativado.")


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
	
	if DadosDoJogo.inventario_global[dados["custo_recurso"]] >= dados["custo_quantidade"]:
		if preview_fantasma:
			preview_fantasma.queue_free()
			preview_fantasma = null
			
		DadosDoJogo.adicionar_recurso(dados["custo_recurso"], -dados["custo_quantidade"])
		DadosDoJogo.definir_ocupacao_celula(coordenada_grelha, true)
		
		var nova_maquina = dados["cena"].instantiate()
		nova_maquina.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)
		get_parent().add_child(nova_maquina)
		
		esta_a_construir = false
		print("Jogador: Máquina construída com sucesso!")
	else:
		cancelar_construcao()

# --- INTERAÇÕES TRADICIONAIS (Mantém o teu código base de busca) ---
func tentar_interagir_com_objeto(posicao_clique: Vector2) -> bool:
	# 1. Verifica plantas colhíveis
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
				
	# 2. Verifica móveis/camas interagíveis
	var interagiveis = get_tree().get_nodes_in_group("Interagiveis")
	for obj in interagiveis:
		if obj is Area2D and obj.global_position.distance_to(posicao_clique) < 16.0:
			if global_position.distance_to(obj.global_position) <= ALCANCE_INTERACAO and obj.has_method("usar_cama"):
				obj.usar_cama()
				return true
	return false

func plantar_com_o_rato(pos_rato: Vector2) -> void:
	var inv = DadosDoJogo.inventario_global
	var semente_atual = DadosDoJogo.item_selecionado # 🌟 Deteta qual semente está na mão (ex: "semente_trigo")
	
	# Segurança baseada na semente atual
	if inv[semente_atual] <= 0:
		DadosDoJogo.modo_plantacao_ativo = false
		DadosDoJogo.item_selecionado = ""
		print("🫙 Acabou este tipo de semente!")
		return

	var x_grelha = int(floor(pos_rato.x / 16.0))
	var y_grelha = int(floor(pos_rato.y / 16.0))
	var coordenada_grelha = Vector2i(x_grelha, y_grelha)
	
	if DadosDoJogo.esta_celula_livre(coordenada_grelha) and DadosDoJogo.gastar_energia(CUSTO_ENERGIA_PLANTAR):
		
		# 🌟 GASTA A SEMENTE CORRETA DINAMICAMENTE!
		inv[semente_atual] -= 1
		DadosDoJogo.recurso_alterado.emit(semente_atual, inv[semente_atual])
		
		# [Lógica do TileMap...]
		var chao = get_parent().get_node("Chao") as TileMapLayer
		if chao:
			chao.set_cell(coordenada_grelha, 0, Vector2i(1, 0))
		
# 🌟 SELEÇÃO DINÂMICA E SEGURA DA CENA:
		var nova_planta

		if semente_atual == "semente_tree_oak":
			# Se a semente na mão for a da árvore, cria o Carvalho
			nova_planta = CENA_TREE_OAK.instantiate()
			
		#elif semente_atual == "semente_trigo":
			# Se no futuro usares trigo, ele fica isolado aqui
			#nova_planta = CENA_TRIGO.instantiate() 
			
		elif semente_atual == "semente":
			# Se for a semente padrão, cria a Flor Amarela
			nova_planta = CENA_PLANTA.instantiate()
			
		else:
			# Linha de segurança caso haja algum erro de texto no menu
			print("⚠️ Erro: Semente desconhecida na mão: ", semente_atual)
			return
	
	
		nova_planta.global_position = Vector2((x_grelha * 16) + 8, (y_grelha * 16) + 8)
		if nova_planta.has_method("definir_posicao_na_grelha"):
			nova_planta.definir_posicao_na_grelha(coordenada_grelha)
			
		DadosDoJogo.definir_ocupacao_celula(coordenada_grelha, true)
		DadosDoJogo.criar_texto_energia(CUSTO_ENERGIA_PLANTAR, nova_planta.global_position)
		get_parent().add_child(nova_planta)
		
		if inv[semente_atual] <= 0:
			DadosDoJogo.modo_plantacao_ativo = false
			DadosDoJogo.item_selecionado = ""
