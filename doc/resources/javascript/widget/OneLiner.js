define([
  'dojo/_base/declare'
, 'dojo/_base/connect'
, 'dojo/_base/fx'
, 'dojo/_base/lang'
, 'dojo/ready'
, 'dojo/parser'
, 'dijit/_WidgetBase'
, 'dijit/_TemplatedMixin'
, 'dijit/_WidgetsInTemplateMixin'
], function(declare, connect, fx, lang, ready, parser, _wb, _tm, _witm) {
  declare('ywesee.widget.OneLiner', [_wb, _tm], {
    templatePath: require.toUrl(
      '/resources/javascript/widget/templates/HtmlOneLiner.html')
  , messageString: ''
  , messages:      []
  , colors:        []
  , messageIdx:    -1
  , nodeOut:       'lineOne'
  , nodeIn:        'lineTwo'
  , delay:         1200
  , constructor: function(params, srcNodeRef) {
      // pass
    }
  , nextMessage: function() {
      this.messageIdx++;
      if (this.messageIdx >= this.messages.length) {
        this.messageIdx = 0;
      }
      this[this.nodeIn].innerHTML   = this.messages[this.messageIdx];
      this[this.nodeIn].style.color = this.colors[this.messageIdx];
      this.fadeOut();
    }
  , fadeIn: function() {
      this[this.nodeOut].style.display = 'none';
      this[this.nodeIn].style.display  = 'inline';
      var anim = fx.fadeIn({
        node:     this[this.nodeIn]
      , duration: this.delay
      });
      connect.connect(anim, 'onEnd', this, 'endTransition');
      anim.play();
    }
  , fadeOut: function() {
      var anim = fx.fadeOut({
        node:     this[this.nodeOut]
      , duration: this.delay
      });
      connect.connect(anim, 'onEnd', this, 'fadeIn');
      anim.play();
    }
  , display: function() {
      setTimeout(lang.hitch(this, 'nextMessage'), this.delay);
    }
  , postCreate: function() {
      this.lineOne.style.opacity = 0.0;
      this.lineTwo.style.opacity = 0.0;
      this.messages = this.messageString.split(/\s*\|\s*/);
      this.nextMessage();
    }
  , endTransition: function() {
      var tmp = this.nodeOut;
      this.nodeOut = this.nodeIn;
      this.nodeIn  = tmp;
      this.display();
    }
  });

  ready(function() {
    parser.parse();
  });
});
