extends Button

# 🌟 Referência à nova Label que está SEMPRE visível no ecrã!
@onready var label_calendario: Label = $"../PanelContainerCalendario/LabelCalendarioSempreVisivel"

# Referências antigas do painel retrátil
@onready var painel_missoes: PanelContainer = $PainelMissoes
@onready var label_texto: Label = $PainelMissoes/LabelTexto

func _ready() -> void:
	if painel_missoes:
		painel_missoes.visible = false
		
	pressed.connect(_on_botao_pressed)
	atualizar_interface_tempo_e_contrato()

func _process(_delta: float) -> void:
	# 🌟 Atualiza continuamente as duas Labels para refletir 
	# o novo dia instantaneamente assim que o jogador acorda da cama!
	atualizar_interface_tempo_e_contrato()

func _on_botao_pressed() -> void:
	if painel_missoes:
		painel_missoes.visible = !painel_missoes.visible

func atualizar_interface_tempo_e_contrato() -> void:
	# 1. Puxamos as variáveis de tempo do DadosDoJogo.gd
	var dia = DadosDoJogo.dia_atual
	var nome_dia = DadosDoJogo.get_nome_do_dia()
	var semana = DadosDoJogo.semana_actual if "semana_actual" in DadosDoJogo else DadosDoJogo.semana_atual
	
	# ==========================================
	# 🌟 2. ATUALIZA A LABEL SEMPRE VISÍVEL (Calendário)
	# ==========================================
	if is_instance_valid(label_calendario):
		label_calendario.text = "📅 Dia " + str(dia) + " | Sem. " + str(semana)

	# ==========================================
	# 📦 3. ATUALIZA A LABEL RETRÁTIL (Lista do Contrato)
	# ==========================================
	if is_instance_valid(label_texto) and painel_missoes and painel_missoes.visible:
		var texto_final = "📜 CONTRATO DA SEMANA " + str(semana) + ":\n"
		
		var itens_exigidos = []
		for recurso in DadosDoJogo.taxa_semanal_ativa:
			var quantidade = DadosDoJogo.taxa_semanal_ativa[recurso]
			var nome_bonito = recurso.capitalize().replace("_", " ")
			itens_exigidos.append("  • " + nome_bonito + ": " + str(quantidade))
			
		if itens_exigidos.size() > 0:
			texto_final += "\n".join(itens_exigidos)
		else:
			texto_final += "  • Nenhum (Semana Livre!)"
			
		label_texto.text = texto_final
