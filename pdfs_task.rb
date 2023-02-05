require 'mechanize'
require 'date'
require 'pdf-reader'
require 'nokogiri'
require 'colorize'

class Pdfs

	MAIN_URL = 'https://drive.google.com/drive/folders/1v8kAzirygnGsKm4X0eX_OhNgFPw865aQ'

	def initialize
		@agent = Mechanize.new
	end

	def download_pdfs
		main_response = agent.get(MAIN_URL)
		pdf_ids = get_pdfs_ids(main_response)
		pdf_ids.each_with_index do |id,index|
			puts "Downloading Pdf ===> #{index+1}"
			pdf_response = get_pdf_response(id)
			save_pdf(pdf_response,"Document_#{index+1}")
		end
	end

	def parse_pdfs
		data_array = []
		pdfs = Dir["*.pdf"]
		pdfs.each do |pdf|
			data_array << parse_data(pdf)
		end
		data_array.reject{|data_hash| data_hash.nil?}
	end

	private

	attr_reader :document,:agent

	def get_pdf_response(id)
		url = "https://drive.google.com/u/0/uc?id=#{id}"
		agent.get(url)
	end

	def get_pdfs_ids(response)
		page = parse_page(response.body)
		page.css('div.WYuW0e.Ss7qXc').map{|div| div['data-id']}
	end

	def parse_page(response)
		Nokogiri::HTML(response.force_encoding('utf-8'))
	end

	def save_pdf(content,filename)
    File.open("#{filename}.pdf","wb") do |f|
      f.write(content.body)
    end
  end

	def parse_data(path)
		@document = get_pdf_document(path)
		if(document.to_s.downcase.include? 'judgment')
			data_hash = {}
			data_hash[:petitioner] = get_petitioner
			data_hash[:state]      = get_state
			data_hash[:date]       = get_date_required_format
			data_hash[:amount]     = get_amount
			data_hash
		end
	end

	def get_pdf_document(path)
		pdf_reader = PDF::Reader.new(open(path))
		pdf_reader.pages.first.text.scan(/^.+/)
	end

	def get_petitioner
		petitioner_obj   = document.select{|e| e.downcase.include? 'petitioner'}.first
		petitioner_index = document.index(petitioner_obj)
		petitioner_value = document[petitioner_index - 1]
		(petitioner_value.downcase.include? 'dob') ? get_required_value(document[petitioner_index-2]) : get_required_value(petitioner_value)
	end

	def get_required_value(value)
		value.split(',').first.strip
	end

	def get_date_required_format
		date = document.select{|e| e.downcase.include? 'date'}.first.split(':').last.strip
		Date.parse(date).strftime("%Y-%m-%d")
	end

	def get_state
		state = document.select{|e| e.downcase.include? 'state'}.first
		"State #{state.split('State').last.strip}"
	end

	def get_amount
		amount = document.select{|e| e.downcase.include? '$'}.first
		"$#{amount.split('$').last.split.first.gsub(',','')}"
	end

end

Pdfs.new.download_pdfs
pdfs_data_array = Pdfs.new.parse_pdfs
puts '===================='.yellow
puts "PDF's Required Data"
puts '===================='.yellow
puts pdfs_data_array
