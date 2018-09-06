class PdfController < ApplicationController

  def index
  end

  def invoice
    printer = :ox
    pdf = Invoice.new
    if params[:print]
      path = Tempfile.new(['invoice','.pdf']).path
      pdf.render_file path
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
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
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
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
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
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
    printer = :ox
    pdf = BillOfLading.new
    if params[:print]
      path = Tempfile.new(['bill_of_lading','.pdf']).path
      pdf.render_file path
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
      File.delete(path)
      render plain: "PDF (#{path}) sent to printer."
    else
      send_data pdf.render,
                filename: "bill_of_lading.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def so
    printer = :ox
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
    if params[:print]
      ['yellow', 'green', 'blue', 'purple', '', ''].each do |color|
        pdf = SO.new @data, color
        path = Tempfile.new(['so','.pdf']).path
        pdf.render_file path
        spooler = VMS::PrintSpooler.new printer: printer, color: true
        spooler.print_files path
       # File.delete(path)
      end
      render plain: "PDF sent to printer."
    #Otherwise, render and display Shop Order as PDF
    else
      pdf = SO.new @data, 'blue'
      send_data pdf.render,
                filename: "SO.pdf",
                type: "application/pdf",
                disposition: "inline"
    end
  end

  def inert_id_bakestand_bakesheets
    data = params[:data]
    id = InertIdentificationBakesheet.new data
    bakestand = InertBakestandBakesheet.new data
    id_path = Tempfile.new(['id','.pdf']).path
    bakestand_path = Tempfile.new(['bakestand','.pdf']).path
    id.render_file id_path
    bakestand.render_file bakestand_path
    spooler = VMS::PrintSpooler.new printer: :ph, color: true
    spooler.print_files id_path, landscape: true
    spooler.print_files bakestand_path
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
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path, landscape: true
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
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
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
      spooler = VMS::PrintSpooler.new printer: printer, color: true
      spooler.print_files path
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