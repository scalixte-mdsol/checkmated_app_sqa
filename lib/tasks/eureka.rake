namespace :admin do
  desc "Deploy all api docs to Eureka"
  task :deploy_api_docs do
    require_relative '../../config/initializers/euresource'
    begin
      Euresource.eureka_client.deploy_apis!(api_docs)
      puts "Api doc deployment succeeded."
    rescue => e
      puts "Api doc deployment failed or was redundant."
      puts e.message
    end
  end
end

def api_docs
  Dir.glob(File.join('apis','api_document_v*.yml')).map{ |file| YAML.load_file(file) }
end
