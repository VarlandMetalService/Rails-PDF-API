class PayStub < VarlandPdf
    
  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil)

      # Call parent constructor and store passed data.
      super()
      @data = data

      # Set options.
      @standard_color = '000000'
      @standard_font = 'Helvetica'
      @data_color = 'ff0000'
      @data_font = 'SF Mono'

      # Print standard graphics.
      self.print_graphics

      # Print data.
      self.print_data

      # Encrypt PDF.
      encrypt_document(owner_password: :random,
                       permissions: {
                         print_document: true,
                         modify_contents: false,
                         copy_contents: true,
                         modify_annotations: false
                       })
      
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

    # Print employee information in top left corner.

    # Print summary box data.
    self.bol_text_box('01/05/19', 7.1, 10.1, 0.8, 0.25, 8, :normal, :center, :center, @data_font, @data_color)
    self.bol_text_box('01/10/19', 7.1, 9.85, 0.8, 0.25, 8, :normal, :center, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 9.6, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 9.35, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 9.1, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 8.85, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 8.6, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('1.00', 7.1, 8.35, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)

    # Draw earnings summary data.
    y = 7.2
    16.times do |i|
      self.bol_text_box('Type', 0.6, y, 1.3, 0.25, 8, :normal, :left, :center, @data_font, @data_color)
      self.bol_text_box('1.00', 2.1, y, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
      self.bol_text_box('1.00', 3.1, y, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
      y -= 0.25
    end
    self.bol_text_box('5.00', 2.1, 3.2, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
    self.bol_text_box('5.00', 3.1, 3.2, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)

    # Draw deduction summary data.
    y = 7.2
    12.times do |i|
      self.bol_text_box('Type', 4.6, y, 2.3, 0.25, 8, :normal, :left, :center, @data_font, @data_color)
      self.bol_text_box('1.00', 7.1, y, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)
      y -= 0.25
    end
    self.bol_text_box('5.00', 7.1, 4.2, 0.8, 0.25, 8, :normal, :right, :center, @data_font, @data_color)

  end

  # Prints standard text & graphics on each page.
  def print_graphics
    
    # Define line widths.
    thick_line = 0.012.in
    thin_line = thick_line / 2;
    self.line_width = thick_line

    # Draw summary box.
    heading_width = 1.5.in
    data_width = 1.in
    box_height = 0.25.in
    header_box_height = 0.4.in
    x = 8.in - heading_width - data_width
    y = 10.5.in
    fill_color('000000')
    fill_rectangle([x, y], heading_width + data_width, header_box_height)
    stroke_rectangle([x, y], heading_width + data_width, header_box_height)
    y -= header_box_height
    8.times do |i|
      stroke_rectangle([x, y], heading_width, box_height)
      stroke_rectangle([x + heading_width, y], data_width, box_height)
      y -= box_height
    end
    self.bol_text_box('Summary', 5.5, 10.5, 2.5, 0.4, 12, :bold, :center, :center, nil, 'ffffff')
    self.bol_text_box('Period Ending', 5.6, 10.1, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Check Date', 5.6, 9.85, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Gross Pay', 5.6, 9.6, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Deductions', 5.6, 9.35, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Net Pay', 5.6, 9.1, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Hours Paid', 5.6, 8.85, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Vacation Balance', 5.6, 8.6, 1.3, 0.25, 10, :bold, :left, :center)
    self.bol_text_box('Leave Balance', 5.6, 8.35, 1.3, 0.25, 10, :bold, :left, :center)

    # Draw earnings summary box.
    hours_box_width = 1.in
    type_box_width = 1.5.in
    amount_box_width = 1.in
    x = 0.5.in
    y = 3.2.in
    fill_color('cccccc')
    fill_rectangle([x, y], 3.5.in, box_height)
    self.bol_text_box('Total', 0.6, 3.2, 1.3, 0.25, 10, :bold, :left, :center)
    y = 7.85.in
    fill_color('000000')
    fill_rectangle([x, y], 3.5.in, header_box_height)
    stroke_rectangle([x, y], 3.5.in, header_box_height)
    self.bol_text_box('Earnings Summary', 0.5, 7.85, 3.5, 0.4, 12, :bold, :center, :center, nil, 'ffffff')
    y -= header_box_height
    fill_color('333333')
    fill_rectangle([x, y], 3.5.in, box_height)
    self.bol_text_box('Type', 0.6, 7.45, 1.3, 0.25, 10, :bold, :left, :center, nil, 'ffffff')
    self.bol_text_box('Hours', 2.1, 7.45, 0.8, 0.25, 10, :bold, :center, :center, nil, 'ffffff')
    self.bol_text_box('Amount', 3.1, 7.45, 0.8, 0.25, 10, :bold, :center, :center, nil, 'ffffff')
    18.times do |i|
      stroke_rectangle([x, y], type_box_width, box_height)
      stroke_rectangle([x + type_box_width, y], hours_box_width, box_height)
      stroke_rectangle([x + hours_box_width + type_box_width, y], amount_box_width, box_height)
      y -= box_height
    end

    # Draw deduction summary box.
    type_box_width = 2.5.in
    amount_box_width = 1.in
    x = 4.5.in
    y = 4.2.in
    fill_color('cccccc')
    fill_rectangle([x, y], 3.5.in, box_height)
    self.bol_text_box('Total', 4.6, 4.2, 2.3, 0.25, 10, :bold, :left, :center)
    y = 7.85.in
    fill_color('000000')
    fill_rectangle([x, y], 3.5.in, header_box_height)
    stroke_rectangle([x, y], 3.5.in, header_box_height)
    self.bol_text_box('Deductions Summary', 4.5, 7.85, 3.5, 0.4, 12, :bold, :center, :center, nil, 'ffffff')
    y -= header_box_height
    fill_color('333333')
    fill_rectangle([x, y], 3.5.in, box_height)
    self.bol_text_box('Type', 4.6, 7.45, 2.3, 0.25, 10, :bold, :left, :center, nil, 'ffffff')
    self.bol_text_box('Amount', 7.1, 7.45, 0.8, 0.25, 10, :bold, :center, :center, nil, 'ffffff')
    14.times do |i|
      stroke_rectangle([x, y], type_box_width, box_height)
      stroke_rectangle([x + type_box_width, y], amount_box_width, box_height)
      y -= box_height
    end
    return

    # Draw direct deposit summary box.
    bank_id_box_width = 1.25.in
    bank_name_box_width = 3.75.in
    type_box_width = 1.25.in
    amount_box_width = 1.25.in
    x = 0.5.in
    y = 3.2.in
    fill_color('cccccc')
    fill_rectangle([x, y], 3.5.in, box_height)
    self.bol_text_box('Total', 0.6, 3.2, 1.3, 0.25, 10, :bold, :left, :center)
    y = 7.85.in
    fill_color('000000')
    fill_rectangle([x, y], 3.5.in, header_box_height)
    stroke_rectangle([x, y], 3.5.in, header_box_height)
    self.bol_text_box('Earnings Summary', 0.5, 7.85, 3.5, 0.4, 12, :bold, :center, :center, nil, 'ffffff')
    y -= header_box_height

    return

    # Print header graphic and text above the box.
    header_graphic = Rails.root.join('app', 'assets', 'bol_header.jpg')
    image(header_graphic, at: [0.35.in, 10.75.in], width: 7.8.in, height: 1.25.in)
    self.bol_text_box('STRAIGHT BILL OF LADING - SHORT FORM', 0, 9.15 + _p(12), 8.5, _p(12), 12, :bold, :center, :center)
    self.bol_text_box('Name of Carrier:', 0.25, 8.55 + _p(8), 4, _p(8), 8, :normal, :left, :center)
    self.bol_text_box('VMS Shipper #:', 0, 8.75 + _p(8), 6.65, _p(8), 8, :normal, :right, :center)
    self.bol_text_box('Date:', 0, 8.55 + _p(8), 6.65, _p(8), 8, :normal, :right, :center)

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