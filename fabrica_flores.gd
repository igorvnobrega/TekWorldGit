# fabrica_flores.gd
extends MaquinaBase

func _ready() -> void:
	# 1. Configura os custos padrão da fábrica antes do molde iniciar
	custo_eletricidade = 1.0  # Consome 1 de eletricidade por ciclo
	custo_oleo = 1.0         # Consome 1 de óleo por ciclo
	tempo_ciclo = 5.0         # Corre a cada 5 segundos
	
	# 2. Inicializa o molde pai (isto cria o timer limpo automaticamente!)
	super._ready()

func executar_trabalho() -> void:
	# 🌟 A PROTEÇÃO CRÍTICA: Se a máquina estiver OFF no pai, 
	# aborta a produção imediatamente e não dá recursos!
	if not maquina_ligada:
		return
		
	var inv = DadosDoJogo.inventario_global
	
	# Produz a flor amarela
	inv["flor_amarela"] += 2
	DadosDoJogo.recurso_alterado.emit("flor_amarela", inv["flor_amarela"])
	
	print("🌸 Fábrica de Flores: +2 Flores Amarelas produzidas com sucesso!")
	modulate = Color(1, 1, 1)
