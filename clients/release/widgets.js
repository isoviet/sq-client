// ========= SPONSORPAY RULES!!!! =======================================

var SPONSORPAY = SPONSORPAY || {};
SPONSORPAY.Widget = SPONSORPAY.Widget || {};
SPONSORPAY.Video = SPONSORPAY.Video || {};

SPONSORPAY.debug = function(obj) {
  if (typeof window.console != 'object' && obj.debug == true) {
    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
    "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];
    window.console = {};
    for (var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
  }
  return obj.debug;
}

// {{{ VIDEO Iframe
SPONSORPAY.Video.Iframe = function(options) {
  var _self = this;

  // constants
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      =  window.location.protocol + '//ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.6.1';
  this.SP_FALLBACK_MS     =  10000; // 5sec
  this.PUB_PARAMS         =  10; // pub0..pub9

  this.jq       = null;
  this.timeout  = null;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host           = 'iframe.sponsorpay.com';
  this.asset_host         = 'asset1.sponsorpay.com';
  this.environment        = 'production';
  this.integration        = 'video_iframe';
  this.cookie_expiration  = 14; // days
  this.myoffset           = null;
  this.max_views          = 0;    // times
  this.ps_time            = null; // user creation_date
  this.greyout            = 'true'; // true is default, display grayed background for overlay

  //options
  this.where = null;  // where to insert iframe to, null for overlay
  this.display_format     = 'bare_player';
  this.callback_on_start  = null;     // offers exists && loaded
  this.callback_on_conversion = null; // offers
  this.callback_no_offers = null;     // no offers
  this.callback_on_close = null;     // close

  this.enable_regular_offers = 'false';
  this.multiple_offers     = 'false';

  this.vertical_offset    = null;     // vertical offset for overlay

  // private
  this._sp_branding       = null;     // false as OFF, value to custom URL
  this._display_instructions = true;   // true = ON
  this._display_reward    = true;
  this.width              = null;
  this.height             = null;
  this._default_width     = 400;
  this._default_height    = 330;
  this._overlay_height    = 750;
  this._overlay_width     = 750;
  this._extra_width       = 0;
  this._extra_height      = 0;
  this._overlay           = true;     //
  this._prepared          = false;    // offer prepared, able to show
  this._offers            = null;
  this._source_url        = null;
  this._extra_params      = null;
  this._autostart         = true;
  this._next_offer        = null;   // type of next offer or null if no next offer
  this._multiple_offers_limit = 10; // 10 offers in queue
  this.brandengage        = true;

  this.ab_test            = null;
  this.debug              = false;

  this.er                 = null;
  this.currency           = null;
  this.digest             = null;
  this.ts                 = null;

  this.country            = null;
  this.language           = null;

  this._continue_button_ids = [2733, 2169];

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }


  // Starting point ***************************************
  // just wrappers
  this.backgroundLoad = function() {
    this._autostart = false;
    this.start();
  };

  this.loadAndShow = function() {
    this.start();
  };


  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') || !this._checkDisplayFormat()) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }
    if (SPONSORPAY.debug(this)) console.info( "INIT" );

    SPUtils.loadJQueryAndInit(this, this.init);
  };

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'Not ie6 support' );
      return false;
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'SponsorPay ' + this.integration + ' is not active' );
      return false;
    }

    var callbackNoOffersPublisher = _self.callback_no_offers;

    _self.callback_no_offers = function() {
      SPUtils.trackView(_self, null);
      if (typeof callbackNoOffersPublisher === 'function') {
        callbackNoOffersPublisher.call();
      }
    };

    // set default width and height if null
    _self.width = _self.width || (_self.where == null ? _self._overlay_width : _self._default_width);
    _self.height = _self.height || (_self.where == null ? _self._overlay_height : _self._default_height);

    // add extra height if next offer link
    if (_self.multiple_offers == 'true') _self._extra_height += 35;

    // check width, can't be larger than screen
    // 68 = 2*__add + 2*10 as margin
    if (parseInt(_self.width)>window.innerWidth && parseInt(window.innerWidth)>=68) {
      _self.width = (window.innerWidth-68)+'';
    };
    // send max width/height for videos

    _self._extra_params = {width:(_self.width-_self._extra_width), height:(_self.height-_self._extra_height), brandengage:_self.brandengage};

    if (_self.jq.inArray(parseInt(_self.appid), _self._continue_button_ids) >= 0) _self._extra_height += 30;

    // if overlay, prepare overlay
    if (this.where == null) {
      this.where = '_sp_overlay_iframe';
      // prepare our 'lightbox'
      //var _close_div='<div style="top:0px;position:relative;text-align:right;padding-right:10px;"><a href="#" style="text-decoration:none;font-weight:bold;font-family:sans-serif;font-size:14px" id="_sp_close">x</a></div>';
      _self.jq(document).bind('ready',function() {
        _self._prepare_overlay();
      });
      _self._extra_params = _self.jq.extend(_self._extra_params, {limit:10});  // load more offers
    } else {
      _self._overlay = false;
    }
    // set html element (even inside an overlay)
    _self._prepare_html_element();

    // prepare postMessage receiver
    if (_self.callback_on_conversion != null && typeof _self.callback_on_conversion == 'function') {
      pm.unbind('sponsorpay');
      pm.bind('sponsorpay', function(data) {
        if (_self._offers != null) {
          _self._offers.shift(); // remove first offer
        }
        _self.callback_on_conversion.call();
      });
    }

    if (_self.multiple_offers == 'true') {
      pm.unbind('sponsorpay_next_offer');
      pm.bind('sponsorpay_next_offer', function(data) {
        _self._show_next_offer();
      });
      _self.jq("#_sp_center ._sp_next_offer a").live('click', function(){
        _self._show_next_offer();
        return false;
      });
    }

    this._doInit(_self._extra_params);
  }; // initialize

  this._doInit = function(extra_params) {
    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
        SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, this.jq.extend( extra_params, SPUtils.pub_literals(this, this.PUB_PARAMS) ), _self._multiple_offers_limit);
      });
    } else {
      this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
      SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, this.jq.extend( extra_params, SPUtils.pub_literals(this, this.PUB_PARAMS) ), _self._multiple_offers_limit);
    }
  }; // _doInit


  this.showVideo = function() {
    if (!_self._prepared) {
      return false;
    }
    if (_self._offers.length>0) {
      // shift when no regular offers
      if (_self.enable_regular_offers != 'true' || (_self.width - _self._extra_width) < 400 || (_self.height - _self._extra_height) < 330) {
        // remove all the non-video offers
        for (var i = 0; i < _self._offers.length; i++) {
          if (_self._offers[i].video == false) {
            _self._offers.splice(i, 1);
            i--;
          }
        }
      }
    }
    if (_self._offers.length>0) {
      // load CSS only when no video offer
      if (_self._offers[0].video == false) {
        SPUtils.loadCSSFile(window.location.protocol + '//' + _self.asset_host + '/stylesheets/' + _self.integration + '/v1/default.css');
      }

      if (_self.multiple_offers === 'true') {
        _self._next_offer = 'none';
        if (_self._offers.length > 1) {
          _self._next_offer = _self._offers[1].video ? 'video' : 'offer';
        }
      }

      this._render_offer(_self._offers[0]);
      this._blacklistVideoOffer(_self._offers[0]);
      SPUtils.trackView(this, _self._offers[0]);
    } else {
      // no offers, if callback exists, call or display alert()
      if (typeof _self.callback_no_offers == 'function') {
        _self.callback_no_offers.call();
      } else {
        alert('no offers');
      }
    }
  }; // showVideo

  // Private methods ***************************************

  this._blacklistVideoOffer = function(offer) {
    var blacklist = SPUtils.getCookie(_self, 'videoOffersBlacklist') || '';
    var time = new Date();
    var offerInCookie =  offer.id+':'+time.getTime();
    var cookie = blacklist === '' ? offerInCookie : blacklist+'#'+offerInCookie;

    SPUtils.setCookie(_self, 'videoOffersBlacklist', cookie);
  };

  this._removeBlacklisted = function(offers) {
    var blacklistedOffers = SPUtils.getCookie(_self, 'videoOffersBlacklist');
    blacklistedOffers = blacklistedOffers === null ? [] : blacklistedOffers.split('#');
    var currentTime       = new Date();

    for (var i=0; i < offers.length; i++) {
      for (var j=0; j < blacklistedOffers.length; j++) {
        // format landing_page_id:timestamp
        blOffer = blacklistedOffers[j].split(':');
        // if landing_page_id matches
        // and offer is not multiple completion
        // check if last 'click' was within the last 15 minutes
        if (offers[i].mc === false && offers[i].id === parseInt(blOffer[0], 10) && ((currentTime.getTime() - parseInt(blOffer[1], 10)) / 1000 / 60) <= 15) {
          offers.splice(i, 1);
        }
      }
    }
    return offers;
  }

  this._set_ab_test = function(ab_test_value) {
    this.ab_test = ab_test_value;
  };

  this._set_information = function(information) {
    this.country = information.country;
    this.language = information.language;
    this._t_next_video = information.next_video;
    this._t_next_offer = information.next_offer;
    this._t_no_offer = information.no_offer;
  };

  this._prepare_overlay = function() {
    if (_self.jq('#_sp_fade').length == 0) {
      var bgcolor = '#ffffff';
      var bocolor = '#000000';
      if (_self.display_format == 'bare_player') {
        bgcolor = '#000000'
      } else {
        bocolor = '#f0f0f0';
      }
      _self.jq('<div id="_sp_content" style="display: none; position: absolute; top: '+_self._getTop()+'px; left: '+_self._getLeft()+'px; width: '+_self._getWidth()+'px; height: '+_self._getHeight()+'px; padding: 0px; border: 8px solid '+bocolor+'; background-color: '+bgcolor+'; z-index:1002; border-radius: 10px; -moz-border-radius: 10px;"><div id="_sp_main_content"></div></div>').appendTo('body');
      var _fade_style = 'display: none; position: absolute; top: 0%; left: 0%; width: 100%; height: 100%; background-color: white; z-index:1001; -moz-opacity: 0; opacity:0.0; filter: alpha(opacity=0);';
      if (_self.greyout=='true' || _self.greyout == true) {
        _fade_style = 'display: none; position: absolute; top: 0%; left: 0%; width: 100%; height: 100%; background-color: black; z-index:1001; -moz-opacity: 0.5; opacity:0.5; filter: alpha(opacity=50);width:100%';
      }
      _self.jq('<div id="_sp_fade" style="'+_fade_style+'"></div>').appendTo('body');
    }
  }
  this._getLeft = function() {
    var _left = (_self._getWindowWidth()/2 - _self._getWidth()/2);
    if (_left<0) _left = 10;
    return _left;
  }; // _getLeft

  this._getTop = function() {
    var _top = (_self._getWindowHeight()/2 - _self._getHeight()/2);
    if (_top<0) _top = 10;
    return _top;
  }; // _getTop

  this._getWidth = function() {
    return (parseInt(_self.width) + parseInt(_self._extra_width));
  }; // _getWidth

  this._getHeight = function() {
    return (parseInt(_self.height) + parseInt(_self._extra_height));
  }; // _getHeight

  this._getWindowWidth = function() {
    if (typeof window.innerWidth!='undefined' && window.innerWidth>0) return window.innerWidth;
    return document.documentElement.clientWidth;
  }; // _getWindowWidth

  this._getWindowHeight = function() {
    if (typeof window.innerHeight!='undefined' && window.innerHeight>0) return window.innerHeight;
    return document.documentElement.clientHeight;
  }; // _getWindowHeight

  // check & set display formats
  this._checkDisplayFormat = function() {
    if(_self.display_format == 'bare_player') {
      _self._extra_width = 0;
      _self._extra_height = 0;
      _self._sp_branding = false;
      _self._display_reward = false;
      _self._display_instructions = false;
      return true;
    }
    if (_self.display_format == 'player_and_reward') {
      _self._extra_width = 76;
      _self._extra_height = 76; //46
      _self._sp_branding = false;
      _self._display_reward = true;
      _self._display_instructions = false;
      return true;
    }
    return false;
  }; // _checkDisplayFormat

  // close overlay
  this._close_overlay = function() {
    if (_self._overlay === true) {
      // send 'cancel playing' event
      pm({
        target: window.frames['_sp_wiframe'],
        type: 'sponsorpay_video',
        url: _self._source_url,
        data: {'action':true},
        error: function(data) {
          //alert('pm error '+JSON.stringify(data));
        },
        success: function(data) {
          //_self.jq('#_sp_main_content').html('');
          //_self.jq('#_sp_wiframe').remove();
        }
      });
      // remove iframe
      //_self.jq('#_sp_wiframe').remove();
      _self.jq('#_sp_content').hide();
      _self.jq('#_sp_fade').hide();

      if (this.callback_on_close != null && typeof this.callback_on_close == 'function') {
        _self.callback_on_close.call();
      }
    }
  }; // _close_overlay

  this._is_active = function() {
    var max_amount = parseInt(this.max_views);
    if( (SPUtils.getCookie(this, 'num_times_shown', 0, true) < max_amount) || max_amount == 0 ) {
      return true;
    } else {
      return false;
    }
  }; // is_active

  this._round_robin = function() {
    SPUtils.setCookie(_self, 'offers_offset', _self.myoffset + 1);
  }; // round_robin

  this._prepare_offer = function(offers) {
    /**
    if( offers.length == 0 ) {
      console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );
      _self._render_no_offers_fallback();       // no offers
      return false;
    }
    if( _self.timeout ) clearTimeout( _self.timeout );
    **/
    offers['offers'] = _self._removeBlacklisted(offers['offers']);

    _self._set_information(offers['information']);

    if( offers['offers'].length == 0 ) {
      if (SPONSORPAY.debug(this)) console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );

      clearTimeout( _self.timeout );
      if (_self.myoffset != 0) {
        _self._doInit(_self._extra_params); // Round Robin
      } else {
        _self._render_no_offers_fallback();
      }
      return false;
    }

    _self._set_ab_test(offers['information'].ab_test_result);

    // set prepared
    _self._offers = offers['offers'];
    _self._prepared = true;

    if (_self.enable_regular_offers == 'true') {
      // if this callback exists, call it
      if (this.callback_on_start != null && typeof this.callback_on_start == 'function') {
        _self.callback_on_start.call();
      }
    } else {
      if (_self._offers[0].video == true) {
        if (this.callback_on_start != null && typeof this.callback_on_start == 'function') {
          _self.callback_on_start.call();
        }
      } else {
        if (this.callback_no_offers != null && typeof this.callback_no_offers == 'function') {
          _self.callback_no_offers.call();
         return false;
        }
      }
    }

    // render first offer available && !overlay
    if (_self._autostart == true) {
      // render offer when NO overlay
      _self.showVideo();
    }

  }; // prepare_offer

  /**
    flags = SP:F;DI:T;DR:F means sp_branding (false), display_instruction (true), display_reward (false)
  **/
  this._return_render_flags = function() {
    var _flags = [];
    if (_self._sp_branding === false) {    // no sp logo
      _flags.push('SP:F');
    }
    if (_self._sp_branding === null) {     // sp logo
      _flags.push('SP:T');
    }
    if (_self._sp_branding != null && _self._sp_branding != false && _self._sp_branding.match(/^http[s]?:\/\//i) != null) { // custom logo
      _flags.push('SP:C');
      _flags.push('URL:'+_self._sp_branding);
    }
    _flags.push('DI:'+((_self._display_instructions === true )?'T':'F'));
    _flags.push('DR:'+((_self._display_reward === true)?'T':'F'));
    return encodeURIComponent(_flags.join(';'));
  }; // _return_render_flags

  this._render_no_offers_fallback = function() {
    clearTimeout(_self.timeout);

    //SPUtils.trackView(this, null);

    // when callback is defined, run that callback
    if (this.callback_no_offers != null && typeof this.callback_no_offers == 'function') {
        _self.callback_no_offers.call();
        return false;
    }

    if (_self._overlay == true) { return false; }

    var src = window.location.protocol + '//'+_self.api_host+'/XX/'+_self.appid+'/video_none'
    var border_width = 8;

    var style = ";border: 8px solid #f0f0f0;"
    _self._source_url = src;
    var content = '<iframe id="_sp_wiframe" name="_sp_wiframe" src="' + src + '" scrollbar="no" scrolling="no" frameborder="0" width="' + (_self.width-2*border_width)+ '" height="' + (_self.height-2*border_width) + '" style="overflow:hidden'+style+'"></iframe>';
    _self.jq('#' + _self.where).html(content);
    return false;
  }; // _render_no_offers_fallback

  this._render_fallback = function() {
    // when timeout or other error
    if (this.callback_no_offers != null && typeof this.callback_no_offers == 'function') {
        _self.callback_no_offers.call();
    }
    return true;
  }; // _render_fallback

  this._render_offer = function(offer) {
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1);

    this._round_robin();
    var offer_url = offer.url.replace(/^https?:/, window.location.protocol);
    var src = offer_url + '?integration=' + _self.integration + '&width=' + _self._getWidth() + '&height=' + _self._getHeight() + '&show=' + _self._return_render_flags()+'&display_format='+_self.display_format+'&next_offer='+_self._next_offer+'&continue_button='+_self._continue_button_ids;
    var style = '';
    var border_width = 0;
    var transparent = 'allowtransparency="true"';
    if (_self.display_format!='bare_player' && _self._overlay==false && offer.video == true) {
      style = ";border: 8px solid #f0f0f0; border-radius: 10px;"
      border_width = 16;
    }
    _self._source_url = src;
    // when overlay, overlay width = offer.width
    // when dedicated, element width > offer.width
    if (offer.video == true) {
      offer.width = parseInt(offer.width);
      offer.height = parseInt(offer.height);
    } else {
      offer.width = 400;
      offer.height = 330;
    }
    if (_self._overlay) {
      var width_was = _self.width;
      var height_was = _self.height;
      var _left = 0;
      var _top = 0;
      if (offer.video == true) {
        _self.width = parseInt(offer.width);
        _self.height = parseInt(offer.height);
      } else {
        _self.width = 400;
        _self.height = 330;
      }
    } else {

      var _left = (parseInt(_self.width)/2-(parseInt(offer.width)+_self._extra_width+border_width)/2);
      var _top = (parseInt(_self.height)/2-(parseInt(offer.height)+_self._extra_height+border_width)/2);
    }

    var x_close = _self._x_close();

    var content = '<div id="_sp_center" style="text-align:left;width:'+_self._getWidth()+'px;height:'+_self._getHeight()+'px;">' + x_close;
    // only for video
    if (offer.video == true) {
      content += '<iframe id="_sp_wiframe" name="_sp_wiframe" src="' + src + '" scrollbar="no" scrolling="no" frameborder="0" width="' + (parseInt(offer.width)+parseInt(_self._extra_width)) + '" height="' + (parseInt(offer.height)+parseInt(_self._extra_height)) + '" style="position:relative;top:'+_top+'px;left:'+_left+'px;overflow:hidden'+style+'"'+transparent+'></iframe>';
    } else {
      // regular offer content
      content += '<div class="_sp_wrapper" style="position:relative;top:'+_top+'px;left:'+_left+'px;overflow:hidden;width:'+ (offer.width + _self._extra_width - 42) +'px;height:'+ (offer.height + _self._extra_height - 42) +'px;" >';
      // player_and_reward
      if (_self.display_format=='player_and_reward') {
        content += '<h3>'+offer.widget_title+'</h3>';
      }
      content += '<h1>'+offer.title+'</h1>';
      if (offer.brand_banner != '') {
        content+= '<div class="logo"><img src="'+offer.brand_banner+'"/></div>';
      }
      content += '<p>'+offer.teaser+'</p><div class="coins"><a href="'+offer.url+'">'+offer.widget_earn+'</a></div>';

      if (_self._next_offer) {
        content += '<div class="_sp_next_offer">';
        if (_self._next_offer != 'none') {
          content += '<a href="#">';
          content += _self._next_offer == 'video' ? _self._t_next_video : _self._t_next_offer;
          content += '</a>';
        } else {
          content += _self._t_no_offer;
        }
        content += '</div>';
      }

      content += '</div>'; // _sp_wrapper
    }
    content += '</div>';
    if (_self._overlay) {
      // try to create overlay if not existing
      _self._prepare_overlay();

      _self.jq('#_sp_content').css('top', _self._getTop()+'px');

      // use vertical_offset if provided
      var top = _self.vertical_offset ? Math.max(parseInt(_self.vertical_offset), 0) : _self._getTop();
      _self.jq('#_sp_content').css('top', top+'px');

      _self.jq('#_sp_content').css('left', _self._getLeft()+'px');
      _self.jq('#_sp_content').css('width', _self._getWidth()+'px');
      _self.jq('#_sp_content').css('height', _self._getHeight()+'px');
      _self.jq('#_sp_main_content').html(content);
      _self.jq('#_sp_fade').show();
      _self.jq('#_sp_content').show();

      _self.jq('#_sp_fade').unbind('click');
      _self.jq('#_sp_x').unbind('click');

      _self.jq('#_sp_fade').click(function() {_self._close_overlay()});
      _self.jq('#_sp_x').click(function() {_self._close_overlay()});

      _self.width = width_was;
      _self.height = height_was;
    } else {
      _self.jq('#' + this.where).html(content);
    }
  }; // render_offer

  this._x_close= function() {
    if (_self._overlay) {
      var x_type = _self._display_reward ? 'light' : 'dark';
      var x_style = "background: url('" + window.location.protocol + "//" + this.asset_host + "/images/video/x-close-" + x_type + ".png" + "') no-repeat 0 0";
      return '<div id="_sp_x" style="position: absolute; right: -18px; top: -18px; width: 21px; height: 21px; cursor: pointer;' + x_style + ';"></div>';
    }
    return "";
  }; // _close_x

  // set some params to html element
  this._prepare_html_element = function() {
    _self.jq('#' + _self.where).css('width',_self.width+'px').css('height', _self.height+'px');
  }; // _prepare_html_element

  this._show_next_offer = function() {
    _self._offers.shift(); // remove first offer
    if (_self.timeout) clearTimeout(_self.timeout);
    _self.showVideo();
  }

}
// }}}

