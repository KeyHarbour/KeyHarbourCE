#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

# Méthode corrigée pour fusionner récursivement deux Hash
def deep_merge(hash1, hash2)
  hash1.merge(hash2) do |key, old_val, new_val|
    if old_val.is_a?(Hash) && new_val.is_a?(Hash)
      deep_merge(old_val, new_val)
    else
      new_val # En cas de conflit direct, la valeur du dernier fichier chargé l'emporte
    end
  end
end

def combiner_fichiers_yaml(dossier_source, fichier_sortie)
  dictionnaire_final = {}

  # Récupérer tous les fichiers .yaml et .yml du dossier (triés par nom)
  fichiers = Dir.glob(File.join(dossier_source, "*.{yaml,yml}")).sort

  fichiers.each do |chemin_fichier|
    nom_fichier = File.basename(chemin_fichier)
    
    # On évite de lire le fichier de sortie s'il existe déjà
    next if nom_fichier == fichier_sortie

    puts "Lecture de : #{nom_fichier}"

    begin
      contenu = YAML.load_file(chemin_fichier)
      if contenu.is_a?(Hash)
        dictionnaire_final = deep_merge(dictionnaire_final, contenu)
      end
    rescue => e
      puts "  Erreur lors de la lecture de #{nom_fichier} : #{e.message}"
    end
  end

  # Écriture du résultat final en UTF-8
  File.open(fichier_sortie, 'w:utf-8') do |f|
    f.write(YAML.dump(dictionnaire_final))
  end

  puts "\n Succès ! Fichier combiné créé : #{fichier_sortie}"
end

# Exécution dans le dossier courant
combiner_fichiers_yaml('.', 'traduction_complete.yaml')
