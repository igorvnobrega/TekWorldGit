extends Node2D

# 🌟 Arrastarás para aqui as tuas cenas de recursos e o portal no Inspector!
@export var CENA_PEDRA_COMUM: PackedScene
@export var CENA_MINERIO_FERRO: PackedScene
@export var CENA_PORTAL_SAIDA: PackedScene # 👈 O teu portal voltou!

@onready var chao: TileMapLayer = $Chao

func _ready() -> void:
	# Adia a geração de mapa por um frame para o jogador assentar o grupo de forma estável
	call_deferred("iniciar_geracao_segura")

func iniciar_geracao_segura() -> void:
	# 1. Ativação da câmara imediata para seguir o WASD
	var camera_expedicao = get_node_or_null("Jogador/Camera2D")
	if camera_expedicao:
		camera_expedicao.make_current()
		
	# 2. Vai buscar as configurações da expedição selecionada
	var id_mapa = DadosDoJogo.expedicao_atual_selecionada
	var dados_mapa = DadosDoJogo.expedicoes[id_mapa]
	
	print("🚀 A iniciar geração procedimental para: ", dados_mapa["nome"])
	gerar_mapa_aleatorio(dados_mapa["tamanho_grelha"])

func gerar_mapa_aleatorio(tamanho: Vector2i) -> void:
	# Definimos aqui a coordenada onde a tua escada de corda vai nascer
	var coordenada_escada = Vector2i(10, 10)
	
	# 🌟 SPAWN DO PORTAL DE SAÍDA: Criamos a escada antes do loop das pedras
	if CENA_PORTAL_SAIDA:
		var escada = CENA_PORTAL_SAIDA.instantiate()
		escada.global_position = chao.map_to_local(coordenada_escada)
		add_child(escada)
		# Avisa a grelha global que esta célula está ocupada
		DadosDoJogo.definir_ocupacao_celula(coordenada_escada, true)
		print("🧗 Portal de fuga criado com sucesso na coordenada (10, 10)!")

	print("⚙️ A preencher todos os tiles de spawn com recursos de 16x16...")
	
	# LOOP DE PREENCHIMENTO DA GRELHA
	for x in range(tamanho.x):
		for y in range(tamanho.y):
			var coordenada_atual = Vector2i(x, y)
			
			# 🌟 PROTEÇÃO: Se for a célula da escada, salta para a próxima para não meter lá pedras!
			if coordenada_atual == coordenada_escada:
				continue
			
			# Proteção de Spawn do Jogador (Centro do mapa livre de pedras)
			if x >= 8 and x <= 12 and y >= 8 and y <= 12:
				continue
			
			# Filtro: Só coloca pedras onde pintaste o teu tile de spawn (0, 2)
			var coordenadas_atlas = chao.get_cell_atlas_coords(coordenada_atual)
			if coordenadas_atlas != Vector2i(0, 2):
				continue
				
			# Roda o dado para a raridade (80% pedra comum vs 20% ferro)
			var dado_raridade = randf()
			var novo_recurso: Node2D = null
			
			if dado_raridade <= 0.80:
				if CENA_PEDRA_COMUM:
					novo_recurso = CENA_PEDRA_COMUM.instantiate()
			else:
				if CENA_MINERIO_FERRO:
					novo_recurso = CENA_MINERIO_FERRO.instantiate()
			
			# Posiciona o recurso perfeitamente alinhado na tua grelha de 16x16
			if novo_recurso:
				add_child(novo_recurso)
				var pos_local = chao.map_to_local(coordenada_atual)
				novo_recurso.global_position = chao.to_global(pos_local)
				
				if "coordenada_chao" in novo_recurso:
					novo_recurso.coordenada_chao = coordenada_atual
					
				DadosDoJogo.definir_ocupacao_celula(coordenada_atual, true)
