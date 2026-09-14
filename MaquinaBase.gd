# MaquinaBase.gd
extends Area2D
class_name MaquinaBase

@export_group("Consumos por Ciclo")
@export var custo_eletricidade: float = 1.0
@export var custo_oleo: float = 0.5
@export var tempo_ciclo: float = 5.0

var timer_interno: Timer
var maquina_ligada: bool = true
@onready var indicador_visual: Sprite2D = $IndicadorOnOff 

func _ready() -> void:
	# # 🌟 CORREÇÃO 1: Adiciona a máquina ao grupo para o jogador conseguir clicar!
	add_to_group("Maquinas")
	
	# Cria e configura o Timer automaticamente
	timer_interno = Timer.new()
	timer_interno.wait_time = tempo_ciclo
	timer_interno.one_shot = false
	timer_interno.autostart = true
	add_child(timer_interno)
	timer_interno.timeout.connect(_processar_ciclo_maquina)
	
	# Garante que o visual começa correto com base no estado inicial
	atualizar_indicador_visual()

# Referência ao novo nó que vai flutuar no topo do teu pixel art
@onready var icone_producao: Sprite2D = $IconeProducao

# 🌟 Dicionário com os caminhos reais dos teus ícones individuais!
# (⚠️ AJUSTA OS CAMINHOS entre aspas para as pastas exatas onde guardas as tuas imagens!)
const ICONES = {
	"ingot_iron": preload("res://icones/IconIronIngot.png"),

}

# Função automática que altera a textura do balão flutuante
func atualizar_icone_produto(id_receita: String) -> void:
	if not is_instance_valid(icone_producao):
		print("⚠️ Erro: O nó IconeProducao não foi encontrado nesta máquina!")
		return
		
	# Se a máquina não tiver receita ativa ("nenhuma" ou vazia), esconde o balão
	if id_receita == "nenhuma" or id_receita == "" or not ICONES.has(id_receita):
		icone_producao.visible = false
		return
		
	# Se a receita for válida, injeta a imagem e torna-a visível por cima do teto
	icone_producao.texture = ICONES[id_receita]
	icone_producao.visible = true
	print("✨ SUCESSO: Ícone atualizado visualmente para: ", id_receita)

# 🌟 A FUNÇÃO QUE FALTAVA (Escrita fora do _ready(), alinhada à parede esquerda!):
func alternar_estado() -> void:
	maquina_ligada = !maquina_ligada # Inverte o valor (se era true passa a false)
	
	if maquina_ligada:
		print("🔌 Máquina LIGADA!")
		if timer_interno:
			timer_interno.start() # 🟢 Reativa o ciclo
		modulate = Color(1.0, 1.0, 1.0) # Restaura a cor brilhante
	else:
		print("🛑 Máquina DESLIGADA!")
		if timer_interno:
			timer_interno.stop() # 🔴 Para o relógio imediatamente
		efeito_visual_parado() # Deixa a máquina escura em OFF
			
	atualizar_indicador_visual()

# 🌟 4. Nova função para gerir os frames da tua imagem (Vermelho/Verde)
func atualizar_indicador_visual() -> void:
	if is_instance_valid(indicador_visual):
		if maquina_ligada:
			indicador_visual.frame = 1 # 🟢 Frame Verde (Luz Ligada)
		else:
			indicador_visual.frame = 0 # 🔴 Frame Vermelho (Luz Desligada)

func _processar_ciclo_maquina() -> void:
	# 🌟 CORREÇÃO 2: Se a máquina estiver desligada no interruptor, 
	# aborta imediatamente e não gasta nem produz nada!
	if not maquina_ligada:
		efeito_visual_parado()
		return
		
	# 1. Verifica se há eletricidade e óleo suficientes no sistema global
	var tem_eletricidade = DadosDoJogo.inventario_global["eletricidade"] >= custo_eletricidade
	var tem_oleo = DadosDoJogo.inventario_global["oleo_vegetal"] >= custo_oleo
	
	# 2. Pergunta à máquina filha se ela tem os seus ingredientes extra
	var maquina_pronta = pode_executar()
	
	if tem_eletricidade and tem_oleo and maquina_pronta:
		# 3. Consome os recursos globais
		DadosDoJogo.inventario_global["eletricidade"] -= custo_eletricidade
		DadosDoJogo.inventario_global["oleo_vegetal"] -= custo_oleo
		
		# Força a atualização da UI
		DadosDoJogo.recurso_alterado.emit("eletricidade", DadosDoJogo.inventario_global["eletricidade"])
		DadosDoJogo.recurso_alterado.emit("oleo_vegetal", DadosDoJogo.inventario_global["oleo_vegetal"])
		
		# 4. Executa o trabalho específico da máquina
		executar_trabalho()
		efeito_visual_sucesso()
		
		modulate = Color(1.0, 1.0, 1.0)
	else:
		efeito_visual_parado()

# 🌟 5. O AJUSTE CRÍTICO: Atualiza a tua função "pode_executar()" existente!
# Tens de acrescentar a condição da máquina estar ligada.
func pode_executar() -> bool:
	# Só dá luz verde à máquina se ela estiver fisicamente LIGADA no botão 
	# AND cumprir os teus requisitos antigos de óleo/eletricidade!
	return maquina_ligada and (DadosDoJogo.inventario_global["oleo_vegetal"] >= custo_oleo) # (ou a tua regra atual)
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
