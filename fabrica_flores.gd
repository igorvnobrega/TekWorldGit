# FabricaFlores.gd
extends MaquinaBase # 🌟 Agora herda as regras de óleo e luz!

func executar_trabalho() -> void:
	# Como a MaquinaBase já validou e consumiu o Óleo e a Eletricidade, 
	# aqui só te preocupas em dar a recompensa!
	DadosDoJogo.adicionar_recurso("flor_amarela", 1)
	
	# Usamos a função visual que já tinhas criado
	if has_method("criar_texto_producao"):
		criar_texto_producao(1, global_position)
