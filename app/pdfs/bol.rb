class BOL < VarlandPdf
    
  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil)

      # Call parent constructor and store passed data.
      super()
      @data = data
      @bill = @data[:bill]
      @signature = @data[:signature]
      puts(@bill.inspect)
      puts(@signature.inspect)

      # Create specified number of pages.
      extra_pages = @bill.fetch(:bolpCopies, 1).to_i - 1
      extra_pages.times do |e| start_new_page end

      # Set options.
      @standard_color = '000000'
      @standard_font = 'Helvetica'
      @data_color = '000000'
      @data_font = 'SF Mono'

      # Print standard graphics.
      self.print_graphics
      self.add_copy_numbers

      # Print data.
      self.print_data
      self.draw_signatures
      
  end

  # Draws absolutely positioned text box on page.
  def bol_text_box(text, x, y, width, height, size = 10, style = :normal, align = :center, valign = :center, font_family = nil, font_color = nil)
      font_family = @standard_font if font_family.nil?
      font_color = @standard_color if font_color.nil?
      font(font_family,
           style: style)
      font_size(size)
      fill_color(font_color)
      text_box(text,
              at: [x.in, y.in],
              width: width.in,
              height: height.in,
              align: align,
              valign: valign,
              inline_format: true,
              overflow: :shrink_to_fit)
  end

  # Prints data on BOL.
  def print_data

    # Add graphics on each page.
    repeat :all do

      # Print header graphic and text above the box.
      self.bol_text_box(@bill[:bolpCarrier], 1.171, 8.55 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:bolpVmsShipNo], 6.75, 8.75 + _p(10), 6.65, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:_shipDate], 6.75, 8.55 + _p(10), 6.65, _p(10), 10, :bold, :left, :center, @data_font, @data_color)

      # Draw ship to info.
      if @bill[:bolpShipName2].blank?
        self.bol_text_box(@bill[:bolpShipName1], 1.006, 8.175 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      else
        self.bol_text_box(@bill[:bolpShipName1], 1.006, 8.35 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
        self.bol_text_box(@bill[:bolpShipName2], 1.006, 8.175 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      end
      self.bol_text_box(@bill[:bolpShipStreet], 1.006, 8 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:bolpShipCitySt], 1.006, 7.825 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:bolpShipZip], 3.65, 7.825 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      
      # Draw ship from info.
      self.bol_text_box(@bill[:bolpInitials], 7.65, 7.825 + _p(10), 4, _p(10), 10, :bold, :left, :center, @data_font, @data_color)

      # Draw table.
      vertical_position = 7.1 + _p(10)
      0.upto(8) do |i|
        self.bol_text_box(@bill[:shippingUnits][i], 0.25, vertical_position, 1.25, _p(10), 10, :bold, :center, :center, @data_font, @data_color) unless @bill[:shippingUnits][i].to_i == 0
        self.bol_text_box(@bill[:hazardous][i], 1.5, vertical_position, 0.4, _p(10), 10, :bold, :center, :center, @data_font, @data_color)
        self.bol_text_box(@bill[:descriptions][i], 1.95, vertical_position, 3.25, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
        self.bol_text_box(@bill[:weights][i], 5.25, vertical_position, 1.25, _p(10), 10, :bold, :center, :center, @data_font, @data_color)
        self.bol_text_box(@bill[:rates][i], 6.5, vertical_position, 0.6, _p(10), 10, :bold, :center, :center, @data_font, @data_color)
        vertical_position -= 0.193
      end

      # Draw special instructions.
      self.bol_text_box(@bill[:specialInstructions][0], 0.35, 3.67 + _p(10), 7.8, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:specialInstructions][1], 0.35, 3.5325 + _p(10), 7.8, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:specialInstructions][2], 0.35, 3.395 + _p(10), 7.8, _p(10), 10, :bold, :left, :center, @data_font, @data_color)

      # Check box for collect.
      unless @bill[:bolpCollect].blank?
        self.bol_text_box("XX", 7.377, 1.81 + _p(10), 0.2, 0.2, 10, :bold, :center, :center, @data_font, @data_color)
      end

      # Draw certification info.
      self.bol_text_box(@bill[:bolpCarrier], 4.95, 0.725 + _p(10), 5, _p(10), 10, :bold, :left, :center, @data_font, @data_color)
      self.bol_text_box(@bill[:_shipDate], 6.8, 0.575 + _p(10), 5, _p(10), 10, :bold, :left, :center, @data_font, @data_color)

    end

  end

  # Draws signatures.
  def draw_signatures

    # Return if not auto-signing.
    return unless @bill[:bolpAutoSign] == 'Y'
    return if @signature.blank?

    # Draw on every page.
    repeat :all do

      # Load graphics.
      signature_graphic = Rails.root.join('app', 'assets', "#{@signature[:signatureUser].downcase}.png")

      # Draw signature in miscellaneous box.
      width = @signature[:widths][0].to_f
      height = (@signature[:signaturePixelHeight].to_f / @signature[:signaturePixelWidth].to_f) * width
      x = 4.6
      y = 1.925 - @signature[:offsets][0].to_f + height
      image(signature_graphic, at: [x.in, y.in], width: width.in, height: height.in)

      # Draw signature in certification box.
      width = @signature[:widths][1].to_f
      height = (@signature[:signaturePixelHeight].to_f / @signature[:signaturePixelWidth].to_f) * width
      x = 0.95
      y = 0.5 - @signature[:offsets][1].to_f + height
      image(signature_graphic, at: [x.in, y.in], width: width.in, height: height.in)

    end

  end

  # Adds page/copy numbers.
  def add_copy_numbers

    # Print page numbers.
    string = "<page>"
    options = {:at => [0.in, 0.91.in],
               :width => 8.15.in,
               :align => :right,
               :size => 32,
               :start_count_at => 1}
    number_pages(string, options)

  end

  # Prints standard text & graphics on each page.
  def print_graphics

    # Add special graphics on first page.
    repeat [1] do
      self.bol_text_box('ORIGINAL - NOT NEGOTIABLE', 0, 9 + _p(9), 8.5, _p(9), 9, :normal, :center, :center)
    end

    # Add special graphics on each page after the first page.
    repeat(lambda { |pg| pg > 1 }) do
      self.bol_text_box('NOT NEGOTIABLE', 0, 9 + _p(9), 8.5, _p(9), 9, :normal, :center, :center)
    end

    # Add graphics on each page.
    repeat :all do

      # Print header graphic and text above the box.
      header_graphic = Rails.root.join('app', 'assets', 'bol_header.jpg')
      image(header_graphic, at: [0.35.in, 10.75.in], width: 7.8.in, height: 1.25.in)
      self.bol_text_box('STRAIGHT BILL OF LADING - SHORT FORM', 0, 9.15 + _p(12), 8.5, _p(12), 12, :bold, :center, :center)
      self.bol_text_box('Name of Carrier:', 0.25, 8.55 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('VMS Shipper #:', 0, 8.75 + _p(8), 6.65, _p(8), 8, :normal, :right, :center)
      self.bol_text_box('Date:', 0, 8.55 + _p(8), 6.65, _p(8), 8, :normal, :right, :center)
      
      # Define line widths.
      thick_line = 0.012.in
      thin_line = 0.006.in

      # Draw main box.
      self.line_width = thick_line
      stroke_rectangle([0.25.in, 8.5.in], 8.in, 8.in)

      # Draw ship to box.
      stroke_rectangle([0.25.in, 8.5.in], 4.in, 0.75.in)
      self.bol_text_box('TO:', 0.35, 8.35 + _p(8), 4, _p(8), 8, :bold, :left, :center)
      self.bol_text_box('Consignee', 0.35, 8.175 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Street', 0.35, 8 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Destination', 0.35, 7.825 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Zip', 0, 7.828 + _p(8), 3.55, _p(8), 8, :normal, :right, :center)
      
      # Draw ship from box.
      stroke_rectangle([4.25.in, 8.5.in], 4.in, 0.75.in)
      self.bol_text_box('FROM:', 4.35, 8.35 + _p(8), 4, _p(8), 8, :bold, :left, :center)
      self.bol_text_box('Shipper', 4.35, 8.175 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Varland Metal Service, Inc.', 5.006, 8.175 + _p(8), 4, _p(8), 8, :bold, :left, :center)
      self.bol_text_box('Street', 4.35, 8 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('3231 Fredonia Avenue • (513) 861-0555', 5.006, 8 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Origin', 4.35, 7.825 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Cincinnati, OH 45229-3394', 5.006, 7.825 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('Initials', 0, 7.828 + _p(8), 7.55, _p(8), 8, :normal, :right, :center)
      
      # Draw route box.
      stroke_rectangle([0.25.in, 7.75.in], 6.25.in, 0.25.in)
      self.bol_text_box('Route', 0.35, 7.75, 6.25, 0.25, 8, :normal, :left, :center)

      # Draw vehicle number box.
      stroke_rectangle([6.5.in, 7.75.in], 1.75.in, 0.25.in)
      self.bol_text_box("Vehicle\nNumber", 6.6, 7.75, 1.25, 0.25, 8, :normal, :left, :center)

      # Draw table.
      stroke_rectangle([0.25.in, 7.5.in], 8.in, 0.25.in)
      stroke_rectangle([0.25.in, 7.25.in], 8.in, 3.3.in)
      [1.5, 1.9, 5.25, 6.5, 7.1].each do |x|
        stroke_line([x.in, 7.5.in], [x.in, 3.95.in])
      end
      self.bol_text_box("Number of\nShipping Units", 0.25, 7.5, 1.25, 0.25, 8, :normal, :center, :center)
      self.bol_text_box("HM*", 1.5, 7.5, 0.4, 0.25, 8, :normal, :center, :center)
      self.bol_text_box("Kind of Packaging, Description of Articles\nSpecial Marks and Exceptions", 1.9, 7.5, 3.35, 0.25, 8, :normal, :center, :center)
      self.bol_text_box("§ Weight", 5.25, 7.5, 1.25, 0.125, 8, :normal, :center, :bottom)
      self.bol_text_box("(Subject to Correction)", 5.25, 7.375, 1.25, 0.125, 6, :normal, :center, :top)
      self.bol_text_box("Rate or\nClass", 6.5, 7.5, 0.6, 0.25, 8, :normal, :center, :center)
      self.bol_text_box("CHARGES", 7.1, 7.5, 1.15, 0.25, 8, :normal, :center, :center)

      # Draw special instructions box.
      stroke_rectangle([0.25.in, 3.95.in], 8.in, 0.6.in)
      self.bol_text_box('SPECIAL INSTRUCTIONS:', 0.35, 3.8075 + _p(8), 4, _p(8), 8, :bold, :left, :center)

      # Draw COD box.
      stroke_rectangle([0.25.in, 3.35.in], 4.in, 0.6.in)
      stroke_rectangle([4.25.in, 3.35.in], 2.25.in, 0.6.in)
      stroke_rectangle([6.5.in, 3.35.in], 1.75.in, 0.6.in)
      self.bol_text_box('REMIT C.O.D. TO:', 0.35, 3.2075 + _p(8), 4, _p(8), 8, :bold, :left, :center)
      self.bol_text_box('ADDRESS', 0.35, 3 + _p(8), 4, _p(8), 8, :normal, :left, :center)
      self.bol_text_box("ON COLLECT ON DELIVERY SHIPMENTS THE LETTERS \"COD\"\nMUST APPEAR BEFORE CONSIGNEE'S NAME - OR AS\nOTHERWISE PROVIDED IN ITEM 430, SEC. 1.", 4.3, 3.24 + _p(5), 2.15, 0.6, 5, :normal, :left, :top)
      self.bol_text_box('COD', 4.3, 2.8 + _p(12), 2.15, _p(12), 12, :bold, :left, :center)
      self.bol_text_box('Amt:', 5.05, 2.8 + _p(6), 2.15, _p(6), 6, :normal, :left, :center)
      self.bol_text_box('$', 5.245, 2.8 + _p(8), 2.15, _p(8), 8, :normal, :left, :center)
      self.bol_text_box('C.O.D. FEE', 6.6, 3.2075 + _p(8), 1.75, _p(8), 8, :bold, :left, :center)
      stroke_rectangle([7.212.in, 2.95.in], 0.2.in, 0.2.in)
      stroke_rectangle([7.212.in, 3.15.in], 0.2.in, 0.2.in)
      self.bol_text_box('PREPAID', 6.6, 3.15, 1.75, 0.2, 8, :normal, :left, :center)
      self.bol_text_box('COLLECT', 6.6, 2.95, 1.75, 0.2, 8, :normal, :left, :center)
      self.bol_text_box('$', 7.512, 2.95, 1.75, 0.2, 8, :normal, :left, :center)

      # Draw miscellansous box.
      stroke_rectangle([0.25.in, 2.75.in], 4.in, 1.in)
      stroke_rectangle([4.25.in, 2.75.in], 2.25.in, 1.in)
      stroke_rectangle([6.5.in, 2.75.in], 1.75.in, 1.in)
      stroke_line([0.25.in, 2.1.in], [4.25.in, 2.1.in])
      self.line_width = thin_line
      stroke_line([4.35.in, 1.925.in], [6.4.in, 1.925.in])
      self.line_width = thick_line
      stroke_line([6.5.in, 2.35.in], [8.25.in, 2.35.in])
      self.bol_text_box("§ If the shipment moves between two ports by a carrier by water, the law requires that the bill of lading shall state whether it is\ncarrier's or shipper's weight.", 0.3, 2.65 + _p(5), 3.9, 1, 5, :normal, :left, :top)
      self.bol_text_box("† \"The fibre containers used for this shipment conform to the specifications set forth in the box maker's certificate thereon, and\nall other requirements of Rule 41 of the Uniform Freight Classification and Rule 5 of the National Motor Freight Classification.\"\n† \"Shipper's imprint in lieu of stamp; not a part of the bill of lading approved by the Interstate Commerce Commission.\"", 0.3, 2.35 + _p(5), 3.9, 1, 5, :normal, :left, :top)
      self.bol_text_box("NOTE: Where the rate is dependent on value, shippers are required to state specifically in writing the agreed or declared value\nof the property. <strong>Shipper hereby specifically states agreed or declared value of this property to be not exceeding</strong>", 0.3, 2.015 + _p(5), 3.9, 1, 5, :normal, :left, :top)
      self.bol_text_box('$', 0.3, 1.79 + _p(9), 1.75, _p(9), 9, :normal, :left, :center)
      self.bol_text_box('PER', 2.3, 1.79 + _p(9), 1.75, _p(9), 9, :normal, :left, :center)
      self.bol_text_box("  Subject to Section 7 of the conditions, if this shipment is to be\ndelivered to the consignee without recourse on the consignor, the\nconsignor shall sign the following statement:\n  The carrier shall not make delivery of this shipment without payment\nof freight and all other lawful charges.", 4.3, 2.65 + _p(5), 2.15, 1, 5, :normal, :left, :top)
      self.bol_text_box("Signature of Consignor", 4.25, 1.83 + _p(7), 2.25, _p(7), 7, :normal, :center, :center)
      self.bol_text_box("TOTAL\nCHARGES", 6.6, 2.75, 1.55, 0.4, 7, :normal, :left, :center)
      self.bol_text_box("FREIGHT CHARGES", 6.5, 2.24 + _p(6), 1.75, _p(6), 6, :normal, :center, :center)
      self.bol_text_box("FREIGHT PREPAID\nexcept when box\nat right is checked", 6.55, 1.95 + _p(6), 1.65, 3 * _p(6), 6, :normal, :left, :bottom)
      self.bol_text_box("Check box if\ncharges are to\nbe collect", 7.667, 1.95 + _p(6), 1.65, 3 * _p(6), 6, :normal, :left, :bottom)
      stroke_rectangle([7.377.in, 1.95.in], 0.2.in, 0.2.in)

      # Draw legal box.
      stroke_rectangle([0.25.in, 1.75.in], 8.in, 0.75.in)
      left = "  RECEIVED, subject to the classifications and lawfully filed tariffs in effect on the date of the issue of this Bill of Lading, the\nproperty described above in apparent good order, except as noted (contents and condition of contents of packages unknown),\nmarked, cosigned and destined as indicated above which said carrier (the word carrier being understood throughout this\ncontract as meaning any person or corporation in possession of the property under the contract) agrees to carry to its usual\nplace of delivery at said destination if on its route, otherwise to deliver to another carrier on the route to said destination. It is\nmutually agreed as to each carrier of all or any of said property over all or any portion of said route to destination and as to\neach party at any time interested in all or any said property, that every service to be performed hereunder shall be subject to all"
      right = "the Bill of Lading terms and conditions in the governing classification on the date of shipment. Shipper hereby certifies that he\nis familiar with all the Bill of Lading terms and conditions in the governing classification and the said terms and conditions are\nhereby agreed to by the shipper and accepted for himself and his assigns. NOTICE: Freight moving under this Bill of Lading is\nsubject to the classifications and lawfully filed tariffs in effect on the date of this Bill of Lading. This notice supersedes and\nnegates any claimed, alleged or asserted oral or written contract, promise, representation or understanding between the\nparties with respect to this freight, except to the extent of any written contract which established lawful contract carriage and is\nsigned by authorized representatives of both parties to the contract."
      self.bol_text_box(left, 0.3, 1.80 + _p(5), 3.9, 0.75, 5, :normal, :left, :bottom)
      self.bol_text_box(right, 4.3, 1.80 + _p(5), 3.9, 0.75, 5, :normal, :left, :bottom)

      # Draw certification box.
      stroke_rectangle([0.25.in, 1.in], 8.in, 0.5.in)
      self.bol_text_box("This is to certify that the above named materials are properly classified, packaged, marked, and labeled, and are in proper condition for transportation according to the applicable regulations of the Department of Transportation.", 0.35, 0.875 + _p(5), 7.9, _p(5), 5, :normal, :left, :center)
      self.bol_text_box("SHIPPER", 0.35, 0.725 + _p(8), 7.9, _p(8), 8, :normal, :left, :center)
      self.bol_text_box("Varland Metal Service, Inc. • Cincinnati OH 45229-3394", 0.95, 0.725 + _p(8), 7.9, _p(8), 8, :bold, :left, :center)
      self.bol_text_box("PER", 0.35, 0.575 + _p(8), 7.9, _p(8), 8, :normal, :left, :center)
      self.bol_text_box("CARRIER", 4.35, 0.725 + _p(8), 7.9, _p(8), 8, :normal, :left, :center)
      self.bol_text_box("PER", 4.35, 0.575 + _p(8), 7.9, _p(8), 8, :normal, :left, :center)
      self.bol_text_box("DATE", 0, 0.575 + _p(8), 6.7, _p(8), 8, :normal, :right, :center)

      # Draw footer text.
      self.bol_text_box('* MARK WITH "X" TO DESIGNATE HAZARDOUS MATERIAL AS DEFINED IN TITLE 49 OF FEDERAL REGULATIONS', 0.25, 0.4 + _p(6), 8, _p(6), 6, :bold, :left, :center)
      self.bol_text_box('Permanent post-office address of shipper.', 0.25, 0.3 + _p(5), 8, _p(5), 5, :bold, :left, :center)
    
    end

  end

end