// TOPBAR +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// {{{ SPONSORPAY.Widget.Bar
SPONSORPAY.Widget.Bar = function(options) {

  var _self = this;

  // constants
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      = window.location.protocol + '//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.4.4';
  this.SP_FALLBACK_MS     = 5000; // 5sec
  this.PUB_PARAMS         = 10;
  this.MINIMUM_ROTATION   = 15000; // 10sec
  this.OFFERS_NUM         = 10;


  this.jq       = null;
  this.timeout  = null;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host               = 'iframe.sponsorpay.com';
  this.asset_host             = 'asset1.sponsorpay.com';
  this.environment            = 'production';
  this.integration            = 'bar';
  this.cookie_expiration      = 14; // days
  this.myoffset               = null;
  this.max_views              = 0;    // times
  this.ps_time                = null; // user creation_date

  // bar options
  this.bg_color               = '#FFEEBB';
  this.text_color             = '#000000';
  this.link_color             = '#1B73C4';
  this.animation_duration     = 1000; // ms
  this.bar_height             = 30;   // pixels

  // automatic rotation
  this.rotation_duration      = null; // ms
  this.rotation               = false;
  this.rotation_timeout       = null;
  this.offers_bunch           = null;
  this.rotation_long_timeout  = null;

  this.ab_test                = null;

  this.er                     = null;
  this.currency               = null;
  this.digest                 = null;
  this.ts                     = null;
  this.debug                  = false;

  // internal
  this._tracked               = []; // tracked offer views

  this.country                = null;
  this.language               = null;

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }

  // Starting point ***************************************
  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') ) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }

    // minumum timeout is 10 seconds
    if ( (this.rotation_duration != null) && (this.rotation_duration < this.MINIMUM_ROTATION) ) {
      this.rotation_duration = this.MINIMUM_ROTATION;
    }
    SPUtils.loadJQueryAndInit(this, this.init);
  };

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'Not ie6 support' );
      return false;
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'SponsorPay Bar is not active' );
      return false;
    }

    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
        SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS), this.OFFERS_NUM );
      });
    } else {
      this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
      SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS), this.OFFERS_NUM );
    }

  }; // initialize

  // Private methods ***************************************
  this._set_ab_test = function(ab_test_value) {
    this.ab_test = ab_test_value;
  };

  this._set_country_and_language = function(country, language) {
    this.country = country;
    this.language = language;
  };

  this._is_active = function() {
    var max_amount = parseInt(this.max_views);
    if( (SPUtils.getCookie(this, 'num_times_shown', 0, true) < max_amount) || max_amount == 0 ) {
      return true;
    } else {
      return false;
    }
  }; // is_active

  this._render_fallback = function() {
    SPUtils.trackView(this, null);
    return true;
  }; // _render_fallback

  this._round_robin = function() {
    SPUtils.setCookie(this, 'offers_offset', _self.myoffset + 1);
    _self.myoffset = SPUtils.getCookie(_self, 'offers_offset', 0, true);
  }; // round_robin

  this._prepare_offer = function(offers) {
    _self.offers_bunch = offers;

    _self._set_country_and_language(offers['information'].country, offers['information'].language);

    if( _self.offers_bunch['offers'].length == 0 ) {
      if (SPONSORPAY.debug(this)) console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );

      if( _self.timeout ) clearTimeout( _self.timeout );
      _self._render_fallback();
      return false;
    }

    if (_self.myoffset >= (_self.offers_bunch['offers'].length - 1)) {
      SPUtils.setCookie( _self, "offers_offset", 0 );
      _self.myoffset = SPUtils.getCookie(_self, 'offers_offset', 0, true);
      _self.rotation = false;
      //_self.init(); // Round Robin
    } else {
      /*
      SPUtils.setCookie(_self, 'offers_offset', _self.myoffset + 1);
      _self.myoffset = SPUtils.getCookie(_self, 'offers_offset', 0, true);
      */
    }

    if( _self.timeout ) clearTimeout( _self.timeout );

    this._set_ab_test(offers['information'].ab_test_result);

    SPUtils.loadCSSFile(window.location.protocol + '//' + _self.asset_host + '/stylesheets/' + _self.integration + '/v1/default.css');

    _self._render_offer(_self.offers_bunch['offers'][_self.myoffset]);
    _self._trackOfferView();
    this._round_robin();
  }; // prepare_offer

  // track view offer
  this._trackOfferView = function() {
    // track only not tracked
    var _offer_id = _self.offers_bunch['offers'][_self.myoffset].id;
    if (this.jq.inArray(_offer_id, _self._tracked) == -1) {
      _self._tracked.push(_offer_id);
      SPUtils.trackView(this, _self.offers_bunch['offers'][_self.myoffset]);
    }
  }; // prepare_offer

  this._render_offer = function(offer) {
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1);

    if (this.rotation || (this.jq('#sponsorpay-bar').length > 0) ) {

      if( _self.rotation_timeout ) clearTimeout( _self.rotation_timeout );
      this.jq('#sponsorpay-bar .sponsorpay-offer').fadeOut('slow');
      this.jq('#sponsorpay-bar').html(this._create_html_offer(offer));
      this._adjust_offer(false);
      this.jq('#sponsorpay-bar .sponsorpay-offer').fadeIn('slow');

    } else {
      var content = "<div id='sponsorpay-bar' style='position: absolute; top: -30px; left: 0; width: " + this.jq(window).width() + "px; background-color: " + this.bg_color + "; height: " + this.bar_height + "px;'>" + this._create_html_offer(offer) + "</div>";

      if (this.jq('#sponsorpay-bar').length <= 0 ) {
        this.jq('body').find(':first').before(content);
      }

      this._adjust_offer();
    }

    if ( (_self.rotation_duration != null)) {
      clearTimeout( _self.rotation_timeout );
      _self._start_rotating();
    }

  }; // render_offer

  // resize offer bar
  this.resize_offer = function(offers) {
    _self.jq('#sponsorpay-bar').css('width', _self.jq(window).width());
  }

  this._adjust_offer = function(enable_animation, user_click) {
    enable_animation = typeof(enable_animation) != 'undefined' ? enable_animation : true;
    user_click       = typeof(user_click)       != 'undefined' ? user_click : false;

    _self.jq('#sponsorpay-bar').css( 'cursor', 'pointer' );

    _self.jq('#sponsorpay-bar .sponsorpay-offer .sponsorpay-bar-ul .sponsorpay-header, #sponsorpay-bar .sponsorpay-offer .sponsorpay-bar-ul .sponsorpay-desc, #sponsorpay-bar .sponsorpay-offer .sponsorpay-bar-ul .sponsorpay-coins').click( function(){
      window.open( jQuery('#sponsorpay-bar .sponsorpay-offer .sponsorpay-bar-ul .sponsorpay-coins a').attr('href') );

      // request the next offer and render it
      if( _self.rotation_timeout ) clearTimeout( _self.rotation_timeout );
      _self._prepare_offer(_self.offers_bunch);
      return false;
    });

    // Centering
    _self.jq("#sponsorpay-bar .sponsorpay-closeme").css('top', (_self.jq("#sponsorpay-bar .sponsorpay-closeme").parent().height() - _self.jq("#sponsorpay-bar .sponsorpay-closeme").height()) / 2 + 'px');

    if (enable_animation) {
      _self._animate_bar();
    }

    // handle browser resize
    _self.jq(window).bind('resize', _self.resize_offer);

    _self._closeme_button();
    _self._show_support_link();

  }; // _adjust_offer

  this._animate_bar = function() {
    this.jq("body").animate({ marginTop: parseInt(this.bar_height) + parseInt(this.jq("body").css('margin-top').replace("px", "")) + 'px' }, parseInt(this.animation_duration) );
    this.jq("#sponsorpay-bar").animate({ top: '0' }, parseInt(this.animation_duration) );
  }

  this._closeme_button = function() {
    //close
    _self.jq('#sponsorpay-bar .sponsorpay-closeme').click( function(){
      _self.jq("#sponsorpay-bar").animate({ top: -1 * parseInt(_self.bar_height) + 'px' }, parseInt(_self.animation_duration) );
      _self.jq("body").animate({ marginTop: -1 * parseInt(_self.bar_height) + parseInt(_self.jq("body").css('margin-top').replace("px", "")) + 'px' }, parseInt(_self.animation_duration) );
      _self.jq(window).unbind('resize', _self.resize_offer);
      _self.rotation = false;

      if( _self.rotation_timeout ) clearTimeout( _self.rotation_timeout );

      return false;
    });
  };

  this._show_support_link = function() {
    var additional_params = SPUtils.additional_params(_self);
    var content = "\
      <div class='support-link'  style='background-color: " + _self.bg_color + ";'>\
        <a href='" + window.location.protocol + "//" + _self.api_host + '/support?appid=' + _self.appid + '&uid=' + _self.uid + additional_params +"' target='_blank'>\
          <span class='icon' style='border-color: " + _self.text_color + "'>\
           <span class='dot' style='background-color: " + _self.text_color + "'></span>\
           <span class='stroke' style='background-color: " + _self.text_color + "'></span>\
         </span>\
         <span class='hover' style='background-color: " + _self.bg_color + "; color: " + _self.text_color + "; border: 1px solid " + _self.text_color +"'>Support</span>\
       </a>\
     </div>";

    _self.jq('#sponsorpay-bar').prepend(content);
  }

  this._create_html_offer = function(offer) {
    var content = " \
        <div class='sponsorpay-offer' style='color: " + _self.text_color + ";'>\
          <table class='sponsorpay-bar-ul'>\
            <tr>\
              <td class='sponsorpay-header'><span class='sponsorpay-space'>&nbsp;</span>" + offer.widget_short_title + "</td> \
              <td class='sponsorpay-desc'><span class='sponsorpay-space'>&nbsp;</span>" + offer.widget_short_teaser + "</td> \
              <td class='sponsorpay-coins'><span class='sponsorpay-space'>&nbsp;</span><a href='" + offer.url + "' target='_blank' class='offer-linkto popupize-me' style='color: " + _self.link_color + ";'>" + offer.widget_title + "</a></td>\
              <td class='sponsorpay-closeme'><a href='#' style='color: " + _self.text_color + ";'>X</a></td> \
            </tr> \
          </table> \
        </div>";

    return content;
  }

  this._start_rotating = function() {

    _self.rotation = true;
    if( _self.rotation_timeout ) clearTimeout( _self.rotation_timeout );

    _self.rotation_timeout = setTimeout( function() {
      _self._prepare_offer(_self.offers_bunch);
    }, _self.rotation_duration );

  }


}
// }}} Bar

