class Invoice < VarlandPdf
    DEFAULT_MARGIN = 0
    DEFAULT_LAYOUT = :portrait

    def initialize(data = nil)
        super()
        @data = data
        insert_headerImage
        draw_invoice
    end

    def draw_invoice
        #Draw Table
        bounding_box [_i(0.5), _i(7.5)], width: _i(7.5), height: _i(7) do

            #Draw border around entire box
            stroke_color '000000'
            stroke_bounds

            #Draw Horizontal Lines
            [0.25, 6.75].each do |y|
                stroke_line [_i(0), _i(y)], [_i(7.5), _i(y)]
            end
            stroke_line [_i(6.75), _i(6.52)], [_i(7.45), _i(6.52)] #Line under TOTALS
            stroke_line [_i(6.75), _i(5.02)], [_i(7.45), _i(5.02)]

            # Draw Vertical Lines
            [0.75, 1.4, 2, 4.2].each do |x|
                stroke_line [_i(x), _i(0.25)], [_i(x), _i(7)]
            end

            [5.4, 6.7, 7.5].each do |x|
                stroke_line [_i(x), _i(0)], [_i(x), _i(7)]
            end

            #Draw Header Text
            page_header_text_box 'Order', 0, 7.08, 0.75, 0.4
            page_header_text_box 'Pounds', 0.75, 7.08, 0.6, 0.4
            page_header_text_box 'Pieces', 1.4, 7.08, 0.6, 0.4
            page_header_text_box 'Part Desc./Process Spec.', 2, 7.08, 2.2, 0.4
            page_header_text_box 'Ref #', 4.2, 7.08, 1.2, 0.4
            page_header_text_box 'Price/Remarks', 5.4, 7.08, 1.3, 0.4
            page_header_text_box 'Totals', 6.7, 7.08, 0.8, 0.4
            page_header_text_box 'Terms: 1% 10 Days Net 30, 1 1/2% Interest charge on Past due balance-18% Annual', 0, 0.33, 5.4, 0.4
            page_header_text_box 'Invoice total', 5.4, 0.33, 1.3, 0.4
            page_header_text_box '$', 6.4, 0.33, 0.8, 0.4
            [6.8, 6.65, 5.3, 5.15].each do |y|
                page_header_text_box '$', 6.4, y, 0.8, 0.4
            end


            page_header_text_box 'SHIPPER #:', 0, 6.7, 0.8, 0.2
            page_header_text_box 'VMS ORDER #:', 0, 6.4, 0.8, 0.2
            page_header_text_box 'SHIP DATE:', 0, 6.1, 0.8, 0.2

            #Draw Order Data
            y = 6.55 #6.5
            ['253411',
            '',
            '284435',
            '',
            '04/09/18',
            '',
            '',
            '',
            '',
            'SHIPPER #:',
            '253411',
            'VMS ORDER #:',
            '28434',
            'SHIPPER #:',
            '284434',
            'SHIP DATE:',
            '04/09/18'].each do |text|
                page_header_data_box text, 0, y, 0.8, 0.2, :center
                y -= 0.15 #0.2
            end

            #Draw Pounds Data
            y = 6.7
            ['3,223',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '17,100'].each do |text|
                page_header_data_box text, 1.4, y, 0.6, 0.2, :center
                y -= 0.15
            end

            #Draw Pieces Data
            y = 6.7
            ['2.77',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '550.00'].each do |text|
                page_header_data_box text, 0.75, y, 0.6, 0.2, :center
                y -= 0.15
            end

            #Draw Part Desc. Data
            y = 6.7
            ['MMXP02.6C006TZ STZ',
            'RECD AS MMXP02.6C006Z',
            'M2.6-45 X 6 PH PAN M/S:',
            'STRIP ZINC, REPLATE',
            'TIN-ZINC (.0002" - .0004")',
            '& CLEAR TRIVALENT CHROMATE',
            '',
            '',
            '',
            '',
            'MMXP02.6C006TZ STZ',
            'RECD AS MMXP02.6C006Z',
            'M2.6-45 X 6 PH PAN M/S:',
            'STRIP ZINC, REPLATE',
            'TIN-ZINC (.0002" - .0004")',
            '& CLEAR TRIVALENT CHROMATE',].each do |text|
                page_header_data_box text, 2.1, y, 2.2, 0.2, :left
                y -= 0.15
            end

            #Draw Part Desc. Data
            y = 6.7
            ['COMPLETE ORDER',
            '4125960',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            'COMPLETE ORDER',
            '4125957'].each do |text|
                page_header_data_box text, 4.2, y, 1.2, 0.2, :center
                y -= 0.15
            end

            #Draw Price/Remarks Data
            y = 6.7
            ['MINIMUM CHARGE',
            'TOTAL DUE',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '$0.032/EACH',
            'TOTAL DUE'].each do |text|
                page_header_data_box text, 5.44, y, 1.3, 0.2, :left
                y -= 0.15
            end

            #Draw Totals Data
            y = 6.7
            ['200.00',
            '200.00',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '547.20',
            '547.20'].each do |text|
                page_header_data_box text, 6.6, y, 0.8, 0.2, :right
                y -= 0.15
            end

            #Draw Invoice Total Data
            page_header_data_box '747.20', 6.65, 0.23, 0.8, 0.2, :right

        end

        bounding_box [_i(0.5), _i(9)], width: _i(7.5), height: _i(1.5) do
            #Draw Header Text
            font_size 22
            text "INVOICE #: 276876", :align => :center
            page_header_data_box_bold 'SOLD TO:', 0, 1, 2.5, 0.2, :left
            page_header_data_box_bold 'SHIPPED VIA:', 0, 0.2, 0.75, 0.2
            page_header_data_box_bold 'SHIP TO:', 4.2, 1, 0.75, 0.2
            page_header_data_box_bold 'INOVICE DATE:', 4.79, 0.2, 0.75, 0.2
            page_header_data_box_bold 'INOVICE #:', 6.6, 0.2, 0.75, 0.2

            #Draw SOLD TO Data
            y = 0.875
            ['SOLUTION INDUSTRIES LLC',
            'UNIT 7-11',
            '17830 ENGLEWOOD DR.',
            'MIDDLEBURG HTS., OH 44130'].each do |text|
                page_header_data_box text, 0, y, 2.5, 0.2, :left
                y -= 0.125
            end

            #Draw SHIP TO Data
            y = 0.875
            ['SOLUTION INDUSTRIES LLC',
            'UNIT 7-11',
            '17830 ENGLEWOOD DR.',
            'MIDDLEBURG HTS., OH 44130'].each do |text|
                page_header_data_box text, 4.2, y, 2.5, 0.2, :left
                y -= 0.125
            end

            #Draw SHIPPED VIA data
            page_header_data_box 'UPS FREIGHT PRO#433831215', 0.7, 0.2, 2, 0.2, :left

            #Draw Invoice Date
            page_header_data_box '04/10/18', 5.55, 0.2, 0.75, 0.2

            #Draw Invoice Number.
            page_header_data_box '276876', 7.2, 0.2, 0.75, 0.2, :left

            y = 0.875
            ['SOLIND',
            '',
            'FAX: (440) 816-9501'].each do |text|
                page_header_data_box text, 6.3, y, 2.5, 0.2, :left
                y -= 0.125
            end
        end

        bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
            number_pages 'PAGE <page> OF <total>', align: :right
        end
        
        #Draw sub-header
        page_header_text_box 'We Hereby Certify That These Goods Were Produced In Compliance With The Fair Labor Standards Act, As Amended', 1.5, 0.5, 5.5, 0.2, :center

    end

    def insert_headerImage
        bounding_box([_i(0.5), _i(10.6)], :width => _i(7.5), :height => _i(1.2)) do
            image "#{Prawn::DATADIR}/images/varlandLogo.jpg", :fit => [_i(7.5), _i(1.2)]
        end
    end

    def page_header_text_box(text, x, y, width, height = 0.2, large = false, align = :center, valign = :center)
        font 'Arial Narrow', style: :bold
        font_size large ? 14 : 8
        fill_color '000000'
        text_box  text.upcase,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end

    def page_large_header_text_box(text, x, y, width, height = 0.2, large = true, align = :center, valign = :center)
        font 'Arial Narrow', style: :bold
        font_size large ? 20 : 14
        fill_color '000000'
        text_box  text.upcase,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  overflow: :shrink_to_fit
    end
    
    def page_header_data_box(text, x, y, width, height = 0.2, align = :left, large = false, valign = :center)
        return if text.blank?
        font 'Arial Narrow', style: :normal
        font_size large ? 14 : 8
        fill_color '000000'
        text_box  text,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  inline_format: true
    end

    def page_header_data_box_bold(text, x, y, width, height = 0.2, align = :left, large = false, valign = :center)
        return if text.blank?
        font 'Arial Narrow', style: :bold
        font_size large ? 14 : 8
        fill_color '000000'
        text_box  text,
                  at: [_i(x), _i(y)],
                  width: _i(width),
                  height: _i(height),
                  align: align,
                  valign: valign,
                  inline_format: true
    end
    
end
