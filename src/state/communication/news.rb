#!/usr/bin/env ruby
# State::Communication::News -- davaz.com -- 06.09.2005 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/communication/news'

module DAVAZ
	module State
		module Communication 
class News < State::Communication::Global
	VIEW = View::Communication::News
	def init
		@model = @session.app.load_news
	end
end
class AdminNews < State::Communication::News
	VIEW = View::Communication::AdminNews
end
		end
	end
end
