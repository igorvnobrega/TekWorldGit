# planta.gd
extends MaquinaBase

# 🌟 CORREÇÃO: Agora condiz exatamente com a tua imagem de 2 frames!
enum Estado { CRESCENDO, MADURO }
var estado_atual: Estado = Estado.CRESCENDO

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
# ==========================================================
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if estado_atual == Estado.MADURO and jogador_na_area:
			get_viewport().set_input_as_handled()
			colher()
		else:
			get_viewport().set_input_as_handled()

func colher() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# 1. Dá os recursos de volta ao saco central
	inv["flor_amarela"] += 1
	inv["semente"] += 1
	DadosDoJogo.recurso_alterado.emit("flor_amarela", inv["flor_amarela"])
	DadosDoJogo.recurso_alterado.emit("semente", inv["semente"])
	
	# 2. 10% de hipótese de bónus de semente extra
	if randf() <= 0.10:
		inv["semente"] += 1
		DadosDoJogo.recurso_alterado.emit("semente", inv["semente"])
		print("✨ Bónus! Encontraste uma semente extra na colheita!")
		
	print("🌸 Colheita realizada com sucesso!")
	queue_free()

# ==========================================================
# 🚶 SINAIS FÍSICOS DE PROXIMIDADE
# ==========================================================
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("plantar_com_o_rato") or body.name == "Jogador" or body.is_in_group("Jogador"):
		jogador_na_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("plantar_com_o_rato") or body.name == "Jogador" or body.is_in_group("Jogador"):
		jogador_na_area = false
