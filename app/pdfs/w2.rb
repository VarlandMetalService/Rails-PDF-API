class W2 < VarlandPdf
    
  DEFAULT_MARGIN = 0
  DEFAULT_LAYOUT = :portrait
  
  def initialize(data = nil)

    # Call parent constructor and store passed data.
    super()
    @data = data

    # Set options.
    @standard_color = '000000'
    @standard_font = 'Helvetica'
    @data_color = '000000'
    @data_font = 'SF Mono'

    # Print employer copies.
    self.print_employee_graphics
    self.print_employee_data
    # self.print_cut_lines
    # self.print_employee_instructions
    # self.print_cut_lines

    # Print employer copies.
    # self.print_employer_graphics
    # self.print_employee_data
    # self.print_cut_lines
    # self.print_employer_instructions
    # self.print_cut_lines

    # Encrypt PDF.
    encrypt_document(owner_password: :random,
                     user_password: "W2",
                     permissions: {
                       print_document: true,
                       modify_contents: false,
                       copy_contents: true,
                       modify_annotations: false
                     })
      
  end

  # Prints cutting guides.
  def print_cut_lines
    return
    dash([1])
    stroke_color('aaaaaa')
    stroke_horizontal_line(0.25.in, 8.25.in, :at => 5.5.in)
    stroke_vertical_line(0.25.in, 10.75.in, :at => 4.25.in)
    undash()
    stroke_color('000000')
  end

  # Prints instructions on back.
  def print_employee_instructions

    # Start new page.
    self.start_new_page()

    # Back of Copy B.
    copy_b = File.read(Rails.root.join('lib', 'assets', 'w2_instructions_b.htm'))
    self.vms_text_box(copy_b, 4.5, 10.75, 3.75, 5, 8, :normal, :left, :center)

    # Back of Copy C.
    copy_c = File.read(Rails.root.join('lib', 'assets', 'w2_instructions_c.htm'))
    column_box([4.5.in, 5.25.in], columns: 2, width: 3.75.in, height: 5.in) do
      text(copy_c,
           inline_format: true,
           valign: :top,
           align: :left,
           size: 4.2)
    end

  end

  # Prints instructions on back.
  def print_employer_instructions

    # Start new page.
    self.start_new_page()

    # Employer copy.
    employer = File.read(Rails.root.join('lib', 'assets', 'w2_employer.htm'))
    self.vms_text_box(employer, 0.25, 10.75, 3.75, 5, 8, :normal, :left, :center)
    self.vms_text_box(employer, 4.5, 10.75, 3.75, 5, 8, :normal, :left, :center)
    self.vms_text_box(employer, 0.25, 5.25, 3.75, 5, 8, :normal, :left, :center)
    self.vms_text_box(employer, 4.5, 5.25, 3.75, 5, 8, :normal, :left, :center)

  end
  
  # Prints data on W-2.
  def print_employee_data

    # Define positions.
    box_offsets = [[0, 0], [4.25, 0], [0, -5.5], [4.25, -5.5]]
    starting_x = 0.25
    starting_y = 10.75

    # Draw text for each position.
    box_offsets.each do |o|
      box_x = starting_x + o[0]
      box_y = starting_y + o[1]
      print_employee_data_box(box_x, box_y)
    end

  end

  # Prints data on one of four boxes.
  def print_employee_data_box(box_x, box_y)

    # Draw box.
    x = box_x
    y = box_y - 0.375
    self.vms_text_box(@data[:employee][:ssn], x, y, 1.25, 0.25, 7, :bold, :center, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:wages][:gross]), x + 1.3, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:taxes][:federal]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.25
    self.vms_text_box(curr(@data[:wages][:social_security]), x + 1.3, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:taxes][:social_security]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.125
    self.vms_text_box(@data[:employer][:ein], x, y, 1.25, 0.25, 7, :bold, :center, :center, @data_font, @data_color)
    y -= 0.125
    self.vms_text_box(curr(@data[:wages][:medicare]), x + 1.3, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:taxes][:medicare]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.25
    self.vms_text_box("#{@data[:employer][:name]}\n#{@data[:employer][:street]}\n#{@data[:employer][:city]}, #{@data[:employer][:state]} #{@data[:employer][:zip]}", x + 0.05, y, 3.65, 0.625, 7, :bold, :left, :center, @data_font, @data_color)
    y -= 1
    self.vms_text_box("#{@data[:employee][:name]}\n#{@data[:employee][:street]}\n#{@data[:employee][:city]}, #{@data[:employee][:state]} #{@data[:employee][:zip]}", x + 0.05, y, 3.65, 0.625, 7, :bold, :left, :center, @data_font, @data_color)
    y -= 1
    self.vms_text_box(@data[:box_12][:a][:code], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:box_12][:a][:amount]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.25
    self.vms_text_box("X", x + 0.05, y, 0.9, 0.125, 7, :bold, :center, :center, @data_font, @data_color) if @data[:box_13][:statutory]
    self.vms_text_box(@data[:box_12][:b][:code], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:box_12][:b][:amount]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.25
    self.vms_text_box("X", x + 0.05, y, 0.9, 0.125, 7, :bold, :center, :center, @data_font, @data_color) if @data[:box_13][:retirement]
    self.vms_text_box(@data[:box_12][:c][:code], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:box_12][:c][:amount]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.25
    self.vms_text_box("X", x + 0.05, y, 0.9, 0.125, 7, :bold, :center, :center, @data_font, @data_color) if @data[:box_13][:third_party_sick]
    self.vms_text_box(@data[:box_12][:d][:code], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    self.vms_text_box(curr(@data[:box_12][:d][:amount]), x + 2.55, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    y -= 0.125
    unless @data[:state][0].blank?
      self.vms_text_box(@data[:state][0][:code], x, y, 0.3, 0.125, 7, :bold, :center, :center, @data_font, @data_color)
      self.vms_text_box(@data[:state][0][:ein], x + 0.35, y, 1, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:state][0][:wages]), x + 1.45, y, 1.1, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:state][0][:tax]), x + 2.65, y, 1.05, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    end
    y -= 0.125
    unless @data[:state][1].blank?
      self.vms_text_box(@data[:state][1][:code], x, y, 0.3, 0.125, 7, :bold, :center, :center, @data_font, @data_color)
      self.vms_text_box(@data[:state][1][:ein], x + 0.35, y, 1, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:state][1][:wages]), x + 1.45, y, 1.1, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:state][1][:tax]), x + 2.65, y, 1.05, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
    end
    y -= 0.375
    unless @data[:local][0].blank?
      self.vms_text_box(curr(@data[:local][0][:wages]), x + 0.05, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:local][0][:tax]), x + 1.3, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(@data[:local][0][:name], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    end
    y -= 0.125
    unless @data[:local][1].blank?
      self.vms_text_box(curr(@data[:local][1][:wages]), x + 0.05, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(curr(@data[:local][1][:tax]), x + 1.3, y, 1.15, 0.125, 7, :bold, :right, :center, @data_font, @data_color)
      self.vms_text_box(@data[:local][1][:name], x + 2.55, y, 1.15, 0.125, 7, :bold, :left, :center, @data_font, @data_color)
    end

  end
  
  # Prints standard text & graphics on each page.
  def print_employee_graphics

    # Define boxes.
    boxes = [
      { x: 0.25,
        y: 10.75,
        title: "Copy B — To Be Filed With Employee's\nFEDERAL Tax Return.",
        bottom_left: "This information is being furnished to the Internal Revenue Service.",
        bottom_left_offset: 0.1,
        bottom_left_height: 0.125,
        bottom_right: "<em>www.irs.gov/efile</em>",
        bottom_right_offset: 0.025 },
      { x: 4.5,
        y: 10.75,
        title: "Copy 2 — To Be Filed With Employee's State\nCity, or Local Income Tax Return.",
        bottom_left: "",
        bottom_left_offset: 0,
        bottom_left_height: 0.125,
        bottom_right: "",
        bottom_right_offset: 0 },
      { x: 0.25,
        y: 5.25,
        title: "Copy C — For EMPLOYEE'S RECORDS (See\n<em>Notice to Employee</em> on the back of Copy B.)",
        bottom_left: "This information is being furnished to the IRS. If you are required to file a tax return, a negligence\npenalty or other sanction may be imposed on you if this income is taxable and you fail to report it.",
        bottom_left_offset: 0.1,
        bottom_left_height: 0.25,
        bottom_right: "",
        bottom_right_offset: 0 },
      { x: 4.5,
        y: 5.25,
        title: "Copy 2 — To Be Filed With Employee's State\nCity, or Local Income Tax Return.",
        bottom_left: "L4UP",
        bottom_left_offset: 0.125,
        bottom_left_height: 0.125,
        bottom_right: "5205",
        bottom_right_offset: 0 }
    ]

    # Draw boxes.
    boxes.each do |box|
      print_employee_graphics_box(box)
    end

  end

  # Prints graphics for one of four boxes.
  def print_employee_graphics_box(box)

    # Horizontal lines (top to bottom, left to right).
    x = box[:x].in
    y = box[:y].in
    self.line_width = 0.01.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    self.line_width = 0.02.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x + 1.25.in, y], [x + 3.75.in, y])
    y -= 0.125.in
    stroke_line([x, y], [x + 1.25.in, y])
    y -= 0.125.in
    self.line_width = 0.01.in
    stroke_line([x + 1.25.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.75.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.75.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 1.in, y])
    stroke_line([x + 2.5.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 1.in, y])
    stroke_line([x + 2.5.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.375.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.375.in
    stroke_line([x, y], [x + 3.75.in, y])

    # Vertical lines (top to bottom, left to right).
    x = box[:x].in
    y = box[:y].in
    stroke_line([x, y], [x, y - 4.75.in])
    stroke_line([x + 2.6.in, y], [x + 2.6.in, y - 0.25.in])
    stroke_line([x + 3.75.in, y], [x + 3.75.in, y - 4.75.in])
    self.line_width = 0.02.in
    y -= 0.25.in
    stroke_line([x, y], [x, y - 0.375.in])
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    stroke_line([x + 3.75.in, y], [x + 3.75.in, y - 0.25.in])
    y -= 0.25.in
    self.line_width = 0.01.in
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    y -= 0.125.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    y -= 0.125.in
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    y -= 2.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.5.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 1.25.in])
    y -= 0.5.in
    stroke_line([x + 1.in, y], [x + 1.in, y - 0.75.in])
    y -= 0.75.in
    stroke_line([x + 0.3.in, y], [x + 0.3.in, y - 0.25.in])
    stroke_line([x + 1.4.in, y], [x + 1.4.in, y - 0.375.in])
    stroke_line([x + 2.6.in, y], [x + 2.6.in, y - 0.375.in])
    y -= 0.375.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.375.in])

    # Text (top to bottom, left to right).
    x = box[:x]
    y = box[:y]
    self.vms_text_box(box[:title], x + 0.1, y, 2.4, 0.25, 7, :bold, :left, :center, nil, 'ff0000')
    self.vms_text_box("41-0852411\nOMB No. 1545-0008", x + 2.6, y, 1.15, 0.25, 6, :normal, :center, :center)
    y -= 0.25
    self.vms_text_box("<strong>a</strong> Employee's soc. sec. no.", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>1</strong> Wages, tips, other comp.", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>2</strong> Federal income tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>3</strong> Social security wages", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>4</strong> Social security tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>b</strong> Employer ID number (EIN)", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>5</strong> Medicare wages and tips", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>6</strong> Medicare tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>c</strong> Employer's name, address, and ZIP code", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    y -= 0.75
    self.vms_text_box("<strong>d</strong> Control number", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>e</strong> Employee's name, address, and ZIP code", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("Suff.", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :right, :top)
    y -= 0.75
    self.vms_text_box("<strong>7</strong> Social security tips", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>8</strong> Allocated tips", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>9</strong> Verification code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>10</strong> Dependent care benefits", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>11</strong> Nonqualified plans", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>12a</strong> Code (See inst. for box 12)", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>13</strong> Statutory employee", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>14</strong> Other", x + 1.05, y - 0.02, 1.4, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>12b</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("Retirement plan", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :center, :top)
    self.vms_text_box("<strong>12c</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("Third-party sick pay", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :center, :top)
    self.vms_text_box("<strong>12d</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.5
    self.vms_text_box("<strong>15</strong> State Employer's ID Number", x + 0.05, y - 0.02, 1.3, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>16</strong> State wages, tips, etc.", x + 1.45, y - 0.02, 1.1, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>17</strong> State income tax", x + 2.65, y - 0.02, 1.05, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>18</strong> Local wages, tips, etc.", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>19</strong> Local income tax", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>20</strong> Locality name", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.375
    self.vms_text_box("2018", x, y - 0.02, 3.75, 0.25, 8, :bold, :center, :top, nil, 'ff0000')
    self.vms_text_box("Form W-2 Wage and Tax Statement", x, y - 0.04, 3.75, 0.125, 6, :bold, :left, :top, nil, 'ff0000')
    self.vms_text_box("Dept. of the Treasury -- IRS", x, y - 0.04, 3.75, 0.125, 6, :normal, :right, :top)
    y -= box[:bottom_left_offset]
    self.vms_text_box(box[:bottom_left], x, y - 0.04, 3.75, box[:bottom_left_height], 6, :normal, :left, :top)
    y -= box[:bottom_right_offset]
    self.vms_text_box(box[:bottom_right], x, y - 0.04, 3.75, 0.125, 6, :normal, :right, :top)

  end
  
  # Prints standard text & graphics on each page.
  def print_employer_graphics

    # Start new page.
    self.start_new_page()

    # Define boxes.
    boxes = [
      { x: 0.25,
        y: 10.75,
        bottom_right: "",
        bottom_right_offset: 0 },
      { x: 4.5,
        y: 10.75,
        bottom_right: "",
        bottom_right_offset: 0 },
      { x: 0.25,
        y: 5.25,
        bottom_right: "",
        bottom_right_offset: 0 },
      { x: 4.5,
        y: 5.25,
        bottom_right: "L4UPR                                               5405",
        bottom_right_offset: 0.175 }
    ]

    # Draw boxes.
    boxes.each do |box|
      print_employer_graphics_box(box)
    end

  end

  # Prints graphics for one of four boxes.
  def print_employer_graphics_box(box)

    # Horizontal lines (top to bottom, left to right).
    x = box[:x].in
    y = box[:y].in
    self.line_width = 0.01.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x + 1.25.in, y], [x + 3.75.in, y])
    y -= 0.125.in
    stroke_line([x, y], [x + 1.25.in, y])
    y -= 0.125.in
    stroke_line([x + 1.25.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.75.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.75.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 1.in, y])
    stroke_line([x + 2.5.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 1.in, y])
    stroke_line([x + 2.5.in, y], [x + 3.75.in, y])
    y -= 0.25.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.375.in
    stroke_line([x, y], [x + 3.75.in, y])
    y -= 0.375.in
    stroke_line([x, y], [x + 3.75.in, y])

    # Vertical lines (top to bottom, left to right).
    x = box[:x].in
    y = box[:y].in
    stroke_line([x, y], [x, y - 4.75.in])
    stroke_line([x + 2.1.in, y], [x + 2.1.in, y - 0.25.in])
    stroke_line([x + 2.7.in, y], [x + 2.7.in, y - 0.25.in])
    stroke_line([x + 3.75.in, y], [x + 3.75.in, y - 4.75.in])
    y -= 0.25.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    y -= 0.25.in
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    y -= 0.125.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    y -= 0.125.in
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.25.in])
    y -= 2.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.5.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 1.25.in])
    y -= 0.5.in
    stroke_line([x + 1.in, y], [x + 1.in, y - 0.75.in])
    y -= 0.75.in
    stroke_line([x + 0.3.in, y], [x + 0.3.in, y - 0.25.in])
    stroke_line([x + 1.4.in, y], [x + 1.4.in, y - 0.375.in])
    stroke_line([x + 2.6.in, y], [x + 2.6.in, y - 0.375.in])
    y -= 0.375.in
    stroke_line([x + 1.25.in, y], [x + 1.25.in, y - 0.375.in])
    stroke_line([x + 2.5.in, y], [x + 2.5.in, y - 0.375.in])

    # Text (top to bottom, left to right).
    x = box[:x]
    y = box[:y]
    self.vms_text_box("Employers State, Local, or File Copy", x + 0.1, y, 1.9, 0.25, 7, :bold, :left, :center)
    self.vms_text_box("22222", x + 2.1, y + 0.015, 0.6, 0.25, 10, :normal, :center, :center, 'SF Mono')
    self.vms_text_box("2018", x + 2.7, y, 0.5, 0.25, 12, :bold, :center, :center, 'Whitney Bold')
    self.vms_text_box("OMB No.\n1545-0008", x + 3.2, y, 0.55, 0.25, 6, :normal, :center, :center)
    y -= 0.25
    self.vms_text_box("<strong>a</strong> Employee's soc. sec. no.", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>1</strong> Wages, tips, other comp.", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>2</strong> Federal income tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>3</strong> Social security wages", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>4</strong> Social security tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>b</strong> Employer ID number (EIN)", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>5</strong> Medicare wages and tips", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>6</strong> Medicare tax withheld", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>c</strong> Employer's name, address, and ZIP code", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    y -= 0.75
    self.vms_text_box("<strong>d</strong> Control number", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>e</strong> Employee's name, address, and ZIP code", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("Suff.", x + 0.05, y - 0.02, 3.65, _p(6), 6, :normal, :right, :top)
    y -= 0.75
    self.vms_text_box("<strong>7</strong> Social security tips", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>8</strong> Allocated tips", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>9</strong> Verification code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>10</strong> Dependent care benefits", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>11</strong> Nonqualified plans", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>12a</strong> Code (See inst. for box 12)", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("<strong>13</strong> Statutory employee", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>14</strong> Other", x + 1.05, y - 0.02, 1.4, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>12b</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("Retirement plan", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :center, :top)
    self.vms_text_box("<strong>12c</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.25
    self.vms_text_box("Third-party sick pay", x + 0.05, y - 0.02, 0.9, _p(6), 6, :normal, :center, :top)
    self.vms_text_box("<strong>12d</strong> Code", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.5
    self.vms_text_box("<strong>15</strong> State Employer's ID Number", x + 0.05, y - 0.02, 1.3, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>16</strong> State wages, tips, etc.", x + 1.45, y - 0.02, 1.1, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>17</strong> State income tax", x + 2.65, y - 0.02, 1.05, _p(6), 6, :normal, :left, :top)
    y -= 0.125
    self.vms_text_box("<strong>18</strong> Local wages, tips, etc.", x + 0.05, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>19</strong> Local income tax", x + 1.3, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    self.vms_text_box("<strong>20</strong> Locality name", x + 2.55, y - 0.02, 1.15, _p(6), 6, :normal, :left, :top)
    y -= 0.375
    self.vms_text_box("Form W-2 Wage and Tax Statement\nFor Privacy Act and Paperwork Reduction\nAct Notice, see separate instructions.", x, y - 0.04, 3.75, 0.375, 6, :bold, :left, :top)
    self.vms_text_box("Dept. of the Treasury -- IRS", x, y - 0.04, 3.75, 0.125, 6, :normal, :right, :top)
    y -= box[:bottom_right_offset]
    self.vms_text_box(box[:bottom_right], x, y - 0.04, 3.75, 0.125, 6, :normal, :right, :top)

  end

# Private methods.
private

  # Prints currency amount.
  def curr(amount)
    if amount.blank?
      ""
    else
      helpers.number_with_precision(amount, precision: 2, delimiter: ',')
    end
  end

  # Reference Rails helpers.
  def helpers
    ApplicationController.helpers
  end
  
end