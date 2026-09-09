# prensa_oleo.gd
extends MaquinaBase

func _ready() -> void:
	custo_eletricidade = 2.0
	custo_oleo = 0.0
	tempo_ciclo = 5.0
	super._ready()

# 🌟 1. Esta função protege o teu inventário. Se retornar false, a MaquinaBase não gasta NADA.
func pode_executar() -> bool:
	var inv = DadosDoJogo.inventario_global
	if inv["flor_amarela"] >= 5:
		return true
	else:
		print("❌ Prensa de Óleo parada: Flores amarelas insuficientes.")
		return false

# 🌟 2. Como a MaquinaBase já validou as flores acima, aqui dentro o sucesso é garantido!
func executar_trabalho() -> void:
	var inv = DadosDoJogo.inventario_global
	
	# Consome a matéria-prima com toda a segurança
	inv["flor_amarela"] -= 5
	DadosDoJogo.recurso_alterado.emit("flor_amarela", inv["flor_amarela"])
	
	# Produz o óleo vegetal
	inv["oleo_vegetal"] += 2
	DadosDoJogo.recurso_alterado.emit("oleo_vegetal", inv["oleo_vegetal"])
	
	print("🛢️ Prensa de Óleo: 5 Flores transformadas com sucesso em 1 Óleo Vegetal!")
	modulate = Color(1, 1, 1)
