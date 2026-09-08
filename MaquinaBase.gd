# MaquinaBase.gd
extends Area2D
class_name MaquinaBase

@export_group("Consumos por Ciclo")
@export var custo_eletricidade: float = 1.0
@export var custo_oleo: float = 0.5
@export var tempo_ciclo: float = 5.0

var timer_interno: Timer

func _ready() -> void:
	# Cria e configura o Timer de forma automática para QUALQUER máquina!
	timer_interno = Timer.new()
	timer_interno.wait_time = tempo_ciclo
	timer_interno.one_shot = false
	timer_interno.autostart = true
	add_child(timer_interno)
	timer_interno.timeout.connect(_processar_ciclo_maquina)

func _processar_ciclo_maquina() -> void:
	# 1. Verifica se há eletricidade e óleo suficientes no sistema global
	var tem_eletricidade = DadosDoJogo.inventario_global["eletricidade"] >= custo_eletricidade
	var tem_oleo = DadosDoJogo.inventario_global["oleo_vegetal"] >= custo_oleo
	
	if tem_eletricidade and tem_oleo:
		# 2. Consome os recursos globais
		DadosDoJogo.inventario_global["eletricidade"] -= custo_eletricidade
		DadosDoJogo.inventario_global["oleo_vegetal"] -= custo_oleo
		
		# Força a atualização da UI (Sinal que já tinhas criado!)
		DadosDoJogo.recurso_alterado.emit("eletricidade", DadosDoJogo.inventario_global["eletricidade"])
		DadosDoJogo.recurso_alterado.emit("oleo_vegetal", DadosDoJogo.inventario_global["oleo_vegetal"])
		
		# 3. Executa o trabalho específico da máquina
		executar_trabalho()
		efeito_visual_sucesso()
	else:
		efeito_visual_parado()

# 🔮 FUNÇÃO MÁGICA: Cada máquina vai reescrever esta função com o seu próprio trabalho!
func executar_trabalho() -> void:
	pass

func efeito_visual_sucesso() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func efeito_visual_parado() -> void:
	# Fica ligeiramente azul/escura se faltar combustível ou luz
	modulate = Color(0.6, 0.6, 0.8)
