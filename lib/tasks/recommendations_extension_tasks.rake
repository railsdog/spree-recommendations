require 'fastercsv'

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
      
      desc "export customers in csv for Recoset"
      task :export_customers => :environment do
        timestamp = Time.now.to_i.to_s
        
        puts "saving customers"
        file_name = "customers.csv.#{timestamp}"
        FasterCSV.open(file_name, "w") do |csv|
          csv << ['id', 'firstname', 'address', 'city', 'country', 'zipcode']
        end
        sql = <<-eos
          COPY (
          SELECT u.id, a.firstname, a.address1 as address, a.city, c.iso as country, a.zipcode
          FROM users u
          LEFT JOIN addresses a ON (a.id = u.ship_address_id)
          LEFT JOIN countries c ON (c.id = a.country_id)
          WHERE a.id IS NOT NULL)
          TO '/tmp/#{file_name}' CSV;
        eos
        ActiveRecord::Base.connection.execute(sql)
        `cat /tmp/#{file_name} >> #{file_name}`
        
        puts "saving products"
        file_name = "products.csv.#{timestamp}"
        FasterCSV.open(file_name, "w") do |csv|
          csv << ["id", "master_product_id", "price", "name", "description"] # TODO: category/tags => taxon?
        end
        sql = <<-eos
          COPY (
          SELECT v.id, p.id as master_product_id, v.price, p.name, p.description
          FROM variants v
          LEFT JOIN products p ON (p.id=v.product_id))
          TO '/tmp/#{file_name}' CSV;
        eos
        ActiveRecord::Base.connection.execute(sql)
        `cat /tmp/#{file_name} >> #{file_name}`
        
        
        puts "saving orders"
        FasterCSV.open("orders.csv.#{timestamp}", "w") do |csv|
          csv <<  ["id", "customer_id", "date", "total_amount", "cc_type", "cc_expiry", "shipping_type"]
          Order.all.each do |o|
            cc = o.creditcards.first
            csv << [o.id, o.user_id, o.created_at, o.total, (cc ? cc.cc_type : ''), o.checkout.shipping_method_id || '0']
          end
        end
        
        puts "saving order line items"
        file_name = "purchased_items.csv.#{timestamp}"
        FasterCSV.open(file_name, "w") do |csv|
          # nice to have: "discount_percentage", but adjustment is currently stored in orders rather than items.
          csv << ["order_id", "product_id", "quantity", "amount"]
        end
        sql = <<-eos
          COPY (
          SELECT order_id, variant_id as product_id, quantity, price as amount 
          FROM line_items)
          TO '/tmp/#{file_name}' CSV;
        eos
        ActiveRecord::Base.connection.execute(sql)
        `cat /tmp/#{file_name} >> #{file_name}`          

      end
    end
  end
end
