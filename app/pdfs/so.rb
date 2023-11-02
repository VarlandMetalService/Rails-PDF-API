require 'barby'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/prawn_outputter'
require 'json'
require 'uri'
require 'date'
require 'net/http'
require 'tempfile'
require 'prawn/measurement_extensions'
require 'barby/outputter/png_outputter'
require 'fastimage'
include ActionView::Helpers::NumberHelper

class SO < VarlandPdf

  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  def download_to_tempfile(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.get(uri.path)
      file = Tempfile.new('shop_order')
      file.binmode
      file.write(resp.body)
      file.flush
      file
    end
  end

  def draw_photo

    # Attempt to load photo.
    found_photo = false
    url, photo = nil
    ["jpg", "png"].each do |extension|
      url = "http://so.varland.com/so_photos/#{@data["partControl"]}.#{extension}";
      puts url
      photo = self.download_to_tempfile(url)
      if photo.size >= 10.kilobytes
        found_photo = true
        break
      end
    end

    # If no photo found, return.
    return false unless found_photo

    # Read image dimensions and calculate rendered size.
    photo_width, photo_height = FastImage.size(photo.path)
    photo_ratio = photo_height.to_f / photo_width.to_f
    render_width = 1.8
    render_height = photo_ratio * 1.8
    if render_height > 2
      render_height = 2
      render_width = render_height / photo_ratio
    end
    puts render_width
    puts render_height

    # Determine position.
    x_buffer = (1.8 - render_width) * 0.5
    y_buffer = (2 - render_height) * 0.5
    photo_x = 0 + x_buffer
    photo_y = 2 - y_buffer
    puts photo_x
    puts photo_y
    #photo_x = (1.8 - render_width) * 0.5
    #photo_y = 2 + (2 - render_height) * 0.5

    # Draw photo centered in box.
    image(photo.path, at: [photo_x.in, photo_y.in], width: render_width.in, height: render_height.in)

    # Return success.
    return true

  end

  def initialize(data = nil, reprint = false)
    super()
    @data = data
    @isReprint = reprint

    # Sets the color of the shop order
    @color = 'white'
    if @data['scheduleCode'] != nil
      case @data['scheduleCode']
        when 'YEL'
          @color = 'yellow'
        when 'GRN'
          @color = 'green'
        else
          @color = 'white'
      end
    else
        @color = 'white'
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
          page_header_data_box DateTime.parse(date_initials[i][0]).strftime("%m/%d/%y %H:%M"), 1.75, y, 1.5, 0.2, :left
        end
        if(date_initials[i][1] != ''|| date_initials[i][2] != '') #Formats initials
          page_header_data_box "#{date_initials[i][1]}:#{date_initials[i][2]}", 2.7525, y, 1.5, 0.2, :left
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
            t_array = [@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['value'], @data['revisionDates'][i]['extra'], "$/#{@data['pricePer']}"]
            date_numbers.push(t_array)
          else
            if @data['revisionDates'][i]['count'] == 1
              t_array = [@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['number'], '', '']
            else
              t_array = [@data['revisionDates'][i]['timestamp'], @data['revisionDates'][i]['number'], '', "(#{@data['revisionDates'][i]['count']})"]
            end
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
          page_header_data_box DateTime.parse(date_numbers[i][0]).strftime("%m/%d/%y"), 4.9, y, 1.5, 0.2, :left
        end
          page_header_data_box date_numbers[i][1].to_s, 5.55, y, 1.5, 0.2, :left
          page_header_data_box date_numbers[i][3].to_s, 6.15, y, 1.5, 0.2, :left
          page_header_data_box date_numbers[i][2].to_s, 6.6, y, 1.5, 0.2, :left
        y -= 0.2
      end
    end

    # Draw thickness location photo.
    found_photo = false
    bounding_box [_i(6.45), _i(2.25)], width: _i(1.8), height: _i(2) do
      found_photo = self.draw_photo
    end
    if found_photo
      bounding_box [_i(6.45), _i(2.25)], width: _i(1.8), height: _i(2) do
        stroke_bounds
      end
      bounding_box [_i(6.45), _i(2.5)], width: _i(1.8), height: _i(0.25) do
        fill_color 'cccccc'
        fill_rectangle([_i(0), _i(0.25)], _i(1.8), _i(0.25))
        stroke_bounds
        font_size 11.96
        fill_color '000000'
        font 'Arial Narrow', style: :bold
        text_box  'Thickness Location'.upcase,
                  at: [_i(0.05), _i(0.25)],
                  width: _i(1.7),
                  height: _i(0.25),
                  align: :center,
                  valign: :center
      end
    end

    # Properties for shop order notes.
    so_notes_width = 6.2
    so_notes_font_size = 9
    if !found_photo
      so_notes_width = 8
      so_notes_font_size = 11.5
    end

    if(@data['shopOrderNote'] != nil)
      # Draw shop order note box.
      bounding_box [_i(0.25), _i(2.5)], width: _i(so_notes_width), height: _i(0.25) do
        fill_color 'cccccc'
        fill_rectangle([_i(0), _i(0.25)], _i(so_notes_width), _i(0.25))
        stroke_bounds
        font_size 11.96
        fill_color '000000'
        font 'Arial Narrow', style: :bold
        text_box  'Shop Order Notes'.upcase,
                  at: [_i(0.05), _i(0.25)],
                  width: _i(so_notes_width - 0.1),
                  height: _i(0.25),
                  align: :center,
                  valign: :center
      end

      #Draw shop order notes
      bounding_box [_i(0.25), _i(2.25)], width: _i(so_notes_width), height: _i(2) do
        unless @data['shopOrderNote'].blank?
          fill_color 'ffffcc'
          fill_rectangle([_i(0), _i(2)], _i(so_notes_width), _i(2))
        end
        stroke_bounds
        font_size so_notes_font_size
        fill_color '000000'
        font 'Source Code Pro', style: :bold
        text_box  @data['shopOrderNote'],
                  at: [_i(0.05), _i(1.95)],
                  width: _i(so_notes_width - 0.1),
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
      fill_rectangle([_i(2.95), _i(3.3)], _i(8), _i(2.5))

      prod_recording_widths = [0.5, 0.45, 0.65, 0.45, 0.75, 0.45]
      x_ray_data_widths = [0.3, 0.75, 0.75]

      # Draw shaded header boxes.
      fill_color 'cccccc'
      fill_rectangle([_i(2.95 + prod_recording_widths.sum), _i(4)], _i(x_ray_data_widths.sum), _i(0.7))
      fill_color 'cccccc'
      fill_rectangle([_i(2.95), _i(4)], _i(prod_recording_widths.sum), _i(0.7))
      fill_rectangle([_i(0), _i(5)], _i(7.75), _i(0.2))
      fill_rectangle([_i(6.5), _i(5)], _i(1.5), _i(0.2))
      fill_rectangle([_i(0), _i(0.8)], _i(2.95), _i(0.2))

      #Stroke lines for SHIP TO, FINAL INSPECTION, and P&M DESC.
      stroke_color '000000'
      stroke_line [_i(0), _i(4.8)], [_i(8.0), _i(4.8)]
      stroke_line [_i(0), _i(0.6)], [_i(2.95), _i(0.6)]

      # Draw border around entire box.
      stroke_color '000000'
      stroke_bounds

      # Draw horizontal lines.
      x = 2.95
      [4, 3.7, 3.3, 3.05, 2.8, 2.55, 2.3, 2.05, 1.8, 1.55, 1.3, 1.05].each do |y|
        stroke_line [_i(x), _i(y)], [_i(8), _i(y)]
      end
      stroke_line [_i(0), _i(0.8)], [_i(8), _i(0.8)]

      # Draw vertical lines.
      x = 2.95
      [0.5, 0.45, 0.65, 0.45, 0.75, 0.45, 0.3, 0.75, 0.75].each do |w|
        stroke_line [_i(x), _i(3.7)], [_i(x), _i(0.8)]
        x += w
      end
      stroke_line [_i(2.95), _i(5)], [_i(2.95), _i(0)]
      stroke_line [_i(2.95 + prod_recording_widths.sum), _i(5)], [_i(2.95 + prod_recording_widths.sum), _i(3.7)]

      # Draw header text.
      x = 2.95
      page_header_text_box 'Production Recording', x, 4, prod_recording_widths.sum, 0.3, true
      page_header_text_box 'X-Ray Data', x + prod_recording_widths.sum, 4, x_ray_data_widths.sum, 0.3, true
      page_header_text_box 'Date', x, 3.7, prod_recording_widths[0], 0.4
      x += prod_recording_widths[0]
      page_header_text_box 'Shift', x, 3.7, prod_recording_widths[1], 0.4
      x += prod_recording_widths[1]
      page_header_text_box 'Op', x, 3.7, prod_recording_widths[2], 0.2, false, :center, :bottom
      page_header_text_box 'Letter', x, 3.5, prod_recording_widths[2], 0.2, false, :center, :top
      x += prod_recording_widths[2]
      page_header_text_box 'Dept', x, 3.7, prod_recording_widths[3], 0.4
      x += prod_recording_widths[3]
      page_header_text_box 'Quantity', x, 3.7, prod_recording_widths[4], 0.2, false, :center, :bottom
      page_header_text_box '(lbs)', x, 3.5, prod_recording_widths[4], 0.2, false, :center, :top
      x += prod_recording_widths[4]
      page_header_text_box 'Emp', x, 3.7, prod_recording_widths[5], 0.4 #, false, :center, :bottom
      #page_header_text_box '#', x, 3.5, prod_recording_widths[5], 0.2, false, :center, :top
      x += prod_recording_widths[5]
      page_header_text_box 'LD', x, 3.7, x_ray_data_widths[0], 0.2, false, :center, :bottom
      page_header_text_box '#', x, 3.5, x_ray_data_widths[0], 0.2, false, :center, :top
      x += x_ray_data_widths[0]
      page_header_text_box 'Thick', x, 3.7, x_ray_data_widths[1], 0.2, false, :center, :bottom
      page_header_text_box '(mils)', x, 3.5, x_ray_data_widths[1], 0.2, false, :center, :top
      x += x_ray_data_widths[1]
      page_header_text_box 'Alloy %', x, 3.7, x_ray_data_widths[2], 0.4

      page_header_text_box 'Process Specification', 0, 5, 2.95, 0.2, false, :center
      page_header_text_box 'Ship To', 2.95, 5, prod_recording_widths.sum, 0.2, false, :center
      page_header_text_box 'Final Inspection', 2.95 + prod_recording_widths.sum, 5, x_ray_data_widths.sum, 0.2, false, :center
      page_header_text_box 'Part & Material Description', 0, 0.8, 2.95, 0.2, false, :center

      #Draw circle under FINAL INSPECTION
      x = 2.95 + prod_recording_widths.sum + (x_ray_data_widths.sum / 2)
      fill_color 'ffffff'
      fill_circle [_i(x), _i(4.4)], _i(0.35)
      circle_size = 0.35
      stroke_circle [_i(x), _i(4.4)], _i(0.35)

      # Draw header data.
      shipping_no = (@data['shipTo']['phone'] != "0") ? number_to_phone(@data['shipTo']['phone'].to_i, area_code: true) : ""
      zip_code = sprintf('%05d', @data['shipTo']['zipCode'])
      if @data['shipTo']['name_2'].blank?
        ship_to_address = @data['shipTo']['name_1'] + "\n" + @data['shipTo']['address'] + "\n" + @data['shipTo']['city'] + ', ' + @data['shipTo']['state'] + ', ' + zip_code
      else
        ship_to_address = @data['shipTo']['name_1'] + "\n" + @data['shipTo']['name_2'] + "\n" + @data['shipTo']['address'] + "\n" + @data['shipTo']['city'] + ', ' + @data['shipTo']['state'] + ', ' + zip_code
      end
      page_header_data_box shipping_no, 2.95, 4.75, prod_recording_widths.sum, 0.8, :right, false, :top
      page_header_data_box ship_to_address, 2.95, 4.75, prod_recording_widths.sum, 0.8, :left, false, :top
      temp_y = 4.75
      process_height = (@data['processLines'] + 1) * (11.0 / 72.0)
      dept_height = 0
      page_header_data_box @data['process'].to_s, 0.025, temp_y, 2.95, process_height, :left, false, :top
      temp_y -= process_height
      unless @data['primaryDept'].nil?
        fill_color 'cccccc'
        dept_height = 2.5 * (11.0 / 72.0)
        fill_rectangle([_i(0.1), _i(temp_y)], _i(2.75), _i(dept_height))
        bounding_box([_i(0.1), _i(temp_y)], :width => _i(2.75), :height => _i(dept_height)) do
          transparent(1) { stroke_bounds }
          page_header_data_box "PRIMARY DEPARTMENT: #{@data['primaryDept']}\nALTERNATE DEPARTMENT#{@data['altDepts'].length == 1 ? '' : 'S'}: #{@data['altDepts'].join(', ')}", 0.05, 0.4, 2.65, 0.4, :left, false, :center
         end
         temp_y -= dept_height + (11.0 / 72.0)
      end
      unless @color == 'white'
        fill_color 'ffffff'
        blank_height = 3.2 - process_height - dept_height - (11.0 / 72.0)
        fill_rectangle([_i(0.1), _i(temp_y)], _i(2.75), _i(blank_height))
        stroke_rectangle([_i(0.1), _i(temp_y)], _i(2.75), _i(blank_height))
      end
      page_header_data_box @data['partDescription'].join("\n"), 0, 0.55, 2.95, 0.6, :left, false, :top
      page_header_data_box (number_with_precision(@data['piecesPerPound'], precision: 3)) + ' PCS / LB', 2.95, 0.8, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['ft2PerPound'], precision: 2)) + " FT² / LB", 2.95, 0.6, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['poundsPerFt3'], precision: 2)) + ' LB / FT³', 2.95, 0.4, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['gramsPerPiece'], precision: 6)) + ' GRAMS / PC', 2.95, 0.2, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['poundsPerThousand'], precision: 2)) + ' LBS / M', 5.47, 0.8, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['ft2PerThousand'], precision: 2)) + ' FT² / M', 5.47, 0.6, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['pieceWeight'], precision: 5)) + ' PC WT', 5.47, 0.4, 2.4, 0.2, :left
      page_header_data_box (number_with_precision(@data['cm2PerPiece'], precision: 6)) + ' CM² / PC', 5.47, 0.2, 2.4, 0.2, :left

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
                  width: _i(2.95),
                  height: _i(0.6),
                  align: :center,
                  valign: :center,
                  mode: :fill_stroke
      end
      if (@data['isDevelopmental'])
        font_size 22
        case [@color]
        when 'red'
          fill_color 'ffffff'
        end
        text_box  'DEVELOPMENTAL',
                  at: [_i(0), _i(1.3)],
                  width: _i(2.95),
                  height: _i(0.6),
                  align: :center,
                  valign: :center,
                  mode: :fill_stroke
      end
    end

  end

  def print_header

    # Print page numbers.
    font_size 8
    font 'Arial Narrow', style: :bold
    bounding_box [_i(0.25), _i(10.75)], width: _i(8), height: _i(0.75) do
      promise_date_text = "" #(@data['promiseDate'] != nil ? "\nPROMISE DATE: " + DateTime.parse(@data['promiseDate']).strftime("%m/%d/%y") : "")
      page_number_text = "#{@isReprint ? 'REPRINT ' : ''}PAGE <page> OF <total>#{promise_date_text}"
      number_pages page_number_text, align: :center
      #if @isReprint
      #   number_pages 'REPRINT PAGE <page> OF <total>', align: :center
      #else
      #  number_pages "PAGE <page> OF <total>", align: :center
      #end
    end

    # Configure shop order barcode.
    barcode = Barby::Code39.new @data['shopOrder'].to_s.rjust(10)
    qrcode = Barby::QrCode.new @data['shopOrder'].to_s, level: :q, size: 5

    # Print header on every page.
    repeat :all do

      # Print special barrel designation for HIL jobs in Dept. 5.
      if @data["customerCode"] == "HIL" && (@data["accountNumbers"].include?("505.50") || @data["accountNumbers"].include?("505.57"))
        cubic = @data["hilLoadSize"].to_f # @data["pounds"].to_f / @data["poundsPerFt3"].to_f
        hilbbl = "XXX"
        if cubic >= 0.5
          hilbbl = "LG"
        elsif cubic >= 0.25
          hilbbl = "70X"
        elsif cubic >= 0.15
          hilbbl = "71X"
        elsif cubic >= 0.1
          hilbbl = "72X"
        end
        self.fbox(7.85, 10.75, 0.4, 0.25, "000000")
        self.txtb(hilbbl, 7.85, 10.75, 0.4, 0.25, 14, :bold, :center, :center, nil, "ffffff")
        self.fill_color("000000")
      end

      # Print special barrel designation for HIL jobs in Dept. 3.
      if @data["customerCode"] == "HIL" && @data["accountNumbers"].include?("503.57")
        cubic = @data["hilLoadSize"].to_f # @data["pounds"].to_f / @data["poundsPerFt3"].to_f
        hilbbl = ""
        if cubic >= 0.35
          hilbbl = "LG"
        elsif cubic >= 0.2
          hilbbl = "MD"
        elsif cubic >= 0.08
          hilbbl = "SM"
        else
          hilbbl = "MC"
        end
        self.fbox(7.85, 10.75, 0.4, 0.25, "000000")
        self.txtb(hilbbl, 7.85, 10.75, 0.4, 0.25, 14, :bold, :center, :center, nil, "ffffff")
        self.fill_color("000000")
      end

      # Draw oversized shop order numbers.
      font_size 40
      # @data["loadingsIndicator"]
      so_text = @data["shopOrder"].to_s
      if @data["isRework"]
        so_text += "<font name=\"WhitneyIndexSquared\"><color rgb=\"ff0000\">R</color></font>"
      end
      if @data["loadingsIndicator"]
        so_text += "<font name=\"WhitneyIndexSquared\"><color rgb=\"0000ff\">L</color></font>"
      end
      font 'Arial Narrow', style: :bold
      #if @data["isRework"]
      #  text_box "#{@data["shopOrder"].to_s}<font name=\"WhitneyIndexSquared\"><color rgb=\"ff0000\">R</color></font>", at: [_i(0.5), _i(10.75)], width: _i(2.5), height: _i(0.6), inline_format: true
      #  text_box "#{@data["shopOrder"].to_s}<font name=\"WhitneyIndexSquared\"><color rgb=\"ff0000\">R</color></font>", at: [_i(8.25), _i(10.75)], width: _i(2.3), height: _i(0.6), rotate: 270, align: :center, inline_format: true
      #else
        text_box so_text, at: [_i(0.5), _i(10.75)], width: _i(3), height: _i(0.6), inline_format: true
        text_box so_text, at: [_i(8.25), _i(10.5)], width: _i(2.05), height: _i(0.6), rotate: 270, align: :center, inline_format: true, overflow: :shrink_to_fit
      #end

      # Draw shop order barcodes.
      bounding_box [_i(5.58), _i(10.75)], width: _i(2.5), height: _i(0.3) do
        barcode.annotate_pdf self, height: _i(0.3)
      end
      png_outputter = Barby::PngOutputter.new(qrcode)
      #png_outputter.height = 300
      png_outputter.xdim = 5
      #png_outputter.ydim = 5
      png_outputter.margin = 0
      png_data = png_outputter.to_png
      self.image StringIO.new(png_data), at: [4.83.in, 10.75.in], width: 0.46.in, height: 0.46.in

      #Draw text under barcode
      #bounding_box [_i(0.25), _i(10.45)], width: _i(7.5), height: _i(0.2) do
      #  page_header_data_box 'VMS' + @data['shopOrder'].to_s, 5.275, 0.2, 7.55, 0.2, :left
      #  page_header_data_box DateTime.parse(@data['shopOrderDate']).strftime("%m/%d/%y") + ' ' +  @data['timeReceived'], 0, 0.2, 7.55, 0.2, :right
      #end
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

        fill_rectangle([0, _i(1.8)], _i(7.5), _i(1.5))
        #f# ill_rectangle([0, _i(0.3)], _i(6.2), _i(0.3))

        # Draw shaded header boxes.
        fill_color 'cccccc'
        [1.8, 1.3, 0.5].each do |y|
          fill_rectangle([0, _i(y)], _i(7.5), _i(0.2))
        end

        # Draw border around entire box.
        stroke_color '000000'
        stroke_bounds

        # Draw horizontal lines.
        [1.6, 1.1, 1.3, 0.5, 0.3].each do |y|
          stroke_line [0, _i(y)], [_i(7.5), _i(y)]
        end

        # Draw vertical lines.
        [4.5, 5.2, 7.2].each do |x|
          stroke_line [_i(x), _i(1.8)], [_i(x), _i(1.3)]
        end
        stroke_line [_i(3.5), _i(1.8)], [_i(3.5), _i(0.5)]
        stroke_line [_i(6), _i(1.3)], [_i(6), _i(0.5)]
        [1.25, 2.65, 4.05, 6.2].each do |x|
          stroke_line [_i(x), _i(0.5)], [_i(x), _i(0)]
        end

        # Draw header text.
        page_header_text_box 'Customer Name', 0, 1.8, 3.5
        page_header_text_box 'Cust Code', 3.5, 1.8, 1
        page_header_text_box 'Proc Code', 4.5, 1.8, 0.7
        page_header_text_box 'Part ID', 5.2, 1.8, 2
        page_header_text_box 'Sub', 7.2, 1.8, 0.3
        page_header_text_box 'Equipment Used', 0, 1.3, 3.5
        page_header_text_box 'Part Name & Information', 3.5, 1.3, 2.5
        page_header_text_box 'Customer PO #', 6, 1.3, 1.5
        page_header_text_box 'Receipt Date', 0, 0.5, 1.25
        #page_header_text_box 'Promise Date', 1.25, 0.5, 1.25
        page_header_text_box 'Pounds', 1.25, 0.5, 1.4
        page_header_text_box 'Pieces', 2.65, 0.5, 1.4
        page_header_text_box 'Containers', 4.05, 0.5, 2.15
        page_header_text_box 'Shipping #', 6.2, 0.5, 1.3

        # Draw header data.
        page_header_data_box @data['customerName'], 0, 1.6, 3.5, 0.3, :left, true
        page_header_data_box @data['customerCode'], 3.5, 1.6, 1, 0.3, :center, true
        page_header_data_box @data['processCode'], 4.5, 1.6, 0.7, 0.3, :center, true
        page_header_data_box @data['partID'], 5.2, 1.6, 2, 0.3, :left, true
        page_header_data_box @data['subID'], 7.2, 1.6, 0.3, 0.3, :center, true
        page_header_data_box @data['equipmentUsed'].join("\n"), 0, 1.025, 3.5, 0.6, :left, false, :top
        page_header_data_box @data['partName'].join("\n"), 3.5, 1.025, 2.5, 0.6, :left, false, :top
        po_text = []
        0.upto(2) do |po|
          if @data['poNumbers'][po] == @data['partPOs'][po] || @data['poNumbers'][po] == @data['customerPOs'][po]
            po_text << "<em>#{@data['poNumbers'][po]}</em>"
          else
            po_text << @data['poNumbers'][po]
          end
        end
        page_header_data_box po_text.join("\n"), 6, 1.025, 1.5, 0.6, :left, false, :top
        page_header_data_box (@data['receiptDate'] != nil ? DateTime.parse(@data['receiptDate']).strftime("%m/%d/%y") : ""), 0, 0.3, 1.25, 0.3, :center, true
        #page_header_data_box (@data['promiseDate'] != nil ? DateTime.parse(@data['promiseDate']).strftime("%m/%d/%y") : ""), 1.25, 0.3, 1.25, 0.3, :center, true
        page_header_data_box (number_with_delimiter(number_with_precision(@data['pounds'], precision: 2))).to_s, 1.25, 0.3, 1.4, 0.3, :center, true
        page_header_data_box (number_with_delimiter(@data['pieces'])).to_s, 2.65, 0.3, 1.4, 0.3, :center, true
        page_header_data_box @data['containers'].to_s + " " +  @data['containerType'], 4.05, 0.3, 2.15, 0.3, :left, true
        # page_header_data_box '$/' + @data['pricePer'], 6.2, 0.3, 1.3, 0.3, :right, true, :bottom
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
      text @data['body'], inline_format: true
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

  def page_header_data_box(text, x, y, width, height = 0.3, align = :left, large = false, valign = :center, small = false)
    return if text.blank?
    font 'Arial Narrow', style: :bold
    font_size large ? 14 : (small ? 10 : 11)
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