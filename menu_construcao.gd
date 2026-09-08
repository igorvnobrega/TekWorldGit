# MenuConstrucao.gd
extends HBoxContainer

func _ready() -> void:
	# O símbolo $ procura o nó filho pelo nome exato. 
	# Altera "BotaoFabrica" para o nome exato que deste ao teu botão no painel de cenas!
	if has_node("BotaoFabrica"):
		$BotaoFabrica.pressed.connect(_on_botao_fabrica_pressed)
	else:
		print("ERRO: Não encontrou o nó chamado BotaoFabrica dentro do MenuConstrucao!")

func _on_botao_fabrica_pressed() -> void:
	print("Menu UI: Botão da Fábrica foi clicado!") # 🌟 Isto vai ajudar a testar na Consola!
	
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao("fabrica_flores")
	else:
		print("ERRO: Não encontrou o Jogador ou o Jogador não tem a função entrar_modo_construcao!")
func _on_botao_solar_pressed() -> void:
	enviar_ordem_construcao("gerador_energia")

func enviar_ordem_construcao(id_maquina: String) -> void:
	var jogador = get_tree().get_first_node_in_group("Jogador")
	if jogador and jogador.has_method("entrar_modo_construcao"):
		jogador.entrar_modo_construcao(id_maquina)
