class BillOfLading < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :portrait

    def initialize(data = nil)
        super()
        @data = data
        insert_header
        draw_bol
        insert_data
    end

    def draw_bol
        bounding_box([_i(0.25), _i(8.3)], :width => _i(8), :height => _i(8)) do

            #Draw Vertical Lines
            stroke_line [_i(4.0), _i(8.0)], [_i(4.0), _i(7.25)]
            stroke_line [_i(6.25), _i(7.25)], [_i(6.25), _i(3.45)]
            [1.25, 1.65, 5.0, 6.9].each do |x|
                stroke_line [_i(x), _i(7.0)], [_i(x), _i(3.45)]
            end
            [4.0, 6.25].each do |x|
                stroke_line [_i(x), _i(2.85)], [_i(x), _i(1.25)]
            end

            #Draw Horizonatal Lines
            [7.25, 7.0, 6.75, 3.45, 2.85, 2.25, 1.25, 0.5].each do |y|
                stroke_line [_i(0), _i(y)], [_i(8.0), _i(y)]
            end
            stroke_line [_i(0.0), _i(1.6)], [_i(4.0), _i(1.6)]
            stroke_line [_i(6.25), _i(1.85)], [_i(8.0), _i(1.85)]

            #Line for 'Signature of Consignor'
            stroke_line [_i(4.05), _i(1.425)], [_i(6.2), _i(1.425)]

            #Draw boxes in C.O.D. Fee
            [2.65, 2.45].each do |y|
                stroke_rectangle [_i(7.0), _i(y)], _i(0.2), _i(0.2)
            end

            #Draw box in 'FRIEGHT CHARGES'
            stroke_rectangle [_i(7.15), _i(1.45)], _i(0.2), _i(0.2)

            #Draw Header Texts
            page_header_text_box 'TO:', 0.05, 7.95, 4.0, 0.75, false, :left, :top, :bold
            y = 7.775
            ['Cosignee', 'Street', 'Destination'].each do |text|
                page_header_text_box text, 0.05, y, 4.0, 0.75, false, :left, :top
                y -= 0.175
            end
            page_header_text_box 'Zip', 3.15, 7.425, 0.2, 0.75, false, :left, :top
            page_header_text_box 'FROM:', 4.05, 7.95, 4.0, 0.75, false, :left, :top, :bold
            y = 7.775
            ['Shipper', 'Street', 'Origin'].each do |text|
                page_header_text_box text, 4.05, y, 4.0, 0.75, false, :left, :top
                y -= 0.175
            end
            page_header_text_box 'Initials', 7.0, 7.425, 4.0, 0.75, false, :left, :top
            page_header_text_box 'Route', 0.05, 7.25, 6.25, 0.25, false, :left
            page_header_text_box 'Vehicle Number', 6.25, 7.25, 0.6, 0.25, false, :center
            y = 7.05
            ['Number of', 
            'Shipping Units:'].each do |text|
                page_header_text_box text, 0, y, 1.25, 0.25, false, :center
                y -= 0.1
            end
            page_header_text_box 'HM*', 1.25, 7.0, 0.4, 0.25, false, :center
            y = 6.9755
            ['Kind of Packaging, Description of Articles', 
            'Special Marks and Exceptions'].each do |text|
                page_header_text_box text, 1.65, y, 3.355, 0.25, false, :center, :top
                y -= 0.11
            end
            page_header_text_box '§ Weight', 5.0, 6.975, 1.25, 0.25, false, :center, :top
            font_size(6) do #Requires smaller font
                text_box "(Subject to Correction)", 
                            :at => [_i(5.0), _i(6.85)],
                            :width => _i(1.25),
                            :height => _i(0.25),
                            :align => :center,
                            :valign => :top,
                            font => 'Arial Narrow', style: :bold
            end
            page_header_text_box 'Rate or Class', 6.25, 7.0, 0.65, 0.25, false, :center
            page_header_text_box 'CHARGES', 6.9, 7.0, 1.1, 0.25, false, :center
            page_header_text_box 'SPECIAL INSTRUCTIONS:', 0.05, 3.40, 8.0, 0.55, false, :left, :top, :bold
            page_header_text_box 'REMIT C.O.D. TO:', 0.05, 2.80, 4.0, 0.55, false, :left, :top, :bold
            page_header_text_box 'ADDRESS', 0.05, 2.825, 4.0, 0.55, false, :left, :center
            page_header_text_box 'COD', 4.05, 2.80, 4.0, 0.55, true, :left, :bottom, :bold
            page_header_text_box 'C.O.D. FEE', 6.3, 2.80, 1.75, 0.5, false, :left, :top, :bold
            page_header_text_box 'PREPAID', 6.3, 2.80, 1.75, 0.5, false, :left, :center
            page_header_text_box 'COLLECT', 6.3, 2.80, 1.75, 0.5, false, :left, :bottom
            page_header_text_box '$', 7.3, 2.80, 1.75, 0.5, false, :left, :bottom
            page_header_text_box '$', 0.05, 1.63, 4.0, 0.35, false, :left, :bottom
            page_header_text_box 'PER', 0.05, 1.63, 4.0, 0.35, false, :center, :bottom
            page_header_text_box 'TOTAL CHARGES', 6.3, 2.25, 0.6, 0.4, false, :left, :center
            page_header_text_box 'SHIPPER', 0.05, 0.45, 0.6, 0.4, false, :left, :center
            page_header_text_box 'PER', 0.05, 0.45, 0.6, 0.4, false, :left, :bottom
            page_header_text_box 'CARRIER', 4.1, 0.45, 4.0, 0.4, false, :left, :center
            page_header_text_box 'PER', 4.1, 0.45, 4.0, 0.4, false, :left, :bottom
            page_header_text_box 'DATE', 6.175, 0.45, 4.0, 0.4, false, :left, :bottom

            #Draw small-font static text
            page_small_text_box 'ON COLLECT ON DELIVERY SHIPMENTS THE LETTERS "COD" MUST APPEAR BEFORE COSIGNEES NAME  - OR AS OTHERWISE PROVIDED IN ITEM 430, SEC. 1', 4.05, 2.83, 2.2, 0.3, true, :left
            page_small_text_box 'Amt: $', 4.0, 2.83, 2.0, 0.55, true, :center, :bottom
            page_small_text_box 'Signature of Cosignor', 4.1, 1.43, 2.1, 0.2, true, :center, :center, :bold
            page_small_text_box 'FREIGHT CHARGES', 6.3, 1.825, 1.75, 0.6, true, :center, :top

            page_small_text_box 'FREIGHT PREPAID
                                except when box
                                at right is checked.', 6.3, 1.875, 1.75, 0.6, true, :left, :bottom

            page_small_text_box 'Check box if
                                charges are to 
                                be collect.', 7.465, 1.875, 0.54, 0.6, true, :left, :bottom

            page_small_text_box '§ If the shipment moves between two ports by a carrier of water, the law requires that the bill of lading shall state whether it is carriers or shippers weight.
                                
                                †"The fibre contains used for this shipment conform to the specifications set forth in the box makers certificate thereon, and all other requirements of Rule 41 of the Uniform Freight Classification and Rule 5 of the National Motor Freight Classification."
                                †"Shippers imprint in lieu of stamp; not a part of the bill of lading approved by the Interstate Commerce Commission."', 0.05, 2.225, 3.95, 0.625, false, :left, :top

            page_small_text_box 'NOTE: Where the rate is dependent on value, shippers are required to stats specifically in writing the agreed or declared value of the property.', 0.05, 1.585, 4.0, 0.35, false, :left, :top
            page_small_text_box 'Shipper hereby specifically states agreed or declared value of this property to be not exceeding', 0.457, 1.49, 4.0, 0.5, false, :left, :top, :bold

            page_small_text_box 'Subject to Section 7 of the conditions, if this shipment is to be
                                 delivered to the consignee without recourse on the consignor, the
                                 consignor shall sign the following statement:
                                 The carrier shall not make delivery of this shipment without payment of freight and all other lawful charges.', 4.05, 2.2, 2.25, 1.0, false, :left, :top
            
            page_small_text_box 'RECIEVED, subject to the classifications and lawfully filled tariffs in effect on the date of the issue of this Bill of Lading, the
                                 property described above in apparent good order, except as noted (contents and condition of contents of packages unknown),
                                 marked, cosigned and destined as indicated above which said carrier (the word carrier being understood throughout this
                                 contract as meaning any person or corporation in possession of the property under the contract) agrees to carry to its usual
                                 place of delivery at said destination if on its route, otherwise to deliver to another carrier on the route to said destination. It is
                                 mutually agreed as to each carrier of all or any of said property over all or any portion of said route to destination and as to
                                 each party at any time interested in all or any said property, that every service to be performed hereunder shall be subject to all', 0.05, 1.2, 3.95, 1.2, false, :left, :top

            page_small_text_box 'the Bill of Lading terms and conditions in the governing classification on the date of shipment. Shipper hereby certifies that he
                                 is familiar with all the Bill of Lading terms and conditions in the governing classification and the said terms and conditions are
                                 hereby agreed to by the shipper and accepted for himself and his assigns. NOTICE: Freight moving under this Bill of Lading is
                                 subject to classifications and lawfully filled tariffs in effect on the date of this Bill of Lading. This notice supersedes and
                                 negates and claimed, alleged or asserted oral or written contract promise, representation or understanding between the
                                 parties with respect to this freight, except to the extent of any written contract which established lawful contract carriage and is
                                 signed by authorized representatives of both parties to the contract.', 4.05, 1.2, 3.95, 1.2, false, :left, :top
            
            page_small_text_box 'This is to certify that the above named materials are properly classified, packaged, marked, and labeled, and are in proper condition for transportation according to the applicable regulations of the Department of Transportation', 0.05, 0.45, 8.0, 0.5, false, :left, :top

            #Insert "Signature of Consignor"
            bounding_box([_i(4.6), _i(1.8)], :width => _i(3.0), :height => _i(0.5)) do
                image "#{Prawn::DATADIR}/images/terry.png", :fit => [_i(3.0), _i(0.5)]
            end

            #Insert at bottom of page
            bounding_box([_i(0.6), _i(0.3)], :width => _i(2), :height => _i(0.4)) do
                image "#{Prawn::DATADIR}/images/terry.png", :fit => [_i(2), _i(0.4)]
            end


            stroke_color '000000'
            stroke_bounds
        end

        #Footer
        page_small_text_box '* MARK WITH "X" TO DESIGNATE HAZARDOUS MATERIAL AS DEFINED IN TITLE 49 OF FEDERAL REGULATION', 0.25, 0.25, 8.0, 0.2, false, :left, :top, :bold
    end

    def insert_header
        #Header Image inserted at the top of page
        bounding_box([_i(0.25), _i(10.5)], :width => _i(8), :height => _i(1.25)) do
            image "#{Prawn::DATADIR}/images/bol_header.jpg", :fit => [_i(8), _i(1.25)]
        end

        bounding_box([_i(0.25), _i(9.3)], :width => _i(8), :height => _i(1)) do
            page_header_text_box 'STRAIGHT BILL OF LADING - SHORT FORM', 0.0, 0.8, 8.0, 0.8, true, :center, :top, :bold
            font_size(11) do
                text_box "ORIGINAL - NOT NEGOTIABLE", 
                            :at => [_i(0.0), _i(0.6)],
                            :width => _i(8),
                            :height => _i(0.65),
                            :align => :center,
                            :valign => :top,
                            font => 'Arial Narrow', style: :normal
            end

            #Draw Header Texts
            page_header_text_box 'Name of Carrier:', 0, 0.2, 0.9, 0.2, false, :left
            page_header_text_box 'VMS Shipper #:', 0, 0.4, 6.4, 0.2, false, :right
            page_header_text_box 'Date:', 0, 0.2, 6.4, 0.2, false, :right

        end    

    end

    def insert_data
        #Header Data
        bol_header_data = [
            "R & L Carriers",
            "253474",
            "04/11/2018"
        ]

        #insert header data
        bounding_box([_i(0.25), _i(9.3)], :width => _i(8), :height => _i(1)) do
            page_header_data_box bol_header_data[0], 0.9, 0.2, 3, 0.2, false, :left, :center
            page_header_data_box bol_header_data[1], 6.45, 0.4, 1.5, 0.2, false, :left, :center
            page_header_data_box bol_header_data[2], 6.45, 0.2, 1.5, 0.2, false, :left, :center
        end

        #Body Data
        bounding_box([_i(0.25), _i(8.3)], :width => _i(8), :height => _i(8)) do

            #TO Data
            to_info = [
                "SECURITY SIGNALS INC.",
                "9509 MACON ROAD",
                "CORDOVA, TN", 
                "38016"
            ]

            #Insert TO Data
            y = 7.775
            to_info[0...to_info.length-1].each do |text|
                page_header_data_box text, 0.75, y, 3.0, 0.75, false, :left, :top
                y -= 0.175
            end
            page_header_data_box to_info[-1], 3.4, 7.425, 0.6, 0.75, false, :left, :top 

            #FROM Data
            from_info = [
                "VARLAND METAL SERVICE",
                "3231 FREDONIA AVENUE ● (513) 861-0555",
                "Cincinnati, OH 45229-3394"
            ]
            page_header_data_box from_info[0], 4.7, 7.775, 3.25, 0.75, false, :left, :top
            
            #Insert FROM Data
            y = 7.6
            from_info[1...from_info.length].each do |text|
                page_header_text_box text, 4.75, y, 3.25, 0.75, false, :left, :top, :normal
                y -= 0.175
            end

            #Insert initials
            page_header_data_box 'TM', 7.4, 7.425, 0.6, 0.75, false, :left, :top

            #Order Data
            order_data = [
                ["1", "", "##############################################################################################################################", "570#", "50", ""],
                ["2", "", "##############################################################################################################################", "460#", "30", ""],
                ["3", "", "##############################################################################################################################", "460#", "30", ""],
                ["4", "", "##############################################################################################################################", "460#", "30", ""],
                ["5", "", "##############################################################################################################################", "460#", "30", ""],
                ["6", "", "##############################################################################################################################", "460#", "30", ""],
                ["7", "", "##############################################################################################################################", "460#", "30", ""],
                ["8", "", "##############################################################################################################################", "460#", "30", ""],
                ["9", "", "##############################################################################################################################", "460#", "30", ""]
            ]

            #Insert Order Data
            move_cursor_to _i(6.75)
            table(order_data, :width => (8*72)) do
                style(row(0...-1).columns(0...-1), :align => :center)
                style(row(0...-1).columns(2), :align => :left)
                style(row(0...-1).columns(0...-1), :borders => [])
                style(columns(0), :width => (1.25*72))
                style(columns(1), :width => (0.4*72))
                style(columns(2), :width => (3.35*72))
                style(columns(3), :width => (1.25*72))
                style(columns(4), :width => (0.65*72)) 
            end

            page_header_data_box 'XXX', 7.1, 1.4, 0.4, 0.2, false, :left

            page_header_data_box 'Varland Metal Service, Inc. ● Cincinnati, OH 45229-3394', 0.6, 0.3, 3.3, 0.15
            page_header_data_box 'R & L Carriers', 4.6, 0.3, 3.3, 0.15
            page_header_data_box '04/11/2018', 6.6, 0.45, 4.0, 0.4, false, :left, :bottom
        end
    end

    def page_header_text_box(text, x, y, width, height, large = false, align = :center, valign = :center, style = :normal)
        font 'Arial Narrow', style: style
        font_size large ? 14 : 9
        fill_color '000000'
        text_box  text,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end

    def page_header_data_box(text, x, y, width, height, large = false, align = :left, valign = :top, style = :bold)
        return if text.blank?
        font 'Arial Narrow', style: style
        font_size large ? 16 : 8
        fill_color '000000'
        x += 0.05
        width -= 0.1
        text_box  text,
              at: [_i(x), _i(y)],
              width: _i(width),
              height: _i(height),
              align: align,
              valign: valign,
              inline_format: true
    end

    def page_small_text_box(text, x, y, width, height, large = false, align = :center, valign = :center, style = :normal)
        font 'Arial Narrow', style: style
        font_size large ? 7 : 6
        fill_color '000000'
        text_box  text,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end
end