# fundicao.gd
extends MaquinaBase


# O setter garante que sempre que a receita muda por código, o ícone muda no ecrã!
var receita_atual_id: String = "nenhuma":
	set(novo_id):
		receita_atual_id = novo_id
		atualizar_icone_produto(novo_id) # 👈 Avisa o pai para trocar a imagem!

func _ready() -> void:
	custo_eletricidade = 2.0  
	custo_oleo = 1.0         
	tempo_ciclo = 6.0
	
	super._ready()
	# Força o ícone inicial no arranque (caso a máquina se lembre da receita anterior)
	atualizar_icone_produto(receita_atual_id)
# 🌟 MODIFICAÇÃO DO PODE_EXECUTAR: 
# Além da eletricidade/óleo, o pai vai perguntar se temos minério suficiente para a receita ativa!
func pode_executar() -> bool:
	# Se não houver receita selecionada, a máquina não trabalha
	if receita_atual_id == "nenhuma":
		return false
		
	var receita = DadosDoJogo.receitas_fundicao[receita_atual_id]
	var inv = DadosDoJogo.inventario_global
	
	# Verifica se temos minério suficiente no stock global da base
	var tem_minerio = inv[receita["ingrediente"]] >= receita["quantidade_ingrediente"]
	
	return maquina_ligada and tem_minerio

# 🌟 O TRABALHO DA MÁQUINA:
func executar_trabalho() -> void:
	var receita = DadosDoJogo.receitas_fundicao[receita_atual_id]
	var inv = DadosDoJogo.inventario_global
	
	# Consome o Minério Bruto
	inv[receita["ingrediente"]] -= receita["quantidade_ingrediente"]
	# Produz a Barra Refinada
	inv[receita["resultado"]] += receita["quantidade_resultado"]
	
	# Emite os sinais para avisar os teus menus e UI
	DadosDoJogo.recurso_alterado.emit(receita["ingrediente"], inv[receita["ingrediente"]])
	DadosDoJogo.recurso_alterado.emit(receita["resultado"], inv[receita["resultado"]])
	
	print("🔥 Fundição: Transformou ", receita["quantidade_ingrediente"], " minérios em ", receita["nome_ui"], "!")
