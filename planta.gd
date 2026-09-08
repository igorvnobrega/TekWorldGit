extends Area2D
class_name PlantaCrescente

# --- CONFIGURAÇÕES DA PLANTA ---
@export_group("Dados da Planta")
@export var nome_planta: String = "Flor Amarela"
@export var tempo_por_estagio: float = 3.0

@export_group("Configuração Visual")
@export var frame_inicial: int = 1
@export var frame_final: int = 2
#Energia Planta
@export var custo_energia_colheita: float = 1.0 # 🌟 Planta custa 1 de energia
# --- REFERÊNCIAS INTERNAS ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

var frame_atual: int
var minha_coordenada_grelha: Vector2i

func _ready() -> void:
	# Regista a planta num grupo global para o jogador a conseguir encontrar via rato
	add_to_group("Colhiveis")
	
	frame_atual = frame_inicial
	sprite.frame = frame_atual
	
	timer.wait_time = tempo_por_estagio
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if frame_atual < frame_final:
		frame_atual += 1
		sprite.frame = frame_atual
		if frame_atual < frame_final:
			timer.start()

func definir_posicao_na_grelha(coordenada: Vector2i) -> void:
	minha_coordenada_grelha = coordenada

# A planta agora apenas executa a ordem quando o jogador manda!
# A planta agora apenas executa a ordem quando o jogador manda!
func colher_planta() -> void:
	# 1. Adiciona o recurso ao banco de dados global
	DadosDoJogo.adicionar_recurso("flor_amarela", 1)
	
	# 2. Avisa o cérebro global para libertar IMEDIATAMENTE este espaço na grelha
	# (Assim o jogador pode voltar a plantar aqui se quiser, mesmo estando em terra)
	DadosDoJogo.definir_ocupacao_celula(minha_coordenada_grelha, false)
	
	# 3. Encontra o nó do chão que está no Mundo
	var chao = get_node("/root/Mundo/Chao") as TileMapLayer
	
	if chao:
		# Ocultamos o Sprite da flor imediatamente para dar o efeito visual de que foi colhida!
		sprite.visible = false
		
		print("Colheita feita! A terra vai descansar por 4 segundos...")
		
		# 🌟 A CORREÇÃO DE OURO: O script espera 4 segundos aqui antes de avançar!
		await get_tree().create_timer(4.0).timeout
		
		# 4. Esta linha só roda PASSADOS os 4 segundos!
		chao.set_cell(minha_coordenada_grelha, 0, Vector2i(0, 0)) # Devolve a Relva (0, 0)
		print("Cenário: A terra descansou e a relva voltou a crescer!")
	else:
		print("ERRO: Não encontrou o caminho /root/Mundo/Chao!")
	
	# 5. Só agora, com tudo concluído, é que eliminamos a planta da memória de forma segura!
	queue_free()
