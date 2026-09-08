# DadosDoJogo.gd (Script Global / Autoload)
extends Node

# --- SINAIS ---
signal recurso_alterado(nome_recurso: String, novo_valor: int)
signal energia_alterada(nova_energia: float, energia_maxima: float) # 🌟 Garante que este sinal existe!

# --- VARIÁVEIS DE INVENTÁRIO ---
# --- INVENTÁRIO ATUALIZADO ---
var inventario_global: Dictionary = {
	"flor_amarela": 0,
	"semente": 20,         # 🌟 Começa com algumas sementes para testar
	"oleo_vegetal": 5,     # 🌟 Novo recurso lubrificante
	"eletricidade": 10     # 🌟 Novo recurso de rede (energia elétrica)
}

# --- VARIÁVEIS DE GRELHA ---
var celulas_ocupadas: Dictionary = {}

# --- 🌟 VARIÁVEIS DE ENERGIA (As que provavelmente faltavam!) ---
var energia_maxima: float = 100.0
var energia_atual: float = 100.0

# --- FUNÇÕES DE RECURSOS ---
func adicionar_recurso(nome_recurso: String, quantidade: int) -> void:
	if inventario_global.has(nome_recurso):
		inventario_global[nome_recurso] += quantidade
		recurso_alterado.emit(nome_recurso, inventario_global[nome_recurso])

# --- FUNÇÕES DE ENERGIA ---
func gastar_energia(quantidade: float) -> bool:
	if energia_atual >= quantidade:
		energia_atual -= quantidade
		energia_alterada.emit(energia_atual, energia_maxima)
		print("Global: Energia gasta! Atual: ", energia_atual)
		return true # Tinha energia e gastou com sucesso
	else:
		print("Global: Sem energia suficiente!")
		return false # Bloqueia a ação por falta de energia

func recarregar_energia_total() -> void:
	energia_atual = energia_maxima
	energia_alterada.emit(energia_atual, energia_maxima)
	print("Global: Energia totalmente recarregada após o sono!")

# --- FUNÇÕES DE CONTROLO DE CÉLULAS ---
func esta_celula_livre(coordenada_grelha: Vector2i) -> bool:
	return not celulas_ocupadas.has(coordenada_grelha)

func definir_ocupacao_celula(coordenada_grelha: Vector2i, ocupado: bool) -> void:
	if ocupado:
		celulas_ocupadas[coordenada_grelha] = true
	else:
		if celulas_ocupadas.has(coordenada_grelha):
			celulas_ocupadas.erase(coordenada_grelha)
# --- EFEITOS VISUAIS (Adicionar no fim do DadosDoJogo.gd) ---
func criar_texto_energia(quantidade: float, posicao_mundo: Vector2) -> void:
	# Cria um nó de texto dinamicamente
	var label = Label.new()
	label.text = "-" + str(int(quantidade))
	
	# Cor vermelha/laranja para indicar gasto de energia
	label.modulate = Color(1.0, 0.35, 0.35) 
	label.global_position = posicao_mundo - Vector2(8, 16) # Centraliza sobre o clique
	
	# Garante que o texto fica por cima de tudo no Mundo
	var arvore_atual = Engine.get_main_loop() as SceneTree
	if arvore_atual and arvore_atual.current_scene:
		arvore_atual.current_scene.add_child(label)
	
	# Animação fluida com Tween (Sobe e desaparece)
	var tween = label.create_tween().set_parallel(true)
	# Sobe 25 píxeis em 0.5 segundos
	tween.tween_property(label, "global_position:y", label.global_position.y - 25, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Desvanece a opacidade até sumir
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	# Remove o nó da memória do Godot assim que terminar a animação
	tween.chain().tween_callback(label.queue_free)


# --- BASE DE DADOS DE CONSTRUÇÃO ---
# --- BASE DE DADOS DE CONSTRUÇÃO EXPANDIDA ---
var dados_construcao: Dictionary = {
	"fabrica_flores": {
		"nome": "Fábrica de Flores",
		"custo_recurso": "flor_amarela",
		"custo_quantidade": 10,
		"cena": preload("res://fabrica_flores.tscn")
	},
	"prensa_oleo": {
		"nome": "Prensa de Óleo",
		"custo_recurso": "flor_amarela",
		"custo_quantidade": 15,
		"cena": preload("res://prensa_oleo.tscn") # 🌟 Nova máquina!
	}
}
