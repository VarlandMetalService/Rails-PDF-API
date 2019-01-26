class Quote < VarlandPdf
    
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :portrait
  
    def initialize(data = nil)
  
        # Call parent constructor and store passed data.
        super()
        @data = data
  
        # Set options.
        @standard_color = '000000'
        @standard_font = 'Helvetica'
        @data_color = '000000'
        @data_font = 'SF Mono'
  
        # Print standard graphics.
        self.print_graphics
        #self.add_copy_numbers
  
        # Print data.
        self.print_data
        #self.draw_signatures
        
    end
  
    # Draws absolutely positioned text box on page.
    def vms_text_box(text, x, y, width, height, size = 10, style = :normal, align = :center, valign = :center, font_family = nil, font_color = nil)
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

        # Print customer information.
        box_height = 0.166667
        y = 8.9
        self.vms_text_box("Attn: <strong>PIERRE PAROZ</strong>", 0.5, y, 3.5, box_height, 10, :normal, :left, :center)
        self.vms_text_box("AMEMIC", 4.5, y, 3.5, box_height, 10, :bold, :left, :center)
        self.vms_text_box("Date: <strong>12/13/18</strong>", 4.5, y, 3.5, box_height, 10, :normal, :right, :center)
        y -= box_height
        self.vms_text_box("AMERICAN MICRO PRODUCTS, INC.", 0.5, y, 3.5, box_height, 10, :bold, :left, :center)
        y -= box_height
        self.vms_text_box("4288 ARMSTRONG BLVD", 0.5, y, 3.5, box_height, 10, :bold, :left, :center)
        self.vms_text_box("Phone:", 4.5, y, 0.75, box_height, 10, :normal, :left, :center)
        self.vms_text_box("(513) 732-2674", 5.15, y, 3.5, box_height, 10, :bold, :left, :center)
        y -= box_height
        self.vms_text_box("BATAVIA, OH 45103-1600", 0.5, y, 3.5, box_height, 10, :bold, :left, :center)
        self.vms_text_box("Fax:", 4.5, y, 0.75, box_height, 10, :normal, :left, :center)
        self.vms_text_box("(513) 732-3535", 5.15, y, 1.5, box_height, 10, :bold, :left, :center)
        self.vms_text_box("Ext", 6.4, y, 0.5, box_height, 10, :normal, :left, :center)
        self.vms_text_box("032", 6.7, y, 1, box_height, 10, :bold, :left, :center)
        y -= (box_height + 0.25)

        # Draw quotation box.
        fill_color('000000')
        fill_rectangle([0.25.in, y.in], 8.in, 0.4.in)
        stroke_rectangle([0.25.in, y.in], 8.in, 0.4.in)
        self.vms_text_box("VMS Quote # <strong>71295</strong>", 0.35, y, 3.8, 0.4, 12, :normal, :left, :center, nil, 'ffffff')
        self.vms_text_box("Your Request # <strong>Q02I7446</strong>", 4.35, y, 3.8, 0.4, 10, :normal, :right, :center, nil, 'ffffff')
        y -= 0.4
        fill_color('cccccc')
        fill_rectangle([0.25.in, y.in], 8.in, 0.25.in)
        stroke_rectangle([0.25.in, y.in], 2.in, 0.25.in)
        stroke_rectangle([2.25.in, y.in], 4.5.in, 0.25.in)
        stroke_rectangle([6.75.in, y.in], 1.5.in, 0.25.in)
        self.vms_text_box("Part Number", 0.25, y, 2, 0.25, 10, :bold, :center, :center)
        self.vms_text_box("Part Description & Process Specification", 2.25, y, 4.5, 0.25, 10, :bold, :center, :center)
        self.vms_text_box("EAU", 6.75, y, 1.5, 0.25, 10, :bold, :center, :center)
        quotation_lines = 9
        y -= 0.25
        stroke_rectangle([0.25.in, y.in], 2.in, (quotation_lines * _p(10)).in)
        stroke_rectangle([2.25.in, y.in], 4.5.in, (quotation_lines * _p(10)).in)
        stroke_rectangle([6.75.in, y.in], 1.5.in, (quotation_lines * _p(10)).in)
        self.vms_text_box("627591\n \n \n \n \n \n ", 0.35, y, 1.8, quotation_lines * _p(10), 10, :normal, :left, :center)
        self.vms_text_box("POLE PIECE\n\n12L14 STEEL X 12.3MM OD X 7MM ID\n& 1.90MM THRU HOLE X 13.9MM LONG\n\nZINC-NICKEL (.0003\" MINIMUM) &\nCLEAR TRIVALENT CHROMATE", 2.35, y, 4.3, quotation_lines * _p(10), 10, :normal, :left, :center)
        self.vms_text_box("500,000 PCS\n \n \n \n \n \n ", 6.85, y, 1.3, quotation_lines * _p(10), 10, :normal, :center, :center)
        y -= quotation_lines * _p(10)
        remarks_lines = 4
        stroke_rectangle([0.25.in, y.in], 8.in, (remarks_lines * _p(10)).in)
        self.vms_text_box("<em>Remarks:</em>\nPLEASE NOTE: FORD WSA-M1P87-A1 IS OBSOLETE.\nUSING FORD WSS-M1P87-B1 FOR PURPOSE OF THIS QUOTATION.", 0.35, y, 7.8, remarks_lines * _p(10), 10, :normal, :left, :center)
        y -= remarks_lines * _p(10)
        fill_color('000000')
        fill_rectangle([0.25.in, y.in], 8.in, 0.32.in)
        stroke_rectangle([0.25.in, y.in], 8.in, 0.32.in)
        self.vms_text_box("Price: <strong>$0.028/each</strong>", 0.35, y, 3.8, 0.32, 10, :normal, :left, :center, nil, 'ffffff')
        self.vms_text_box("Minimum Lot Charge: <strong>$250.00</strong>", 4.35, y, 3.8, 0.32, 10, :normal, :right, :center, nil, 'ffffff')
        y -= 0.57

        fill_color('000000')
        fill_rectangle([0.25.in, y.in], 8.in, 0.4.in)
        stroke_rectangle([0.25.in, y.in], 8.in, 0.4.in)
        self.vms_text_box("VMS Quote # <strong>71296</strong>", 0.35, y, 3.8, 0.4, 12, :normal, :left, :center, nil, 'ffffff')
        self.vms_text_box("Your Request # <strong>Q02I7447</strong>", 4.35, y, 3.8, 0.4, 10, :normal, :right, :center, nil, 'ffffff')
        y -= 0.4
        fill_color('cccccc')
        fill_rectangle([0.25.in, y.in], 8.in, 0.25.in)
        stroke_rectangle([0.25.in, y.in], 2.in, 0.25.in)
        stroke_rectangle([2.25.in, y.in], 4.5.in, 0.25.in)
        stroke_rectangle([6.75.in, y.in], 1.5.in, 0.25.in)
        self.vms_text_box("Part Number", 0.25, y, 2, 0.25, 10, :bold, :center, :center)
        self.vms_text_box("Part Description & Process Specification", 2.25, y, 4.5, 0.25, 10, :bold, :center, :center)
        self.vms_text_box("EAU", 6.75, y, 1.5, 0.25, 10, :bold, :center, :center)
        quotation_lines = 9
        y -= 0.25
        stroke_rectangle([0.25.in, y.in], 2.in, (quotation_lines * _p(10)).in)
        stroke_rectangle([2.25.in, y.in], 4.5.in, (quotation_lines * _p(10)).in)
        stroke_rectangle([6.75.in, y.in], 1.5.in, (quotation_lines * _p(10)).in)
        self.vms_text_box("627599\n \n \n \n \n \n ", 0.35, y, 1.8, quotation_lines * _p(10), 10, :normal, :left, :center)
        self.vms_text_box("ARMATURE\n\n12L14 STEEL X 12.3MM & 10.3MM &\n4.5MM & 1.90MM OD X 50.05MM LONG\n\nZINC-NICKEL (.0003\" MINIMUM) &\nCLEAR TRIVALENT CHROMATE", 2.35, y, 4.3, quotation_lines * _p(10), 10, :normal, :left, :center)
        self.vms_text_box("500,000 PCS\n \n \n \n \n \n ", 6.85, y, 1.3, quotation_lines * _p(10), 10, :normal, :center, :center)
        y -= quotation_lines * _p(10)
        remarks_lines = 4
        stroke_rectangle([0.25.in, y.in], 8.in, (remarks_lines * _p(10)).in)
        self.vms_text_box("<em>Remarks:</em>\nPLEASE NOTE: FORD WSA-M1P87-A1 IS OBSOLETE.\nUSING FORD WSS-M1P87-B1 FOR PURPOSE OF THIS QUOTATION.", 0.35, y, 7.8, remarks_lines * _p(10), 10, :normal, :left, :center)
        y -= remarks_lines * _p(10)
        fill_color('000000')
        fill_rectangle([0.25.in, y.in], 8.in, 0.32.in)
        stroke_rectangle([0.25.in, y.in], 8.in, 0.32.in)
        self.vms_text_box("Price: <strong>$0.091/each</strong>", 0.35, y, 3.8, 0.32, 10, :normal, :left, :center, nil, 'ffffff')
        self.vms_text_box("Minimum Lot Charge: <strong>$250.00</strong>", 4.35, y, 3.8, 0.32, 10, :normal, :right, :center, nil, 'ffffff')
        y -= 0.57

        return

        # Print data table.
        self.vms_text_box("LN", 0.25, 7.95, 0.5, 8 * _p(10), 10, :normal, :center, :top)
        self.vms_text_box("627591\nQuote # <strong>71295</strong>", 0.8, 7.95, 1.9, 8 * _p(10), 10, :normal, :left, :top)
        self.vms_text_box("POLE PIECE\n\n12L14 STEEL X 12.3MM OD X 7MM ID\n& 1.90MM THRU HOLE X 13.9MM LONG\n\nZINC-NICKEL (.0003\" MINIMUM) &\nCLEAR TRIVALENT CHROMATE", 2.8, 7.95, 3.15, 8 * _p(10), 10, :normal, :left, :top)
        self.vms_text_box("500,000 PCS", 6.05, 7.95, 1.15, 8 * _p(10), 10, :normal, :center, :top)
        self.vms_text_box(".028\n$/EACH\n\n<em>MINIMUM</em>:\n$250.00", 7.3, 7.95, 0.9, 8 * _p(10), 10, :normal, :center, :top)
        fill_color('eeeeee')
        fill_rectangle([0.5.in, 6.75.in], 7.5.in, (8 * _p(10)).in)
        stroke_rectangle([0.5.in, 6.75.in], 7.5.in, (8 * _p(10)).in)
        self.vms_text_box("PLEASE NOTE: FORD WSA-M1P87-A1 IS OBSOLETE.\nUSING FORD WSS-M1P87-B1 FOR PURPOSE OF THIS QUOTATION.\n\nYOUR REQUEST NUMBER <strong>Q0217446</strong>\n\nPLEASE REFER TO OUR QUOTATION NUMBER <strong>71295</strong> ON ALL CORRESPONDENCE OR ORDERS", 0.5, 6.75, 7.5, 8 * _p(10), 10, :normal, :center, :center)
        self.vms_text_box("LN", 0.25, 5.5, 0.5, 8 * _p(10), 10, :normal, :center, :top)
        self.vms_text_box("627599\nQuote # <strong>71296</strong>", 0.8, 5.5, 1.9, 8 * _p(10), 10, :normal, :left, :top)
        self.vms_text_box("ARMATURE\n\n12L14 STEEL X 12.3MM & 10.3MM &\n4.5MM & 1.9MM OD X 50.05MM LONG\n\nZINC-NICKEL (.0003\" MINIMUM) &\nCLEAR TRIVALENT CHROMATE", 2.8, 5.5, 3.15, 8 * _p(10), 10, :normal, :left, :top)
        self.vms_text_box("500,000 PCS", 6.05, 5.5, 1.15, 8 * _p(10), 10, :normal, :center, :top)
        self.vms_text_box(".091\n$/EACH\n\n<em>MINIMUM</em>:\n$250.00", 7.3, 5.5, 0.9, 8 * _p(10), 10, :normal, :center, :top)
        fill_color('eeeeee')
        fill_rectangle([0.5.in, 4.3.in], 7.5.in, (8 * _p(10)).in)
        stroke_rectangle([0.5.in, 4.3.in], 7.5.in, (8 * _p(10)).in)
        self.vms_text_box("PLEASE NOTE: FORD WSA-M1P87-A1 IS OBSOLETE.\nUSING FORD WSS-M1P87-B1 FOR PURPOSE OF THIS QUOTATION.\n\nYOUR REQUEST NUMBER <strong>Q0217447</strong>\n\nPLEASE REFER TO OUR QUOTATION NUMBER <strong>71296</strong> ON ALL CORRESPONDENCE OR ORDERS", 0.5, 4.3, 7.5, 8 * _p(10), 10, :normal, :center, :center)


  
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
  
        # Print header graphic and text above the box.
        header_graphic = Rails.root.join('app', 'assets', 'quote_header.jpg')
        image(header_graphic, at: [0.35.in, 10.75.in], width: 7.8.in, height: 1.25.in)
        self.vms_text_box('QUOTATION', 0, 9.4, 8.5, 0.25, 16, :bold, :center, :center)

        # Define line widths.
        self.line_width = 0.012.in

        # Draw footer.
        fill_color('eeeeee')
        fill_rectangle([0.25.in, 1.5.in], 8.in, 1.25.in)
        stroke_rectangle([0.25.in, 1.5.in], 4.in, 0.75.in)
        stroke_rectangle([4.25.in, 1.5.in], 4.in, 0.75.in)
        stroke_rectangle([0.25.in, 0.75.in], 8.in, 0.5.in)
        self.vms_text_box("Terms:\n\n<strong>1% 10 DAYS, NET 30\nQUOTED PRICES ARE FOB VARLAND PLANT</strong>", 0.35, 1.5, 3.8, 0.75, 9, :normal, :left, :center)
        self.vms_text_box("Quoted By:\n\n\n<strong>John McGuire</strong>", 4.35, 1.5, 3.8, 0.75, 9, :normal, :left, :center)
        signature_graphic = Rails.root.join('app', 'assets', 'tim.png')
        image(signature_graphic, at: [(8.15 - 1.7224).in, 1.4.in], width: 1.7224.in, height: 0.55.in)
        self.vms_text_box("CORPORATE COMPLIANCE POLICY: Varland Metal Service, Inc. certifies that its pollution abatement system is operated\nin compliance with U.S. EPA, state, and local regulations applicable to waste water discharge and sludge disposal.", 0.25, 0.75, 8, 0.5, 9, :italic, :center, :center)

        return

        # Draw main box.
        stroke_rectangle([0.25.in, 8.25.in], 0.5.in, 0.25.in)
        stroke_rectangle([0.75.in, 8.25.in], 2.in, 0.25.in)
        stroke_rectangle([2.75.in, 8.25.in], 3.25.in, 0.25.in)
        stroke_rectangle([6.in, 8.25.in], 1.25.in, 0.25.in)
        stroke_rectangle([7.25.in, 8.25.in], 1.in, 0.25.in)
        self.vms_text_box('Code', 0.25, 8.25, 0.5, 0.25, 9, :bold, :center, :center)
        self.vms_text_box('Part Number', 0.75, 8.25, 2, 0.25, 9, :bold, :center, :center)
        self.vms_text_box('Part Description/Process Specification', 2.75, 8.25, 3.25, 0.25, 9, :bold, :center, :center)
        self.vms_text_box('Quantity', 6, 8.25, 1.25, 0.25, 9, :bold, :center, :center)
        self.vms_text_box('Price', 7.25, 8.25, 1, 0.25, 9, :bold, :center, :center)
        stroke_rectangle([0.25.in, 8.in], 0.5.in, 6.5.in)
        stroke_rectangle([0.75.in, 8.in], 2.in, 6.5.in)
        stroke_rectangle([2.75.in, 8.in], 3.25.in, 6.5.in)
        stroke_rectangle([6.in, 8.in], 1.25.in, 6.5.in)
        stroke_rectangle([7.25.in, 8.in], 1.in, 6.5.in)

        # Draw terms boxes.
        stroke_rectangle([0.25.in, 1.5.in], 4.in, 0.25.in)
        stroke_rectangle([0.25.in, 1.25.in], 4.in, 0.5.in)
        stroke_rectangle([4.25.in, 1.5.in], 4.in, 0.25.in)
        stroke_rectangle([4.25.in, 1.25.in], 4.in, 0.5.in)
        self.vms_text_box('Terms: 1% 10 Days, Net 30', 0.25, 1.5, 4, 0.25, 9, :bold, :center, :center)
        self.vms_text_box('All quoted prices are FOB Varland', 4.25, 1.5, 4, 0.25, 9, :bold, :center, :center)

        # Draw corporate compliance policy.
        self.vms_text_box("CORPORATE COMPLIANCE POLICY: Varland Metal Service, Inc. certifies that its pollution abatement system is operated\nin compliance with U.S. EPA, state, and local regulations applicable to waste water discharge and sludge disposal.", 0.25, 0.65, 8, 0.4, 8, :normal, :center, :center)
  
    end
  
  end