require 'uri'
require 'htmlgrid/namedcomponent'
require 'htmlgrid/span'
require 'htmlgrid/link'
require 'htmlgrid/image'
require 'util/image_helper'
require 'view/_partial/live_editor'
require 'view/_partial/tooltip'


module DaVaz::View
  # predefine
  class Tooltip      < HtmlGrid::DivComposite; end
  class AdminTooltip < Tooltip;                end

  module TextBlockLinksMethods
    def add_links(txt, context)
      map = {}
      @model.links.each { |link|
        map.store(link.word, link)
      }
      txt.gsub(/(#{map.keys.join(')|(')})/) { |match|
        link = map[match]
        link ? linkify(link, context).to_s : ''
      }
    end

    def linkify(link, context)
      return unless link.artobjects.size >= 1
      if link.artobjects.size == 1
        artobject = link.artobjects.first
        if artobject.is_url?
          lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
          lnk.href  = artobject.url
          lnk.value = link.word
          lnk.to_html(context)
        else
          @link_id ||= 0
          @link_id += 1
          span = HtmlGrid::Span.new(@model, @session, self)
          span.value     = link.word
          span.css_id    = ['tooltip', link.link_id, @link_id].join('_')
          span.css_class = 'tooltip blue'
          span.set_attribute(
            :href,
            @lookandfeel.event_url(:tooltip, :tooltip, [
              [:artobject_id, artobject.artobject_id]
            ])
          )
          span.to_html(context)
        end
      else
        lnk = HtmlGrid::Link.new(link.word, @model, @session, self)
        lnk.href  = 'javascript:void(0)'
        lnk.value = link.word
        lnk.set_attribute('onclick', <<~EOS)
          return toggleHiddenDiv('#{link.link_id}_hidden_div');
        EOS
        lnk.to_html(context)
      end
    end
  end

  class TextBlock < HtmlGrid::Component
    include TextBlockLinksMethods

    def self.onload_tooltips
      <<~EOS.gsub(/\n|^\s*/, '')
        (function() {
          require([
            'dojo/query'
          ], function(query) {
            query('span.tooltip').forEach(function(node) {
              return setHrefTooltip(
                node.id,
                node.id,
                'tooltip_' + String(node.id),
                ['below-alt', 'above-centered']
              );
            });
          });
        })();
      EOS
    end

    def add_hidden_divs(html, context)
      links = @model.links
      links.each { |link|
        div_content = ''
        if link.artobjects.size > 1
          link.artobjects.each { |aobject|
            artobject_id = aobject.artobject_id
            image = HtmlGrid::Image.new(artobject_id, \
              @model, @session, self)
            url = DaVaz::Util::ImageHelper.image_url(artobject_id)
            image.set_attribute('src', url)
            div_content << image.to_html(context)
            if aobject.text
              span = HtmlGrid::Span.new(@model, @session, self)
              span.value = aobject.text
              div_content << span.to_html(context)
            end
          }
        end
        compose_hidden_div(html, context, link, div_content)
      }
      html
    end

    def add_image(context)
      artobject_id = @model.artobject_id
      args = {
        'class' => 'block-image',
        'id'    => "artobject_image_#{@model.artobject_id}",
      }
      if DaVaz::Util::ImageHelper.has_image?(artobject_id)
        image = HtmlGrid::Image.new(artobject_id, @model, @session, self)
        url = DaVaz::Util::ImageHelper.image_url(artobject_id)
        image.set_attribute('src', url)
        image.css_id = @model.artobject_id
        div = context.div(args) { image.to_html(context) }
      else
        div = context.div(args) {}
      end
    end

    def author_to_html(context)
      return '' if @model.author.empty?
      context.div('class' => 'block-author') {
        add_links(@model.author, context)
      }
    end

    def compose_hidden_div(html, context, link, div_content)
      html << context.div(
        'class' => 'hidden-div',
        'id'    => "#{link.link_id}_hidden_div",
      ) {
        hide_link(link, context) << div_content << hide_link(link, context)
      }
    end

    def date_to_html(context)
      return '' if @model.date == '0000-00-00'
      context.div('class' => 'block-date') { @model.date_ch }
    end

    def hide_link(link, context)
      hide_link = HtmlGrid::Link.new(:hide_link, @model,
        @session, self)
      hide_link.href = 'javascript:void(0);'
      span = HtmlGrid::Span.new(@model, @session, self)
      span.css_class = 'hide-hidden-div-link'
      span.value     = @lookandfeel.lookup(:hide)
      hide_link.value = span.to_html(context)
      hide_link.set_attribute('onclick', <<~EOS)
        return toggleHiddenDiv('#{link.link_id}_hidden_div');
      EOS
      hide_link.to_html(context)
    end

    def text_to_html(context)
      return '' if @model.text.empty?
      context.div('class' => 'block-text') {
        add_links(@model.text, context)
      }
    end

    def url_to_html(context)
      parsed = URI.parse(@model.url)
      parsed = URI.parse('http://' + @model.url) unless parsed.scheme
      context.div('class' => 'block-url') {
        context.a(
          'href'   => parsed,
          'target' => '_blank',
        ) {
          @model.url
        }
      }
    rescue URI::InvalidURIError
      ''
    end

    def title_to_html(context)
      return '' if @model.title.empty?
      context.div('class' => 'block-title') {
        link = context.a('name' => @model.title.downcase.gsub(/\s+/, '')) {
          add_links(@model.title, context)
        }
      }
    end

    def to_html(context)
      html = title_to_html(context)
      html << url_to_html(context)
      html << date_to_html(context)
      html << author_to_html(context)
      html << add_image(context)
      html << text_to_html(context)
      add_hidden_divs(html, context)
    end
  end

  class OnelinerTextBlock < TextBlock
    def text_to_html(context)
      return '' if @model.text.empty?
      attrs = {
        'class' => 'block-oneliner-text',
        'style' => "color: #{@model.color}"
      }
      context.div(attrs) {
        @model.text
      }
    end

    def to_html(context)
      html = text_to_html(context)
      html
    end
  end

  class TooltipTextBlock < TextBlock
    def word_to_html(context)
      return '' if @model.word.empty?
      attrs = {
        'class' => 'block-tooltip-word'
      }
      context.div(attrs) {
        @model.word
      }
    end

    def to_html(context)
      html = word_to_html(context)
      html
    end
  end

  # @api admin
  class AdminTextBlock < HtmlGrid::Component
  end

  # @api admin
  class AdminTextBlockList < HtmlGrid::DivList
    COMPONENTS = {
      [0, 0] => AdminLiveEditor,
      [0, 1] => AdminImageDiv
    }
    CSS_MAP = {
      0 => 'text'
    }
  end

  # @api admin
  class AdminTooltipLinks < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => :from_label,
      [1, 0] => :from_link,
      [0, 1] => :to_label,
      [1, 1] => :to_link,
      [0, 2] => DaVaz::View::AdminTooltip
    }
    CSS_MAP = {
      0 => 'link',
      1 => 'link',
    }

    def from_label(model)
      span = HtmlGrid::Span.new(model, @session, self)
      span.set_attribute('class', 'tooltip-label')
      span.value = 'FROM URL'
      span
    end

    def from_link(model)
      obj = @session.app.load_artobject(model.artobject_id)
      url = !obj ? '' : @session.lookandfeel.event_url(:gallery, :art_object, [
        [:artgroup_id,  obj.artgroup_id],
        [:artobject_id, obj.artobject_id]
      ])
      link = HtmlGrid::Link.new(:gallery, model, @session, self)
      link.set_attribute('id', "tooltip_from_artobject_#{model.link_id}")
      link.set_attribute('target', '_blank')
      if url.empty?
        link.value = 'unknown'
        link.href  = 'javascript:void(0);'
      else
        link.value = url
        link.href  = url
      end
      link
    end

    def to_label(model)
      span = HtmlGrid::Span.new(model, @session, self)
      span.set_attribute('class', 'tooltip-label')
      span.value = 'TO URL'
      span
    end

    def to_link(model)
      obj = model.artobjects.first
      url = !obj.artobject_id ? '' : @session.lookandfeel.event_url(:gallery, :art_object, [
        [:artgroup_id,  obj.artgroup_id],
        [:artobject_id, obj.artobject_id]
      ])
      link = HtmlGrid::Link.new(:gallery, model, @session, self)
      link.set_attribute('id', "tooltip_to_artobject_#{model.link_id}")
      link.set_attribute('target', '_blank')
      if url.empty?
        link.value = 'unknown'
        link.href  = 'javascript:void(0);'
      else
        link.value = url
        link.href  = url
      end
      link
    end
  end

  # @api admin
  class AdminTooltipTextBlock < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => AdminTooltipLinks,
      [0, 1] => AdminTooltipLiveEditor
    }
    CSS_MAP = {
      0 => 'tooltip-link',
      1 => 'tooltip-text'
    }
  end

  # @api admin
  class AdminTooltipTextBlockList < HtmlGrid::DivList
    COMPONENTS = {
      [0, 0] => AdminTooltipLinks,
      [0, 1] => AdminTooltipLiveEditor
    }
    CSS_MAP = {
      0 => 'tooltip-link',
      1 => 'tooltip-text'
    }
  end

  # @api admin
  class AdminOnelinerTextBlockList < HtmlGrid::DivList
    COMPONENTS = {
      [0, 0] => AdminOnelinerLiveEditor
    }
    CSS_MAP = {
      0 => 'oneliner-text'
    }
  end
end
