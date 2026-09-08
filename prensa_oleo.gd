# PrensaOleo.gd
extends MaquinaBase # 🌟 Herda tudo da MaquinaBase!

func executar_trabalho() -> void:
	# Esta máquina precisa de 2 sementes físicas para esmagar e fazer óleo
	if DadosDoJogo.inventario_global["semente"] >= 2:
		DadosDoJogo.inventario_global["semente"] -= 2
		DadosDoJogo.adicionar_recurso("oleo_vegetal", 1) # Produz 1 óleo!
		DadosDoJogo.recurso_alterado.emit("semente", DadosDoJogo.inventario_global["semente"])
		print("Prensa: Sementes esmagadas em Óleo!")