// BANNER +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// {{{ SPONSORPAY.Widget.Banner
SPONSORPAY.Widget.Banner = function(options) {

  var _self = this;

  // constants
  this.SP_RANKED_OFFERS   =  10;
  this.SP_FALLBACK_MS     =  5000; // 5sec
  this.PUB_PARAMS         =  10; // pub0..pub9
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      =  window.location.protocol + '//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.4.4';
  this.SP_BANNER_SHAPES   = { "square"            :   {   w: 250, h: 250  },
                              "medium_rectangle"  :   {   w: 300, h: 250  },
                              "leaderboard"       :   {   w: 728, h: 90   },
                              "wide_skyscraper"   :   {   w: 160, h: 600  },
                              "standard"          :   {   w: 468, h: 60   },
                              "canvas"            :   {   w: 760, h: 90   },
                              "skyscraper"        :   {   w: 120, h: 600  }}

  this.jq       = null;
  this.timeout  = null;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host           = 'iframe.sponsorpay.com';
  this.asset_host         = 'asset1.sponsorpay.com';
  this.skin_host          = 'offerwall.s3.amazonaws.com'
  this.environment        = 'production';
  this.integration        = 'banner';
  this.cookie_expiration  = 14; // days
  this.myoffset           = null;
  this.ps_time            = null; // user creation_date

  // banner options
  this.shape        = 'standard';
  this.where        = null;
  this.skin         = 'default';
  this.loading      = 'sponsorpay';
  this.fallback_url = window.location.protocol + '//iframe.sponsorpay.com/iframe';
  this.fallback     = null;
  this.background   = null;

  this.ab_test       = null;

  this.er           = null;
  this.currency     = null;
  this.digest       = null;
  this.ts           = null;

  this.country      = null;
  this.language     = null;
  this.debug        = false;

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }

  // Starting point ***************************************
  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') ) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }
    SPUtils.loadJQueryAndInit(this, this.init);
  }

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'Not ie6 support' );
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'Widget is not active' );
      return false;
    }
    this._render_loading();

    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
        SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, this.jq.extend( { allow_campaign: 'on' },  SPUtils.pub_literals(this, this.PUB_PARAMS) ) );
      });
    } else {
      this.myoffset = SPUtils.getCookie(this, 'offers_offset', 0, true);
      SPUtils.loadOffer( this, this._prepare_offer, this._render_fallback, this.jq.extend( { allow_campaign: 'on' },  SPUtils.pub_literals(this, this.PUB_PARAMS) ) );
    }
  }; // initialize

  // Private methods ***************************************
  this._is_active = function() {
    return true;
  }; // is_active

  this._is_campaign = function(offer) {
    return offer.campaign && offer.campaign_img_url;
  }; // is_campaign

  this._render_loading = function() {
    var content = " \
        <div class='sponsorpay-banner' style='background-color: #ffffff; width: " + this.SP_BANNER_SHAPES[this.shape].w + "px; height: " + this.SP_BANNER_SHAPES[this.shape].h + "px; text-align: center; position: relative;'> \
          <div class='sponsorpay-loader' style='position: absolute; top: " + ((this.SP_BANNER_SHAPES[this.shape].h / 2) - 24) + "px; left: " + ((this.SP_BANNER_SHAPES[this.shape].w / 2) - 24) +"px;'> \
            <img src='" + window.location.protocol + "//" + this.asset_host + "/images/" + this.integration + "/v1/fallbacks/ajax-loader.gif' border='none' /> \
          </div> \
        </div>"

      this.jq("#" + this.where).html(content);
  }; // render_loading

  this._fallback_url_with_params = function() {
    var pubs = SPUtils.pub_literals(this, this.PUB_PARAMS);
    var pubs_params = '';
    for (var pub in pubs) {
      pubs_params = pubs_params + '&'+pub+'='+pubs[pub];
    }
    var additional_params = SPUtils.additional_params(_self);
    return this.fallback_url+'?uid='+this.uid+'&appid='+this.appid+'&more_offers=on&integration='+_self.integration+pubs_params+additional_params;
  };

  this._render_fallback = function() {
    if (_self.fallback == null) {
      _self.fallback = window.location.protocol + "//" + _self.asset_host + "/images/" + _self.integration + "/v1/fallbacks/" + _self.shape +".png";
    }
    // FIXME: position relative
    var content = " \
      <div class='sponsorpay-banner' style='background-color: #ffffff; width: " + _self.SP_BANNER_SHAPES[_self.shape].w + "px; height: " + _self.SP_BANNER_SHAPES[_self.shape].h + "px; text-align: center; position: relative;'> \
        <a href='" + _self._fallback_url_with_params() + "' target='_blank'> \
          <img src='" + _self.fallback + "' border='none' /> \
        </a> \
      </div>"

      _self.jq("#" + _self.where).html(content);
      _self._add_support_link();
  }; // render_fallback

  this._prepare_offer = function(offers) {

    _self._set_country_and_language(offers['information'].country, offers['information'].language);
    _self._t_more_offers = offers['information'].more_offers;

    if( offers['offers'].length == 0 ) {
      if (SPONSORPAY.debug(this)) console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );

      if (_self.myoffset != 0) {
        clearTimeout( _self.timeout );
        _self.init(); // Round Robin
      } else {
        _self._render_fallback();
        SPUtils.trackView(this, null);
      }
      return false;
    }

    if( _self.timeout ) clearTimeout( _self.timeout );

    this._set_ab_test(offers['information'].ab_test_result);

    SPUtils.loadCSSFile(window.location.protocol + '//' + _self.skin_host + '/banner_skins/common/style.css');
    SPUtils.loadCSSFile(window.location.protocol + '//' + _self.skin_host + '/banner_skins/' + _self.skin + '/style.css');

    SPUtils.loadCustomCSS(_self);

    _self._render_offer(offers['offers'][0]);

    SPUtils.popupizeLinks(_self, _self.jq('.sponsorpay-banner.facebook a.popupize-me'), 478, 220);
    SPUtils.popupizeLinks(_self, _self.jq('.sponsorpay-banner.video a.popupize-me'), 550, 640);

    // Replace Background with custom one
    if (_self.background) {
      SPUtils.loadCustomBkg(_self, ".sponsorpay-banner-" + _self.skin + "." + _self.shape );
    }

    SPUtils.trackView(this, offers['offers'][0]);
    //SPUtils.preloadImages( sp_object, sp_object.jq("#sponsorpay-widget img"), null, 5000 );
  }; // prepare_offer

  this._set_ab_test = function(ab_test_value) {
    this.ab_test = ab_test_value;
  };

  this._set_country_and_language = function(country, language) {
    this.country = country;
    this.language = language;
  };

  this._round_robin = function() {
    if (this.myoffset >= (this.SP_RANKED_OFFERS - 1)) {
      next_offset = 0;
    } else {
      next_offset = this.myoffset + 1;
    }

    SPUtils.setCookie(this, 'offers_offset', next_offset);
  }; // round_robin

  this._render_offer = function(offer) {
    if (this._is_campaign(offer)) {
      this._render_campaign_offer(offer);
    } else {
      this._render_standard_offer(offer);
    }
  }; // render_offer

  this._render_standard_offer = function(offer) {
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1);

    this._round_robin();

    var classes =
      (offer.free ? 'free ' : '') +
      (offer.quick ? 'quick ' : '') +
      (offer.video ? 'video ' : '') +
      (offer.facebook ? 'facebook ' : '') +
      (offer.variable_payout ? 'variable_payout ' : '');

    var content = " \
      <div class='sponsorpay-banner sponsorpay-banner-" + this.skin + ' ' + this.shape + ' ' + classes + "'> \
        <div class='offer'> \
          <div class='header'>" + offer.widget_short_title + "</div> \
          <div class='main'> \
            <div class='desc'>" + offer.widget_short_teaser + "</div> \
          </div> \
          <div class='more-link'><a href='" + _self._fallback_url_with_params() + "' target='_blank'><div class='more-link-text'>" + _self._t_more_offers + "</div> <div class='right-arrow'></div><div style='clear: both'></div></a></div> \
          <div class='coins'><a href='" + offer.url + "' target='_blank' class='offer-linkto popupize-me'>" + offer.widget_title + "</a></div> \
        </div> \
      </div>"

    this.jq("#" + this.where).html(content);

    this._customize_banner_css(offer);
    this._add_support_link();

    _self.jq('.sponsorpay-banner .more-link').unbind('click').click(function() {
      window.open( jQuery('.sponsorpay-banner .more-link a').attr('href') );
      return false;
    });

  }; // render_standard_offer

  this._render_campaign_offer = function(offer) {
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1);

    classes =
      (offer.free ? 'free ' : '') +
      (offer.quick ? 'quick ' : '') +
      (offer.video ? 'video ' : '') +
      (offer.facebook ? 'facebook ' : '') +
      (offer.variable_payout ? 'variable_payout ' : '');

    var content = " \
      <div class='sponsorpay-banner sponsorpay-banner-" + this.skin + ' ' + this.shape + ' ' + classes + "'> \
        <a href='" + offer.url + "' target='_blank' class='popupize-me'> \
          <img src='" + offer.campaign_img_url + "' border='none' /> \
        </a> \
      </div>"

    this.jq("#" + this.where).html(content);
  }; // render_campaign_offer

  this._add_support_link = function() {
    var additional_params = SPUtils.additional_params(_self);
    var content = "\
      <div class='support-link'> \
        <a href='" + window.location.protocol + "//" + _self.api_host + '/support?appid=' + _self.appid + '&uid=' + _self.uid + additional_params +"' target='_blank'> \
          <span class='img'> \
            <img src='" + window.location.protocol + "//" + _self.skin_host + "/banner_skins/common/images/i.png' width='4' height='7' alt='I' title='support'></span><span class='hover'> \
            Support \
          </span> \
        </a> \
      </div>"

    _self.jq("#" + _self.where + ' .sponsorpay-banner .offer').append(content);

    _self.jq("#" + _self.where + ' .sponsorpay-banner .offer .support-link').unbind('click').click( function() {
      window.open( jQuery("#" + _self.where + ' .sponsorpay-banner .offer .support-link a').attr('href') );
      return false;
    });
  }; // _add_support_link


  this._customize_banner_css = function(offer) {
    this.jq("#" + this.where + " .sponsorpay-banner").css( 'cursor', 'pointer' );

    this.jq("#" + this.where + " .sponsorpay-banner").click(function() {
      //alert( jQuery('#' + this.where + ".sponsorpay-banner .offer .coins a.offer-linkto").attr('href')  );
      window.open( offer.url );
      return false;
    });

  }; // _customize_banner_css

}
// }}}

