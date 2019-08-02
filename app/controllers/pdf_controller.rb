class PdfController < ApplicationController

  def index
  end

  def bakesheet
    if params[:bakestand]
      bakestand = params[:bakestand]
      url = "http://optoapi.varland.com/ovens/bakestands/#{bakestand}.json"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response, { symbolize_names: true })
      pdf = Bakesheet.new(data)
      send_data pdf.render,
                filename: "Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def final_bakesheet
    if params[:cycle]
      cycle = params[:cycle]
      url = "http://optoapi.varland.com/ovens/bake_cycles/#{cycle}.json"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response, { symbolize_names: true })
      pdf = FinalBakesheet.new(data)
      send_data pdf.render,
                filename: "FinalBakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def pay_stub
    pdf = PayStub.new()
    send_data pdf.render,
              filename: "PayStub.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def w2
    data = JSON.parse(File.read(Rails.root.join('lib', 'assets', 'w2.json')), { symbolize_names: true })
    pdf = W2.new(data)
    send_data pdf.render,
              filename: "W2.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def quote
    pdf = Quote.new()
    send_data pdf.render,
              filename: "Quote.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def invoice
    printer = :ox
    pdf = Invoice.new
    if params[:print]
      path = Tempfile.new(['invoice','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "invoice.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def packing_slip
    printer = :ox
    pdf = PackingSlip.new
    if params[:print]
      path = Tempfile.new(['packing_slip','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "Packing Slip.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def plating_certificate
    printer = :ox
    pdf = PlatingCertificate.new
    if params[:print]
      path = Tempfile.new(['plating_certificate','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "plating_certificate.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def bill_of_lading
    data = JSON.parse(params[:data], { symbolize_names: true })
    pdf = BOL.new(data)
    send_data pdf.render,
              filename: "BOL.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def so_test
    @so = params[:shop_order]
    url = "http://as400railsapi.varland.com/v1/so_test?shop_order=#{@so}"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    @data = JSON.parse(response)
    pdf = SO.new @data
    send_data pdf.render,
              filename: "SO.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def so

    # Store whether or not reprinting.
    reprint = false
    if params[:reprint] && params[:reprint] == '1'
      reprint = true
    end
    
    #Check if a shop order number has been entered & prepares data
    if params[:shop_order]
      @so_number = params[:shop_order]
      url = "http://as400railsapi.varland.com/v1/so?shop_order=" + @so_number
      uri = URI(url)
      response = Net::HTTP.get(uri)
      @data = JSON.parse(response)

      # Aborts PDF Generation process if the shop order is not within the system.
      if @data['shopOrderDate'] == "Wed, 31 Dec 1969 19:00:00 -0500"
        render plain: "The shop order number you entered is currently not in the system.\n\nPlease try a new shop order number or contact IT with any concerns." and return   
      end

    #Checks if the user wants to view a 'sample' shop order & prepares sample data.
    elsif  params[:sample]
      file = File.read('288473.json')
      @data = JSON.parse(file)
    
    #The user hasn't searched a proper shop order. Display error message.
    else
      render plain: "No shop order number was entered.\n\nPlease use the format '/so?shop_order=###### ' when searching for a shop order." and return
    end

    #Print shop order if "Print" was selected
    pdf = SO.new @data, reprint
    send_data pdf.render,
              filename: "SO.pdf",
              type: "application/pdf",
              disposition: "inline"

  end

  def dmr

    id = params[:id]
    uri = URI("http://192.168.100.7:3001/defective_materials/#{id}")
    response = Net::HTTP.get(uri)
    dmr = DmrFormatter.parse(response)
    pdf = DMR.new dmr
    send_data pdf.render,
              filename: "DMR.pdf",
              type: "application/pdf",
              disposition: "inline"

  end

  def inert_id_bakestand_bakesheets
    data = params[:data]
    id = InertIdentificationBakesheet.new data
    bakestand = InertBakestandBakesheet.new data
    id_path = Tempfile.new(['id','.pdf']).path
    bakestand_path = Tempfile.new(['bakestand','.pdf']).path
    id.render_file id_path
    bakestand.render_file bakestand_path
    #spooler = VMS::PrintSpooler.new printer: :ph, color: true
    #spooler.print_files id_path, landscape: true
    #spooler.print_files bakestand_path
    File.delete id_path
    File.delete bakestand_path
    render plain: "OK"
  end

  def inert_identification_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_id.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertIdentificationBakesheet.new data
    if params[:print]
      path = Tempfile.new(['id','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path, landscape: true
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "Identification Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end
  
  def inert_bakestand_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_id.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertBakestandBakesheet.new data
    if params[:print]
      path = Tempfile.new(['bakestand','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "Bakestand Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def inert_final_bakesheet
    data = nil
    if params[:sample]
      printer = :ox
      data = File.read(Rails.root.join('lib', 'assets', 'sample_iao_final.txt'))
    else
      printer = :ph
      data = params[:data]
    end
    pdf = InertFinalBakesheet.new data
    if params[:print]
      path = Tempfile.new(['final','.pdf']).path
      pdf.render_file path
      #spooler = VMS::PrintSpooler.new printer: printer, color: true
      #spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "Final Bakesheet.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

end