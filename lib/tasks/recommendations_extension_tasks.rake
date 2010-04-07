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
        
        puts "saving customers"
        file_name = "customers.csv.#{timestamp}"
        File.open(file_name, "w") do |f|
          f.puts ['id', 'firstname', 'address', 'city', 'country', 'zipcode'].join(',')
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
        File.open(file_name, "w") do |f|
          f.puts ["id", "master_product_id", "price", "name", "description"].join(',') # TODO: category/tags => taxon?
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
        file_name = "orders.csv.#{timestamp}"
        File.open(file_name, "w") do |f|
          f.puts ["id", "customer_id", "date", "total_amount", "cc_type", "cc_expiry", "shipping_type"].join(',')
        end
        sql = <<-eos
          COPY (
          SELECT o.id, COALESCE(o.user_id, 0) as user_id, o.created_at as date, o.total,
            COALESCE(cc.cc_type, '') as cc_type,
            cc.year||'-'||cc.month||'-01' as cc_expiry,
            COALESCE(c.shipping_method_id, 0) as shipping_type
          FROM orders o
          LEFT JOIN checkouts c ON (o.id = c.order_id)
          LEFT JOIN payments p ON ((p.payable_id = c.id AND p.payable_type = 'Checkout') OR
            (p.payable_id = o.id AND p.payable_type = 'Order'))
          LEFT JOIN creditcards cc ON (cc.id = p.source_id AND p.source_type = 'Creditcard'))
          TO '/tmp/#{file_name}' CSV;
        eos
        ActiveRecord::Base.connection.execute(sql)
        `cat /tmp/#{file_name} >> #{file_name}`
        
        
        puts "saving order line items"
        file_name = "purchased_items.csv.#{timestamp}"
        File.open(file_name, "w") do |f|
          # nice to have: "discount_percentage", but adjustment is currently stored in orders rather than items.
          f.puts ["order_id", "product_id", "quantity", "amount"].join(',')
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
