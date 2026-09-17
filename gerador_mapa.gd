extends Node2D

# 🌟 Arrastarás para aqui as tuas cenas de recursos e o portal no Inspector!
@export var CENA_PEDRA_COMUM: PackedScene
@export var CENA_MINERIO_FERRO: PackedScene
@export var CENA_PORTAL_SAIDA: PackedScene 

@onready var chao: TileMapLayer = $Chao

func _ready() -> void:
	# Adia a geração de mapa por um frame para o jogador assentar o grupo de forma estável
	call_deferred("iniciar_geracao_segura")

func iniciar_geracao_segura() -> void:
	var camera_expedicao = get_node_or_null("Jogador/Camera2D")
	if camera_expedicao:
		camera_expedicao.make_current()
		
	var id_mapa = DadosDoJogo.expedicao_atual_selecionada
	var dados_mapa = DadosDoJogo.expedicoes[id_mapa]
	
	print("🚀 A iniciar geração procedimental para: ", dados_mapa["nome"])
	gerar_mapa_aleatorio(dados_mapa["tamanho_grelha"])

func gerar_mapa_aleatorio(tamanho: Vector2i) -> void:
	var coordenada_escada = Vector2i(10, 10)
	
	if CENA_PORTAL_SAIDA:
		var escada = CENA_PORTAL_SAIDA.instantiate()
		escada.global_position = chao.map_to_local(coordenada_escada)
		add_child(escada)
		
		# 🌟 CORREÇÃO 1: Passamos a string "portal" em vez de true!
		DadosDoJogo.definir_ocupacao_celula(coordenada_escada, "portal")
		print("🧗 Portal de fuga criado com sucesso na coordenada (10, 10)!")

	print("⚙️ A preencher todos os tiles de spawn com recursos de 16x16...")
	
	for x in range(tamanho.x):
		for y in range(tamanho.y):
			var coordenada_atual = Vector2i(x, y)
			
			if coordenada_atual == coordenada_escada:
				continue
			
			if x >= 8 and x <= 12 and y >= 8 and y <= 12:
				continue
			
			var coordenadas_atlas = chao.get_cell_atlas_coords(coordenada_atual)
			if coordenadas_atlas != Vector2i(0, 2):
				continue
				
			var dado_raridade = randf()
			var novo_recurso: Node2D = null
			
			# 🌟 CORREÇÃO 2: Guardamos o ID do recurso para registar na grelha de texto
			var id_recurso_texto = ""
			
			if dado_raridade <= 0.80:
				if CENA_PEDRA_COMUM:
					novo_recurso = CENA_PEDRA_COMUM.instantiate()
					id_recurso_texto = "pedra_mina"
			else:
				if CENA_MINERIO_FERRO:
					novo_recurso = CENA_MINERIO_FERRO.instantiate()
					id_recurso_texto = "ferro_mina"
			
			if novo_recurso:
				add_child(novo_recurso)
				var pos_local = chao.map_to_local(coordenada_atual)
				novo_recurso.global_position = chao.to_global(pos_local)
				
				if "coordenada_chao" in novo_recurso:
					novo_recurso.coordenada_chao = coordenada_atual
					
				# 🌟 CORREÇÃO 3: Registamos o ID do texto em vez de true!
				DadosDoJogo.definir_ocupacao_celula(coordenada_atual, id_recurso_texto)