// OVERLAY +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// {{{ SPONSORPAY.Widget.Overlay
SPONSORPAY.Widget.Overlay = function(options) {

  var _self = this;

  // constants
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      = window.location.protocol + '//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.4.4';
  this.SP_FALLBACK_MS     = 5000; // 5sec
  this.PUB_PARAMS         = 10; // pub0..pub9

  this.jq           = null;
  this.timeout      = null;
  this.height       = 0;
  this.y_open       = 0;
  this.y_close      = 0;
  this.y_minimized  = 0;
  this.state        = 'open';
  this.countdown    = 0;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host           = 'iframe.sponsorpay.com';
  this.asset_host         = 'asset1.sponsorpay.com';
  this.environment        = 'production';
  this.integration        = 'overlay';

  // overlay options
  this.closing_countdown  = 0; // seconds
  this.closing_behavior   = 'minimize';
  this.animation_duration = 500; // ms
  this.skin               = 'default';
  this.max_views          = 0; // times
  this.cookie_expiration  = 14; // days
  this.background_color   = null;
  this.ps_time            = null; // user creation_date

  this.ab_test            = null;

  this.er                 = null;
  this.currency           = null;
  this.digest             = null;
  this.ts                 = null;

  this.country            = null;
  this.language           = null;
  this.debug              = false;

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }

  // Starting point ***************************************
  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') ) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }

    if( this.closing_countdown == 0 ) {
      this.minimize_counter = false;
    } else {
      this.minimize_counter = true;
    }

    SPUtils.loadJQueryAndInit(this, this.init);
  }; // start

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'Not ie6 support' );
      return false;
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'Widget is not active' );
      return false;
    }

    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        SPUtils.loadOffer(this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS) );
      });
    } else {
      SPUtils.loadOffer(this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS) );
    }
  }; // init

  // Private methods ***************************************
  this._set_ab_test = function(ab_test_value) {
    this.ab_test = ab_test_value;
  };

  this._set_country_and_language = function(country, language) {
    this.country = country;
    this.language = language;
  };

  this._is_active = function() {
    var max_amount = parseInt(this.max_views);
    if( (SPUtils.getCookie(this, 'num_times_shown', 0, true) < max_amount) || max_amount == 0 ) {
      return true;
    } else {
      return false;
    }
  }; // _is_active

  this._prepare_offer = function(offers) {

    _self._set_country_and_language(offers['information'].country, offers['information'].language);

    if( offers['offers'].length == 0 ) {
      if (SPONSORPAY.debug(this)) console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );
      return false;
    }

    if( _self.timeout ) clearTimeout( _self.timeout );

    this._set_ab_test(offers['information'].ab_test_result);

    SPUtils.loadCSSFile( window.location.protocol + '//' + _self.asset_host + '/stylesheets/widget/v1/skins/' + _self.skin + '.css');
    SPUtils.loadCustomCSS(_self);

    _self._render_offer(offers['offers'][0]);

    SPUtils.trackView(this, offers['offers'][0]);
    SPUtils.preloadImages( _self, _self.jq("#sponsorpay-widget img"), _self._after_preload_images, 5000 );
  }; // _prepare_offer

  this._render_fallback = function() {
    SPUtils.trackView(this, null);
    return true;
  }; // _render_fallback

  // prepend asset host if this image is not from remote server
  this._render_asset_image = function(image) {
    if (image.match(/^\//)!=null) {
      return window.location.protocol + '//'+_self.asset_host + image;
    }
    return image;
  }

  this._render_offer = function(offer) {
    classes =
      (offer.free ? 'free ' : '') +
      (offer.quick ? 'quick ' : '') +
      (offer.video ? 'video ' : '') +
      (offer.facebook ? 'facebook ' : '') +
      (offer.variable_payout ? 'variable_payout ' : '');

    // FIXME: INLINE STYLING
    var content = " \
      <div id='sponsorpay-widget' class='bottom " + classes + "' style='position: fixed; bottom: -400px'> \
        <div id='sp-header'> \
          <div id='title'>" + offer.widget_title + "</div> \
          <div id='close'><a href='#'>X</a></div> \
          <div id='open'><a href='#'>^</a></div> \
        </div> \
        <div id='sp-main'> \
          <div id='info'> \
            <div id='logo'> <img src='" + _self._render_asset_image(offer.brand_banner) + "' /> </div> \
            <div id='offer-title' class='description'>" + offer.title + "</div> \
            <div id='offer-teaser' class='description'>" + offer.teaser + "</div> \
            <div id='offer-required_actions' class='description'>" + offer.required_actions + "</div> \
            <div id='offer-link' class='description'><a href='" + offer.url + "' target='_blank'  class='offer-linkto popupize-me'>" + offer.widget_title + "</a></div> \
          </div> \
          <div id='countdown'>" + offer.widget_counter + "</div> \
        </div> \
      </div>"

    _self.jq('body').append(content);
  }; // _render_offer

  this._after_preload_images = function() {
    this._set_initial_position();
    this.countdown = this.closing_countdown;
    if( this.state == 'open' ) this._counter_tic();
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1) // after_preload_images

    SPUtils.setCookie(this, 'offers_offset', SPUtils.getCookie(this, 'offers_offset', 0, true) + 1);
  }; // _after_preload_images

  // counter for auto-hidding
  this._counter_tic = function(){
    if( !_self.minimize_counter ) return;
    _self.jq('#sponsorpay-widget #countdown span').html(_self.countdown);

    if( _self.countdown <= 0 ){
      _self._minimize();
    } else if( _self.state == 'open' ) {
      setTimeout( _self._counter_tic, 1000 );
      _self.countdown--;
    }
  }; // _counter_tic

  this._set_initial_position = function() {
    // remove the counter if not used
    if( !this.minimize_counter ) {
      this.jq('#sponsorpay-widget #countdown').hide();
    }

    // initial position
    this.state = 'closed';
    this.jq('#sponsorpay-widget').css('bottom', this._bottom_coordinate() + 'px' );

    // open it with animation
    this.state = 'open';
    this.jq('#sponsorpay-widget').animate({ bottom: this._bottom_coordinate() + 'px' }, this.animation_duration);
    this.jq('#sponsorpay-widget #close').show();
    this.jq('#sponsorpay-widget #open').hide();

    // cursors in active zones
    this.jq('#sponsorpay-widget #sp-header').css( 'cursor', 'pointer' );
    this.jq('#sponsorpay-widget #sp-main').css( 'cursor', 'pointer' );

    // onclicks in active zones
    this._title_bar_behavior( this._minimize );

    this.jq('#sponsorpay-widget #sp-main').click( function(){
      window.open( jQuery('#sponsorpay-widget #offer-link a').attr('href') );
      return false;
    });

    // Popupize links
    SPUtils.popupizeLinks(_self, _self.jq('#sponsorpay-widget.facebook a.popupize-me'), 478, 220);
    SPUtils.popupizeLinks(_self, _self.jq('#sponsorpay-widget.video a.popupize-me'), 550, 640);

    // Popupize the whole widget
    _self.jq('#sponsorpay-widget.facebook #sp-main, #sponsorpay-widget.video #sp-main').unbind('click').click( function() {
      jQuery('#sponsorpay-widget a.popupize-me').click();
      return false;
    });

    this.jq('#sponsorpay-widget #close').click( function(){
      this._user_closes();
      return false;
    });

    var additional_params = SPUtils.additional_params(_self);
    var content = "\
      <div class='support-link'> \
        <a href='" + window.location.protocol + "//" + _self.api_host + '/support?appid=' + _self.appid + '&uid=' + _self.uid + additional_params +"'>\
        <span class='icon'>\
          <img src='" + window.location.protocol + "//" + _self.asset_host + "/images/support-i.png' alt='I' width='4' height='7' title='support' />\
        </span>\
        <span class='hover'>Support</span>\
      </a>\
    </div>"

     this.jq('#sponsorpay-widget').prepend(content);

     this.jq('#sponsorpay-widget .support-link a').click( function(){
       window.open( jQuery('#sponsorpay-widget .support-link a').attr('href') );
       return false;
     });

  }; // _set_initial_position

  // what to do when the title bar is clicked
  this._title_bar_behavior = function( behavior ){
    this.jq('#sponsorpay-widget #sp-header').unbind('click').click(behavior);
  }; // _title_bar_behavior

  // what to do when user ask to close the widget
   this._user_closes = function(){
    if( this.closing_behavior == 'close' ) {
      this._close();
    } else {
      this._minimize();
    }
  }; // _user_closes

  // what to do when user ask to open the widget
  this._user_opens = function(){
    // remove the counter
    _self.minimize_counter = false;
    _self.jq('#sponsorpay-widget #countdown').html( '&nbsp;' ); // using hide() makes the widget jump

    // show the widget
    _self._show();
  }; // _user_opens

  // show the widget
  this._show = function(){
    this.state = 'open';
    this.jq('#sponsorpay-widget').animate({ bottom: this._bottom_coordinate() }, this.animation_duration);
    this.jq('#sponsorpay-widget #close').show();
    this.jq('#sponsorpay-widget #open').hide();
    this.countdown = this.closing_countdown;
    this._counter_tic();
    this._title_bar_behavior( this._minimize );
  }; // _show

  // close the widget
  this._close = function(){
    _self.state = 'closed';
    _self.jq('#sponsorpay-widget').animate({ bottom: _self._bottom_coordinate() + 'px' }, (_self.animation_duration / 2));
    _self._title_bar_behavior( _self._user_opens );
  }; // _close

  // minimize the widget
  this._minimize = function(){
    _self.state = 'minimized';
    _self.jq('#sponsorpay-widget').animate({ bottom: _self._bottom_coordinate() + 'px' }, (_self.animation_duration / 2));
    _self.jq('#sponsorpay-widget #close').hide();
    _self.jq('#sponsorpay-widget #open').show();
    _self._title_bar_behavior( _self._user_opens );
  }; // _minimize

  this._bottom_coordinate = function( state ){
    if( typeof state == 'undefined' ) state = this.state

    this.height = parseInt( this.jq('#sponsorpay-widget.bottom').css('height').replace('px','') );

    switch( state ) {
      case 'minimized'  : return (-1 * (this.height - 27)); break;
      case 'closed'     : return (-1 * (this.height + 20)); break;
      case 'open'       : return 10; break;
      default           : if (SPONSORPAY.debug(this)) console.warn( "not valid state for bottomCoordinate: " + state );
    }

    return 0;
  }; // _bottom_coordinate

}
// }}}

