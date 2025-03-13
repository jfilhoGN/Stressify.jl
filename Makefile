.PHONY: all clean help debug

SCRIPTS_DIR := examples
SCRIPTS := $(wildcard $(SCRIPTS_DIR)/*.jl)
LOGS_DIR := logs
JULIA_CMD := julia

all:
	@mkdir -p $(LOGS_DIR)
	@for script in $(SCRIPTS); do \
		echo "Executando $$script..."; \
		$(JULIA_CMD) $$script > $(LOGS_DIR)/$$(basename $$script).log 2>&1; \
		if [ $$? -ne 0 ]; then \
			echo "Erro ao executar $$script. Verifique o log: $(LOGS_DIR)/$$(basename $$script).log"; \
			exit 1; \
		else \
			echo "$$script executado com sucesso."; \
		fi \
	done

clean:
	@echo "Limpando logs..."
	@rm -rf $(LOGS_DIR)/*.log

help:
	@echo "Uso: make [alvo]"
	@echo "Makefile para execução de scripts Examples Julia"
	@echo "Alvos disponíveis:"
	@echo "  all       - Executa todos os scripts"
	@echo "  clean     - Remove os logs"
	@echo "  help      - Exibe esta mensagem de ajuda"

debug:
	@echo "Scripts encontrados:"
	@echo $(SCRIPTS)
