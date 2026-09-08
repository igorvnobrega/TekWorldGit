# PrensaOleo.gd
extends MaquinaBase

func executar_trabalho() -> void:
	if DadosDoJogo.inventario_global["semente"] >= 2:
		DadosDoJogo.inventario_global["semente"] -= 2
		DadosDoJogo.adicionar_recurso("oleo_vegetal", 1)
		DadosDoJogo.recurso_alterado.emit("semente", DadosDoJogo.inventario_global["semente"])
