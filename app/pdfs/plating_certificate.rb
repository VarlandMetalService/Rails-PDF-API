class PlatingCertificate < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :landscape

    def initialize(data = nil)
        super()
        @data = data

        draw_platingCert
        insert_headerImage
    end


    def draw_platingCert

        bounding_box [_i(0.25), _i(5.3)], width: _i(10.5), height: _i(4.75) do
            #Fill shaded area
            fill_color 'cccccc'
            fill_rectangle([_i(0), _i(4.0)], _i(10.5), _i(0.25))

            #Draw Horizontal Line
            stroke_line [_i(0), _i(4.0)], [_i(10.5), _i(4.0)]
            stroke_line [_i(0), _i(3.75)], [_i(10.5), _i(3.75)]

            #Draw Vertical Lines
            [0.6, 1.35, 2.1, 2.85, 3.85, 5.25, 7.1, 9.7].each do |x|
                stroke_line [_i(x), _i(4.0)], [_i(x), _i(0)]
            end

            #Draw Outside borders
            stroke_color '000000'
            stroke_bounds

            fill_color '000000'
            font_size(32) do
                text_box "PLATING CERTIFICATION", 
                            :at => [_i(0.0), _i(4.75)],
                            :width => _i(10.5),
                            :height => _i(0.75),
                            :align => :center,
                            :valign => :center,
                            font => 'Arial Narrow', style: :bold
            end

            page_header_text_box 'S.O. #', 0, 4.0, 0.6
            page_header_text_box 'S.O. DATE', 0.6, 4.0, 0.75
            page_header_text_box 'POUNDS', 1.35, 4.0, 0.75
            page_header_text_box 'PIECES', 2.1, 4.0, 0.75
            page_header_text_box 'CONTAINERS', 2.85, 4.0, 1
            page_header_text_box 'YOUR PO #', 3.85, 4.0, 1.4
            page_header_text_box 'PART DESCRIPTION', 5.25, 4.0, 1.85
            page_header_text_box 'PROCESS SPECIFICATION', 7.1, 4.0, 2.6
            page_header_text_box 'STATUS', 9.7, 4.0, 0.8

            #Draw Table Data
            page_header_data_box '284555', 0, 3.7, 0.6, 4.5, :center, false
            page_header_data_box '04/06/18', 0.6, 3.7, 0.75, 4.5, :center, false
            page_header_data_box '47.38', 1.35, 3.7, 0.75, 4.5, :right, false
            page_header_data_box '680', 2.1, 3.7, 0.75, 4.5, :right, false
            page_header_data_box '1 CTN', 2.85, 3.7, 1, 4.5, :center, false
            page_header_data_box 'PJ00027663', 3.85, 3.7, 1.4, 4.5, :left, false
            y = 3.7
            ['235900P', '60A SWITCH BLADE', 'U-SHAPED', 'LOT #19472-01-13450'].each do |text|
                page_header_data_box text, 5.25, y, 1.85, 4.5, :left, false
                y -= 0.15
            end
            
            y = 3.7
            ['WE CERTIFY THAT THIS LOT OF PARTS',
             'WAS PROCESSED TO THE FOLLOWING',
             'PARAMETERS:',
             '',
             'CADMIUM (.0002" MINIMUM)', 
             '& CLEAR SEAL', 
             'PER SQUARE D 40004-016-01',
             '',
             'QUALITY CONTROL DEPARTMENT',
             'VARLAND METAL SERVICE, INC.'].each do |text|
                page_header_data_box text, 7.1, y, 2.6, 4.5, :left, false
                y -= 0.15
            end
            page_header_data_box 'COMPLETE', 9.7, 3.7, 0.8, 4.5, :center, false            
        end

        bounding_box [_i(0.25), _i(6.7)], width: _i(10.5), height: _i(1.4) do
            #Draw SOLD TO along left side
            y = 1.4
            ['S', 'O', 'L', 'D', '', 'T', 'O'].each do |text|
                page_header_data_box text, 0, y, 0.2, 1.4, :center
                y -= 0.15
            end

            # Draw SOLD TO data
            y = 1.4
            ['SMALL PARTS INC.',
             'PO BOX 23',
             'LOGANSPORT, IN 46947'].each do |text|
                page_header_data_box text, 0.25, y, 2.0, 1.4, :left
                y -= 0.175
            end

            #Draw SHIP DATE and SHIP DATE data
            page_header_text_box 'SHIP DATE:', 0, 0.2, 0.6, 0.2, false, :left
            page_header_data_box '04/10/18', 0.6, 0.2, 0.75, 0.2, :left, false, :center

            #Draw SHIP TO 
            y = 1.4
            ['S', 'H', 'I', 'P', '', 'T', 'O'].each do |text|
                page_header_data_box text, 5.25, y, 0.2, 1.4, :center
                y -= 0.15
            end

            #Draw SHIP TO Data
            y = 1.4
            ['SMALL PARTS INC.',
             'C/O F1 LOGISTICS - SUITE 2',
             '543-A AMERICAS',
             'EL PASO, TX 79907'].each do |text|
                page_header_data_box text, 5.50, y, 2.5, 1.4, :left
                y -= 0.175
            end

            #Draw SHIP VIA and SHIP VIA data
            page_header_text_box 'SHIP VIA:', 5.25, 0.2, 0.6, 0.2, false, :left
            page_header_data_box 'U.P.S. SECOND DAY', 5.8, 0.2, 3.0, 0.2, :left, false, :center

            #Fill shaded area
            fill_color 'cccccc'
            fill_rectangle([_i(9.5), _i(1.4)], _i(1.0), _i(0.25))
            
            #Draw SHIPPER # Box
            stroke_rectangle [_i(9.5), _i(1.4)], _i(1.0), _i(0.25)
        
            #DRAW SHIPPER #
            page_header_data_box 'SHIPPER #', 9.5, 1.4, 1.0, 0.25, :center, true, :center
            font_size(20) do
                text_box "253443", :at => [_i(9.5), _i(1.0)],
                                :width => _i(1),
                                :align => :center,
                                font => 'Arial Narrow', style: :bold
            end

            #Draw Customer Code
            page_header_data_box 'SMAELP', 9.5, 0.4, 1, 0.75, :center
        end

        #Draw the footer 'Recieved by' 
        font_size(9) do
            text_box "Recieved By:", 
                        :at => [_i(0.85), _i(0.4)],
                        :width => _i(1),
                        :align => :left,
                        :valign => :top,
                        font => 'Arial Narrow', style: :normal
        end

        #Draw line for signature
        stroke_line [_i(1.5), _i(0.3)], [_i(4.5), _i(0.3)]

    end

    def insert_headerImage
        #Header Image inserted at the top of page
        bounding_box([_i(0), _i(8.3)], :width => _i(11), :height => _i(1.5)) do
            image "#{Prawn::DATADIR}/images/cert_header.jpg", :fit => [_i(11), _i(1.5)]
        end
    end

    def page_header_text_box(text, x, y, width, height = 0.25, large = false, align = :center, valign = :center)
        font 'Arial Narrow', style: :normal
        font_size large ? 14 : 10
        fill_color '000000'
        text_box  text.upcase,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end
    
    def page_header_data_box(text, x, y, width, height = 4.5 , align = :left, large = false, valign = :top)
        return if text.blank?
        font 'Arial Narrow', style: :bold
        font_size large ? 14 : 10
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

end