// RIGHT OVERLAY +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// {{{ SPONSORPAY.Widget.OverlayRight
SPONSORPAY.Widget.OverlayRight = function(options) {

  var _self = this;

  // constants
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      = window.location.protocol + '//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.4.4';
  this.SP_FALLBACK_MS     = 5000; // 5sec
  this.PUB_PARAMS         = 10; // pub0..pub9

  this.jq           = null;
  this.timeout      = null;
  this.height       = 0;
  this.y_open       = 0;
  this.y_close      = 0;
  this.y_minimized  = 0;
  this.state        = 'open';
  this.countdown    = 0;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host           = 'iframe.sponsorpay.com';
  this.asset_host         = 'asset1.sponsorpay.com';
  this.environment        = 'production';
  this.integration        = 'overlay';

  // overlay options
  this.closing_countdown  = 0; // seconds
  this.closing_behavior   = 'minimize';
  this.animation_duration = 500; // ms
  this.skin               = 'default';
  this.max_views          = 0; // times
  this.max_views_per_day  = 0; // times
  this.cookie_expiration  = 14; // days
  this.background_color   = null;
  this.ps_time            = null; // user creation_date
  this.initial_state      = 'minimized'; // open

  this.ab_test            = null;

  this.er                 = null;
  this.currency           = null;
  this.digest             = null;
  this.ts                 = null;

  this.country            = null;
  this.language           = null;
  this.debug              = false;

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }

  // Starting point ***************************************
  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') ) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }

    if( this.closing_countdown == 0 ) {
      this.minimize_counter = false;
    } else {
      this.minimize_counter = true;
    }

    SPUtils.loadJQueryAndInit(this, this.init);
  }; // start

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'Not ie6 support' );
      return false;
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'Widget is not active' );
      return false;
    }

    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        SPUtils.loadOffer(this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS) );
      });
    } else {
      SPUtils.loadOffer(this, this._prepare_offer, this._render_fallback, SPUtils.pub_literals(this, this.PUB_PARAMS) );
    }
  }; // init

  // Private methods ***************************************
  this._set_ab_test = function(ab_test_value) {
    this.ab_test = ab_test_value;
  };

  this._set_country_and_language = function(country, language) {
    this.country = country;
    this.language = language;
  };

  this._is_active = function() {
    var max_amount       = parseInt(this.max_views);
    var max_amount_today = parseInt(this.max_views_per_day);

    if (SPUtils.viewsForToday(this) < max_amount_today || max_amount_today === 0) {
      SPUtils.increaseDailyViewCounterInCookie(this);

      if( (SPUtils.getCookie(this, 'num_times_shown', 0, true) < max_amount) || max_amount == 0 ) {
        return true;
      } else {
        return false;
      }
    }
    else {
      return false;
    }
  }; // _is_active

  this._prepare_offer = function(offers) {

    _self._set_country_and_language(offers['information'].country, offers['information'].language);

    if( offers['offers'].length == 0 ) {
      if (SPONSORPAY.debug(this)) console.warn( "offers empty" );
      SPUtils.setCookie( _self, "offers_offset", 0 );
      return false;
    }

    if( _self.timeout ) clearTimeout( _self.timeout );

    this._set_ab_test(offers['information'].ab_test_result);

    SPUtils.loadCSSFile( window.location.protocol + '//' + _self.asset_host + '/stylesheets/widget/v1/skins/' + _self.skin + '.css');
    SPUtils.loadCustomCSS(_self);

    _self._render_offer(offers['offers'][0]);

    SPUtils.trackView(this, offers['offers'][0]);
    SPUtils.preloadImages( _self, _self.jq("#sponsorpay-widget img"), _self._after_preload_images, 5000 );
  }; // _prepare_offer

  this._render_fallback = function() {
    return true;
  }; // _render_fallback

  // prepend asset host if this image is not from remote server
  this._render_asset_image = function(image) {
    if (image.match(/^\//)!=null) {
      return window.location.protocol + '//'+_self.asset_host + image;
    }
    return image;
  }

  this._render_offer = function(offer) {
    classes =
      (offer.free ? 'free ' : '') +
      (offer.quick ? 'quick ' : '') +
      (offer.video ? 'video ' : '') +
      (offer.facebook ? 'facebook ' : '') +
      (offer.variable_payout ? 'variable_payout ' : '');

    // aply differen top value only for IE
    var ieStyle = SPUtils.isIE() ? "style='left:4px; font-weight: normal'" : ""

    var content = " \
      <div id='sponsorpay-widget' class='right " + classes + "' style='position: fixed; display: none; right: -400px'> \
      <table border='0'><tr><td id='sp-header'> \
        <div> \
          <div id='title' " + ieStyle + ">" + offer.widget_title + "</div> \
          <div id='close'><a href='#'>X</a></div> \
          <div id='open'><a href='#'>^</a></div> \
        </div> \
      </td><td> \
        <div id='sp-main'> \
          <div id='info'> \
            <div id='logo'> <img src='" + _self._render_asset_image(offer.brand_banner) + "' /> </div> \
            <div id='offer-title' class='description'>" + offer.title + "</div> \
            <div id='offer-teaser' class='description'>" + offer.teaser + "</div> \
            <div id='offer-required_actions' class='description'>" + offer.required_actions + "</div> \
            <div id='offer-link' class='description'><a href='" + offer.url + "' target='_blank'  class='offer-linkto popupize-me'>" + offer.widget_title + "</a></div> \
          </div> \
          <div id='countdown'>" + offer.widget_counter + "</div> \
        </div> \
      </td></tr></table> \
      </div>"

    _self.jq('body').append(content);
  }; // _render_offer

  this._after_preload_images = function() {
    this._set_initial_position();
    this.countdown = this.closing_countdown;
    if( this.state == 'open' ) this._counter_tic();
    SPUtils.setCookie(this, 'num_times_shown', SPUtils.getCookie(this, 'num_times_shown', 0, true) + 1) // after_preload_images

    SPUtils.setCookie(this, 'offers_offset', SPUtils.getCookie(this, 'offers_offset', 0, true) + 1);
  }; // _after_preload_images

  // counter for auto-hidding
  this._counter_tic = function(){
    if( !_self.minimize_counter ) return;
    _self.jq('#sponsorpay-widget #countdown span').html(_self.countdown);

    if( _self.countdown <= 0 ){
      _self._minimize();
    } else if( _self.state == 'open' ) {
      setTimeout( _self._counter_tic, 1000 );
      _self.countdown--;
    }
  }; // _counter_tic

  this._set_initial_position = function() {
    // remove the counter if not used
    if( !this.minimize_counter ) {
      this.jq('#sponsorpay-widget #countdown').hide();
    }

    // initial position
    // when the initial position is open we
    // want the widget to slide from the 'closed'
    // position to the 'open' position
    this.state = this.initial_state === 'open' ? 'closed' : 'minimized';
    this.jq('#sponsorpay-widget').css('right', this._right_coordinate() + 'px' );

    // for some reason firefox flickers... so the widget first has display: none
    this.jq('#sponsorpay-widget').css('display', '');

    // place the title depending on widget height
    if (SPUtils.isIE()) {
      // set the minimum height
      var ieWidgetHeight = this.jq('#sponsorpay-widget #title').height() + 65;
      this.jq('#sponsorpay-widget table').attr('height', ieWidgetHeight+'px');
      // now get the real height and place the title
      var title_position = this.jq('#sponsorpay-widget').height() - (this.jq('#sponsorpay-widget #title').height() + 20)
    }
    else {
      var title_height = this.jq('#sponsorpay-widget #title').width()
      // set the minimum height
      var widgetHeight = title_height + 65;
      this.jq('#sponsorpay-widget table').attr('height', widgetHeight+'px');
      // now get the real height and place the title
      var title_position = (this.jq('#sponsorpay-widget').height() + title_height) - (title_height + 20)
    }
    this.jq('#sponsorpay-widget #title').css('top', title_position);

    // open it with animation
    if (this.initial_state === 'open') {
      this.state = 'open';
      this.jq('#sponsorpay-widget').animate({ right: this._right_coordinate() + 'px' }, this.animation_duration);
      this.jq('#sponsorpay-widget #close').show();
      this.jq('#sponsorpay-widget #open').hide();
    }
    else {
      this.jq('#sponsorpay-widget #close').hide();
      this.jq('#sponsorpay-widget #open').show();
    }

    // cursors in active zones
    this.jq('#sponsorpay-widget #sp-header').css( 'cursor', 'pointer' );
    this.jq('#sponsorpay-widget #sp-main').css( 'cursor', 'pointer' );

    // onclicks in active zones
    if (this.initial_state === 'open') {
      this._title_bar_behavior( this._minimize );
    }
    else {
      this._title_bar_behavior( this._user_opens );
    }

    this.jq('#sponsorpay-widget #sp-main').click( function(){
      window.open( jQuery('#sponsorpay-widget #offer-link a').attr('href') );
      return false;
    });

    // Popupize links
    SPUtils.popupizeLinks(_self, _self.jq('#sponsorpay-widget.facebook a.popupize-me'), 478, 220);
    SPUtils.popupizeLinks(_self, _self.jq('#sponsorpay-widget.video a.popupize-me'), 550, 640);

    // Popupize the whole widget
    _self.jq('#sponsorpay-widget.facebook #sp-main, #sponsorpay-widget.video #sp-main').unbind('click').click( function() {
      jQuery('#sponsorpay-widget a.popupize-me').click();
      return false;
    });

    this.jq('#sponsorpay-widget #close').click( function(){
      this._user_closes();
      return false;
    });
  }; // _set_initial_position

  // what to do when the title bar is clicked
  this._title_bar_behavior = function( behavior ){
    this.jq('#sponsorpay-widget #sp-header').unbind('click').click(behavior);
  }; // _title_bar_behavior

  // what to do when user ask to close the widget
   this._user_closes = function(){
    if( this.closing_behavior == 'close' ) {
      this._close();
    } else {
      this._minimize();
    }
  }; // _user_closes

  // what to do when user ask to open the widget
  this._user_opens = function(){
    // remove the counter
    _self.minimize_counter = false;
    _self.jq('#sponsorpay-widget #countdown').html( '&nbsp;' ); // using hide() makes the widget jump

    // show the widget
    _self._show();
  }; // _user_opens

  // show the widget
  this._show = function(){
    this.state = 'open';
    this.jq('#sponsorpay-widget').animate({ right: this._right_coordinate() }, this.animation_duration);
    this.jq('#sponsorpay-widget #close').show();
    this.jq('#sponsorpay-widget #open').hide();
    this.countdown = this.closing_countdown;
    this._counter_tic();
    this._title_bar_behavior( this._minimize );
  }; // _show

  // close the widget
  this._close = function(){
    _self.state = 'closed';
    _self.jq('#sponsorpay-widget').animate({ right: _self._right_coordinate() + 'px' }, (_self.animation_duration / 2));
    _self._title_bar_behavior( _self._user_opens );
  }; // _close

  // minimize the widget
  this._minimize = function(){
    _self.state = 'minimized';
    _self.jq('#sponsorpay-widget').animate({ right: _self._right_coordinate() + 'px' }, (_self.animation_duration / 2));
    _self.jq('#sponsorpay-widget #close').hide();
    _self.jq('#sponsorpay-widget #open').show();
    _self._title_bar_behavior( _self._user_opens );
  }; // _minimize

  this._right_coordinate = function( state ){
    if( typeof state == 'undefined' ) state = this.state

    this.width = parseInt( this.jq('#sponsorpay-widget.right').css('width').replace('px','') );

    switch( state ) {
      case 'minimized'  : return (-1 * (this.width - 27)); break;
      case 'closed'     : return (-1 * (this.width + 20)); break;
      case 'open'       : return 10; break;
      default           : if (SPONSORPAY.debug(this)) console.warn( "not valid state for rightCoordinate: " + state );
    }

    return 0;
  }; // _right_coordinate
}
// }}}

