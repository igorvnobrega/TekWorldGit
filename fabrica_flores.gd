# fabrica_flores.gd
extends MaquinaBase

func _ready() -> void:
	# 1. Configura os custos padrão da fábrica antes do molde iniciar
	custo_eletricidade = 1.0  # Consome 1 de eletricidade por ciclo
	custo_oleo = 0.5          # Consome 0.5 de óleo por ciclo
	tempo_ciclo = 5.0         # Corre a cada 5 segundos
	
	# 2. Inicializa o molde pai (isto cria o timer limpo automaticamente!)
	super._ready()

# 🌟 Como a fábrica de flores usa recursos padrão, não precisa da função pode_executar()!
# A MaquinaBase já valida eletricidade e óleo sozinha.

func executar_trabalho() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# Produz a flor amarela
	inv["flor_amarela"] += 2
	DadosDoJogo.recurso_alterado.emit("flor_amarela", inv["flor_amarela"])
	
	print("🌸 Fábrica de Flores: +1 Flor Amarela produzida com sucesso!")
	modulate = Color(1, 1, 1)
