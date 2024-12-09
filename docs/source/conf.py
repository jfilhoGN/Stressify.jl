import os
import sys
sys.path.insert(0, os.path.abspath('.'))

project = 'Stressify'
author = 'João Martins Filho @jfilhogn'
release = '0.1'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx_rtd_theme',
]

#templates_path = ['_templates']
exclude_patterns = ['_build', '**/.ipynb_checkpoints']

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
