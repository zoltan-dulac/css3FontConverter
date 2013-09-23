/*! sprintf.js | Copyright (c) 2007-2013 Alexandru Marasteanu <hello at alexei dot ro> | 3 clause BSD license */
(function(e){function r(e){return Object.prototype.toString.call(e).slice(8,-1).toLowerCase()}function i(e,t){for(var n=[];t>0;n[--t]=e);return n.join("")}var t=function(){return t.cache.hasOwnProperty(arguments[0])||(t.cache[arguments[0]]=t.parse(arguments[0])),t.format.call(null,t.cache[arguments[0]],arguments)};t.format=function(e,n){var s=1,o=e.length,u="",a,f=[],l,c,h,p,d,v;for(l=0;l<o;l++){u=r(e[l]);if(u==="string")f.push(e[l]);else if(u==="array"){h=e[l];if(h[2]){a=n[s];for(c=0;c<h[2].length;c++){if(!a.hasOwnProperty(h[2][c]))throw t('[sprintf] property "%s" does not exist',h[2][c]);a=a[h[2][c]]}}else h[1]?a=n[h[1]]:a=n[s++];if(/[^s]/.test(h[8])&&r(a)!="number")throw t("[sprintf] expecting number but found %s",r(a));switch(h[8]){case"b":a=a.toString(2);break;case"c":a=String.fromCharCode(a);break;case"d":a=parseInt(a,10);break;case"e":a=h[7]?a.toExponential(h[7]):a.toExponential();break;case"f":a=h[7]?parseFloat(a).toFixed(h[7]):parseFloat(a);break;case"o":a=a.toString(8);break;case"s":a=(a=String(a))&&h[7]?a.substring(0,h[7]):a;break;case"u":a>>>=0;break;case"x":a=a.toString(16);break;case"X":a=a.toString(16).toUpperCase()}a=/[def]/.test(h[8])&&h[3]&&a>=0?"+"+a:a,d=h[4]?h[4]=="0"?"0":h[4].charAt(1):" ",v=h[6]-String(a).length,p=h[6]?i(d,v):"",f.push(h[5]?a+p:p+a)}}return f.join("")},t.cache={},t.parse=function(e){var t=e,n=[],r=[],i=0;while(t){if((n=/^[^\x25]+/.exec(t))!==null)r.push(n[0]);else if((n=/^\x25{2}/.exec(t))!==null)r.push("%");else{if((n=/^\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosuxX])/.exec(t))===null)throw"[sprintf] huh?";if(n[2]){i|=1;var s=[],o=n[2],u=[];if((u=/^([a-z_][a-z_\d]*)/i.exec(o))===null)throw"[sprintf] huh?";s.push(u[1]);while((o=o.substring(u[0].length))!=="")if((u=/^\.([a-z_][a-z_\d]*)/i.exec(o))!==null)s.push(u[1]);else{if((u=/^\[(\d+)\]/.exec(o))===null)throw"[sprintf] huh?";s.push(u[1])}n[2]=s}else i|=2;if(i===3)throw"[sprintf] mixing positional and named placeholders is not (yet) supported";r.push(n)}t=t.substring(n[0].length)}return r};var n=function(e,n,r){return r=n.slice(0),r.splice(0,0,e),t.apply(null,r)};e.sprintf=t,e.vsprintf=n})(typeof exports!="undefined"?exports:window);

