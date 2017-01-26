class Options
	def initialize(options={})
		@link = options[:link]
		@file = options[:file]
	end

  	def link
		@link
	end

	def file
		@file
	end	
end