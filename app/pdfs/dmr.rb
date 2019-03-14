class DMR < VarlandPdf
    
  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait

  BOX_HEADER_HEIGHT = 0.25
  BOX_LINE_HEIGHT = 0.18
  
  def initialize(data = nil)

    # Call parent constructor and store passed data.
    super()
    @data = data

    # Set options.
    @standard_color = '000000'
    @standard_font = 'Arial'
    @data_color = '000000'
    @data_font = 'SF Mono'

    # Print DMR.
    self.print_dmr
    # self.print_data

    # Encrypt PDF.
    encrypt_document(owner_password: :random,
                     permissions: {
                       print_document: true,
                       modify_contents: false,
                       copy_contents: true,
                       modify_annotations: false
                     })
      
  end

  def print_dmr

    # Set up drawing.
    self.line_width = 0.02.in

    # Draw header graphic.
    header_graphic = Rails.root.join('lib', 'images', 'dmr_header.jpg')
    image(header_graphic, at: [0.35.in, 10.75.in], width: 7.8.in, height: 1.25.in)

    # Draw title.
    self.txtb("DEFECTIVE MATERIAL REPORT: #{@data[:year]}-#{sprintf("%04d", @data[:number])}", 0, 9.4, 8.5, 0.25, 16, :bold, :center, :center)

    # DMR date.
    y = 9.15
    self.txtb("Date: #{@data[:_dateSent]}", 0, y, 8.5, BOX_LINE_HEIGHT, 10, :bold, :center, :top)

    # Draw customer information.
    customer_lines = ["ATTN: #{@data[:sentTo][:attention]}"]
    @data[:customerName].each do |n|
      customer_lines << n
    end
    unless @data[:sentTo][:address].blank?
      customer_lines << @data[:sentTo][:address]
      customer_lines << "#{@data[:sentTo][:city]}, #{@data[:sentTo][:state]} #{@data[:sentTo][:zip]}"
    end
    self.txtb(customer_lines.join("\n"), 0.25, 8.9, 8, customer_lines.length * BOX_LINE_HEIGHT, 10, :bold, :left, :top)

    # Disposition of parts.
    widths = [1.25, 2.625]
    y = 7.85
    width = 7.75 - widths.sum
    puts width
    x = 0.5 + widths.sum
    self.fbox(x, y, width, BOX_HEADER_HEIGHT, 'cccccc')
    self.txtb("Disposition of Parts", x + 0.1, y, width, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    self.hline(x, y, width)
    self.vline(x, y, 3 * BOX_HEADER_HEIGHT)
    self.vline(x + width, y, 3 * BOX_HEADER_HEIGHT)
    y -= BOX_HEADER_HEIGHT
    self.hline(x, y, width)
    disposition_text = ""
    if @data[:dispositionUnprocessed]
      disposition_text = "UNPROCESSED"
    elsif @data[:dispositionPartial]
      disposition_text = "PARTIALLY PROCESSED"
    elsif @data[:dispositionComplete]
      disposition_text = "COMPLETELY PROCESSED"
    else
      disposition_text = @data[:dispositionDescription]
    end
    self.txtb(disposition_text, x, y, width, 2 * BOX_HEADER_HEIGHT, 10, :bold, :center, :center)
    y -= 2 * BOX_HEADER_HEIGHT
    self.hline(x, y, width)

    # Order information.
    widths = [1.25, 2.625]
    y = 7.85
    height = 0
    self.fbox(0.25, y, widths.sum, BOX_HEADER_HEIGHT, 'cccccc')
    self.txtb("Order Information", 0.35, y, widths.sum, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    self.hline(0.25, y, widths.sum)
    y -= BOX_HEADER_HEIGHT
    height += BOX_HEADER_HEIGHT
    self.hline(0.25, y, widths.sum)
    self.txtb("VMS Order #", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
    self.txtb(@data[:shopOrder], 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    y -= BOX_HEADER_HEIGHT
    height += BOX_HEADER_HEIGHT
    self.hline(0.25, y, widths.sum)
    unless @data[:invoiceNumber] == 0
      self.txtb("VMS Invoice #", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
      self.txtb(@data[:invoiceNumber], 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
      y -= BOX_HEADER_HEIGHT
      height += BOX_HEADER_HEIGHT
      self.hline(0.25, y, widths.sum)
    end
    self.txtb("Part #", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
    self.txtb(@data[:partID], 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    y -= BOX_HEADER_HEIGHT
    height += BOX_HEADER_HEIGHT
    self.hline(0.25, y, widths.sum)
    unless @data[:subID].blank?
      self.txtb("Sub", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
      self.txtb(@data[:subID], 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
      y -= BOX_HEADER_HEIGHT
      height += BOX_HEADER_HEIGHT
      self.hline(0.25, y, widths.sum)
    end
    self.txtb("Part Name", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
    self.txtb(@data[:partName].join("\n"), 0.35 + widths[0], y, widths[1] - 0.2, BOX_LINE_HEIGHT * @data[:partName].length + 0.04, 10, :bold, :left, :center)
    y -= BOX_LINE_HEIGHT * @data[:partName].length
    height += BOX_LINE_HEIGHT * @data[:partName].length
    y -= 0.04
    height += 0.04
    self.hline(0.25, y, widths.sum)
    unless @data[:poNumber].length == 0
      self.txtb("Purchase Order", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
      self.txtb(@data[:poNumber].join("\n"), 0.35 + widths[0], y, widths[1] - 0.2, BOX_LINE_HEIGHT * @data[:poNumber].length + 0.04, 10, :bold, :left, :center)
      y -= BOX_LINE_HEIGHT * @data[:poNumber].length
      height += BOX_LINE_HEIGHT * @data[:poNumber].length
      y -= 0.04
      height += 0.04
      self.hline(0.25, y, widths.sum)
    end
    self.txtb("Pieces", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
    self.txtb(helpers.number_with_delimiter(@data[:pieces]), 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    y -= BOX_HEADER_HEIGHT
    height += BOX_HEADER_HEIGHT
    self.hline(0.25, y, widths.sum)
    self.txtb("Pounds", 0.35, y, widths[0] - 0.2, BOX_HEADER_HEIGHT, 10, :normal, :left, :center)
    self.txtb(helpers.number_with_precision(@data[:pounds], precision: 2, delimiter: ','), 0.35 + widths[0], y, widths[1] - 0.2, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    y -= BOX_HEADER_HEIGHT
    height += BOX_HEADER_HEIGHT
    self.hline(0.25, y, widths.sum)
    self.vline(0.25, y + height, height)
    self.vline(0.25 + widths.sum, y + height, height)
    self.vline(0.25 + widths[0], y + height - BOX_HEADER_HEIGHT, height - BOX_HEADER_HEIGHT)

    # Initialize vertical position.
    y = 4.85

    # Description of defect box.
    defect_discovered_text = ""
    if @data[:defectFoundBefore]
      defect_discovered_text = "Before Processing".upcase
    elsif @data[:defectFoundDuring]
      defect_discovered_text = "During Processing".upcase
    else
      defect_discovered_text = "After Processing".upcase
    end
    self.fbox(0.25, y, 8, BOX_HEADER_HEIGHT, 'cccccc')
    self.txtb("Description of Defect", 0.35, y, 8, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    self.txtb("Defect Discovered: <strong>#{defect_discovered_text}</strong>", 0.25, y, 7.9, BOX_HEADER_HEIGHT, 10, :normal, :right, :center)
    self.hline(0.25, y, 8)
    self.vline(0.25, y, BOX_HEADER_HEIGHT + 10 * BOX_LINE_HEIGHT)
    self.vline(8.25, y, BOX_HEADER_HEIGHT + 10 * BOX_LINE_HEIGHT)
    y -= BOX_HEADER_HEIGHT
    self.hline(0.25, y, 8)
    y -= 0.05
    self.txtb(@data[:defect].join("\n"), 0.35, y, 8, 10 * BOX_LINE_HEIGHT, 10, :bold, :left, :top, @data_font, @data_color)
    y += 0.05
    y -= 10 * BOX_LINE_HEIGHT
    self.hline(0.25, y, 8)

    # Corrective action box.
    self.fbox(0.25, y, 8, BOX_HEADER_HEIGHT, 'cccccc')
    self.txtb("Corrective Action Taken", 0.35, y, 8, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    if @data[:samplesSentToCustomer]
      self.txtb("SAMPLES SENT TO CUSTOMER", 0.25, y, 7.9, BOX_HEADER_HEIGHT, 10, :bold, :right, :center)
    end
    self.hline(0.25, y, 8)
    self.vline(0.25, y, BOX_HEADER_HEIGHT + 5 * BOX_LINE_HEIGHT)
    self.vline(8.25, y, BOX_HEADER_HEIGHT + 5 * BOX_LINE_HEIGHT)
    y -= BOX_HEADER_HEIGHT
    self.hline(0.25, y, 8)
    y -= 0.04
    self.txtb(@data[:correctiveAction].join("\n"), 0.35, y, 8, 5 * BOX_LINE_HEIGHT, 10, :bold, :left, :top, @data_font, @data_color)
    y += 0.04
    y -= 5 * BOX_LINE_HEIGHT
    self.hline(0.25, y, 8)

    # Customer instructions box.
    self.fbox(0.25, y, 8, BOX_HEADER_HEIGHT, 'cccccc')
    self.txtb("Customer Instructions", 0.35, y, 8, BOX_HEADER_HEIGHT, 10, :bold, :left, :center)
    self.hline(0.25, y, 8)
    self.vline(0.25, y, BOX_HEADER_HEIGHT + 5 * BOX_LINE_HEIGHT)
    self.vline(8.25, y, BOX_HEADER_HEIGHT + 5 * BOX_LINE_HEIGHT)
    y -= BOX_HEADER_HEIGHT
    self.hline(0.25, y, 8)
    y -= 0.04
    self.txtb(@data[:customerInstructions].join("\n"), 0.35, y, 8, 5 * BOX_LINE_HEIGHT, 10, :bold, :left, :top, @data_font, @data_color)
    y += 0.04
    y -= 5 * BOX_LINE_HEIGHT
    self.hline(0.25, y, 8)

    # Notified by line.
    x = 0.25
    methods = []
    methods << "FAX" if @data[:notifiedByFax]
    methods << "PHONE" if @data[:notifiedByPhone]
    methods << "EMAIL" if @data[:notifiedByEmail]
    unless methods.length == 0
      self.txtb("Notified By: <strong>#{methods.join(", ")}</strong>", 0.25, 0.5, 8, 0.25, 10, :normal, :left, :bottom)
    end

    # Signature line.
    sent_by_text = @data[:sentBy][:name]
    unless @data[:sentBy][:title].blank?
      sent_by_text << ", #{@data[:sentBy][:title]}"
    end
    unless sent_by_text.blank?
      self.txtb("Sent By: <strong>#{sent_by_text}</strong>", 0.25, 0.5, 8, 0.25, 10, :normal, :right, :bottom)
    end

  end
  
end