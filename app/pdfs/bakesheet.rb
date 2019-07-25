class Bakesheet < VarlandPdf

  BACKGROUND_COLORS = ['7be042',
                       'ff657f',
                       '9cb5f2',
                       'ffc72d',
                       'b677ff',
                       '73fdff',
                       'fca7ff',
                       'bdffd1',
                       'ffd6bd',
                       'dcecff']
  FOREGROUND_COLORS = ['000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000',
                       '000000']
    
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

    # Encrypt PDF.
    encrypt_document(owner_password: :random,
                      permissions: {
                        print_document: true,
                        modify_contents: false,
                        copy_contents: true,
                        modify_annotations: false
                      })
      
  end

  def print_data
    
    # Print header information.
    self.txtb(@data[:bakestand], 2.25, 9.75, 1, 0.5, 16, :bold, :center, :center, @data_font, @data_color)
    self.txtb("#{@data[:setpoint]}°", 3.25, 9.75, 1, 0.5, 16, :bold, :center, :center, @data_font, @data_color)
    self.txtb("#{@data[:minimum]}°", 4.25, 9.75, 1, 0.5, 16, :bold, :center, :center, @data_font, @data_color)
    self.txtb("#{@data[:maximum]}°", 5.25, 9.75, 1, 0.5, 16, :bold, :center, :center, @data_font, @data_color)
    self.txtb(@data[:hours], 6.25, 9.75, 1, 0.5, 16, :bold, :center, :center, @data_font, @data_color)

    # Print orders table.
    y = 7.25
    row_height = 0.3
    @data[:shop_orders].each_with_index do |so, i|
      self.fbox(0.25, y, 8, row_height, BACKGROUND_COLORS[i])
      self.txtb(so[:number], 0.25, y, 1, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      part_info = []
      part_info << so[:customer]
      part_info << so[:process_code]
      part_info << so[:part_id]
      unless so[:sub_id].blank?
        part_info << so[:sub_id]
      end
      self.txtb(part_info.join(" ● "), 1.35, y, 3.8, row_height, 10, :normal, :left, :center, @data_font, FOREGROUND_COLORS[i])
      self.txtb(so[:setpoint], 5.25, y, 0.75, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      self.txtb(so[:minimum], 6, y, 0.75, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      self.txtb(so[:maximum], 6.75, y, 0.75, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      self.txtb(so[:hours], 7.5, y, 0.75, row_height, 10, :normal, :center, :center, @data_font, FOREGROUND_COLORS[i])
      y -= row_height
    end

    # Print trays.
    tray_width = 1.5
    tray_height = 0.3
    columns = @data[:columns]
    rows = @data[:rows]
    total_width = columns * tray_width
    x = 0.25 + ((8 - total_width) / 2)
    y = 3.75
    @data[:trays].each do |t|
      tray_column = ((t[:number] - 1) / @data[:rows]) + 1
      tray_row = t[:number] - ((tray_column - 1) * @data[:rows])
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
      self.txtb("#{t[:shop_order]} » #{t[:text]}", tray_x, tray_y, tray_width, tray_height, 8, :bold, :center, :center, @data_font, FOREGROUND_COLORS[so_index])
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
    self.txtb("Pre-Bake Bakesheet", title_position, 10.75, 8.25 - title_position, logo_height, 20, :bold, :left, :center)

    # Draw boxes for baking params.
    self.fbox(1.25, 10, 6, 0.25, "cccccc")
    self.fbox(1.25, 9.75, 1, 0.5, "ffffcc")
    self.hline(1.25, 10, 6)
    self.hline(1.25, 9.75, 6)
    self.hline(1.25, 9.25, 6)
    self.vline(1.25, 10, 0.75)
    self.vline(2.25, 10, 0.75)
    self.vline(3.25, 10, 0.75)
    self.vline(4.25, 10, 0.75)
    self.vline(5.25, 10, 0.75)
    self.vline(6.25, 10, 0.75)
    self.vline(7.25, 10, 0.75)
    self.txtb("Oven", 1.25, 10, 1, 0.25, 10, :bold, :center, :center)
    self.txtb("Bakestand", 2.25, 10, 1, 0.25, 10, :bold, :center, :center)
    self.txtb("Set (° F)", 3.25, 10, 1, 0.25, 10, :bold, :center, :center)
    self.txtb("Min (° F)", 4.25, 10, 1, 0.25, 10, :bold, :center, :center)
    self.txtb("Max (° F)", 5.25, 10, 1, 0.25, 10, :bold, :center, :center)
    self.txtb("Hours", 6.25, 10, 1, 0.25, 10, :bold, :center, :center)

    # Draw lines for date/time out of plating and signature.
    t1 = "Date/Time Out of Plating:"
    t2 = "Put in Oven By:"
    w1 = self.calcwidth(t1, 10, :bold).round(2)
    w2 = self.calcwidth(t2, 10, :bold).round(2)
    box_width = (w1 > w2 ? w1 : w2) + 0.01
    buffer = 0.1
    self.txtb(t1, 1.25, 9.25, box_width, 0.5, 10, :bold, :right, :bottom)
    self.txtb(t2, 1.25, 8.75, box_width, 0.5, 10, :bold, :right, :bottom)
    self.fbox(1.25 + box_width + buffer, 9.05, 6 - box_width - buffer, 0.3, "ffffcc")
    self.fbox(1.25 + box_width + buffer, 8.55, 6 - box_width - buffer, 0.3, "ffffcc")
    self.hline(1.25 + box_width + buffer, 8.75, 6 - box_width - buffer)
    self.hline(1.25 + box_width + buffer, 8.25, 6 - box_width - buffer)

    # Draw table for shop order details.
    self.fbox(0.25, 7.75, 8, 0.5, "cccccc")
    self.hline(0.25, 7.75, 8)
    self.hline(0.25, 7.25, 8)
    y = 7.25
    10.times do |i|
      y -= 0.3
      self.hline(0.25, y, 8)
    end
    self.vline(0.25, 7.75, 3.5)
    self.vline(1.25, 7.75, 3.5)
    self.vline(5.25, 7.75, 3.5)
    self.vline(6, 7.75, 3.5)
    self.vline(6.75, 7.75, 3.5)
    self.vline(7.5, 7.75, 3.5)
    self.vline(8.25, 7.75, 3.5)
    self.txtb("S.O. #", 0.25, 7.75, 1, 0.5, 10, :bold, :center, :center)
    self.txtb("Part", 1.35, 7.75, 3.8, 0.5, 10, :bold, :left, :center)
    self.txtb("Set\n(° F)", 5.25, 7.75, 0.75, 0.5, 10, :bold, :center, :center)
    self.txtb("Min\n(° F)", 6, 7.75, 0.75, 0.5, 10, :bold, :center, :center)
    self.txtb("Max\n(° F)", 6.75, 7.75, 0.75, 0.5, 10, :bold, :center, :center)
    self.txtb("Hours", 7.5, 7.75, 0.75, 0.5, 10, :bold, :center, :center)
    #return

    # Draw bakestand diagram.
    tray_width = 1.5
    tray_height = 0.3
    columns = @data[:columns]
    rows = @data[:rows]
    total_width = columns * tray_width
    x = 0.25 + ((8 - total_width) / 2)
    y = 3.75
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