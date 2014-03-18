require 'yaml'
namespace :dev do

  desc "Populate database with data from lib/fixtures"
  task :populate => :environment do
    File.open(Rails.root + 'lib/tasks/fixtures.yml') do |file|
      YAML.load_documents(file) do |hash|
        hash["study_products"].each do |study_product_hash|
          product_hash = study_product_hash.delete("product")
          products_services_hashes = product_hash["products_services"] || []
          product = find_or_initialize_project(Product, product_hash)
          if product.new_record?
            product.save 
            products_services_hashes.each do |products_services_hash|
              service_hash = products_services_hash.delete("service")
              service = find_or_initialize_project(Service, service_hash)
              service.save if service.new_record?
              ProductsService.create(:uuid => products_services_hash["uuid"],
                                     :product => product,
                                     :service => service)
              puts "    Added ProductService for #{service.name} to product #{product.name}"
            end
          end
          study_product = StudyProduct.create(:study_uri => study_product_hash['study_uri'],
                                              :product => product,
                                              :uuid => study_product_hash["uuid"])
          puts "Created StudyProduct for Study with URI #{study_product.study_uri} with #{product.name}"
        end
      end
    end
  end

  def find_or_initialize_project(creator, params)
    project = creator.
      where(:name => params["name"],
            :github_url => params["github_url"],
            :uuid => params["uuid"]).
      first_or_initialize(:name => params["name"],
                          :github_url => params["github_url"],
                          :uuid => params["uuid"])
    puts "  Found or Initialized #{creator.to_s.humanize.downcase} #{project.name}"
    project
  end
end
