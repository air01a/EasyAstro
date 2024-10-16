# -*- coding: utf-8 -*-
import os
from flask import Flask, render_template_string, send_from_directory, abort

app = Flask(__name__)

# Fonction pour obtenir l'arborescence des fichiers
def get_file_tree(path):
    file_tree = []
    for root, dirs, files in os.walk(path):
        level = root.replace(path, '').count(os.sep)
        indent = ' ' * 4 * level
        file_tree.append(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 4 * (level + 1)
        for f in files:
            # Ajouter des liens pour le téléchargement
            relative_path = os.path.relpath(os.path.join(root, f), path)
            file_tree.append(f'{subindent}<a href="/download/{relative_path}">{f}</a>')
    return file_tree

@app.route('/')
def index():
    # Chemin de l'arborescence à exposer (par défaut le répertoire courant)
    path = os.getcwd()
    file_tree = get_file_tree(path)
    
    # Modèle HTML simple pour afficher l'arborescence
    template = """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>File Tree</title>
      </head>
      <body>
        <h1>File Tree</h1>
        <pre>{{ file_tree | join('\n') }}</pre>
      </body>
    </html>
    """
    
    return render_template_string(template, file_tree=file_tree)

# Route pour le téléchargement de fichiers
@app.route('/application/<path:filename>')
def download_file(filename):
    # Chemin de l'arborescence à exposer (par défaut le répertoire courant)
    path = os.getcwd()
    
    # Vérifier si le fichier existe
    if not os.path.isfile(os.path.join(path, filename)):
        abort(404)  # Renvoie une erreur 404 si le fichier n'existe pas

    return send_from_directory(path, filename,  as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True)
