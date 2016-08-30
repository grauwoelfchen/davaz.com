# View::Tooltip -- davaz.com -- 04.10.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/image'
require 'view/_partial/textblock'

module DaVaz
  module View
    class TooltipComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [ 0, 0] => :image,
        [ 0, 1] => :title,
        [ 0, 2] => :text,
        [ 0, 3] => :author,
      }
      CSS_MAP = {
        0 => 'tooltip-image',
        1 => 'tooltip-title',
        2 => 'tooltip-text',
        3 => 'tooltip-author',
      }

      def image(model)
        artobject_id = model.artobject_id
        if Util::ImageHelper.has_image?(artobject_id)
          img = HtmlGrid::Image.new(artobject_id, model, @session, self)
          url = DaVaz::Util::ImageHelper.image_url(artobject_id)
          img.set_attribute('src', url)
          img.css_class = 'image-tooltip-image'
          img
        else
          ''
        end
      end
    end

    class Tooltip < HtmlGrid::DivComposite
      CSS_CLASS = 'tooltip-container'
      COMPONENTS = {
        [ 0, 0] =>  TooltipComposite,
      }
      HTTP_HEADERS = {
        'Content-Type' => 'text/html;charset=UTF-8'
      }
    end
  end
end
