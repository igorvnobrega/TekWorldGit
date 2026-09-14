
extends MaquinaBase

# 🌟 CORREÇÃO: Agora condiz exatamente com a tua imagem de 2 frames!
enum Estado {SEMENTE, CRESCENDO, MADURO }
var estado_atual: Estado = Estado.SEMENTE

var coordenada_chao: Vector2i = Vector2i(-1, -1) 
# Variável de controlo de proximidade
var jogador_na_area: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# 1. Configura as variáveis do molde pai
	custo_eletricidade = 0.0
	custo_oleo = 0.0
	tempo_ciclo = 5.0         # Demora 5 segundos a passar de broto para flor madura
	
	# 2. Inicializa o molde pai (Isto cria o timer_interno por código!)
	super._ready()
	
	# Garante que começa como broto (Frame 0)
	atualizar_visual()

# Força o molde pai a dar sempre LUZ VERDE à planta
func pode_executar() -> bool:
	return true

# 🔮 SUBSTUIÇÃO DA FUNÇÃO MÁGICA: Corre automaticamente a cada 5 segundos
func executar_trabalho() -> void:
	if estado_atual == Estado.SEMENTE:
		estado_atual = Estado.CRESCENDO
		print("🌳 OAK TREE: Passou de semente a árvore jovem!")
		
	elif estado_atual == Estado.CRESCENDO:
		estado_atual = Estado.MADURO
		print("🌲 OAK TREE: Ficou totalmente madura! Pronta para cortar.")
		
		# 🌟 Trava o temporizador da MaquinaBase apenas quando chegar ao fim absoluto!
		if timer_interno:
			timer_interno.stop()
			
	atualizar_visual()

func atualizar_visual() -> void:
	match estado_atual:
		Estado.SEMENTE:
			sprite.frame = 0 # 🌟 Frame 0: Broto verde (da tua imagem)
		Estado.CRESCENDO:
			sprite.frame = 1 # 🌟 Frame 1: Flor amarela (da tua imagem)
		Estado.MADURO:
			sprite.frame = 2
# ==========================================================
# 🟢 CLIQUE DE COLHEITA
@export var distancia_maxima_interacao: float = 150.0 
# ==========================================================
# ==========================================================
# 🟢 CLIQUE DE COLHEITA CORRIGIDO
# ==========================================================
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# 🌟 GARANTE QUE SÓ DETETA QUANDO O BOTÃO É PRESSIONADO (evita o evento de soltar o botão)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if estado_atual == Estado.MADURO:
			var jogador = get_tree().get_first_node_in_group("Jogador")
			if jogador:
				var distancia = global_position.distance_to(jogador.global_position)
				if distancia <= distancia_maxima_interacao:
					get_viewport().set_input_as_handled()
					colher()
				else:
					print("❌ Demasiado longe!")
				
func colher() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# 1. Dá os recursos ao inventário
	inv["madeira_oak"] += 5
	inv["semente_tree_oak"] += 1
	DadosDoJogo.recurso_alterado.emit("madeira_oak", inv["madeira_oak"])
	DadosDoJogo.recurso_alterado.emit("semente_tree_oak", inv["semente_tree_oak"])
	
	if randf() <= 0.25:
		inv["semente_tree_oak"] += 1
		DadosDoJogo.recurso_alterado.emit("semente_tree_oak", inv["semente_tree_oak"])
	
	print(" Colheita realizada com sucesso! A libertar o espaço...")

	# 2. LIBERTA O ESPAÇO IMEDIATAMENTE
	var chao = get_parent().get_node_or_null("Chao") as TileMapLayer
	if chao:
		# 🌟 GARANTIA: Se a coordenada ainda for a padrão, calcula imediatamente antes de avançar
		if coordenada_chao == Vector2i(-1, -1):
			coordenada_chao = chao.local_to_map(global_position)
		
		# Liberta a célula no sistema global do teu jogo
		DadosDoJogo.definir_ocupacao_celula(coordenada_chao, false)
		
		# Configura o tempo que a terra fica visível (ex: 3 segundos)
		var segundos_em_terra: float = 3.0 
		
		# Guardamos a coordenada exata nesta variável para o timer não a perder
		var posicao_alvo = coordenada_chao
		
		get_tree().create_timer(segundos_em_terra).timeout.connect(
			func():
				if is_instance_valid(chao):
					# 🌟 SINTAXE CORRETA PARA TILEMAPLAYER: Passa apenas a coordenada!
					var tile_atual = chao.get_cell_atlas_coords(posicao_alvo)
					
					# Se o bloco ATUAL ainda for Terra (Vector2i(1, 0)), muda para Relva!
					if tile_atual == Vector2i(1, 0):
						chao.set_cell(posicao_alvo, 0, Vector2i(0, 0)) 
						print("🌱 O terreno respirou e voltou a ser relva!")
					else:
						print("ℹ️ O terreno não mudou porque o bloco já não é terra. Tile atual: ", tile_atual)
		)

	# 3. APAGA A PLANTA IMEDIATAMENTE
	queue_free()
