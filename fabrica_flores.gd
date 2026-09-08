# FabricaFlores.gd
extends MaquinaBase

func executar_trabalho() -> void:
	DadosDoJogo.adicionar_recurso("flor_amarela", 1)
