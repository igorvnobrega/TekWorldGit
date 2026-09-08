# PainelTop.gd
extends HBoxContainer

@onready var label_flores: Label = $LabelFlores
@onready var label_sementes: Label = $LabelSementes
@onready var label_oleo: Label = $LabelOleo
@onready var label_eletricidade: Label = $LabelEletricidade
@onready var label_energia: Label = $LabelEnergia

func _ready() -> void:
	# 1. Atualiza os textos com os valores que começam no DadosDoJogo
	atualizar_todos_os_valores()
	
	# 2. Conecta o sinal global para atualizar a UI sempre que algum recurso mudar
	DadosDoJogo.recurso_alterado.connect(_on_recurso_alterado)

func atualizar_todos_os_valores() -> void:
	var inv = DadosDoJogo.inventario_global
	label_flores.text = "🌸 Flores: " + str(inv["flor_amarela"])
	label_sementes.text = "🌱 Sementes: " + str(inv["semente"])
	label_oleo.text = "🛢️ Óleo: " + str(int(inv["oleo_vegetal"]))
	label_eletricidade.text = "⚡ Energia: " + str(int(inv["eletricidade"]))

func _on_recurso_alterado(nome_recurso: String, novo_valor: int) -> void:
	# Quando o sinal global avisa que algo mudou, atualizamos apenas o texto correto
	match nome_recurso:
		"flor_amarela":
			label_flores.text = "🌸 Flores: " + str(novo_valor)
		"semente":
			label_sementes.text = "🌱 Sementes: " + str(novo_valor)
		"oleo_vegetal":
			label_oleo.text = "🛢️ Óleo: " + str(int(novo_valor))
		"eletricidade":
			label_eletricidade.text = "⚡ Energia: " + str(int(novo_valor))