// {{{ LAYOVER +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SPONSORPAY.Widget.Layover = function(options) {

  var _self = this;

  // constants
  this.SP_VERSION         = '1.0';
  this.SP_JQUERY_URL      = 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js';
  this.SP_JQUERY_VERSION  = '1.4.4';
  this.PUB_PARAMS         = 10;    // pub0..pub9
  this.width              = 620;
  this.min_width          = 490;   // 500
  this.max_width          = 1040;  // 1040
  this.height             = 500;
  this.min_height         = 300;  // 300
  this.faceboxClass       = 'sp-widget-layover';  // sp-widget-layover

  this.jq       = null;
  this.timeout  = null;

  // required
  this.appid    = null;
  this.uid      = null;

  // semi-internal
  this.api_host           = 'iframe.sponsorpay.com';
  this.asset_host         = 'asset1.sponsorpay.com';
  this.environment        = 'production';
  this.integration        = 'layover';
  this.cookie_expiration  = 14; // days
  this.ps_time            = null; // user creation_date

  // options
  this.trigger            = '#sp-layover-button';

  this.er                 = null;
  this.currency           = null;
  this.digest             = null;
  this.ts                 = null;

  this.country            = null;
  this.language           = null;
  this.debug              = false;

  // pubX params
  for (x = 0; x < this.PUB_PARAMS; x++) {
    eval("this.pub" + x + " = null");
  }

  // Starting point ***************************************
  this.start = function() {
    if( !SPUtils.initOptions(this, options, 'widgets.js') ) {
      if (SPONSORPAY.debug(this)) console.error( "ERROR: in initializing options" );
      return false;
    }
    SPUtils.loadJQueryAndInit(this, this.init);
  }

  // Public methods ***************************************
  this.init = function() {
    if( SPUtils.ie6() ) {
      if (SPONSORPAY.debug(this)) console.warn( 'No ie6 support' );
      return false;
    }

    if( !this._is_active() ) {
      if (SPONSORPAY.debug(this)) console.info( 'Widget is not active' );
      return false;
    }

    if( SPUtils.safari() ) {
      SPUtils.setUpCookies( this, function() {
        _self._loadCss();
        _self._loadFaceboxAndInit();
      });
    } else {
      _self._loadCss();
      _self._loadFaceboxAndInit();
    }
  }; // init

  // Private methods ***************************************
  this._is_active = function() {return true};

  this._loadCss = function () {
    SPUtils.loadCSSFile(window.location.protocol + '//' + _self.asset_host + '/stylesheets/widget/v1/layover.css');
  };

  this._loadFaceboxAndInit = function () {
    SPUtils.loadJSFile(window.location.protocol + '//' + _self.asset_host + '/javascripts/facebox_layover.js', this._initialize_layover);
  };

  this._sufficientWindowDimensions = function () {
    return ((_self.min_width < _self.jq(window).width()) && (_self.min_height < _self.jq(window).height()));
  };

  this._iframe_src = function () {
    var pubparam = '';
    for (x = 0; x < this.PUB_PARAMS; x++) {
      if ((eval("_self.pub" + x) != 'undefined') && (eval("_self.pub" + x) != null)) {
        pubparam += "&pub" + x + "=" + eval("_self.pub" + x);
      }
    }
    return window.location.protocol + '//' + _self.api_host + "/?appid=" + _self.appid + "&uid=" + _self.uid + "&integration=" + _self.integration + "&integration=" + _self.integration + pubparam;
  }

  this._initialize_layover = function() {
    SPUtils.loadCSSFile(window.location.protocol + '//' + _self.asset_host + '/stylesheets/facebox_layover.css');

    _self.jq.facebox.settings.closeImage   = window.location.protocol + '//' + _self.asset_host + '/images/facebox/closelabel.gif';
    _self.jq.facebox.settings.loadingImage = window.location.protocol + '//' + _self.asset_host + '/images/facebox/loading.gif';

      if (_self._sufficientWindowDimensions()) {
        _self.final_width  = Math.min(Math.max(_self.width, _self.min_width), Math.min ((_self.jq(window).width()-60), _self.max_width));
        _self.final_height = Math.max(_self.height, _self.min_height);

        content = "<iframe src='" + _self._iframe_src() + "' style='width:"+_self.final_width+"px; height:"+_self.final_height+"px;border:none' frameBorder='0'></iframe>";

        _self.jq.facebox(content);
        _self.jq('#facebox').addClass(_self.faceboxClass);
      }
      return false;
  }
}
// }}}

