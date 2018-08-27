require 'barby'
require 'barby/barcode/code_39'
require 'barby/outputter/prawn_outputter'
require 'json'
require 'uri'
require 'date'
include ActionView::Helpers::NumberHelper

class SO < VarlandPdf

  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def initialize(data = nil, color = nil)
    super()
    file = File.read('288473.json')
    @data = JSON.parse(file)

    @color = color
    case @data['scheduleCode']
      when 'YEL'
        @color = 'yellow'
      when 'GRN'
        @color = 'green'
      else
        @color = 'blue'
    end

    print_instructions
    print_header
    first_page_header
  end

  def first_page_header

    # Move to first page.
    go_to_page  1

    # Draw revision dates.
    bounding_box [_i(0.25), _i(3.45)], width: _i(8), height: _i(0.8) do
      
      #Draw REV DATES at bottom
      page_header_data_box 'REV DATES:', -0.05, 0.8, 1.5, 0.2, :left

      #Checking if anything in revisionDates from the JSON file is NIL. Replace with empty string.
      headers = ['SPEC INST', 'STD PROC', 'LOADINGS', 'PART SPEC']
      date_initials = []
      ['special', 'procedure', 'loading', 'part'].each do |i|
        if @data['revisionDates'][i] != nil
          date_initials.push([@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['operatorInitials'], @data['revisionDates'][i]['authorizedInitials']])
        else
          date_initials.push(['', '', ''])
        end
      end

      #Print first column of revision dates
      y = 0.8
      0.upto(headers.length - 1) do |i|
        page_header_data_box headers[i], 1, y, 1.5, 0.2, :left
        if date_initials[i][0] != ''
          page_header_data_box DateTime.parse(date_initials[i][0]).strftime("%m/%d/%Y %H:%M"), 1.75, y, 1.5, 0.2, :left
        end
        if(date_initials[i][1] != ''|| date_initials[i][2] != '') #Formats initials
          page_header_data_box "#{date_initials[i][1]}:#{date_initials[i][2]}", 2.8525, y, 1.5, 0.2, :left
        end
        y -= 0.2
      end

      #'PRICING' is a special field with a dynamic header name
      quote_or_price = @data['revisionDates']['pricing'] ? @data['revisionDates']['pricing']['label'] : ''

      #Checking if anything in revisionDates from the JSON file is NIL. Replace with empty string.
      headers = ['LAST ORDER', 'PREV ORDER', quote_or_price]
      date_numbers = []
      ['lastOrder', 'prevOrder', 'pricing'].each do |i|
        if @data['revisionDates'][i] != nil
          if i == 'pricing'
            t_array = [@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['value']]
            date_numbers.push(t_array)
          else
            t_array = [@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['number']]
            date_numbers.push(t_array)
          end
        else
          date_numbers.push(['', ''])
        end
      end
   
      #Print second column of revision dates
      y = 0.8
      0.upto(headers.length-1) do |i|
        page_header_data_box headers[i], 4, y, 1.5, 0.2, :left
        if(date_numbers[i][0] != '')
          page_header_data_box DateTime.parse(date_numbers[i][0]).strftime("%m/%d/%Y"), 4.9, y, 1.5, 0.2, :left
        end
          page_header_data_box date_numbers[i][1].to_s, 5.65, y, 1.5, 0.2, :left
        y -= 0.2
      end
    end

    if(@data['shopOrderNote'] != nil)
      # Draw shop order note box.
      bounding_box [_i(0.25), _i(2.5)], width: _i(8), height: _i(0.25) do
        fill_color 'cccccc'
        fill_rectangle([_i(0), _i(0.25)], _i(8), _i(0.25))
        stroke_bounds
        font_size 11.96
        fill_color '000000'
        font 'Arial Narrow', style: :bold
        text_box  'Shop Order Notes'.upcase,
                  at: [_i(0.05), _i(0.25)],
                  width: _i(7.9),
                  height: _i(0.25),
                  align: :center,
                  valign: :center
      end

      #Draw shop order notes
      bounding_box [_i(0.25), _i(2.25)], width: _i(8), height: _i(2) do
        stroke_bounds
        font_size 11.5
        fill_color '000000'
        font 'SF Mono', style: :bold
          text_box  @data['shopOrderNote'].join("\n"),
                    at: [_i(0.05), _i(1.95)],
                    width: _i(7.9),
                    height: _i(2.5),
                    align: :left,
                    valign: :top
      end
    end
    
    # Draw page header box.
    bounding_box [_i(0.25), _i(8.45)], width: _i(8), height: _i(5) do

      # Draw shaded background if necessary.
      fill_color 'ffffff'
      case @color
      when 'yellow'
        fill_color 'f9d423'
      when 'green'
        fill_color '93dfb8'
      when 'blue'
        fill_color 'b4f3fd'
      when 'purple'
        fill_color 'e3aad6'
      when 'red'
        fill_color 'ff4e50'
      end
      fill_rectangle([0, _i(5)], _i(8), _i(5))
      fill_color 'ffffff'
      fill_rectangle([_i(3.2), _i(3.3)], _i(8), _i(2.5))

      # Draw shaded header boxes.
      fill_color 'cccccc'
      fill_rectangle([_i(3.2), _i(4)], _i(4.8), _i(0.7))
      fill_rectangle([_i(3.2), _i(5)], _i(4.8), _i(0.2)) 
      fill_rectangle([_i(6.5), _i(5)], _i(1.5), _i(0.2))
      fill_rectangle([_i(0), _i(0.8)], _i(3.2), _i(0.2))

      #Stroke lines for SHIP TO, FINAL INSPECTION, and P&M DESC.
      stroke_color '000000'
      stroke_line [_i(3.2), _i(4.8)], [_i(8.0), _i(4.8)]
      stroke_line [_i(0), _i(0.6)], [_i(3.2), _i(0.6)]

      # Draw border around entire box.
      stroke_color '000000'
      stroke_bounds

      # Draw horizontal lines.
      [4, 3.7, 3.3, 3.05, 2.8, 2.55, 2.3, 2.05, 1.8, 1.55, 1.3, 1.05].each do |y|
        stroke_line [_i(3.2), _i(y)], [_i(8), _i(y)]
      end
      stroke_line [_i(0), _i(0.8)], [_i(8), _i(0.8)]

      # Draw vertical lines.
      x = 3.2
      [0.5, 0.5, 0.8, 0.45, 0.75, 0.45, 0.45, 0.9].each do |w|
        stroke_line [_i(x), _i(3.7)], [_i(x), _i(0.8)]
        x += w
      end
      stroke_line [_i(3.2), _i(5)], [_i(3.2), _i(0)]
      stroke_line [_i(6.5), _i(5)], [_i(6.5), _i(4)]

      # Draw header text.
      page_header_text_box 'Production Report', 3.2, 4, 4.8, 0.3, true
      page_header_text_box 'Date', 3.2, 3.7, 0.5, 0.4
      page_header_text_box 'Shift', 3.7, 3.7, 0.5, 0.4
      page_header_text_box 'Operation', 4.2, 3.7, 0.8, 0.2, false, :center, :bottom
      page_header_text_box 'Letter', 4.2, 3.5, 0.8, 0.2, false, :center, :top
      page_header_text_box 'Dept', 5, 3.7, 0.45, 0.4
      page_header_text_box 'Quantity', 5.45, 3.7, 0.75, 0.4
      page_header_text_box 'By', 6.2, 3.7, 0.45, 0.4
      page_header_text_box '#', 6.65, 3.7, 0.45, 0.4
      page_header_text_box 'Thickness', 7.1, 3.7, 0.9, 0.4
      page_header_text_box 'Ship To', 3.2, 5, 3.5, 0.2, false, :center
      page_header_text_box 'Final Inspection', 6.5, 5, 1.5, 0.2, false, :center
      page_header_text_box 'Part & Material Description', 0, 0.8, 3.2, 0.2, false, :center

      #Draw circle under FINAL INSPECTION
      stroke_circle [_i(7.24), _i(4.401)], _i(0.35)

      # Draw header data.
      shipping_no = @data['shipTo']['phone'].to_i
      ship_to_address = @data['shipTo']['name_1'] + "\n" + @data['shipTo']['address'] + "\n" + @data['shipTo']['city'] + ', ' + @data['shipTo']['state'] + ', ' + @data['shipTo']['zipCode'].to_s
      page_header_data_box number_to_phone(shipping_no, area_code: true), 3.2, 4.75, 3.3, 0.8, :right, false, :top
      page_header_data_box ship_to_address, 3.2, 4.75, 3.2, 0.8, :left, false, :top
      page_header_data_box @data['process'] + "\n\n" + "PRIMARY DEPARTMENT: #{@data['primaryDept']}  \nALTERNATE DEPTS: #{@data['altDepts'][0]}", 0.025, 4.95, 4, 3.2, :left, false, :top
      page_header_data_box @data['partDescription'].join("\n"), 0, 0.55, 4, 0.6, :left, false, :top
      page_header_data_box (number_with_precision(@data['piecesPerPound'], precision: 3)) + ' PCS / LB', 3.2, 0.8, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['ft2PerPound'], precision: 2)) + " FT² / LB", 3.2, 0.6, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['poundsPerFt3'], precision: 2)) + ' LB / FT³', 3.2, 0.4, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['gramsPerPiece'], precision: 6)) + ' GRAMS / PC', 3.2, 0.2, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['poundsPerThousand'], precision: 2)) + ' LBS / M', 5.6, 0.8, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['ft2PerThousand'], precision: 2)) + ' FT² / M', 5.6, 0.6, 2.4, 0.2, :left 
      page_header_data_box (number_with_precision(@data['pieceWeight'], precision: 5)) + ' PC WT', 5.6, 0.4, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['cm2PerPiece'], precision: 6)) + ' CM² / PC', 5.6, 0.2, 2.4, 0.2, :left 
      
      font 'Arial', style: :bold
      font_size 40
      fill_color 'ff0000'
      stroke_color '000000'

      if (@data['isNewJob'])
        case [@color]
        when 'red'
          fill_color 'ffffff'
        end
        text_box  'NEW JOB',
                  at: [_i(0), _i(1.4)],
                  width: _i(3.2),
                  height: _i(0.6),
                  align: :center,
                  valign: :center,
                  mode: :fill_stroke
      end
