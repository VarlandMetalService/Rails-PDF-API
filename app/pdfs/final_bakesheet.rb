class FinalBakesheet < VarlandPdf

  BACKGROUND_COLORS = Bakesheet::BACKGROUND_COLORS
  FOREGROUND_COLORS = Bakesheet::FOREGROUND_COLORS
    
  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait
  
  def initialize(data = nil)

    # Call parent constructor and store passed data.
    super()
    @data = data

    # Set options.
    @standard_color = '000000'
    @standard_font = 'Whitney'
    @data_color = '000000'
    @data_font = 'SF Mono'

    # Set up drawing.
    self.line_width = 0.015.in

    # Draw outline.
    self.print_data
    self.print_format
    @data[:shop_orders].each do |so|
      self.print_order(so[:number])
    end

    # Encrypt PDF.
    # encrypt_document(owner_password: :random,
    #                   permissions: {
    #                     print_document: true,
    #                     modify_contents: false,
    #                     copy_contents: true,
    #                     modify_annotations: false
    #                   })
      
  end

  def draw_temperature_graph(y)

    # Define chart size.
    chart_x = 0.25
    chart_y = y
    chart_width = 8
    chart_height = 3.5

    # Define y-axis.
    y_axis_max = 600;
    y_axis_min = 0;
    y_axis_ticks = 6;
    y_axis_interval = (y_axis_max - y_axis_min) / y_axis_ticks
    y_axis_height = chart_height - 0.5;
    y_axis_delta = y_axis_height.to_f / y_axis_ticks.to_f

    # Define y-axis tick mark labels.
    y_axis_label_height = 0.5
    y_axis_labels = ["#{y_axis_max}° F"]
    1.upto(y_axis_ticks) do |i|
      y_axis_labels << "#{y_axis_max - i * y_axis_interval}° F"
    end
    y_axis_label_widths = y_axis_labels.map {|l| self.calcwidth(l, 8, :bold) }
    y_axis_max_label_width = y_axis_label_widths.max + 0.02
    y_axis_label_x = chart_x
    y_axis_tick_x = y_axis_label_x + y_axis_max_label_width + 0.05
    y_axis_gridline_x = y_axis_label_x + y_axis_max_label_width + 0.1
    y_axis_gridline_width = chart_width - y_axis_gridline_x + chart_x
    data_x = y_axis_gridline_x
    data_width = y_axis_gridline_width
    data_height = y_axis_height
    data_start_value = y_axis_min.to_f
    data_end_value = y_axis_max.to_f
    data_y = chart_y - y_axis_height

    # Define x-axis.
    start_time = Time.at(@data[:loadings_entered]).in_time_zone("Eastern Time (US & Canada)").beginning_of_hour
    end_time = Time.at(@data[:soak_ended]).in_time_zone("Eastern Time (US & Canada)").end_of_hour.advance(seconds: 1)
    total_range = end_time.to_i - start_time.to_i
    x_increment = 1800
    count_increments = total_range / x_increment
    while count_increments > 7 do
      x_increment += 1800
      count_increments = total_range / x_increment
    end
    count_increments += 1
    end_time = start_time.advance(seconds: count_increments * x_increment)
    data_start_time = start_time
    data_end_time = end_time

    # puts ""
    # puts "X-Axis\n======"
    # puts "  Position (From Left)...: #{data_x.round(2)}″"
    # puts "  Width..................: #{data_width.round(2)}″"
    # puts "  Time @ Start...........: #{data_start_time.strftime("%m/%d/%y %I:%M %P")}"
    # puts "  Time @ End.............: #{data_end_time.strftime("%m/%d/%y %I:%M %P")}"
    # puts ""
    # puts "Y-Axis\n======"
    # puts "  Position (From Bottom).: #{data_y.round(2)}″"
    # puts "  Height.................: #{data_height.round(2)}″"
    # puts "  Minimum Value..........: #{data_start_value}° F"
    # puts "  Maximum Value..........: #{data_end_value}° F"
    # puts ""

    # Draw shaded area for soak.
    soak_start = Time.at(@data[:soak_started]).in_time_zone("Eastern Time (US & Canada)")
    soak_end = Time.at(@data[:soak_ended]).in_time_zone("Eastern Time (US & Canada)")
    soak_start_percentage = self.calculate_x_axis_percentage(soak_start, data_start_time, data_end_time)
    soak_end_percentage = self.calculate_x_axis_percentage(soak_end, data_start_time, data_end_time)
    soak_width = (soak_end_percentage - soak_start_percentage) * data_width
    soak_x = data_x + (soak_start_percentage * data_width)
    soak_y = data_y + data_height
    self.fbox(soak_x, soak_y, soak_width, data_height, "ffffcc")

    # Draw labels, gridlines, and tick marks.
    0.upto(count_increments) do |i|
      this_tick_x = data_x + i * (y_axis_gridline_width / count_increments)
      self.stroke_color = "dddddd"
      self.vline(this_tick_x, chart_y, y_axis_height)
      self.stroke_color = "000000"
      self.vline(this_tick_x, chart_y - y_axis_height + 0.05, 0.1)
      tick_time = start_time.advance(seconds: i * x_increment)
      label = tick_time.strftime("%l:%M%P\n%-m/%d")
      if i == 0
        this_label_x = this_tick_x
        this_label_align = :left
      elsif i == count_increments
        this_label_x = this_tick_x - 0.5
        this_label_align = :right
      else
        this_label_x = this_tick_x - 0.25
        this_label_align = :center
      end
      self.txtb(label, this_label_x, chart_y - y_axis_height - 0.1, 0.5, 0.5, 8, :bold, this_label_align, :top)
    end

    # Draw labels, gridlines, and tick marks.
    y_axis_label_y = chart_y
    y_axis_labels.each do |l|
      self.txtb(l, y_axis_label_x, y_axis_label_y + (y_axis_label_height / 2.0), y_axis_max_label_width, y_axis_label_height, 8, :bold, :right, :center)
      self.stroke_color = "dddddd"
      self.hline(y_axis_gridline_x, y_axis_label_y, y_axis_gridline_width)
      self.stroke_color = "000000"
      self.hline(y_axis_tick_x, y_axis_label_y, 0.1)
      y_axis_label_y -= y_axis_delta
    end

    # Draw individual temperature readings.
    @data[:readings].each do |r|
      reading_at = Time.at(r[:time]).in_time_zone("Eastern Time (US & Canada)")
      unless reading_at < data_start_time
        reading_percentage = self.calculate_x_axis_percentage(reading_at, data_start_time, data_end_time)
        reading_x = data_x + (reading_percentage * data_width)
        y_percentage = r[:value].to_f / data_end_value
        y_value = data_y + (y_percentage * data_height)
        if r[:probe] == "air"
          fill_color 'f26077'
          fill_circle [reading_x.in, y_value.in], 2
        else
          fill_color '3a8eed'
          fill_circle [reading_x.in, y_value.in], 3
        end
        fill_color '000000'
      end
    end   

    # Draw borders around chart area.
    self.hline(y_axis_gridline_x, chart_y, y_axis_gridline_width)                       # Top
    self.hline(y_axis_gridline_x, chart_y - y_axis_height, y_axis_gridline_width)       # Bottom
    self.vline(y_axis_gridline_x, chart_y, y_axis_height)                               # Left
    self.vline(chart_x + chart_width, chart_y, y_axis_height)                           # Right

  end

  def calculate_x_axis_percentage(point, min, max)

    total_range = (max.to_i - min.to_i).to_f
    point_position = (point.to_i - min.to_i).to_f
    point_percentage = point_position / total_range

    # puts "X-Axis Percentage\n================="
    # puts "  Value.......: #{point.strftime("%m/%d/%y %I:%M %P")}"
    # puts "  Min.........: #{min.strftime("%m/%d/%y %I:%M %P")}"
    # puts "  Max.........: #{max.strftime("%m/%d/%y %I:%M %P")}"
    # puts "  Total Range.: #{(total_range / 3600.0).round(2)} hours"
    # puts "  Value %.....: #{(100 * point_percentage).round(2)}%"
    # puts ""

    return point_percentage

  end

  def print_order(number)

    # Initialize new page.
    self.start_new_page

    # Look up shop order object.
    so = nil
    @data[:shop_orders].each do |s|
      if s[:number] == number
        so = s
        break
      end
    end

    # Draw header graphic.
    header_graphic = Rails.root.join('lib', 'images', 'logo_m_black_red.png')
    logo_height = 0.5
    logo_ratio = (0.65 / 0.75)
    image(header_graphic, at: [0.25.in, 10.75.in], width: (logo_ratio * logo_height).in, height: logo_height.in)

    # Draw title.
    title_position = 0.35 + (logo_ratio * logo_height)
    title_text = "Final Bakesheet: S.O. ##{number}"
    title_width = self.calcwidth(title_text, 20, :bold)
    self.txtb(title_text, title_position, 10.75, 8.25 - title_position, logo_height, 20, :bold, :left, :center)
    part_info = []
    part_info << so[:customer]
    part_info << so[:process_code]
    part_info << so[:part_id]
    unless so[:sub_id].blank?
      part_info << so[:sub_id]
    end
    self.txtb(part_info.join(" ● "), title_position + title_width + 0.1, 10.75, 8.25 - title_position - title_width - 0.1, logo_height, 12, :normal, :right, :center, @data_font)

    # Draw bake cycle information.
    y = 9.75
    self.fbox(0.25, y, 1, 0.3, "cccccc")
    self.fbox(1.25, y, 1, 1.2, "cccccc")
    self.fbox(3.25, y, 2, 1.2, "cccccc")
    self.hline(0.25, y, 8)
    self.hline(0.25, y - 1.2, 8)
    self.vline(0.25, y, 1.2)
    self.vline(1.25, y, 1.2)
    self.vline(2.25, y, 1.2)
    self.vline(3.25, y, 1.2)
    self.vline(5.25, y, 1.2)
    self.vline(8.25, y, 1.2)
    self.hline(0.25, y - 0.3, 8)
    self.hline(1.25, y - 0.6, 7)
    self.hline(1.25, y - 0.9, 7)
    self.txtb("Oven", 0.25, y, 1, 0.3, 10, :bold, :center, :center)
    self.txtb("#{@data[:oven]}#{@data[:side] == "P" ? "" : @data[:side]}", 0.25, y - 0.3, 1, 0.9, 20, :bold, :center, :center, @data_font, @data_color)
    labels = ["Loadings Entered By:", "Date/Time Loadings Entered:", "Date/Time Soak Started:", "Date/Time Soak Ended"]
    loadings_entered = Time.at(@data[:loadings_entered]).in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %l:%M%P")
    soak_started = Time.at(@data[:soak_started]).in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %l:%M%P")
    soak_ended = Time.at(@data[:soak_ended]).in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %l:%M%P")
    values = [@data[:employee], loadings_entered, soak_started, soak_ended]
    labels_2 = ["Set:", "Min:", "Max:", "Hours:"]
    values_2 = ["#{so[:setpoint]}° F", "#{so[:minimum]}° F", "#{so[:maximum]}° F", so[:hours].to_s]
    y = 9.75
    0.upto(3) do |i|
      self.txtb(labels_2[i], 1.25, y, 0.9, 0.3, 10, :bold, :right, :center)
      self.txtb(values_2[i], 2.35, y, 0.9, 0.3, 10, :bold, :left, :center, @data_font, @data_color)
      self.txtb(labels[i], 3.25, y, 1.9, 0.3, 10, :bold, :right, :center)
      self.txtb(values[i], 5.35, y, 2.9, 0.3, 10, :bold, :left, :center, @data_font, @data_color)
      y -= 0.3
    end

    # Set y position.
    y = 8.05
    
    # If shop order has "within" requirement, draw loads table.
    #unless so[:within] == 0
      y-= 0.5
      save_y = y
      so[:loads].each_with_index do |l, i|
        if l[:out_of_plating].blank?
          out_of_plating = ""
        else
          out_of_plating = Time.at(l[:out_of_plating]).in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %l:%M%P")
        end
        in_oven = Time.at(l[:in_oven]).in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %l:%M%P")
        self.fbox(0.25, y, 0.5, 0.3, BACKGROUND_COLORS[i])
        self.txtb(l[:number], 0.25, y, 0.5, 0.3, 10, :bold, :center, :center, @data_font, FOREGROUND_COLORS[i])
        self.txtb(out_of_plating, 0.85, y, 1.8, 0.3, 10, :bold, :left, :center, @data_font, @data_color)
        self.txtb(in_oven, 2.85, y, 1.8, 0.3, 10, :bold, :left, :center, @data_font, @data_color)
        self.txtb(l[:within], 4.75, y, 1.25, 0.3, 10, :bold, :center, :center, @data_font, @data_color)
        self.txtb(l[:hours_to_load], 6, y, 1.25, 0.3, 10, :bold, :center, :center, @data_font, @data_color)
        unless l[:within].blank?
          if l[:hours_to_load] > l[:within]
            self.fbox(7.25, y, 1, 0.3, "ff0000")
            self.txtb("No", 7.25, y, 1, 0.3, 10, :bold, :center, :center, @data_font, "ffffff")
          else
            self.txtb("Yes", 7.25, y, 1, 0.3, 10, :bold, :center, :center, @data_font, @data_color)
          end
        end
        y -= 0.3
      end
      y = save_y
      so[:loads].each_with_index do |l, i|
        y -= 0.3
        self.hline(0.25, y, 8)
      end
      temp_y = 8.05
      self.fbox(0.25, temp_y, 8, 0.5, "cccccc")
      self.hline(0.25, temp_y, 8)
      self.vline(0.25, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(0.75, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(2.75, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(4.75, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(6, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(7.25, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.vline(8.25, temp_y, 0.5 + 0.3 * so[:loads].length)
      self.txtb("Load #", 0.25, temp_y, 0.5, 0.5, 10, :bold, :center, :center)
      self.txtb("Date/Time Out of Plating", 0.75, temp_y, 2, 0.5, 10, :bold, :center, :center)
      self.txtb("Date/Time Loaded in Oven", 2.75, temp_y, 2, 0.5, 10, :bold, :center, :center)
      self.txtb("Bake Within\n(Hours)", 4.75, temp_y, 1.25, 0.5, 10, :bold, :center, :center)
      self.txtb("Time to Load\n(Hours)", 6, temp_y, 1.25, 0.5, 10, :bold, :center, :center)
      self.txtb("Met\nSpec?", 7.25, temp_y, 1, 0.5, 10, :bold, :center, :center)
      temp_y -= 0.5
      self.hline(0.25, temp_y, 8)
      y-= 0.5
    #end

    # Draw graph.
    self.draw_temperature_graph(y)

    # Print mini bakestand diagram.
    y -= 3.75
    mini_diagram_tray_width = 0.5
    mini_diagram_tray_height = 0.12
    mini_diagram_width = mini_diagram_tray_width * @data[:columns]
    mini_diagram_height = mini_diagram_tray_height * @data[:rows]
    self.fbox(0.25, y, mini_diagram_width, mini_diagram_tray_height, "cccccc")
    @data[:trays].each do |t|
      tray_row = (t[:number] / @data[:columns]) + 1
      tray_column = t[:number] - ((tray_row - 1) * @data[:columns]) + 1
      #tray_column = ((t[:number] - 1) / @data[:rows]) + 1
      #tray_row = t[:number] - ((tray_column - 1) * @data[:rows])
      tray_x = 0.25 + ((tray_column - 1) * mini_diagram_tray_width)
      tray_y = y - ((tray_row - 1) * mini_diagram_tray_height)
      if t[:shop_order] == so[:number]
        if t[:loads].length > 1
          load_x = tray_x
          t[:loads].each do |load_number|
            load_index = nil
            so[:loads].each_with_index do |l, i|
              if l[:number] == load_number
                load_index = i
                break
              end
            end
            self.fbox(load_x, tray_y, mini_diagram_tray_width / 2.0, mini_diagram_tray_height, BACKGROUND_COLORS[load_index])
            load_x += (mini_diagram_tray_width / 2.0)
          end
        else
          load_index = nil
          load_number = t[:loads][0]
          so[:loads].each_with_index do |l, i|
            if l[:number] == load_number
              load_index = i
              break
            end
          end
          self.fbox(tray_x, tray_y, mini_diagram_tray_width, mini_diagram_tray_height, BACKGROUND_COLORS[load_index])
        end
      else
        self.fbox(tray_x, tray_y, mini_diagram_tray_width, mini_diagram_tray_height, "555555")
      end
    end
    self.hline(0.25, y, mini_diagram_width)
    self.vline(0.25, y, mini_diagram_height)
    1.upto(@data[:rows]) do |i|
      self.hline(0.25, y - i * mini_diagram_tray_height, mini_diagram_width)
    end
    1.upto(@data[:columns]) do |i|
      self.vline(0.25 + i * mini_diagram_tray_width, y, mini_diagram_height)
    end

  end

  def print_data

    # Print orders table.
    y = 9.5
    row_height = 0.3
    @data[:shop_orders].each_with_index do |so, i|
      self.fbox(0.25, y, 5, row_height, BACKGROUND_COLORS[i])
      self.txtb(so[:number], 0.25, y, 1, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      part_info = []
      part_info << so[:customer]
      part_info << so[:process_code]
      part_info << so[:part_id]
      unless so[:sub_id].blank?
        part_info << so[:sub_id]
      end
      self.txtb(part_info.join(" ● "), 1.35, y, 3.8, row_height, 10, :normal, :left, :center, @data_font, FOREGROUND_COLORS[i])
      y -= row_height
    end

    # Print trays.
    tray_width = 1.5
    tray_height = 0.3
    columns = @data[:columns]
    rows = @data[:rows]
    total_width = columns * tray_width
    x = 0.25 + ((8 - total_width) / 2)
    y = 6
    @data[:trays].each do |t|
      # tray_column = ((t[:number] - 1) / @data[:rows]) + 1
      # tray_row = t[:number] - ((tray_column - 1) * @data[:rows])
      tray_row = (t[:number] / @data[:columns]) + 1
      tray_column = t[:number] - ((tray_row - 1) * @data[:columns]) + 1
      tray_x = x + ((tray_column - 1) * tray_width)
      tray_y = y - ((tray_row - 1) * tray_height)
      so_index = nil
      @data[:shop_orders].each_with_index do |so, i|
        if so[:number] == t[:shop_order]
          so_index = i
          break
        end
      end
      self.fbox(tray_x, tray_y, tray_width, tray_height, BACKGROUND_COLORS[so_index])
      self.txtb("#{t[:shop_order]} » #{t[:loads].join(" & ")}", tray_x, tray_y, tray_width, tray_height, 8, :bold, :center, :center, @data_font, FOREGROUND_COLORS[so_index])
    end

  end

  def print_format

    # Draw header graphic.
    header_graphic = Rails.root.join('lib', 'images', 'logo_m_black_red.png')
    logo_height = 0.5
    logo_ratio = (0.65 / 0.75)
    image(header_graphic, at: [0.25.in, 10.75.in], width: (logo_ratio * logo_height).in, height: logo_height.in)

    # Draw title.
    title_position = 0.35 + (logo_ratio * logo_height)
    self.txtb("Final Bakesheet: Bakestand ##{@data[:bakestand]}", title_position, 10.75, 8.25 - title_position, logo_height, 20, :bold, :left, :center)

    # Draw table for shop order details.
    self.fbox(0.25, 10, 8, 0.5, "cccccc")
    self.hline(0.25, 10, 8)
    self.hline(0.25, 9.5, 8)
    y = 9.5
    10.times do |i|
      y -= 0.3
      self.hline(0.25, y, 8)
    end
    self.vline(0.25, 10, 3.5)
    self.vline(1.25, 10, 3.5)
    self.vline(5.25, 10, 3.5)
    self.vline(8.25, 10, 3.5)
    self.txtb("S.O. #", 0.25, 10, 1, 0.5, 10, :bold, :center, :center)
    self.txtb("Part", 1.35, 10, 3.8, 0.5, 10, :bold, :left, :center)
    self.txtb("QC Approval to Dump", 5.25, 10, 3, 0.5, 10, :bold, :center, :center)

    # Draw bakestand diagram.
    tray_width = 1.5
    tray_height = 0.3
    columns = @data[:columns]
    rows = @data[:rows]
    total_width = columns * tray_width
    x = 0.25 + ((8 - total_width) / 2)
    y = 6
    self.fbox(x, y, total_width, tray_height, "cccccc")
    1.upto(columns) do |c|
      1.upto(rows) do |r|
        tray_x = x + ((c - 1) * tray_width)
        tray_y = y - ((r - 1) * tray_height)
        self.hline(tray_x, tray_y, tray_width)
        self.vline(tray_x, tray_y, tray_height)
      end
    end
    self.hline(x, y - rows * tray_height, columns * tray_width)
    self.vline(x + columns * tray_width, y, rows * tray_height)
    self.txtb("VIEW FROM LOADING SIDE OF BAKE STAND", x, y - rows * tray_height, total_width, 0.25, 8, :bold, :center, :center)
    1.upto(columns) do |c|
      self.txtb("DO NOT USE", x + ((c - 1) * tray_width), y, tray_width, tray_height, 8, :bold, :center, :center, nil, "999999")
    end

  end
  
end