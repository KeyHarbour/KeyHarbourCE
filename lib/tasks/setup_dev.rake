namespace :dev do
  desc "Charge proprement les fixtures de spec avec l'environnement complet"
  task load_fixtures: :environment do
    # Forcer l'initialisation complète du gestionnaire d'encryption
    ActiveRecord::Encryption.config
    
    # Exécuter le chargement des fixtures programmatiquement
    ENV['FIXTURES_PATH'] = 'spec/fixtures'
    Rake::Task['db:fixtures:load'].invoke

    (Time.current.advance(months: -2).beginning_of_month.to_date..Time.current.to_date).each do |day|
      print "\rCalculate for #{day}"
      ApiQuery.build_from_last_date
      Account.all.each do |account|
        Usage.daily_job(account, day)
      end
    end
    puts "\nCalculation done"
    Rake::Task['meilisearch:reindex'].invoke
  end

  desc "Test l'encryption"
  task test: :environment do
    # if defined?(Dotenv)
    #   puts "🌱 Chargement des variables d'environnement depuis le fichier .env..."
    #   Dotenv.load('.env')
    # else
    #   puts "⚠️ Dotenv n'est pas détecté, assurez-vous que vos variables d'environnement sont chargées."
    # end
    ActiveRecord::Encryption.config
    
    if ActiveRecord::Encryption.key_provider.nil?
      raise "❌ Erreur : Aucun Key Provider trouvé. Vos clés d'encryption ne sont pas chargées."
    else
      puts "Provider found !"
    end
    test_chaine = "Vérification Chiffrement Rails"

    begin
      texte_chiffre = ActiveRecord::Encryption::Encryptor.new.encrypt(test_chaine)
      puts texte_chiffre
      texte_dechiffre = ActiveRecord::Encryption::Encryptor.new.decrypt(texte_chiffre)
      
      if texte_dechiffre == test_chaine
        puts "✅ Chiffrement actif et fonctionnel (Clés validées)."
      else
        raise "❌ Erreur : Le texte déchiffré ne correspond pas."
      end
    rescue => e
      raise "❌ Échec critique du chiffrement : #{e.message}"
    end   
    
    st = Statefile.first
    st.content = "ABC"
    st.save
  end  
end