var toggleFont = new function () {
  var me = this;
  
  
  var $features, $featureLabels, $selects;
  
  me.init = function () {
    
  	var $featuresCont = $('.features');
  	
  	$selects = $('select');
  	
  	if ($featuresCont.length > 0) {
  		$featuresCont[0].scrollTop = 0;
  	}
  	
    $features = $('.features input').bind('change', changeFeaturesEvent);
    $featureLabels = $('.features label')
    
    $('#toggleFont').bind('change', changeEvent)
                    .trigger('change');
                    
    $('#copy-to-show').bind('change', copyToShowEvent)
    								.trigger('change');
    								
    $('#font-select').bind('change', fontSelectEvent)
    								.trigger('change');
    								
    $('#fontSmoothing').bind('change', fontSmoothingEvent)
    								.trigger('change');
    								
    
  }
  
  
  /* from http://stackoverflow.com/questions/1403888/get-url-parameter-with-javascript-or-jquery */
  function getURLParameter(name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
	}
  
  function changeEvent(e) {
    var target = e.currentTarget;
    
    doHashChange = false;
    
    $('body').removeClass('showHinted showAdobeHinted showFontsquirrel showGoogle')
        			
    switch(target.value) {
      case 'show-hinted':
        $('body').addClass('showHinted');
        break;
      case 'show-adobe-hinted':
        $('body').addClass('showAdobeHinted');
        break;
      case 'show-fontsquirrel':
        $('body').addClass('showFontsquirrel');
        break;
      case 'show-google':
        $('body').addClass('showGoogle');
        break;
    }
    
    changeFeaturesEvent();
    
  } 
  
  function copyToShowEvent(e) {
  	var target = e.currentTarget;
  	//alert()
  	
  	$('.copy').css('display', 'none');
  
  	$('#' + target.value).css('display', 'block');
  	
  	
  }
    
  function changeFeaturesEvent() {
  	
  	
  	
    var featurePropValue = ''
    $features.each(function(i, el) {
      
      
    featurePropValue+=sprintf(
      '%s"%s" %s',
      (featurePropValue!=''?',':''), 
      el.id,
      (el.checked?'1':'0')
    );
     
    });  
    
    $('body').css({
      '-o-font-feature-settings': featurePropValue,
      '-ms-font-feature-settings': featurePropValue,
      '-moz-font-feature-settings': featurePropValue,
      '-webkit-font-feature-settings': featurePropValue,
      'font-feature-settings': featurePropValue
    });
    
    
    
    //console.log(document.body.className)
  }
  
  function fontSelectEvent(e) {
  	var target = e.currentTarget,
  			targetVal = target.value.split('|'),
  			dir = targetVal[0],
  			googleFontURL=targetVal[1],
  			supportedFeatures=targetVal[2].split(','),
  			href;
  			
  	$('link[data-url-template]').each(function(i, el) {
  		var $el = $(el);
  		if (el.id == 'google-css') {
  			href = googleFontURL;
  		} else {
  			href = sprintf($el.attr('data-url-template'), dir);
  		}
  		
  		el.href = href;
  	});
  	
  	var $target = $(target),
  			optionSelector = sprintf('option[value="%s"]', target.value),
  			fontName = $(optionSelector).html();
  			
    $('#font-name').html(fontName);
    
    // now -- hide all options except the supported features
    $featureLabels.css('display', 'none');
    
    for (var i=0; i<supportedFeatures.length; i++) {
    	var labelSelector = sprintf('label[for="%s"]', supportedFeatures[i]),
    			$label = $(labelSelector);
    			
    			$label.css('display', 'block');
    			
    	
    }
    
    // if Google Font variant doesn't exist, remove it from the select list
    var $googleOption = $('option[value="show-google"]');
    
    if (googleFontURL == '') {
    	$googleOption.attr('disabled', true)
    } else {
    	$googleOption.attr('disabled', false)
    }
  	
  	
  }
  
  function fontSmoothingEvent(e) {
  	var target = e.target,
  			targetValue = target.value;
  	
  	$('body').css({
      '-o-font-smoothing': targetValue,
      '-ms-font-smoothing': targetValue,
      '-moz-font-smoothing': targetValue,
      '-webkit-font-smoothing': targetValue,
      'font-smoothing': targetValue
    });
    
    console.log($('body').css('-webkit-font-smoothing'))
  }
}

$(document).ready(toggleFont.init);
