class Invoice < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :portrait

    def initialize(data = nil)
        super()
        @data = data

        draw_invoiceTable
        #insert_data
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
                
            

                #Draw '$' symbols as well as lines under 'TOTALS'
                #TODO: Need to make a way to only print this out as many times as needed. As well, let us hope formating remains okay.
                #It may be possible to cound the number of orders, and then use some spacing trickwork to display in the proper places.
                y = 6.5
                stroke_line [_i(6.75), _i((y - 0.15))], [_i(7.45), _i((y-0.15))] 
                ['$','$'].each do |text|
                    page_header_text_box text, 6.75, y, 0.8, 0.25, false, :left, :top
                    y -= 0.2
                end

            end
            #Draw sub-header
            page_header_text_box 'We Hereby Certify That These Goods Were Produced In Compliance With The Fair Labor Standards Act, As Amended', 0.5, 0.6, 7.5, 0.2, false, :center, :top 
        end
    end

    def insert_data
        bounding_box [_i(0.5), _i(7.25)], width: _i(), height: _i() do
            invoice_data = [
                '253411', 
                '284435', 
                '04/09/18',
                '2.77',
                '3,223',
                ['MMXP02.6C006TZ',
                 'RECD AS MMXP02.6C006Z',
                 'M2.6-45 X 6 PH PAN M/S:',
                 'STRIP ZINC, REPLATE',
                 'TIN-ZINC (.0002" - .0004")',
                 '& CLEAR TRIVALENT CHROMATE'],
                 'STZ',
                 '4125960',
                 '200',
                 '200',
                 '747.20'
            ]

            table(invoice_data, :width => (8*72)) do
                style(row(0...-1).columns(0...-1), :borders => [])
                style(columns(0), :width => (0.75*72), :align => :center)
                style(columns(1), :width => (0.65*72), :align => :center)
                style(columns(2), :width => (0.6*72), :align => :center)
                style(columns(3), :width => (2.2*72), :align => :left)
                style(columns(4), :width => (1.2*72), :align => :center)
                style(columns(5), :width => (1.3*72), :align => :left)
                style(columns(6), :width => (1.8*72), :align => :right)
            end

        end
    end

    def insert_header
        repeat :all do
            #Header Image (Varland Logo)
            bounding_box([_i(0.5), _i(10.6)], :width => _i(7.5), :height => _i(1.2)) do
                image "#{Prawn::DATADIR}/images/varlandLogo.jpg", :fit => [_i(7.5), _i(1.2)]
            end

            #Header Labels/Data
            bounding_box [_i(0.5), _i(9)], width: _i(7.5), height: _i(1.5) do
                #Draw Header Text
                font_size 22
                text "INVOICE #: 276876", :align => :center
                page_header_text_box 'SOLD TO:', 0, 1, 2.5, 0.2, true, :left, :top, :bold
                page_header_text_box 'SHIPPED VIA:', 0, 0.15, 0.7, 0.2, true, :left, :top
                page_header_text_box 'SHIP TO:', 4.2, 1, 0.75, 0.2, true, :left, :top, :bold
                page_header_text_box 'INOVICE DATE:', 4.79, 0.15, 0.75, 0.2, true, :left, :top
                page_header_text_box 'INOVICE #:', 6.50, 0.15, 0.75, 0.2, true, :left, :top

                #SOLD TO Data
                sold_to = [
                    "SOLUTION INDUSTRIES LLC",
                    "UNIT 7-11",
                    "17830 ENGLEWOOD DR.",
                    "MIDDLEBURG HTS., OH 44130"
                ]

                #Draw SOLD TO Data
                y = 0.875
                sold_to.each do |text|
                    page_header_data_box text, 0, y, 2.5, 0.15, false, :left
                    y -= 0.14
                end

                #SHIP TO Data
                ship_to = [
                    "SOLUTION INDUSTRIES LLC",
                    "UNIT 7-11",
                    "17830 ENGLEWOOD DR.",
                    "MIDDLEBURG HTS., OH 44130"
                ]

                #Draw SHIP TO Data
                y = 0.875
                ship_to.each do |text|
                    page_header_data_box text, 4.2, y, 2.5, 0.15, false, :left
                    y -= 0.14
                end

                #Draw SHIPPED VIA data
                page_header_data_box 'UPS FREIGHT PRO#433831215', 0.7, 0.2, 2, 0.2, false, :left

                #Draw Invoice Date
                page_header_data_box '04/10/18', 5.55, 0.2, 0.75, 0.2

                #Draw Invoice Number.
                page_header_data_box '276876', 0.0, 0.2, 7.5, 0.2, false, :right

                #Draw customer code and FAX #
                y = 0.875
                ['SOLIND',
                '',
                'FAX: (440) 816-9501'].each do |text|
                    page_header_data_box text, 0.0, y, 7.5, 0.2, false, :right
                    y -= 0.125
                end
            end

            #Print the page number
            bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
                number_pages 'PAGE <page> OF <total>', align: :right
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
    
=begin
        bounding_box [_i(0.5), _i(7.5)], width: _i(7.5), height: _i(6.85) do

             #Labels under 'ORDER'
             y = 6.5
             ['SHIPPER #:', 'VMS ORDER #:', 'SHIP DATE:'].each do |text|
                 page_header_text_box text, 0, y, 0.8, 0.2, false, :center, :top
                 y -= 0.4
             end
 
             #Draw Order Data
             y = 6.35 
             ['253411',
              '284435',
              '04/09/18'].each do |text|
                 page_header_data_box text, 0, y, 0.8, 0.2, false, :center, :top
                 y -= 0.4
             end
 
             #Draw Pounds Data
             y = 6.5
             ['2.77'].each do |text|
                 page_header_data_box text, 0.75, y, 0.6, 0.2, false, :center, :top
                 y -= 0.15
             end
 
             #Draw Pieces Data
             y = 6.5
             ['3,223'].each do |text|
                 page_header_data_box text, 1.4, y, 0.6, 0.2, false, :center, :top
                 y -= 0.15
             end
 
             #Draw Part Desc. Data
             y = 6.5
             ['MMXP02.6C006TZ',
              'RECD AS MMXP02.6C006Z',
              'M2.6-45 X 6 PH PAN M/S:',
              'STRIP ZINC, REPLATE',
              'TIN-ZINC (.0002" - .0004")',
              '& CLEAR TRIVALENT CHROMATE'].each do |text|
                 page_header_data_box text, 2.1, y, 2.2, 0.2, false, :left, :top
                 y -= 0.15
             end
 
             y = 6.5
             ['STZ'].each do |text|
                 page_header_data_box text, 2.1, y, 2.0, 0.2, false, :right, :top
             end
 
             #Draw 'REF#' Data
             y = 6.5
             ['COMPLETE ORDER',
              '4125960'].each do |text|
                 page_header_data_box text, 4.2, y, 1.2, 0.2, false, :center, :top
                 y -= 0.15
             end
 
             #Draw Price/Remarks Data
             y = 6.5
             ['MINIMUM CHARGE',
              'TOTAL DUE'].each do |text|
                 page_header_data_box text, 5.5, y, 1.3, 0.2, false, :left, :top
                 y -= 0.15
             end
 
             #Draw Totals Data
             y = 6.5
             ['200.00',
              '200.00'].each do |text|
                 page_header_data_box text, 6.65, y, 0.8, 0.2, false, :right, :top
                 y -= 0.2
             end

            #Draw Invoice Total Data
            page_header_data_box '747.20', 6.7, 0.25, 0.75, 0.25, false, :right, :center, :bold
        end
=end
end