// ========= SP_UTILS =======================================
// {{{ SP_UTILS
var SPUtils = {};
SPUtils = {
  cookies_form_submitted : false,
  debug : false,

  // init client integration options
  initOptions : function(sp_object, options, script_filename){
    for (var key in options) {
      if ( (typeof sp_object[key]) != 'undefined' ) {
        if (typeof options[key]=='function') {        // I need function!
          sp_object[key] = options[key];
        } else {
          sp_object[key] = String(options[key]);
        }
      } else {
        if (SPONSORPAY.debug(this)) console.warn('client integration option not available: ' + key);
      }
      if (options['debug'] != undefined) this.debug = options['debug'];
    }

    if( sp_object.environment == 'development' ){
      sp_object.api_host = SPUtils.getJSDomain( sp_object, script_filename );
      sp_object.asset_host = SPUtils.getJSDomain( sp_object, script_filename );
    }

    // check required options
    if( sp_object.appid == null || sp_object.uid == null ) {
      if (SPONSORPAY.debug(this)) console.error( 'ERROR: required client integration options not present' );
      return false
    }

    return true;
  },

  getJSDomain : function( sp_object, script_file_name ){
    script = sp_object.jq('script[src$=' + script_file_name + ']:last');
    return script.attr('src').match(/https?:\/\/([^\/]*)\//)[1];
  },

  // load jQuery if needed and call init when ready
  loadJQueryAndInit : function( sp_object, callback ){
    // check if the desired jQuery version is already available
    if( typeof jQuery != 'undefined' && jQuery.fn.jquery == sp_object.SP_JQUERY_VERSION ) {
      if (SPONSORPAY.debug(this)) console.debug( 'jQuery version ' + sp_object.SP_JQUERY_VERSION + ' already available' );
      sp_object.jq = jQuery;
      callback.call(sp_object);
    // if not load it.
    } else {
      if (SPONSORPAY.debug(this)) console.debug( 'Loading jQuery version ' + sp_object.SP_JQUERY_VERSION );
      SPUtils.loadJSFile(
        sp_object.SP_JQUERY_URL,
        function() {
          sp_object.jq = jQuery.noConflict();
          callback.call(sp_object);
        }
      );
    }
  },

  loadJSFile : function( url, callback ){
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = url;
    document.getElementsByTagName("head")[0].appendChild(script);

    if (script.readyState){ // Internet Explorer
      script.onreadystatechange = function(){
        if (script.readyState == "loaded" || script.readyState == "complete") {
          script.onreadystatechange = null;
          callback();
        }
      };
    } else { // Otros navegadores
      script.onload = function(){
        callback();
      };
    }
  },

  // add a css file to the head
  loadCSSFile : function(url){

    var ss = document.styleSheets;
    for (var i = 0, max = ss.length; i < max; i++) {
      if (ss[i].href == url) {
        return;
      }
    }

    var styleElement = document.createElement('link');
    styleElement.setAttribute('type', 'text/css');
    styleElement.setAttribute('media', 'screen');
    styleElement.setAttribute('rel', 'stylesheet');
    styleElement.setAttribute('href', url);
    document.getElementsByTagName('head')[0].appendChild(styleElement);
  },

  loadCustomBkg : function(sp_object, selector){
    sp_object.jq("#" + sp_object.where + ' ' + selector).css('background', 'url(' + sp_object.background + ') no-repeat 0 0');
  },

  // charge the custom css defined into the options
  loadCustomCSS : function(sp_object){
    css = "";

    if( sp_object.background_color ) {
      css += "#sponsorpay-widget h1{ background-color: " + sp_object.background_color + "; }"
    }

    if( css.length != 0 ) {
      var styleElement = document.createElement('style');
      styleElement.setAttribute('type', 'text/css');
      styleElement.setAttribute('media', 'screen');

      if( typeof styleElement.styleSheet !== "undefined" ) {
        styleElement.styleSheet.cssText = css;
      } else {
        styleElement.appendChild( document.createTextNode( css ) );
        styleElement.innerHTML = css;
      }

      document.getElementsByTagName('head')[0].appendChild(styleElement);
    }
  },

  trackView : function (sp_object, offer) {
    var tracking_js_url = window.location.protocol + '//' + sp_object.asset_host +'/javascripts/tracking.js';

    SPUtils.loadJSFile(
      tracking_js_url,
      function() {
        track_view({
            offers:     (offer == null) ? '' : offer.id,
            page:       1
        },
        {
          userid:     sp_object.uid,
          appid:      sp_object.appid,
          country:    sp_object.country,
          language:   sp_object.language,
          type:       sp_object.integration
        });
      }
    );
  },

  // call the callback when all the images has been loaded
  // or when the timeout is gone
  preloadImages : function( sp_object, images, callback, timeout ){
    var num_images = images.length;
    var num_images_loaded = 0;

    // not any image?
    if( num_images == 0 ) {
      return callback.call(sp_object);
    }

    // fallback for timeout
    var timeout =
      setTimeout(
        function(){
          if (SPONSORPAY.debug(this)) console.warn( "timeout for images loading" );
          callback.call(sp_object);
        }, timeout
      );

    images.each( function(){
      img = new Image();
      img.onload = function(){
        num_images_loaded++;
        if( num_images_loaded >= num_images ){
          clearTimeout( timeout );
          callback.call(sp_object);
        }
      }
      img.src = this.src;
    });
  },

  // ie6 detection
  ie6 : function(){
    return ((window.XMLHttpRequest == undefined) && (ActiveXObject != undefined));
  },

  // ie detection
  isIE: function() {
    return /msie/i.test(navigator.userAgent) && !/opera/i.test(navigator.userAgent);
  },

  // safari detection
  safari : function(){
    return(
      SPUtils.getUserAgent().indexOf( 'Safari' ) != -1 &&
      SPUtils.getUserAgent().indexOf( 'Chrome' ) == -1
    );
  },

  getUserAgent : function() {
    return navigator.userAgent;
  },

  // returns de loaded object or null if any error
  loadOffer : function( sp_object, callback, fail_callback, extra_params, limit_offers ){
    extra_params = typeof(extra_params) != 'undefined' ? extra_params : {};
    limit_offers = typeof(limit_offers) != 'undefined' ? limit_offers : 1;

    params = { appid: sp_object.appid, uid: sp_object.uid, limit: limit_offers, offset: SPUtils.nextOffset(sp_object), integration: sp_object.integration, origin: window.location.toString() }

    if ( sp_object.ps_time  )  { params['ps_time']  = sp_object.ps_time;  }
    if ( sp_object.er       )  { params['er']       = sp_object.er;       }
    if ( sp_object.currency )  { params['currency'] = sp_object.currency; }
    if ( sp_object.digest   )  { params['digest']   = sp_object.digest;   }
    if ( sp_object.ts       )  { params['ts']       = sp_object.ts;       }

    sp_object.jq.ajax({
      url       : window.location.protocol + '//' + sp_object.api_host + '/widget' ,
      type      : 'GET',  // jsonp doesn't work with POST
      dataType  : 'jsonp',
      data      : sp_object.jq.extend(params, extra_params),
      success   : function(offers) { callback.call(sp_object, offers); },
      error     : function(XMLHttpRequest, textStatus, errorThrown) {
                    if (SPONSORPAY.debug(this)) console.warn('problem in the ajax call: ' + XMLHttpRequest)
                  }
    });
    sp_object.timeout = setTimeout( fail_callback, sp_object.SP_FALLBACK_MS );
  },


  nextOffset : function(sp_object){
    next_offset = SPUtils.getCookie(sp_object, 'offers_offset', 0, true);

    return next_offset;
  },

  // called if the ajax call takes too long
  timeOutWarn : function() {
    if (SPONSORPAY.debug(this)) console.warn( 'Too much time waiting for the ajax call' );
  },

  pub_literals : function(sp_object, number_of_items){
    literals = {};
    for(x = 0; x < number_of_items; x++) {
      if (( eval("sp_object.pub" + x) != 'undefined') && (eval("sp_object.pub" + x) != null)) {
        literals['pub' + x] = eval("sp_object.pub" + x);
      }
    }
    return literals;
  },

  // get a cookie value
  // you can define a default value in case the cookie doesn't exists yet
  // you can ask for the result to be parsed to Int
  getCookie : function(sp_object, name, default_value, to_int) {
    default_value = typeof(default_value) != 'undefined' ? default_value : null;
    to_int        = typeof(to_int) != 'undefined' ? to_int : false;

    complex_name = SPUtils.complexCookieName(sp_object, name);
    result = (matchs = new RegExp('(?:^|; )' + complex_name + '=([^;]*)').exec(document.cookie)) ? matchs[1] : null;

    if( result == null ) result = default_value;
    if( to_int ) result = parseInt(result);

    return result;
  },

  // charge a new cookie
  setCookie : function(sp_object, name, value){
    expires_date = new Date()
    expires_date.setDate(expires_date.getDate() + parseInt(sp_object.cookie_expiration));
    complex_name = SPUtils.complexCookieName(sp_object, name);

    document.cookie =
      complex_name + '=' + String(value) + ';' +        // cookie name
      'expires=' + expires_date.toUTCString() + ';' +   // expiration date
      'path=/;';                                        // full damain cookie
  },

  // modify the name of the cookie key to be unique by:
  //   * version of the widget
  //   * appid
  //   * uid
  complexCookieName : function(sp_object, name){
    return 'sp_' + sp_object.integration + '_' + sp_object.SP_VERSION.replace('.', '_') + '_' + sp_object.appid + "_" + sp_object.uid + "_"+ name ;
  },

  // trick to avoid the XDomain cookies protection in safari
  // after the trick is done the callback is called.
  setUpCookies : function(sp_object, callback) {
    // magick iframe and form
    if (sp_object.jq("#sp-sponsorpay-cookies-iframe").size() == 0) {

      var magick_iframe_and_form = " \
        <iframe \
          id='sp-sponsorpay-cookies-iframe' \
          name='sp-sponsorpay-cookies-iframe' \
          style='display:none;'\
        ></iframe>\
        <form \
          id='sp-sponsorpay-cookies-form'\
          enctype='application/x-www-form-urlencoded'\
          action='" + window.location.protocol + "//" + sp_object.api_host + "/setup_cookies'\
          target='sp-sponsorpay-cookies-iframe'\
          method='post'\
        ></form>";

      sp_object.jq(document.body).append( magick_iframe_and_form );
      sp_object.jq('#sp-sponsorpay-cookies-iframe').attr( "src", window.location.protocol + "//" + sp_object.api_host + "/blank.html" );
      sp_object.jq('#sp-sponsorpay-cookies-iframe').load( function(){ SPUtils.submitCookiesForm( sp_object, callback ); });
    } else {
      setTimeout( callback.call(sp_object), 2000 );
    }
  },

  submitCookiesForm : function(sp_object, callback) {
    if( !SPUtils.cookies_form_submitted ) {
      SPUtils.cookies_form_submitted = true;
      sp_object.jq('#sp-sponsorpay-cookies-form').submit();
      setTimeout( callback.call(sp_object), 2000 );
    }
  },

  increaseDailyViewCounterInCookie : function(widget) {
    SPUtils.setCookie(widget, 'num_times_shown_today_'+SPUtils.formatedDate(), SPUtils.viewsForToday(widget) + 1);
  },

  viewsForToday : function(widget) {
    return SPUtils.getCookie(widget, 'num_times_shown_today_'+SPUtils.formatedDate(), 0, true);
  },

  formatedDate : function() {
    var dateObj = new Date();
    return dateObj.getUTCFullYear()+''+(dateObj.getUTCMonth()+1)+''+dateObj.getUTCDate();
  },


  // User it like this:
  //     popupizeLinks($('a.sp_facebook_like_offer'), 478, 220);
  popupizeLinks : function(sp_object, links, width, height) {
    links.unbind('click').click( function() {
      url = sp_object.jq(this).attr('href');
      url = SPUtils.addParameterToUrl(url, 'realpopup', 'on');
      url = SPUtils.addParameterToUrl(url, 'widget', 'on');
      SPUtils.openCenteredPopup(url, sp_object.jq(this).attr('title'), width, height).focus();
      return false;
    });
  },

  // from application.js
  openCenteredPopup : function(url, title, pwidth, pheight) {
    var left = (screen.width/2)-(pwidth/2);
    var top = (screen.height/2)-(pheight/2);
    var targetWin = window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=0, scrollbars=no, resizable=no, copyhistory=no, width='+pwidth+', height='+pheight+', top='+top+', left='+left);

    return targetWin;
  },

  // add a new html parameter to an URL
  addParameterToUrl : function( url, key, value ){
    if( url.indexOf('?') == -1 ) {
      url = url + '?' + key + '=' + value;
    } else {
      url = url + '&' + key + '=' + value;
    }

    return url;
  },

  // General utilities
  url_param : function(parameter) {
    var loc = location.search.substring(1, location.search.length);
    var param_value = false;
    var params = loc.split("&");

    for (i=0; i<params.length;i++) {
        param_name = params[i].substring(0,params[i].indexOf('='));
        if (param_name == parameter) {
            param_value = params[i].substring(params[i].indexOf('=')+1)
        }
    }
    if (param_value) {
        return param_value;
    } else {
        return false; //Here determine return if no parameter is found
    }
  },

  merge_params :function(banner_params, pub_params){
      var merged_params = {};
      for (attrname in banner_params) {
        merged_params[attrname] = banner_params[attrname];
      }
      for (attrname in pub_params) {
        if (pub_params[attrname] != false) {
          merged_params[attrname] = pub_params[attrname];
        }
      }
      return merged_params;
  },

  additional_params :function(obj) {
    var params = "";
    if ( obj.er       )  { params += '&er=' + obj.er;             }
    if ( obj.currency )  { params += '&currency=' + obj.currency; }
    if ( obj.digest   )  { params += '&digest=' + obj.digest;     }
    if ( obj.ts       )  { params += '&ts=' + obj.ts;             }
    if ( obj.ps_time  )  { params += '&ps_time=' + obj.ps_time    }
    return params;
  }

} // SPUtils
// }}}

// {{{ - postmessage.js
/**
 The MIT License

 Copyright (c) 2010 Daniel Park (http://metaweb.com, http://postmessage.freebaseapps.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/
var NO_JQUERY = {};
(function(window, $, undefined) {

     /*
     if (SPONSORPAY.debug(this)) {
       if (!("console" in window)) {
         var c = window.console = {};
         c.log = c.warn = c.error = c.debug = function(){};
       }
     }
     */

     if ($ === NO_JQUERY) {
         // jQuery is optional
         $ = {
             fn: {},
             extend: function() {
                 var a = arguments[0];
                 for (var i=1,len=arguments.length; i<len; i++) {
                     var b = arguments[i];
                     for (var prop in b) {
                         a[prop] = b[prop];
                     }
                 }
                 return a;
             }
         };
     }

     $.fn.pm = function() {
         if (SPONSORPAY.debug(this)) console.log("usage: \nto send:    $.pm(options)\nto receive: $.pm.bind(type, fn, [origin])");
         return this;
     };

     // send postmessage
     $.pm = window.pm = function(options) {
         pm.send(options);
     };

     $.pm.debug = false;

     // bind postmessage handler
     $.pm.bind = window.pm.bind = function(type, fn, origin, hash) {
         pm.bind(type, fn, origin, hash);
     };

     // unbind postmessage handler
     $.pm.unbind = window.pm.unbind = function(type, fn) {
         pm.unbind(type, fn);
     };

     // default postmessage origin on bind
     $.pm.origin = window.pm.origin = null;

     // default postmessage polling if using location hash to pass postmessages
     $.pm.poll = window.pm.poll = 200;

     var pm = {

         send: function(options) {
             var o = $.extend({}, pm.defaults, options),
             target = o.target;
             if (!o.target) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage target window required");
                 return;
             }
             if (!o.type) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage type required");
                 return;
             }
             var msg = {data:o.data, type:o.type};
             if (o.success) {
                 msg.callback = pm._callback(o.success);
             }
             if (o.error) {
                 msg.errback = pm._callback(o.error);
             }
             if (("postMessage" in target) && !o.hash) {
                 pm._bind();
                 target.postMessage(JSON.stringify(msg), o.origin || '*');
             }
             else {
                 pm.hash._bind();
                 pm.hash.send(o, msg);
             }
         },

         bind: function(type, fn, origin, hash) {
             if (("postMessage" in window) && !hash) {
                 pm._bind();
             }
             else {
                 pm.hash._bind();
             }
             var l = pm.data("listeners.postmessage");
             if (!l) {
                 l = {};
                 pm.data("listeners.postmessage", l);
             }
             var fns = l[type];
             if (!fns) {
                 fns = [];
                 l[type] = fns;
             }
             fns.push({fn:fn, origin:origin || $.pm.origin});
         },

         unbind: function(type, fn) {
             var l = pm.data("listeners.postmessage");
             if (l) {
                 if (type) {
                     if (fn) {
                         // remove specific listener
                         var fns = l[type];
                         if (fns) {
                             var m = [];
                             for (var i=0,len=fns.length; i<len; i++) {
                                 var o = fns[i];
                                 if (o.fn !== fn) {
                                     m.push(o);
                                 }
                             }
                             l[type] = m;
                         }
                     }
                     else {
                         // remove all listeners by type
                         delete l[type];
                     }
                 }
                 else {
                     // unbind all listeners of all type
                     for (var i in l) {
                       delete l[i];
                     }
                 }
             }
         },

         data: function(k, v) {
             if (v === undefined) {
                 return pm._data[k];
             }
             pm._data[k] = v;
             return v;
         },

         _data: {},

         _CHARS: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split(''),

         _random: function() {
             var r = [];
             for (var i=0; i<32; i++) {
                 r[i] = pm._CHARS[0 | Math.random() * 32];
             };
             return r.join("");
         },

         _callback: function(fn) {
             var cbs = pm.data("callbacks.postmessage");
             if (!cbs) {
                 cbs = {};
                 pm.data("callbacks.postmessage", cbs);
             }
             var r = pm._random();
             cbs[r] = fn;
             return r;
         },

         _bind: function() {
             // are we already listening to message events on this w?
             if (!pm.data("listening.postmessage")) {
                 if (window.addEventListener) {
                     window.addEventListener("message", pm._dispatch, false);
                 }
                 else if (window.attachEvent) {
                     window.attachEvent("onmessage", pm._dispatch);
                 }
                 pm.data("listening.postmessage", 1);
             }
         },

         _dispatch: function(e) {
             //console.log("$.pm.dispatch", e, this);
             try {
                 var msg = JSON.parse(e.data);
             }
             catch (ex) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage data invalid json: ", ex);
                 return;
             }
             if (!msg.type) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage message type required");
                 return;
             }
             var cbs = pm.data("callbacks.postmessage") || {},
             cb = cbs[msg.type];
             if (cb) {
                 cb(msg.data);
             }
             else {
                 var l = pm.data("listeners.postmessage") || {};
                 var fns = l[msg.type] || [];
                 for (var i=0,len=fns.length; i<len; i++) {
                     var o = fns[i];
                     if (o.origin && e.origin !== o.origin) {
                         if (SPONSORPAY.debug(pm)) console.warn("postmessage message origin mismatch", e.origin, o.origin);
                         if (msg.errback) {
                             // notify post message errback
                             var error = {
                                 message: "postmessage origin mismatch",
                                 origin: [e.origin, o.origin]
                             };
                             pm.send({target:e.source, data:error, type:msg.errback});
                         }
                         continue;
                     }
                     try {
                         var r = o.fn(msg.data);
                         if (msg.callback) {
                             pm.send({target:e.source, data:r, type:msg.callback});
                         }
                     }
                     catch (ex) {
                         if (msg.errback) {
                             // notify post message errback
                             pm.send({target:e.source, data:ex, type:msg.errback});
                         }
                     }
                 };
             }
         }
     };

     // location hash polling
     pm.hash = {

         send: function(options, msg) {
             //console.log("hash.send", target_window, options, msg);
             var target_window = options.target,
             target_url = options.url;
             if (!target_url) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage target window url is required");
                 return;
             }
             target_url = pm.hash._url(target_url);
             var source_window,
             source_url = pm.hash._url(window.location.href);
             if (window == target_window.parent) {
                 source_window = "parent";
             }
             else {
                 try {
                     for (var i=0,len=parent.frames.length; i<len; i++) {
                         var f = parent.frames[i];
                         if (f == window) {
                             source_window = i;
                             break;
                         }
                     };
                 }
                 catch(ex) {
                     // Opera: security error trying to access parent.frames x-origin
                     // juse use window.name
                     source_window = window.name;
                 }
             }
             if (source_window == null) {
                 if (SPONSORPAY.debug(pm)) console.warn("postmessage windows must be direct parent/child windows and the child must be available through the parent window.frames list");
                 return;
             }
             var hashmessage = {
                 "x-requested-with": "postmessage",
                 source: {
                     name: source_window,
                     url: source_url
                 },
                 postmessage: msg
             };
             var hash_id = "#x-postmessage-id=" + pm._random();
             target_window.location = target_url + hash_id + encodeURIComponent(JSON.stringify(hashmessage));
         },

         _regex: /^\#x\-postmessage\-id\=(\w{32})/,

         _regex_len: "#x-postmessage-id=".length + 32,

         _bind: function() {
             // are we already listening to message events on this w?
             if (!pm.data("polling.postmessage")) {
                 setInterval(function() {
                                 var hash = "" + window.location.hash,
                                 m = pm.hash._regex.exec(hash);
                                 if (m) {
                                     var id = m[1];
                                     if (pm.hash._last !== id) {
                                         pm.hash._last = id;
                                         pm.hash._dispatch(hash.substring(pm.hash._regex_len));
                                     }
                                 }
                             }, $.pm.poll || 200);
                 pm.data("polling.postmessage", 1);
             }
         },

         _dispatch: function(hash) {
             if (!hash) {
                 return;
             }
             try {
                 hash = JSON.parse(decodeURIComponent(hash));
                 if (!(hash['x-requested-with'] === 'postmessage' &&
                       hash.source && hash.source.name != null && hash.source.url && hash.postmessage)) {
                     // ignore since hash could've come from somewhere else
                     return;
                 }
             }
             catch (ex) {
                 // ignore since hash could've come from somewhere else
                 return;
             }
             var msg = hash.postmessage,
             cbs = pm.data("callbacks.postmessage") || {},
             cb = cbs[msg.type];
             if (cb) {
                 cb(msg.data);
             }
             else {
                 var source_window;
                 if (hash.source.name === "parent") {
                     source_window = window.parent;
                 }
                 else {
                     source_window = window.frames[hash.source.name];
                 }
                 var l = pm.data("listeners.postmessage") || {};
                 var fns = l[msg.type] || [];
                 for (var i=0,len=fns.length; i<len; i++) {
                     var o = fns[i];
                     if (o.origin) {
                         var origin = /https?\:\/\/[^\/]*/.exec(hash.source.url)[0];
                         if (origin !== o.origin) {
                             if (SPONSORPAY.debug(pm)) console.warn("postmessage message origin mismatch", origin, o.origin);
                             if (msg.errback) {
                                 // notify post message errback
                                 var error = {
                                     message: "postmessage origin mismatch",
                                     origin: [origin, o.origin]
                                 };
                                 pm.send({target:source_window, data:error, type:msg.errback, hash:true, url:hash.source.url});
                             }
                             continue;
                         }
                     }
                     try {
                         var r = o.fn(msg.data);
                         if (msg.callback) {
                             pm.send({target:source_window, data:r, type:msg.callback, hash:true, url:hash.source.url});
                         }
                     }
                     catch (ex) {
                         if (msg.errback) {
                             // notify post message errback
                             pm.send({target:source_window, data:ex, type:msg.errback, hash:true, url:hash.source.url});
                         }
                     }
                 };
             }
         },

         _url: function(url) {
             // url minus hash part
             return (""+url).replace(/#.*$/, "");
         }

     };

     $.extend(pm, {
                  defaults: {
                      target: null,  /* target window (required) */
                      url: null,     /* target window url (required if no window.postMessage or hash == true) */
                      type: null,    /* message type (required) */
                      data: null,    /* message data (required) */
                      success: null, /* success callback (optional) */
                      error: null,   /* error callback (optional) */
                      origin: "*",   /* postmessage origin (optional) */
                      hash: false    /* use location hash for message passing (optional) */
                  }
              });

 })(this, typeof jQuery === "undefined" ? NO_JQUERY : jQuery);

