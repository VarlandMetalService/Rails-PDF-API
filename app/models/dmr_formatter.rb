class DmrFormatter

  def self.parse(dmr_json)
    @dmr = { }
    @raw = JSON.parse(dmr_json, {symbolize_names: true})
    basic_attributes = @raw[:data][:attributes]
    number_parts = basic_attributes[:number].split("-")
    @dmr[:year] = number_parts[0].to_i
    @dmr[:number] = number_parts[1].to_i
    @dmr[:pounds] = basic_attributes[:weight].to_f
    @dmr[:pieces] = basic_attributes[:pieces].to_i
    @dmr[:samples_sent] = basic_attributes[:samples_sent]
    @dmr[:disposition] = basic_attributes[:part_disposition]
    @dmr[:defect_discovered] = basic_attributes[:found_when]
    @dmr[:notified_via] = basic_attributes[:notified_by]
    @dmr[:po_numbers] = basic_attributes[:purchase_order_numbers]
    @dmr[:defect_description] = basic_attributes[:defect_description]
    @dmr[:corrective_action] = basic_attributes[:corrective_action]
    @dmr[:customer_instructions] = basic_attributes[:customer_instruction]
    @dmr[:date] = DateTime.parse(basic_attributes[:created_at]).strftime("%m/%d/%y")
    @raw[:included].each do |i|
      case i[:type]
      when "customer"
        @dmr[:customer] = i[:attributes][:name]
      when "address"
        @dmr[:address] = { }
        @dmr[:address][:street] = i[:attributes][:line_one]
        unless i[:attributes][:line_two].blank?
          @dmr[:address][:street] += "\n#{i[:attributes][:line_two]}"
        end
        @dmr[:address][:city] = i[:attributes][:city]
        @dmr[:address][:state] = i[:attributes][:state]
        @dmr[:address][:zip] = i[:attributes][:zip]
      when "contact"
        @dmr[:attn] = i[:attributes][:name]
        @dmr[:attn_title] = i[:attributes][:description]
      when "part"
        @dmr[:part_id] = i[:attributes][:code]
        @dmr[:part_sub_id] = i[:attributes][:code_sub]
        @dmr[:part_name] = i[:attributes][:name]
        @dmr[:part_description] = i[:attributes][:description]
      when "shop_order"
        @dmr[:shop_order] = i[:attributes][:number].to_i
      when "user"
        @dmr[:sent_by] = i[:attributes][:full_name]
        @dmr[:sent_by_title] = i[:attributes][:title]
      end
    end
    parse_files
    return @dmr
  end

  def self.parse_files
    @dmr[:attachments] = []
    @raw[:data][:attributes][:files].each do |f|
      this_file = { }
      this_file[:content_type] = f[:data][:attributes][:content_type]
      this_file[:url] = f[:data][:links][:self]
      if this_file[:content_type].match(/image/)
        this_file[:height] = f[:data][:attributes][:metadata][:height].to_i
        this_file[:width] = f[:data][:attributes][:metadata][:width].to_i
      end
      
      @dmr[:attachments] << this_file
    end
  end

end