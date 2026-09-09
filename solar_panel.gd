# prensa_oleo.gd
extends MaquinaBase

func _ready() -> void:
	custo_eletricidade = 0.0
	custo_oleo = 0.0
	tempo_ciclo = 1.0
	super._ready()

# 🌟 1. Esta função protege o teu inventário. Se retornar false, a MaquinaBase não gasta NADA.
func pode_executar() -> bool:
		return true


# 🌟 2. Como a MaquinaBase já validou as flores acima, aqui dentro o sucesso é garantido!
func executar_trabalho() -> void:
	var inv = DadosDoJogo.inventario_global

	# Produz o Electricidade
	inv["eletricidade"] += 1
	DadosDoJogo.recurso_alterado.emit("eletricidade", inv["eletricidade"])
	
	modulate = Color(1, 1, 1)
