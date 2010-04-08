class Api::ExportController < Api::BaseController
  before_filter :set_file_names
  
  [:customers, :products, :orders, :line_items].each do |action_name|
    define_method(action_name) do
      unless exported_recently(@target_file) 
        Spree::CSV.send("export_#{action_name}", @file_name, @target_dir, @start_date)
      end
      send_file(@target_file)
    end
  end

  private
  
  def set_file_names
    if (params[:year])
      @start_date = Time.local(params[:year], params[:month], params[:day])
    end
    if @start_date
      @file_name = "#{self.action_name}_#{@start_date.to_date.to_s(:db)}.csv"
    else
      @file_name = "#{self.action_name}.csv"
    end
    @target_dir = File.join(RAILS_ROOT, "tmp")
    @target_file = File.join(@target_dir, @file_name)
  end
  
  def exported_recently(target_file)
    File.exists?(target_file) && (File.new(target_file).mtime + 1.hour > Time.now)
  end
end
