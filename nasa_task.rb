require 'mechanize'
require 'json'
require 'date'
require 'nokogiri'

class Nasa

	ARTICLE_URLS = {"related" => 'https://www.nasa.gov/api/1/query/related?page=0&pageSize=5&tids%5B%5D=3121&tids%5B%5D=15505&tids%5B%5D=4505&tids%5B%5D=17445&tids%5B%5D=4642&tids%5B%5D=5168&tids%5B%5D=20725',
		"latest" => 'https://www.nasa.gov/api/1/query/latest'}

	def initialize
		@agent = Mechanize.new
	end

	def fetch_articles(article_type)
		data_array = []
		main_response = agent.get(ARTICLE_URLS[article_type])
		nid_ids = get_nid_ids(main_response,article_type)
		puts "------- #{article_type} articles id's -------"
		nid_ids.each do |id|
			puts "Processing_id ====> #{id}"
			api_response = get_api_request(id)
			data_array << parse_data(api_response)
		end
		data_array
	end

	private

	attr_reader :agent

	def get_api_request(id)
		api_url = "https://www.nasa.gov/api/2/ubernode/#{id}"
		agent.get(api_url)
	end

	def get_nid_ids(response,article_type)
		page = parse_page(response)
		(article_type == 'latest') ? get_ids_array(page[article_type],'cardUbernode') : get_ids_array(page[article_type],'nid')
	end

	def get_ids_array(json_page,key)
		json_page.map{|data_hash| data_hash[key]}.reject{|e| e.nil?}.uniq
	end

	def parse_data(response)
		json_parsed_page = parse_page(response)
		data_hash = {}
		date                    = json_parsed_page['_source']['promo-date-time']
		data_hash[:title]       = json_parsed_page['_source']['title']
		data_hash[:date]        = get_date_required_format(date)
		data_hash[:release_no]  = json_parsed_page['_source']['release-id']
		data_hash[:article]     = get_article_body(json_parsed_page['_source']['body'])
		data_hash
	end

	def get_article_body(body)
		page = Nokogiri::HTML(body)
		page.css('div.dnd-atom-wrapper.type-image.context-full_width').remove
		page.text.strip.gsub(/\n/,'').gsub('-end-','')
	end

	def get_date_required_format(date)
		Date.parse(date).strftime("%y-%m-%d")
	end

	def parse_page(response)
		JSON.parse(response.body)
	end

end

latest_articles  = Nasa.new.fetch_articles('latest')
related_articles = Nasa.new.fetch_articles('related')
