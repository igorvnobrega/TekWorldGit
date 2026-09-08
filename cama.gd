# Cama.gd
extends Area2D
class_name Cama

func usar_cama() -> void:
	print("Cama: O jogador deitou-se para dormir...")
	
	# 1. Chamar a função de recarregar que já tens no DadosDoJogo!
	DadosDoJogo.recarregar_energia_total()
	
	# 2. 🪄 EFEITO VISUAL: Fazer a tela piscar (Fade to Black) para simular o tempo a passar
	# Criamos um efeito rápido na própria cama ou no ecrã se preferires.
	# Aqui vamos fazer a cama piscar suavemente apenas para dar um feedback visual imediato.
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.5), 0.4) # Escurece (noite)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.4) # Clarea (dia)
