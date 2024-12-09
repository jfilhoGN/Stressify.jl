# Makefile for Sphinx documentation
# Adapted for Stressify.jl

# Diretório de saída (build)
BUILDDIR = build

# Comandos padrão
.PHONY: help clean html latexpdf

help:
	@echo "Makefile para documentação do Stressify.jl"
	@echo ""
	@echo "Opções disponíveis:"
	@echo "  make clean      - Remove arquivos de build"
	@echo "  make html       - Gera a documentação em HTML"
	@echo "  make latexpdf   - Gera a documentação em PDF usando LaTeX"
	@echo ""

clean:
	@echo "Limpando arquivos de build..."
	rm -rf $(BUILDDIR)/*

html:
	@echo "Gerando documentação em HTML..."
	sphinx-build -b html source $(BUILDDIR)/html

latexpdf:
	@echo "Gerand
