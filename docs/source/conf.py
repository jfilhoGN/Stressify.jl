# Configuration file for the Sphinx documentation builder.

# -- Project information -----------------------------------------------------
project = 'Stressify.jl'
copyright = '2024, JFilhoGN'
author = '@jfilhogn'

# -- General configuration ---------------------------------------------------
extensions = ['sphinx.ext.autodoc', 'sphinx.ext.viewcode']

# Paths for templates
templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
