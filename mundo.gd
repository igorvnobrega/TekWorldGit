extends Node2D

@onready var base_node: Node2D = $Base
@onready var expedicao_node: Node2D = $Expedicao

# Carrega o molde da tua cena de expedição que criámos
var cena_expedicao_blueprint = preload("res://CenaExpedicao.tscn")

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
