include ActionView::Helpers::NumberHelper

class PackingSlip < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :landscape

    def initialize(data = nil)
        super()
        file = File.read('288473.json')
        @data = JSON.parse(file)

        drawTable
        insertTableData
        insertHeader
        insertFooter
    end

    def insertHeader

        #Page Number
        font 'Arial Narrow', style: :bold
        bounding_box [_i(9.75), _i(5.9)], width: _i(1), height: _i(0.25) do
            number_pages 'PAGE <page> OF <total>', align: :center, :size => 9
        end

        repeat :all do

            #Header Image inserted at the top of page
            bounding_box([_i(0), _i(8.5)], :width => _i(11), :height => _i(1.5)) do
                image "#{Prawn::DATADIR}/images/ps_header.jpg", :fit => [_i(11), _i(1.5)]
            end

            #Draw the title 'Packing List' on top left of page
            font_size(9) do
                text_box "PACKING LIST", 
                            :at => [_i(0.25), _i(8.3)],
                            :width => _i(1),
                            :align => :left,
                            :valign => :top,
                            font => 'Arial Narrow', style: :normal
            end

            #Draw SOLD TO and SHIP TO along with addresses
            bounding_box [_i(0.25), _i(6.7)], width: _i(10.5), height: _i(1.4) do
                #Draw SOLD TO along left side
                y = 1.4
                ['S', 'O', 'L', 'D', '', 'T', 'O'].each do |text|
                    page_header_data_box text, 0, y, 0.2, 1.4, :center
                    y -= 0.15
                end

                #SOLD TO data
                sold_to_data = [
                    "SMALL PARTS INC.",
                    "PO BOX 23",
                    "LOGANSPORT, IN 46947"
                ]

                # Draw SOLD TO data
                y = 1.4
                sold_to_data.each do |text|
                    page_header_data_box text, 0.25, y, 4.5, 1.4, :left
                    y -= 0.2
                end

                #Draw SHIP DATE and SHIP DATE data
                page_header_text_box 'SHIP DATE:', 0, 0.2, 0.6
                page_header_data_box '04/10/18', 0.6, 0.12, 0.75

                #Draw SHIP TO 
                y = 1.4
                ['S', 'H', 'I', 'P', '', 'T', 'O'].each do |text|
                    page_header_data_box text, 5.25, y, 0.2, 1.4, :center
                    y -= 0.15
                end

                #SHIP TO data
                if (@data['shipTo']['name_2'] != "")
                    ship_to = [
                        @data['shipTo']['name_1'],
                        @data['shipTo']['name_2'],
                        @data['shipTo']['address'],
                        @data['shipTo']['city'] + ", " + @data['shipTo']['state'] + " " + (@data['shipTo']['zipCode'].to_s)[0, 5]
                    ]
                else 
                    ship_to = [
                        @data['shipTo']['name_1'],
                        @data['shipTo']['address'],
                        @data['shipTo']['city'] + ", " + @data['shipTo']['state'] + " " + (@data['shipTo']['zipCode'].to_s)[0, 5]
                    ]
                end

                #Draw SHIP TO Data
                y = 1.4
                ship_to.each do |text|
                    page_header_data_box text, 5.50, y, 3.5, 1.4, :left
                    y -= 0.2
                end

                #Draw SHIP VIA and SHIP VIA data
                page_header_text_box 'SHIP VIA:', 5.25, 0.2, 0.6
                page_header_data_box 'U.P.S. SECOND DAY', 5.8, 0.12, 2.0, 0.75

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
                page_header_data_box @data['customerCode'], 9.5, 0.4, 1, 0.75, :center
            end
        end
    end

    def drawTable        
        #Draw Table
        repeat :all do

            bounding_box [_i(0.25), _i(5.30)], width: _i(10.5), height: _i(4.8)do

                #Fill shaded area
                fill_color 'cccccc'
                fill_rectangle([_i(0), _i(4.8)], _i(10.5), _i(0.25))

                #Draw Horizontal Line
                stroke_line [_i(0), _i(4.55)], [_i(10.5), _i(4.55)]

                #Draw Vertical Lines
                [0, 0.6, 1.35, 2.1, 2.85, 3.85, 5.25, 7.1, 9.7, 10.5].each do |x|
                    stroke_line [_i(x), _i(4.8)], [_i(x), _i(0)]
                end

                #Draw Borders of box
                stroke_color '000000'
                stroke_bounds

                #Draw column headers
                page_header_text_box 'S.O. #', 0, 4.8, 0.6
                page_header_text_box 'S.O. DATE', 0.6, 4.8, 0.75
                page_header_text_box 'POUNDS', 1.35, 4.8, 0.75
                page_header_text_box 'PIECES', 2.1, 4.8, 0.75
                page_header_text_box 'CONTAINERS', 2.85, 4.8, 1
                page_header_text_box 'YOUR PO #', 3.85, 4.8, 1.4
                page_header_text_box 'PART DESCRIPTION', 5.25, 4.8, 1.85
                page_header_text_box 'PROCESS SPECIFICATION', 7.1, 4.8, 2.6
                page_header_text_box 'STATUS', 9.7, 4.8, 0.8

            end
        end
    end

    def insertTableData       
        
        bounding_box [_i(0.25), _i(5.05)], width: _i(10.5), height: _i(4.55) do

            poNumbers = @data['poNumbers'][0] + "\n" +  @data['poNumbers'][1] + "\n" +  @data['poNumbers'][2]
            partDescription = @data['partDescription'][0] + "\n" + @data['partDescription'][1] + "\n" + @data['partDescription'][2]

            #Dummny data
            packing_list_data = [
                [@data['shopOrder'].to_s, DateTime.parse(@data['shopOrderDate']).strftime("%m/%d/%y"), (number_with_delimiter(number_with_precision(@data['pounds'], precision: 2))), (number_with_delimiter(@data['pieces'])).to_s, @data['containers'].to_s + ' ' + @data['containerType'], poNumbers, partDescription, @data['process'], "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"],
                ["284555", "04/06/18", "47.38", "680", "1 CTN", "PJ00027663", "235900P\n60A SWITCH BLADE\nU-SHAPED\nLOT #19472-01-13450", "CADMIUM (.0002' MINIMUM)\n& CLEAR SEAL\nPER SQUARE D 40004-016-01", "COMPLETE"]
            ]

            table(packing_list_data, :width => (10.5*72)) do
                style(row(0...-1).columns(0...-1), :borders => [])
                style(columns(0), :width => (0.6*72), :align => :center)
                style(columns(1), :width => (0.75*72), :align => :center)
                style(columns(2), :width => (0.75*72), :align => :right)
                style(columns(3), :width => (0.75*72), :align => :right)
                style(columns(4), :width => (1.0*72), :align => :center)
                style(columns(5), :width => (1.4*72), :align => :left)
                style(columns(6), :width => (1.85*72), :align => :left)
                style(columns(7), :width => (2.6*72), :align => :left)
                style(columns(8), :width => (0.8*72), :align => :center)
            end
        end
    end

    def insertFooter
        repeat :all do

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