# DadosGuardados.gd
extends Resource
class_name DadosGuardados

@export var dia_atual: int = 1
@export var dia_da_semana: int = 1
@export var semana_atual: int = 1
@export var energia_atual: float = 100.0
@export var energia_maxima: float = 100.0

@export var inventario_global: Dictionary = {}
@export var celulas_ocupadas: Dictionary = {}
@export var jogador_pos: Vector2 = Vector2.ZERO
@export var expedicao_atual_selecionada: String = "mina_inicial"
