class Spree::CSV

  class << self

    def export_customers(file_name, target_dir)
      header_fields = ['id', 'firstname', 'address', 'city', 'country', 'zipcode']
      sql = <<-eos
        COPY (
        SELECT u.id, a.firstname, a.address1 as address, a.city, c.iso as country, a.zipcode
        FROM users u
        LEFT JOIN addresses a ON (a.id = u.ship_address_id)
        LEFT JOIN countries c ON (c.id = a.country_id)
        WHERE a.id IS NOT NULL)
        TO '/tmp/#{file_name}' CSV;
      eos
      
      export(header_fields, sql, file_name, target_dir)
    end

    def export_products(file_name, target_dir)
      header_fields = ["id", "master_product_id", "price", "name", "description"]
      sql = <<-eos
        COPY (
        SELECT v.id, p.id as master_product_id, v.price, p.name, p.description
        FROM variants v
        LEFT JOIN products p ON (p.id=v.product_id))
        TO '/tmp/#{file_name}' CSV;
      eos
      
      export(header_fields, sql, file_name, target_dir)
    end

    def export_orders(file_name, target_dir)
      header_fields = ["id", "customer_id", "date", "total_amount", "cc_type", "cc_expiry", "shipping_type"]
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
      
      export(header_fields, sql, file_name, target_dir)
    end

    def export_line_items(file_name, target_dir)
      header_fields = ["order_id", "product_id", "quantity", "amount"]
      sql = <<-eos
        COPY (
        SELECT order_id, variant_id as product_id, quantity, price as amount 
        FROM line_items)
        TO '/tmp/#{file_name}' CSV;
      eos
      
      export(header_fields, sql, file_name, target_dir)
    end
    
    private
    
    def export(header_fields, sql, file_name, target_dir)
      target_file = File.join(target_dir, file_name)
      File.open(target_file, "w") do |f|
        f.puts header_fields.join(',')
      end
      ActiveRecord::Base.connection.execute(sql)
      `cat /tmp/#{file_name} >> #{target_file}`
    end
  
  end
end
