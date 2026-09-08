# ContadorFlores.gd
extends Label

func _ready() -> void:
	# Dizemos ao nosso texto para "ouvir" o sinal do script global
	DadosDoJogo.recurso_alterado.connect(_on_recurso_alterado)

# Esta função roda automaticamente sempre que QUALQUER recurso muda no jogo
func _on_recurso_alterado(nome_recurso: String, novo_valor: int) -> void:
	# Se o recurso que mudou for a nossa flor, atualizamos o texto no ecrã!
	if nome_recurso == "flor_amarela":
		text = "Flores: " + str(novo_valor)