=begin This will be used for the ifDevelopmental tag is ever in place
      if (@data['isDevelopmental']) 
        font_size 25
        case [@color]
        when 'red'
          fill_color 'ffffff'
        end
        text_box  'DEVELOPMENTAL',
                  at: [_i(0), _i(1.4)],
                  width: _i(3.2),
                  height: _i(0.6),
                  align: :center,
                  valign: :center,
                  mode: :fill_stroke
      end
=end
    end

  end

  def print_header

    # Print page numbers.
    font_size 8
    font 'Arial Narrow', style: :bold
    bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
      if @data['isPageReprint']
         number_pages 'REPRINT PAGE <page>', align: :center 
      else
        number_pages 'PAGE <page>', align: :center
      end
    end

    # Configure shop order barcode.
    barcode = Barby::Code39.new @data['shopOrder'].to_s.rjust(10)

    # Print header on every page.
    repeat :all do

      # Draw oversized shop order numbers.
      font_size 40
      font 'Arial Narrow', style: :bold
      text_box @data["shopOrder"].to_s, at: [_i(1), _i(10.75)], width: _i(2.5), height: _i(0.6)
      text_box @data["shopOrder"].to_s, at: [_i(8.25), _i(10.25)], width: _i(1.8), height: _i(0.6), rotate: 270, align: :center

      # Draw shop order barcode.
      bounding_box [_i(5.58), _i(10.75)], width: _i(2.5), height: _i(0.3) do
        barcode.annotate_pdf self, height: _i(0.3)
      end

      #Draw text under barcode
      bounding_box [_i(0.25), _i(10.45)], width: _i(7.5), height: _i(0.2) do
        page_header_data_box 'VMS' + @data['shopOrder'].to_s, 5.275, 0.2, 7.55, 0.2, :left
        page_header_data_box DateTime.parse(@data['shopOrderDate']).strftime("%m/%d/%Y") + ' ' +  @data['timeReceived'], 0, 0.2, 7.55, 0.2, :right
      end
      # Draw page header box.
      bounding_box [_i(0.25), _i(10.25)], width: _i(7.5), height: _i(1.8) do

        # Draw shaded background if necessary.
        fill_color 'ffffff'
        case @color
          when 'yellow'
            fill_color 'f9d423'
          when 'green'
            fill_color '93dfb8'
          when 'blue'
            fill_color 'b4f3fd'
          when 'purple'
            fill_color 'e3aad6'
          when 'red'
            fill_color 'ff4e50'
        end

        fill_rectangle([0, _i(1.8)], _i(7.5), _i(1.8))

        # Draw shaded header boxes.
        fill_color 'cccccc'
        [1.8, 0.5].each do |y|
          fill_rectangle([0, _i(y)], _i(7.5), _i(0.2))
        end
        fill_rectangle([_i(3.5), _i(1.3)], _i(4), _i(0.2))

        # Draw border around entire box.
        stroke_color '000000'
        stroke_bounds

        # Draw horizontal lines.
        [1.6, 1.1, 0.5, 0.3].each do |y|
          stroke_line [0, _i(y)], [_i(7.5), _i(y)]
        end
        stroke_line [_i(3.5), _i(1.3)], [_i(7.5), _i(1.3)]

        # Draw vertical lines.
        [4.5, 5.2, 7.2].each do |x|
          stroke_line [_i(x), _i(1.8)], [_i(x), _i(1.3)]
        end
        stroke_line [_i(3.5), _i(1.8)], [_i(3.5), _i(0.5)]
        stroke_line [_i(6), _i(1.3)], [_i(6), _i(0.5)]
        [1.5, 2.75, 4, 6].each do |x|
          stroke_line [_i(x), _i(0.5)], [_i(x), _i(0)]
        end

        # Draw header text.
        page_header_text_box 'Customer Name', 0, 1.8, 3.5
        page_header_text_box 'Cust Code', 3.5, 1.8, 1
        page_header_text_box 'Proc Code', 4.5, 1.8, 0.7
        page_header_text_box 'Part ID', 5.2, 1.8, 2
        page_header_text_box 'Sub', 7.2, 1.8, 0.3
        page_header_text_box 'Part Name & Information', 3.5, 1.3, 2.5
        page_header_text_box 'Customer PO #', 6, 1.3, 1.5
        page_header_text_box 'Shop Order Date', 0, 0.5, 1.5
        page_header_text_box 'Pounds', 1.5, 0.5, 1.25
        page_header_text_box 'Pieces', 2.75, 0.5, 1.25
        page_header_text_box 'Containers', 4, 0.5, 2
        page_header_text_box 'Shipping #', 6, 0.5, 1.5

        # Draw header data.
        page_header_data_box @data['shipTo']['name_1']+ "\n" + @data['shipTo']['name_2'], 0, 1.6, 3.5, 0.5, :left, true
        page_header_data_box @data['customerCode'], 3.5, 1.6, 1, 0.3, :center, true
        page_header_data_box @data['processCode'], 4.5, 1.6, 0.7, 0.3, :center, true
        page_header_data_box @data['partID'], 5.2, 1.6, 2, 0.3, :left, true
        page_header_data_box @data['subID'], 7.2, 1.6, 0.3, 0.3, :center, true
        page_header_data_box @data['equipmentUsed'].join("\n"), 0, 1.025, 3.5, 0.6, :left, false, :top
        page_header_data_box @data['partName'].join("\n"), 3.5, 1.025, 2.5, 0.6, :left, false, :top
        page_header_data_box @data['poNumbers'].join("\n"), 6, 1.025, 1.5, 0.6, :left, false, :top
        page_header_data_box DateTime.parse(@data['receiptDate']).strftime("%m/%d/%Y"), 0, 0.3, 1.5, 0.3, :center, true
        page_header_data_box (number_with_precision(@data['pounds'], precision: 2)).to_s, 1.5, 0.3, 1.25, 0.3, :center, true
        page_header_data_box (number_with_delimiter(@data['pieces'])).to_s, 2.75, 0.3, 1.25, 0.3, :center, true
        page_header_data_box @data['containers'].to_s + " " +  @data['containerType'], 4, 0.3, 2, 0.3, :center, true
        page_header_data_box '$/' + @data['pricePer'], 6, 0.3, 1.5, 0.3, :right, true, :bottom 
      end
    end

  end

  def print_instructions

    start_new_page
    font_size 11.5
    fill_color '000000'
    font 'Source Code Pro', style: :bold

    #Begin printing
    bounding_box([_i(0.25), _i(8.2)], :width => _i(8.0), :height => _i(7.75)) do
      text @data['body']
    end

  end

  def page_header_text_box(text, x, y, width, height = 0.2, large = false, align = :center, valign = :center)
    font 'Arial Narrow', style: :bold
    font_size large ? 14 : 9
    fill_color '000000'
    text_box  text.upcase,
              at: [_i(x), _i(y)],
              width: _i(width),
              height: _i(height),
              align: align,
              valign: valign,
              overflow: :shrink_to_fit
  end

  def page_header_data_box(text, x, y, width, height = 0.3, align = :left, large = false, valign = :center)
    return if text.blank?
    font 'Arial Narrow', style: :bold
    font_size large ? 14 : 11
    fill_color '000000'
    case @color
    when 'red'
      fill_color 'ffffff'
    end
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