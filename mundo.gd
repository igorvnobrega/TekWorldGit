extends Node2D

@onready var base_node: Node2D = $Base
@onready var expedicao_node: Node2D = $Expedicao

# Carrega o molde da tua cena de expedição que criámos
var cena_expedicao_blueprint = preload("res://CenaExpedicao.tscn")

# No teu script principal do mapa/mundo (ex: mundo.gd):

# Dentro do teu mundo.gd:

# No teu mundo.gd
# mundo.gd
func _ready() -> void:
	# Aguarda os frames de segurança para a cena assentar no motor gráfico
	await get_tree().process_frame
	await get_tree().physics_frame
	
	# 🌟 FORÇAR O MUNDO A SAIR DE QUALQUER ESTADO DE PAUSA ANTERIOR:
	process_mode = PROCESS_MODE_INHERIT
	get_tree().paused = false
	
	# Se existir um savegame gravado, vamos ler a posição e recriar o mundo!
	if ResourceLoader.exists(DadosDoJogo.CAMINHO_SAVE_RES):
		var save = ResourceLoader.load(DadosDoJogo.CAMINHO_SAVE_RES) as DadosGuardados
		if save:
			print("🏡 Mundo.gd: A detetar save nativo. A restaurar jogador e grelhas...")
			
			# 1. Repõe a posição do teu personagem
			var jogador = get_tree().get_first_node_in_group("Jogador")
			if jogador and save.jogador_pos != Vector2.ZERO:
				jogador.global_position = save.jogador_pos
				
				# 🌟 DESBLOQUEAR O PROPRIO JOGADOR VISUAL E FÍSICO:
				jogador.process_mode = PROCESS_MODE_INHERIT
				jogador.velocity = Vector2.ZERO
				
				# 🌟 LIMPAR FANTASMAS DA MÃO:
				# Se o jogador gravou o jogo enquanto tinha o fantasma semitransparente na mão,
				# limpamos as variáveis para ele não nascer trancado no modo de construção!
				if "esta_a_construir" in jogador: jogador.esta_a_construir = false
				if "preview_fantasma" in jogador and is_instance_valid(jogador.preview_fantasma):
					jogador.preview_fantasma.queue_free()
					jogador.preview_fantasma = null
				DadosDoJogo.modo_plantacao_ativo = false
				DadosDoJogo.item_selecionado = ""
				
				print("🚶 Jogador reposicionado e DESBLOQUEADO para: ", jogador.global_position)
				
			# 2. Chama a reconstrução estável das máquinas e sementes
			DadosDoJogo.recriar_mundo_pos_load()
			
	# ==========================================================
	# 🧼 ATUALIZAÇÃO DO HUD DO ECRA
	# ==========================================================
	DadosDoJogo.energia_alterada.emit(DadosDoJogo.energia_atual, DadosDoJogo.energia_maxima)
	DadosDoJogo.dia_alterado.emit(DadosDoJogo.dia_atual, DadosDoJogo.get_nome_do_dia())
	for recurso in DadosDoJogo.inventario_global:
		DadosDoJogo.recurso_alterado.emit(recurso, DadosDoJogo.inventario_global[recurso])
		
	print("🧼 HUD atualizado com sucesso após o carregamento nativo!")


func viajar_para_expedicao() -> void:
	# 1. Esconde e pausa visualmente a base (mas as máquinas continuam a processar!)
	base_node.visible = false
	base_node.process_mode = PROCESS_MODE_DISABLED # Pausa as colisões e movimentos da base, mas NÃO os timers se usares MaquinaBase com modo específico.
	
	# 2. Limpa qualquer expedição antiga que tenha ficado no nó
	for filho in expedicao_node.get_children():
		filho.queue_free()
		
	# 3. Cria a nova gruta procedimental (Ela vai rodar o gerador com novos 80%/20%!)
	var nova_mina = cena_expedicao_blueprint.instantiate()
	expedicao_node.add_child(nova_mina)
	expedicao_node.visible = true

	print("⛏️ Bem-vindo à Expedição!")

func voltar_para_a_base() -> void:
	expedicao_node.visible = false
	
	# 1. 🌟 A CORREÇÃO CRÍTICA: Limpa a cache de células ocupadas do script global 
	# ANTES de reativares a base, eliminando os quadrados invisíveis!
	DadosDoJogo.limpar_mochila_expedicao() # Limpeza de segurança extra
	# Se criaste a função do Passo 1:
	DadosDoJogo.limpar_todas_as_ocupacoes_da_expedicao() 

	# 2. Destrói fisicamente os nós da mina
	for filho in expedicao_node.get_children():
		filho.queue_free()
		
	# 3. Reativa a tua quinta principal
	base_node.visible = true
	base_node.process_mode = PROCESS_MODE_INHERIT
	
	print("🏡 Voltaste para casa e o chão da base está 100% livre para plantação!")


func _on_bot_mina_pedra_pressed() -> void:
	pass # Replace with function body.
