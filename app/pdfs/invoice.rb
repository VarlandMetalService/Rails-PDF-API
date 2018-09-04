include ActionView::Helpers::NumberHelper

class Invoice < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :portrait

    def initialize(data = nil)
        super()
        file = File.read('288473.json')
        @data = JSON.parse(file)

        draw_invoiceTable
        insert_data
        insert_header
    end

    def draw_invoiceTable()

        repeat :all do

            #Draw Table
            bounding_box [_i(0.5), _i(7.5)], width: _i(7.5), height: _i(6.85) do

                #Draw border around entire box
                stroke_color '000000'
                stroke_bounds

                #Draw Horizontal Lines
                [0.25, 6.6].each do |y|
                    stroke_line [_i(0), _i(y)], [_i(7.5), _i(y)]
                end

                # Draw Vertical Lines
                [0.75, 1.4, 2, 4.2].each do |x|
                    stroke_line [_i(x), _i(0.25)], [_i(x), _i(6.85)]
                end
                [5.4, 6.7, 7.5].each do |x|
                    stroke_line [_i(x), _i(0)], [_i(x), _i(6.85)]
                end

                #Draw Header Text
                page_header_text_box 'ORDER', 0, 6.85, 0.75, 0.25
                page_header_text_box 'POUNDS', 0.75, 6.85, 0.6, 0.25
                page_header_text_box 'PIECES', 1.4, 6.85, 0.6, 0.25
                page_header_text_box 'PART DESC./PROCESS SPEC.', 2, 6.85, 2.2, 0.25
                page_header_text_box 'REF #', 4.2, 6.85, 1.2, 0.25
                page_header_text_box 'PRICE/REMARKS', 5.4, 6.85, 1.3, 0.25
                page_header_text_box 'TOTALS', 6.7, 6.85, 0.8, 0.25
                page_header_text_box 'TERMS: 1% 10 DAYS NET 30, 1 1/2% INTEREST CHARGE ON PAST DUE BALANCE-18% ANNUAL', 0, 0.25, 5.4, 0.25, true, :center, :center
                page_header_text_box 'INVOICE TOTAL', 5.5, 0.25, 1.3, 0.25, true, :left, :center
                page_header_text_box '$', 6.75, 0.25, 0.8, 0.25, true, :left, :center

            end
            #Draw footer
            page_header_text_box 'We Hereby Certify That These Goods Were Produced In Compliance With The Fair Labor Standards Act, As Amended', 0.5, 0.6, 7.5, 0.2, false, :center, :top 
        end
    end

    def insert_data
        bounding_box [_i(0.5), _i(7.25)], width: _i(7.5), height: _i(6.4) do

            #Dummy data container
            invoice_data = [
                [
                    ["00000000000", "12345678901", "###########"],
                    '000,000.00',
                    '0,000,000',
                    @data['process'], 
                    @data['processCode'],
                    ['INCOMPLETE ORDER','##################'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['20,000,000.00','12,345,678.90'],
                ],
                [
                    ['XXXXX', @data['shopOrder'].to_s, 'XXXXXX'],
                    (number_with_delimiter(number_with_precision(@data['pounds'], precision: 2))),
                    (number_with_delimiter(@data['pieces'])).to_s,
                    @data['process'],
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],                    
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],                    
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],                    
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],                    
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ],
                [
                    ['253411', '284435', '04/09/18'],
                    '2.77',
                    '3,223',
                    @data['process'],                    
                    @data['processCode'],
                    ['COMPLETE ORDER','4125960'],
                    ['MINIMUM CHARGE', 'TOTAL DUE'],
                    ['200.00','200.00']
                ]
            ]

            #Initialize array
            dataLength = invoice_data.length
            invoice_data_formatted = Array.new(dataLength){Array.new(8)}

            #Inline format for the text under 'ORDER'
            shipperText = "<font size='8'><b>SHIPPER #:</b></font>\n"
            vmsOrderText = "\n<font size='8'><b>VMS ORDER#:</b></font>\n"
            shipDateText = "\n<font size='8'><b>SHIP DATE:</b></font>\n"

            #Undlerines in the TOTALS column (Dirty solution, rework if possible)
            strikeoutText = "\n<font size='4'><strikethrough><i>-                                                     </i></strikethrough><font><font size='9'><fontsize>\n"

            (0...dataLength-1).each do |i|
                invoice_data_formatted[i][0] = shipperText + invoice_data[i][0][0] + vmsOrderText + invoice_data[i][0][1] +  shipDateText + invoice_data[i][0][2]
                invoice_data_formatted[i][1] = invoice_data[i][1]
                invoice_data_formatted[i][2] = invoice_data[i][2]
                invoice_data_formatted[i][3] = invoice_data[i][3]
                invoice_data_formatted[i][4] = invoice_data[i][4]
                invoice_data_formatted[i][5] = invoice_data[i][5].join("\n")
                invoice_data_formatted[i][6] = invoice_data[i][6].join("\n\n")
                invoice_data_formatted[i][7] = ['$', '$'].join("\n\n")
                invoice_data_formatted[i][8] = invoice_data[i][7][0] + strikeoutText + invoice_data[i][7][1]
            end

            font 'Arial Narrow', style: :normal
            font_size  9
            table(invoice_data_formatted, :width => (7.49*72), :cell_style => { :inline_format => true}) do
                style(row(0...-1).columns(0...-1), :borders => [])
                style(columns(0), :width => (0.76*72), :align => :center)
                style(columns(1), :width => (0.65*72), :align => :center)
                style(columns(2), :width => (0.6*72), :align => :center)
                style(columns(3), :width => (1.9*72), :align => :left, :font_size => 8)
                style(columns(4), :width => (0.275*72), :align => :center, :padding => [5, 0, 5, 0])
                style(columns(5), :width => (1.205*72), :align => :center)
                style(columns(6), :width => (1.3*72), :align => :left)
                style(columns(7), :width => (0.08*72), :align => :right, :padding => [5, 0, 5, 0])
                style(columns(8), :width => (0.72*72), :align => :right, :padding => [5, 3, 5, 0])
            end 

        end
    end

    def insert_header
        #Print the page number
        bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
            number_pages 'PAGE <page> OF <total>', align: :right
        end

        repeat :all do
            #Header Image (Varland Logo)
            bounding_box([_i(0.5), _i(10.6)], :width => _i(7.5), :height => _i(1.2)) do
                image "#{Prawn::DATADIR}/images/varlandLogo.jpg", :fit => [_i(7.5), _i(1.2)]
            end
            
            #Header Labels/Data
            bounding_box [_i(0.5), _i(9)], width: _i(7.5), height: _i(1.5) do
                #Draw Header Text
                font_size 22
                text "INVOICE #: " + @data['shopOrder'].to_s, :align => :center
                page_header_text_box 'SOLD TO:', 0, 1, 2.5, 0.2, true, :left, :top, :bold
                page_header_text_box 'SHIPPED VIA:', 0, 0.15, 0.7, 0.2, true, :left, :top
                page_header_text_box 'SHIP TO:', 4.2, 1, 0.75, 0.2, true, :left, :top, :bold
                page_header_text_box 'INVOICE DATE:', 4.79, 0.15, 0.75, 0.2, true, :left, :top
                page_header_text_box 'INVOICE #:', 6.50, 0.15, 0.75, 0.2, true, :left, :top

                #SOLD TO Data
                if (@data['shipTo']['name_2'] != "")
                    sold_to = [
                        @data['shipTo']['name_1'],
                        @data['shipTo']['name_2'],
                        @data['shipTo']['address'],
                        @data['shipTo']['city'] + ", " + @data['shipTo']['state'] + " " + (@data['shipTo']['zipCode'].to_s)[0, 5]
                    ]
                else 
                    sold_to = [
                        @data['shipTo']['name_1'],
                        @data['shipTo']['address'],
                        @data['shipTo']['city'] + ", " + @data['shipTo']['state'] + " " + (@data['shipTo']['zipCode'].to_s)[0, 5]
                    ]
                end

                #Draw SOLD TO Data
                y = 0.875
                sold_to.each do |text|
                    page_header_data_box text, 0, y, 2.5, 0.15, false, :left
                    y -= 0.14
                end

                #SHIP TO Data
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
                y = 0.875
                ship_to.each do |text|
                    page_header_data_box text, 4.2, y, 2.5, 0.15, false, :left
                    y -= 0.14
                end

                #Draw SHIPPED VIA data
                page_header_data_box 'UPS FREIGHT PRO#433831215', 0.7, 0.205, 2, 0.2, false, :left

                #Draw Invoice Date
                page_header_data_box '04/10/18', 5.55, 0.205, 0.75, 0.2

                #Draw Invoice Number.
                page_header_data_box '276876', 0.0, 0.19, 7.5, 0.2, false, :right

                #Draw customer code and FAX #
                y = 0.875
                [@data['customerCode'],
                'Phone: ' + number_to_phone(@data['shipTo']['phone'].to_i),
                'FAX: (440) 816-9501'].each do |text|
                    page_header_data_box text, 0.0, y, 7.5, 0.2, false, :right
                    y -= 0.125
                end
            end

        end
    end

    def page_header_text_box(text, x, y, width, height = 0.2, large = false, align = :center, valign = :center, style =:bold)
        font 'Arial Narrow', style: style
        font_size large ? 10 : 8
        fill_color '000000'
        text_box  text,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end
    
    def page_header_data_box(text, x, y, width, height = 0.2, large = false, align = :left, valign = :center, style =:normal)
        return if text.blank?
        font 'Arial Narrow', style: style
        font_size large ? 14 : 9
        fill_color '000000'
        text_box  text.upcase,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  inline_format: true
    end
    
end
