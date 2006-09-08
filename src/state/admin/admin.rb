#!/usr/bin/env ruby
# State::Admin::Admin -- davaz.com -- 08.06.2006 -- mhuggler@ywesee.com

require 'state/art_object'
require 'state/communication/links'
require 'state/communication/news'
require 'state/public/articles'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/admin/login'
require 'state/admin/admin_home'
require 'state/admin/image_browser'
require 'state/admin/ajax_states'
require 'sbsm/viralstate'

module DAVAZ
	module State
		module Admin
module Admin
	include SBSM::ViralState
	EVENT_MAP = {
		:art_object							=>	State::AdminArtObject,
		#:articles								=>	State::Public::AdminArticles,
		#:ajax_add_element				=>	State::Admin::AjaxAddElement,
		:ajax_add_element				=>	State::AjaxAddElement,
		:ajax_add_form					=>	State::AjaxAddForm,
		#:ajax_add_link					=>	State::Admin::AjaxAddLink,
		#:ajax_add_new_element		=>	State::Admin::AjaxAddNewElement,
		:ajax_all_tags					=>	State::AjaxAllTags,
		:ajax_all_tags_link			=>	State::AjaxAllTagsLink,
		#:ajax_cancel_live_edit	=>	State::Admin::AjaxCancelLiveEdit,
		#:ajax_delete_image			=>	State::Admin::AjaxDeleteImage,
		#:ajax_delete_link				=>	State::Admin::AjaxDeleteLink,
		:ajax_image_browser			=>	State::Admin::AjaxImageBrowser,
		#:ajax_live_edit_form		=>	State::Admin::AjaxLiveEditForm,
		:ajax_reload_tag_images	=>	State::Admin::AjaxReloadTagImages,
		:ajax_remove_element		=>	State::AjaxRemoveElement,
		:ajax_save_live_edit		=> State::Admin::AjaxSaveLiveEdit,
		:ajax_upload_image			=>	State::AjaxUploadImage,
		#:ajax_upload_image_form	=>	State::Admin::AjaxUploadImageForm,
		#:guestbook							=>	State::Communication::AdminGuestbook,
		:links									=>	State::Communication::AdminLinks,
		:login_form							=>	State::Admin::Login,
		#:logout									=>	State::Personal::Init,
		#:life										=>	State::Personal::AdminLife,	
		:new_art_object					=>	State::AdminArtObject,
		:news										=>	State::Communication::AdminNews,
		#:personal_life					=>	State::Personal::AdminLife,
		#:work										=>	State::Personal::AdminWork,
	}
	def ajax_check_removal_status
		State::Admin::AjaxCheckRemovalStatus.new(@session, [])	
	end
	def edit 
		if(!@session.user_input(:artobject_id).nil?)
			#State::Admin::DisplayElementForm.new(@session, self)
		end
	end
	def foot_navigation
		[
			:logout,
			[ :gallery, :new_art_object ],
			[	:communication, :guestbook ],
			[	:communication, :shop ],
			:email_link,
			[	:communication, :news ],
			[	:communication, :links ],
			[	:personal, :home ],
		]
	end
	def switch_zone(zone)
		infect(super)
	end
	def logout
		model = @previous.request_path
		if(fragment = @session.user_input(:fragment))
			model << "##{fragment}" unless fragment.empty?
		end
		State::Redirect.new(@session, model)
	end
end
		end
	end
end
