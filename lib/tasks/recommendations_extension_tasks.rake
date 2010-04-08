namespace :spree do
  namespace :extensions do
    namespace :recommendations do
      desc "Copies public assets of the Recommendations to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[RecommendationsExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(RecommendationsExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      
      desc "export data in csv for Recoset"
      task :export => :environment do
        timestamp = Time.now.to_i.to_s
        target_dir = File.join(RAILS_ROOT, "public", "csv")
        Dir.mkdir(target_dir) unless File.exists? target_dir
        
        puts "saving customers"
        Spree::CSV.export_customers("customers.csv.#{timestamp}", target_dir)
        
        puts "saving products"
        Spree::CSV.export_products("products.csv.#{timestamp}", target_dir)
        
        puts "saving orders"
        Spree::CSV.export_orders("orders.csv.#{timestamp}", target_dir)

        puts "saving order line items"
        Spree::CSV.export_line_items("purchased_items.csv.#{timestamp}", target_dir)         

      end

    end
  end
end
