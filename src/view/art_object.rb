require 'view/publictemplate'
require 'view/form'
require 'view/select'
require 'htmlgrid/divform'
require 'htmlgrid/divlist'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputfile'
require 'rmagick'

module DAVAZ
  module View
    class ArtobjectDetails < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :serie,
        [0, 1] => :tool,
        [0, 2] => :material,
        [0, 3] => :size,
        [0, 4] => :date,
        [0, 5] => :location,
        [0, 6] => :country,
        [0, 7] => :language
      }
    end

    class ArtObjectInnerComposite < HtmlGrid::DivComposite
      CSS_ID = 'artobject_inner_composit'
      COMPONENTS = {
        [0, 0] => :title,
        [0, 1] => :artgroup,
        [0, 2] => :artcode,
        [0, 3] => :image,
        [0, 4] => ArtobjectDetails,
        [0, 5] => :url,
        [0, 6] => :text,
        [0, 7] => :wordpress_url
      }
      CSS_ID_MAP = {
        0 => 'artobject_title',
        1 => 'artobject_subtitle_left',
        2 => 'artobject_subtitle_right',
        3 => 'artobject_image',
        4 => 'artobject_details',
        5 => 'artobject_google_video_url',
        6 => 'artobject_text',
        7 => 'artobject_wordpress_url',
      }

      def image(model=@model)
        return '' unless model
        img = HtmlGrid::Image.new(model.artobject_id, model, @session, self)
        url = DAVAZ::Util::ImageHelper.image_url(model.artobject_id)
        img.css_id = 'artobject_image'
        img.set_attribute('src', url)
        return img if model.url.empty?
        link = HtmlGrid::HttpLink.new(:url, model, @session, self)
        link.href  = model.url
        link.value = img
        link.set_attribute('target', '_blank')
        link
      end

      def url(model=@model)
        return '' if !model || model.url.empty?
        link = HtmlGrid::HttpLink.new(
          :google_video_link, model, @session, self)
        link.href  = model.url
        link.value = @lookandfeel.lookup(:watch_movie)
        link.set_attribute('target', '_blank')
        link
      end

      def wordpress_url(model=@model)
        return '' if !model || model.wordpress_url.empty?
        link = HtmlGrid::HttpLink.new(:wordpress_link, model, @session, self)
        link.href  = model.url
        link.value = @lookandfeel.lookup(:read_wordpress)
        link.set_attribute('target', '_blank')
        link
      end
    end

    class Pager < HtmlGrid::SpanComposite
      COMPONENTS = {
        [0, 0] => :last,
        [0, 1] => :items,
        [0, 2] => :next,
      }

      def items(model)
        "Item #{model.artobjects.index(model.artobject).to_i + 1} of" \
        " #{model.artobjects.size}"
      end

      def next(model)
        artobjects = model.artobjects
        active_index = artobjects.index(model.artobject).to_i
        unless (active_index + 1) == artobjects.size
          link = HtmlGrid::Link.new(:paging_next, model, @session, self)
          args = [
            [:artobject_id, artobjects.at(active_index+1).artobject_id]
          ]
          unless (search_query = @session.user_input(:search_query)).nil?
            args.unshift([ :search_query, search_query])
          end

          unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
            args.unshift([ :artgroup_id, artgroup_id])
          end
          link.href = @lookandfeel.event_url(:gallery, :art_object, args)
          image = HtmlGrid::Image.new(:paging_next, model, @session, self)
          image_src = @lookandfeel.resource(:paging_next)
          image.set_attribute('src', image_src)
          link.value = image
          link
        end
      end

      def last(model)
        artobjects = model.artobjects
        active_index = artobjects.index(model.artobject).to_i
        unless (active_index - 1) == -1
          link = HtmlGrid::Link.new(:paging_last, model, @session, self)
          args = [
            [:artobject_id, artobjects.at(active_index-1).artobject_id]
          ]
          unless (search_query = @session.user_input(:search_query)).nil?
            args.unshift([ :search_query, search_query])
          end

          unless (artgroup_id = @session.user_input(:artgroup_id)).nil?
            args.unshift([ :artgroup_id, artgroup_id])
          end

          link.href = @lookandfeel.event_url(:gallery, :art_object, args)
          image = HtmlGrid::Image.new(:paging_last, model, @session, self)
          image_src = @lookandfeel.resource(:paging_last)
          image.set_attribute('src', image_src)
          link.value = image
          link
        end
      end
    end

    class ShopPager < HtmlGrid::SpanComposite
      COMPONENTS = {
        [0, 0] => :last,
        [0, 1] => :items,
        [0, 2] => :next,
      }

      def items(model)
        "Item #{model.artobjects.index(model.artobject).to_i + 1} of" \
        " #{model.artobjects.size}"
      end

      def next(model)
        artobjects = model.artobjects
        active_index = artobjects.index(model.artobject).to_i
        unless (active_index + 1) == artobjects.size
          link = HtmlGrid::Link.new(:paging_next, model, @session, self)
          args = [
            [:artgroup_id, @session.user_input(:artgroup_id)],
            [:artobject_id, artobjects.at(active_index + 1).artobject_id],
          ]
          link.href = @lookandfeel.event_url(
            :communication, :shop_art_object, args)
          image = HtmlGrid::Image.new(:paging_next, model, @session, self)
          image_src = @lookandfeel.resource(:paging_next)
          image.set_attribute('src', image_src)
          link.value = image
          link
        end
      end

      def last(model)
        artobjects = model.artobjects
        active_index = artobjects.index(model.artobject).to_i
        unless (active_index - 1) == -1
          link = HtmlGrid::Link.new(:paging_last, model, @session, self)
          args = [
            [:artgroup_id,  @session.user_input(:artgroup_id)],
            [:artobject_id, artobjects.at(active_index-1).artobject_id]
          ]
          link.href = @lookandfeel.event_url(:communication, :shop_art_object, args)
          image = HtmlGrid::Image.new(:paging_last, model, @session, self)
          image_src = @lookandfeel.resource(:paging_last)
          image.set_attribute('src', image_src)
          link.value = image
          link
        end
      end
    end

    class MoviesPager < Pager
      def pager_link(link)
        artobject_id = link.attributes['href'].split("/").last
        link.href = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          return toggleInnerHTML(
            'movies-gallery-view'
          , '#{@lookandfeel.event_url(:gallery, :ajax_movie_gallery, [
                [:artobject_id, artobject_id]
            ])}'
          , '#{artobject_id}'
          );
        EOS
        link
      end

      def next(model)
        link = super
        return nil unless link
        pager_link(link)
      end

      def last(model)
        link = super
        return nil unless link
        pager_link(link)
      end
    end

    class MoviesArtObjectOuterComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => MoviesPager,
        [0, 1] => :back_to_overview
      }
      CSS_ID_MAP = {
        0 => 'artobject_pager',
        1 => 'artobject_back_link'
      }

      def back_to_overview(model)
        link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
        link.href = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS)
          showMovieGallery('movies-gallery-view', 'movies-list','');
        EOS
        link
      end
    end

    class ArtObjectOuterComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :pager,
        [0, 1] => :back_to_overview,
      }
      CSS_ID_MAP = {
        0 => 'artobject_pager',
        1 => 'artobject_back_link',
      }

      def back_to_overview(model)
        return '' if @model.artobjects.empty?
        link = HtmlGrid::Link.new(:back_to_overview, model, @session, self)
        link.href = @lookandfeel.event_url(:gallery, :search, [
          [:artgroup_id,  @session.user_input(:artgroup_id)],
          [:search_query, @session.user_input(:search_query)]
        ])
        link
      end

      def pager(model)
        unless @model.artobjects.empty?
          Pager.new(model, @session, self)
        end
      end
    end

    class MoviesArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => MoviesArtObjectOuterComposite,
        [0, 1] => component(ArtObjectInnerComposite, :artobject)
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite'
      }
      HTTP_HEADERS = {
        'type'    => 'text/html',
        'charset' => 'UTF-8'
      }
    end

    class ArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ArtObjectOuterComposite,
        [0, 1] => component(ArtObjectInnerComposite, :artobject)
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite'
      }
    end

    class ArtObject < View::GalleryPublicTemplate
      CONTENT = View::ArtObjectComposite
    end

    class ShopArtObjectOuterComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :pager,
        [0, 1] => :back_to_shop
      }
      CSS_ID_MAP = {
        0 => 'artobject_pager',
        1 => 'artobject_back_link'
      }

      def back_to_shop(model)
        link = HtmlGrid::Link.new(:back_to_shop, model, @session, self)
        link.href = @lookandfeel.event_url(:communication, :shop)
        link
      end

      def pager(model)
        unless @model.artobjects.empty?
          ShopPager.new(model, @session, self)
        end
      end
    end

    class ShopArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ShopArtObjectOuterComposite,
        [0, 1] => component(ArtObjectInnerComposite, :artobject)
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite'
      }
    end

    class ShopArtObject < View::GalleryPublicTemplate
      CONTENT = View::ShopArtObjectComposite
    end

    class ShowAllTagsLink < HtmlGrid::Div
      CSS_ID = 'all_tags_link'

      def init
        super
        link = HtmlGrid::Link.new(:show_tags, @model, @session, self)
        link.href = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          return toggleInnerHTML(
            'all-tags-link'
          , '#{@lookandfeel.event_url(:gallery, :ajax_all_tags)}'
          );
        EOS
        @value = link
      end
    end

    class ShowAllTagsList < HtmlGrid::DivList
      COMPONENTS = {
        [0, 0] => :tag,
        [1, 0] => 'pipe_divider'
      }

      def tag(model)
        link = HtmlGrid::Link.new(model.name, model, @session, self)
        link.value = model.name
        link.href  = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          var values    = document.artobjectform.tags_to_s.value.split(',')
            , has_value = false
            ;
          for (idx = 0; idx < values.length; idx++) {
            if (values[idx] == '#{model.name}') {
              has_value = true;
            }
          }
          if (!has_value) {
            values[values.length] = '#{model.name}';
          }
          document.artobjectform.tags_to_s.value = values.join(',');
        EOS
        link
      end
    end

    class ShowAllTags < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ShowAllTagsList,
        [0, 1] => :close,
      }
      CSS_ID_MAP = {
        0 => 'all_tags',
        1 => 'close_all_tags',
      }
      def close(model)
        link = HtmlGrid::Link.new(:close, model, @session, self)
        link.href = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          toggleInnerHTML(
            'all-tags-link',
            '#{@lookandfeel.event_url(:gallery, :ajax_all_tags_link)}'
          );
        EOS
        link
      end
    end

    class AddFormComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :input_field,
        [1, 0] => :submit,
        [2, 0] => 'pipe_divider',
        [3, 0] => :cancel,
      }
      def build_script(model)
        name = model.name
        url  = @lookandfeel.event_url(:gallery, :ajax_add_element, [
          [:select_name,  name],
          [:select_value, '']
        ])
        <<-EOS.gsub(/(^\s*)|\n/, '')
          var value  = document.artobjectform.#{name}_add_form_input.value
            , select = document.artobjectform.#{name}_id_select
            ;
          addElement(
            select
          , '#{url}'
          , value
          , '#{name}-add-form'
          , '#{name}-remove-link'
          );
        EOS
      end

      def input_field(model)
        name = "#{model.name}_add_form_input"
        input = HtmlGrid::InputText.new(name, model, @session, self)
        script = "if(event.keyCode == '13') { #{build_script(model)} return false; }"
        input.set_attribute('onkeypress', script)
        input
      end

      def submit(model)
        link = HtmlGrid::Link.new(:submit, model, @session, self)
        link.href = "javascript:void(0)"
        link.set_attribute('onclick', build_script(model))
        link
      end

      def cancel(model)
        name = "#{model.name}_add_form_input"
        link = HtmlGrid::Link.new(:cancel, model, @session, self)
        link.href = "javascript:void(0)"
        script = "toggleInnerHTML('#{model.name}-add-form', 'null')"
        link.set_attribute('onclick', script)
        link
      end
    end

    class EditLinks < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :add,
        [1, 0] => 'pipe_divider',
        [2, 0] => :remove,
        [0, 1] => :add_form
      }

      def init
        css_id_map.store(1, "#{@model.name}_add_form")
        super
      end

      def add(model)
        link = HtmlGrid::Link.new("add_#{model.name}", model, @session, self)
        link.href = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          toggleInnerHTML(
            '#{model.name}-add-form'
          , '#{@lookandfeel.event_url(:gallery, :ajax_add_form, [
              [:artobject_id, model.artobject.artobject_id],
              [:name,         model.name ]
            ])}'
          );
        EOS
        link
      end

      def remove(model)
        link = HtmlGrid::Link.new(
          "remove_#{model.name}", model, @session, self)
        link.css_id = "#{model.name}_remove_link"
        link.href   = 'javascript:void(0)'
        link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          return removeElement(
            document.artobjectform.#{model.name}_id
          , '#{@lookandfeel.event_url(:gallery, :ajax_remove_element, [
                [:artobject_id, model.artobject.artobject_id],
                [:select_name,  model.name],
                [:selected_id,  ''],
              ])
            }'
          , '#{link.css_id}'
          );
        EOS
        link
      end

      def add_form(model)
        ''
      end
    end

    class AdminArtobjectDetails < View::Form
      include HtmlGrid::ErrorMessage

      DEFAULT_CLASS = HtmlGrid::InputText
      CSS_ID = 'artobject_details'
      EVENT  = :update
      LABELS = true
      FORM_METHOD = 'POST'
      FORM_NAME   = 'artobjectform'
      COMPONENTS = {
        [0,  0]    => :title,
        [0,  1]    => component(
          View::DynSelect, :select_artgroup, 'artgroup_id'),
        [0,  2]    => component(
          View::DynSelect, :select_serie, 'serie_id'),
        [1,  3]    => :serie,
        [0,  4]    => :serie_position,
        [0,  5]    => :tags,
        [1,  6]    => ShowAllTagsLink,
        [0,  7]    => component(View::DynSelect, :select_tool, 'tool_id'),
        [1,  8]    => :tool,
        [0,  9]    => component(
          View::DynSelect, :select_material, 'material_id'),
        [1, 10]    => :material,
        [0, 11]    => :size,
        [0, 12]    => :date,
        [0, 13]    => :location,
        [0, 14]    => component(
          View::DynSelect, :select_country, 'country_id'),
        [0, 15]    => :form_language,
        [0, 16]    => :url,
        [0, 17]    => :price,
        [0, 18]    => :wordpress_url,
        [0, 20]    => :text_label,
        [1, 20]    => :text,
        [1, 21, 1] => :update,
        [1, 21, 2] => :reset,
        [1, 22, 1] => :new_art_object,
        [1, 22, 2] => :delete
      }
      CSS_MAP = {
        [0, 0]  => 'label red',
        [0, 1]  => 'label red',
        [0, 2]  => 'label red',
        [0, 4]  => 'label red',
        [0, 7]  => 'label red',
        [0, 9]  => 'label red',
        [0, 12] => 'label red',
        [0, 14] => 'label red',
        [0, 20] => 'label'
      }
      LOOKANDFEEL_MAP = {
        :form_language => :language,
      }

      class << self
        def edit_links(*args)
          args.each { |key|
            define_method(key) { |model|
              model.name = key.to_s
              EditLinks.new(model, @session, self)
            }
          }
        end
      end

      edit_links :serie, :tool, :material

      def init
        super
        error_message
      end

      def hidden_fields(context)
        hidden_fields = super
        hidden_fields <<
          context.hidden('artobject_id', @model.artobject.artobject_id) <<
          context.hidden('old_serie_id', @model.artobject.serie_id)

        if @model.fragment
          hidden_fields << context.hidden('fragment', @model.fragment)
        end

        if search_query = @session.user_input(:search_query)
          hidden_fields << context.hidden('search_query', search_query)
        end

        if obj = @model.artobject
          hidden_fields << context.hidden('text', escape(obj.text))
        end
        hidden_fields
      end

      def input_text(symbol, maxlength='50', size='50')
        input = HtmlGrid::InputText.new(
          symbol, model.artobject, @session, self)
        input.set_attribute('size', size)
        input.set_attribute('maxlength', maxlength)
        input
      end

      def date(model)
        input = HtmlGrid::InputText.new(:date, model, @session, self)
        begin
          date = model.artobject.date
          date = Date.parse(date) unless date.is_a?(Date)
          input.value = date.strftime('%d.%m.%y')
        rescue ArgumentError
          input.value = '01.01.1970'
        rescue NoMethodError
          input.value = '00.00.0000'
        end
        input.set_attribute('size', '10')
        input.set_attribute('maxlength', '10')
        input
      end

      def delete(model)
        obj = model.artobject
        return '' unless obj
        args = [
          ['artobject_id', obj.artobject_id],
          ['fragment',     model.fragment],
          ['state_id',     @session.state.object_id.to_s]
        ]
        if search_query = @session.user_input(:search_query)
          args.push([:search_query, search_query])
        else
          args.push([:artgroup_id, obj.artgroup_id])
        end
        url = @lookandfeel.event_url(:admin, :delete, args)
        button = HtmlGrid::Button.new(:delete, model, @session, self)
        button.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          if (confirm('Do you really want to delete this artobject?')) {
            window.location.href = '#{url}';
          }
        EOS
        button
      end

      def form_language(model)
        input = input_text(:language, '150')
        input.set_attribute('name', 'form_language')
        input
      end

      def location(model)
        input_text(:location)
      end

      def new_art_object(model)
        return '' unless model.artobject.artobject_id
        button = HtmlGrid::Button.new(:new_art_object, model, @session, self)
        button.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          window.location.href =
            '#{@lookandfeel.event_url(:gallery, :new_art_object)}';
        EOS
        button
      end

      def price(model)
        input_text(:price, '10')
      end

      def reset(model)
        button = HtmlGrid::Button.new(:reset, model, @session, self)
        button.set_attribute("type", "reset")
        button
      end

      def serie_position(model)
        input_text(:serie_position, '4')
      end

      def size(model)
        input_text(:size)
      end

      def title(model)
        input_text(:title, '150')
      end

      def text_label(model)
        @lookandfeel.lookup(:text)
      end

      def text(model)
        dojo_tag('dijit.Editor', {id: 'html-editor', class: 'tundra'},
                 model.artobject.text)
      end

      def tags(model)
        input_text(:tags_to_s)
      end

      def update(model)
        key = model.artobject.artobject_id ? :update : :save
        button = submit(model)
        button = HtmlGrid::Button.new(key, model, @session, self)
        button.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          this.form.text.value =
           document.getElementById('html-editor').innerHTML;
          this.form.submit();
        EOS
        button
      end

      def url(model)
        input_text(:url, '150')
      end

      def wordpress_url(model)
        input_text(:wordpress_url, '300', '80')
      end
    end

    class ImageDiv < HtmlGrid::Div
      def image(artobject, url)
        img = HtmlGrid::Image.new('artobject_image', artobject, @session, self)
        img.css_id = 'artobject_image'
        img.set_attribute('src', url)
        link = HtmlGrid::HttpLink.new(:url, artobject, @session, self)
        link.href  = artobject.url
        link.value = img
        link.set_attribute('target', '_blank')
        @value = artobject.url.empty? ? img : link
        img
      end

      def init
        super
        obj = @model.artobject
        if obj.artobject_id
          url = DAVAZ::Util::ImageHelper.image_url(obj.artobject_id, nil, true)
          image(obj, url)
        elsif obj.tmp_image_path
          image(obj, obj.tmp_image_url)
        end
      end
    end

    class AjaxUploadImageResponse < ImageDiv
      include HtmlGrid::TemplateMethods

      def to_html(context)
        html = super
        puts "returning: #{html}"
        html
      end
    end

    class UploadImageForm < View::Form
      CSS_ID = 'upload_image_form'
      EVENT  = :ajax_upload_image
      LABELS = true
      TAG_METHOD = :multipart_form
      COMPONENTS = {
        [0, 0]    => :image_file,
        [1, 1]    => :submit,
        [1, 1, 1] => :delete_image
      }
      SYMBOL_MAP = {
        :image_file => HtmlGrid::InputFile,
      }

      def hidden_fields(context)
        super << context.hidden('artobject_id', @model.artobject.artobject_id)
      end

      def init
        super
        self.set_attribute('onsubmit', <<~EOS.gsub(/(^\s*)|\n/, ''))
          if (this.image_file.value != '') {
            submitForm(
              this
            , 'artobject_image_#{@model.artobject.artobject_id}'
            , 'upload_image_form'
            , true
            );
          }
          return false;
        EOS
      end

      def delete_image(model)
        input = HtmlGrid::Input.new(:delete_image, model, @session, self)
        input.value = @lookandfeel.lookup(:delete_image)
        input.set_attribute('type', 'button')
        url = @lookandfeel.event_url(:admin, :ajax_delete_image, [
          [:artobject_id, model.artobject.artobject_id]
        ])
        input.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
          var msg = '#{@lookandfeel.lookup(:ask_for_image_deletion)}'
          if (confirm(msg)) {
            deleteImage(
              '#{url}'
            , 'artobject_image_#{model.artobject.artgroup_id}'
            );
          }
        EOS
        input
      end
    end

    class AdminArtObjectInnerComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => :artcode,
        [0, 1] => ImageDiv,
        [0, 2] => View::UploadImageForm,
        [0, 3] => :error_message_container,
        [0, 4] => AdminArtobjectDetails,
      }
      CSS_ID_MAP = {
        0 => 'artobject_title',
        2 => 'artobject_image_upload_form',
        3 => 'artobject_error_message_container',
        4 => 'artobject_admin_details',
      }
      SYMBOL_MAP = {
        :artcode => HtmlGrid::Value,
      }

      def init
        css_id_map.store(1, "artobject_image_#{@model.artobject.artobject_id}")
        super
      end

      def artcode(model)
        model.artobject.artcode
      end

      def url(model)
        url = mode.artobject.url
        return '' unless url.empty?
        link = HtmlGrid::HttpLink.new(
          :google_video_link, model.artobject, @session, self)
        link.href = url
        link.value = @lookandfeel.lookup(:watch_movie)
        link.set_attribute('target', '_blank')
        link
      end
    end

    class AdminArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => ArtObjectOuterComposite,
        [0, 1] => AdminArtObjectInnerComposite
      }
      CSS_ID_MAP = {
        0 => 'artobject-outer-composite',
        1 => 'artobject-inner-composite',
      }
    end

    class AdminArtObject < View::AdminGalleryPublicTemplate
      CONTENT = View::AdminArtObjectComposite
    end

    class AdminMoviesArtObjectComposite < HtmlGrid::DivComposite
      COMPONENTS = {
        [0, 0] => MoviesArtObjectOuterComposite,
        [0, 1] => AdminArtObjectInnerComposite
      }
      CSS_ID_MAP = {
        0 => 'artobject_outer_composite',
        1 => 'artobject_inner_composite'
      }
      HTTP_HEADERS = {
        'type'    => 'text/html',
        'charset' => 'UTF-8'
      }
    end
  end
end
