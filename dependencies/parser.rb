require 'curb'
require 'csv'
require 'nokogiri'

class Parser
    def initialize(options)
        @products_per_page = 20.0
        @link = options.link
        @file = options.file
        @pages = (get_products_count / @products_per_page).ceil
        create_result_file
        parse_categories
	end

    def parse_categories
        n = 1
        while n < @pages + 1 do 
            Nokogiri::HTML(load_page(@link + "?p=#{n}")).xpath('//div[contains(@class, "block") and contains(@class, "product_list") and contains(@class, "grid") and contains(@class, "row") and contains(@class, "norow")]//a[@class="product_img_link"]').each do |link|
                product_html = load_page(link['href'])
                product_title = Nokogiri::HTML(product_html).xpath('//h1[@itemprop="name"]/text()').text.strip!
                product_image = Nokogiri::HTML(product_html).xpath('//img[@id="bigpic"]/@src')
                product_list = Nokogiri::HTML(product_html).xpath('//ul[@class="attribute_labels_lists"]')
                if product_list.any?
                    product_list.each do |kind|
                        kind_name = kind.xpath('.//span[@class="attribute_name"]').text
                        kind_price = kind.xpath('.//span[@class="attribute_price"]').text.gsub('€', '').strip!

                        product = 
                        {
                            name: "#{product_title} - #{kind_name}",
                            price: kind_price,
                            image: product_image
                        }

                        write_result_file(product)
                    end
                else
                    product = 
                    {
                        name: product_title,
                        price: Nokogiri::HTML(product_html).xpath('//span[@id="price_display"]').text.gsub('€', '').strip!
                    }

                    write_result_file(product)                   
                end
            end
            n += 1
        end 
    end    

    private

    def create_result_file
        CSV.open("results/#{@file}.csv","w") do |write|
            write << ['Name', 'Price', 'Image']
        end
    end

    def write_result_file(data)
        CSV.open("results/#{@file}.csv","a+") do |write|
            write << [data[:name], data[:price], data[:image]]
        end
    end

    def load_page(url)
        Curl::Easy.perform(url).body_str
    end

    def get_products_count
        html = load_page(@link)
        Nokogiri::HTML(html).xpath('//small[@class="heading-counter"]').text.gsub(/\D/, '').to_i
    end
end