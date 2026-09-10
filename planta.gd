# planta.gd
extends MaquinaBase

# 🌟 CORREÇÃO: Agora condiz exatamente com a tua imagem de 2 frames!
enum Estado { CRESCENDO, MADURO }
var estado_atual: Estado = Estado.CRESCENDO

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

# 🔮 SUBSTUIÇÃO DA FUNÇÃO MÁGICA: Corre automaticamente após 5 segundos
func executar_trabalho() -> void:
	if estado_atual == Estado.CRESCENDO:
		estado_atual = Estado.MADURO
		print("🌸 Planta: Ficou totalmente madura! Pronta para colher.")
		
		# 🌟 Trava o temporizador para ela parar de correr ciclos
		if timer_interno:
			timer_interno.stop()
			
	atualizar_visual()

func atualizar_visual() -> void:
	match estado_atual:
		Estado.CRESCENDO:
			sprite.frame = 0 # 🌟 Frame 0: Broto verde (da tua imagem)
		Estado.MADURO:
			sprite.frame = 1 # 🌟 Frame 1: Flor amarela (da tua imagem)

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
	inv["flor_amarela"] += 1
	inv["semente"] += 1
	DadosDoJogo.recurso_alterado.emit("flor_amarela", inv["flor_amarela"])
	DadosDoJogo.recurso_alterado.emit("semente", inv["semente"])
	
	if randf() <= 0.10:
		inv["semente"] += 1
		DadosDoJogo.recurso_alterado.emit("semente", inv["semente"])
	
	print("🌸 Colheita realizada com sucesso!")

	# 2. Transforma a terra de volta em relva IMEDIATAMENTE
	var chao = get_parent().get_node_or_null("Chao") as TileMapLayer
	if chao and coordenada_chao != Vector2i(-1, -1):
		chao.set_cell(coordenada_chao, 0, Vector2i(0, 0)) 
		print("🌱 O terreno voltou a ser relva!")

	# 3. APAGA A PLANTA IMEDIATAMENTE (Liberta o espaço para replantar instantaneamente)
	queue_free()