/**
 * http://www.JSON.org/json2.js
 **/
if (! ("JSON" in window && window.JSON)){JSON={}}(function(){function f(n){return n<10?"0"+n:n}if(typeof Date.prototype.toJSON!=="function"){Date.prototype.toJSON=function(key){return this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z"};String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(key){return this.valueOf()}}var cx=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,escapable=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,gap,indent,meta={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"},rep;function quote(string){escapable.lastIndex=0;return escapable.test(string)?'"'+string.replace(escapable,function(a){var c=meta[a];return typeof c==="string"?c:"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+string+'"'}function str(key,holder){var i,k,v,length,mind=gap,partial,value=holder[key];if(value&&typeof value==="object"&&typeof value.toJSON==="function"){value=value.toJSON(key)}if(typeof rep==="function"){value=rep.call(holder,key,value)}switch(typeof value){case"string":return quote(value);case"number":return isFinite(value)?String(value):"null";case"boolean":case"null":return String(value);case"object":if(!value){return"null"}gap+=indent;partial=[];if(Object.prototype.toString.apply(value)==="[object Array]"){length=value.length;for(i=0;i<length;i+=1){partial[i]=str(i,value)||"null"}v=partial.length===0?"[]":gap?"[\n"+gap+partial.join(",\n"+gap)+"\n"+mind+"]":"["+partial.join(",")+"]";gap=mind;return v}if(rep&&typeof rep==="object"){length=rep.length;for(i=0;i<length;i+=1){k=rep[i];if(typeof k==="string"){v=str(k,value);if(v){partial.push(quote(k)+(gap?": ":":")+v)}}}}else{for(k in value){if(Object.hasOwnProperty.call(value,k)){v=str(k,value);if(v){partial.push(quote(k)+(gap?": ":":")+v)}}}}v=partial.length===0?"{}":gap?"{\n"+gap+partial.join(",\n"+gap)+"\n"+mind+"}":"{"+partial.join(",")+"}";gap=mind;return v}}if(typeof JSON.stringify!=="function"){JSON.stringify=function(value,replacer,space){var i;gap="";indent="";if(typeof space==="number"){for(i=0;i<space;i+=1){indent+=" "}}else{if(typeof space==="string"){indent=space}}rep=replacer;if(replacer&&typeof replacer!=="function"&&(typeof replacer!=="object"||typeof replacer.length!=="number")){throw new Error("JSON.stringify")}return str("",{"":value})}}if(typeof JSON.parse!=="function"){JSON.parse=function(text,reviver){var j;function walk(holder,key){var k,v,value=holder[key];if(value&&typeof value==="object"){for(k in value){if(Object.hasOwnProperty.call(value,k)){v=walk(value,k);if(v!==undefined){value[k]=v}else{delete value[k]}}}}return reviver.call(holder,key,value)}cx.lastIndex=0;if(cx.test(text)){text=text.replace(cx,function(a){return"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})}if(/^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){j=eval("("+text+")");return typeof reviver==="function"?walk({"":j},""):j}throw new SyntaxError("JSON.parse")}}}());


