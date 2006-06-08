var toggle_busy = false;
function toggleRackImage(imageId, url, titleId, title) {
	if(toggle_busy) return;
	var imgNode = dojo.byId(imageId);
	var titleNode = dojo.byId(titleId);
	var src_image_id = imgNode.src.split("/").pop();
	var new_image_id = url.split("/").pop();
	if(src_image_id == new_image_id) return;
	toggle_busy = true;
	var callback2 = function() {
		toggle_busy = false;
	}
	var callback1 = function() {
		imgNode.src = url;
		dojo.fx.fadeIn(imgNode, 200, callback2);
	}
	dojo.fx.fadeOut(imgNode, 200, callback1);
	var callback3 = function() {
		titleNode.innerHTML = title;	
		dojo.fx.fadeIn(titleNode, 200);
	}
	dojo.fx.fadeOut(titleNode, 200, callback3);
}

function toggleSlideshow() {
	var rack = dojo.byId('rack');
	var slideshow = dojo.byId('slideshow');
	display = dojo.style.getStyle(rack, "display");
	if(display=="none") {
		var callback = function() {
			dojo.fx.html.wipeIn(rack, 300);
		}
		dojo.fx.html.wipeOut(slideshow, 300, callback);
	} else {
		var callback = function() {
			dojo.fx.html.wipeIn(slideshow, 300);
		}
		dojo.fx.html.wipeOut(rack, 300, callback);
	}
}

function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.fx.html.wipeIn('ticker-container', 300);	
	} else {
		dojo.fx.html.wipeOut('ticker-container', 300);	
	}
}

function toggleHiddenDiv(divId) {
	var node = dojo.byId(divId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.fx.html.wipeIn(node, 300);	
	} else {
		dojo.fx.html.wipeOut(node, 300);	
	}
}

function reloadShoppingCart(url, count) {
	if(count!='0') {
		var node = dojo.byId('shopping-cart');
		document.body.style.cursor = 'progress';
		dojo.io.bind({
			url: url + count,
			load: function(type, data, event) {
				node.innerHTML = data;
				document.body.style.cursor = 'auto';
			},
			mimetype: 'text/html'
		});	
	}
}

function removeFromShoppingCart(url, fieldId) {
	var node = dojo.byId('shopping-cart');
	var inputNode = dojo.byId(fieldId);
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			node.innerHTML = data;
			inputNode.value = '0';
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function closeSearchSlideShowRack() {
	var slideShowRack = dojo.byId('slideshow-rack');
	var upperSearchComposite = dojo.byId('upper-search-composite');
	var callback = function() {
		dojo.fx.html.wipeIn(upperSearchComposite, 100);
	}
	dojo.fx.html.wipeOut(slideShowRack, 100, callback);	
}

function toggleSearchSlideShowRack(link, url) {
	var slideShowRack = dojo.byId('slideshow-rack');
	var upperSearchComposite = dojo.byId('upper-search-composite');
	display = dojo.style.getStyle(slideShowRack, "display");
	if(display=="none") {
		document.body.style.cursor = 'progress';
		link.style.cursor = 'progress';
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				slideShowRack.innerHTML = data;
				var callback2 = function() {
					document.body.style.cursor = 'auto';
					link.style.cursor = 'auto';
				}
				var callback = function() {
					dojo.fx.html.wipeIn(slideShowRack, 1000, callback2);
				}
				dojo.fx.html.wipeOut(upperSearchComposite, 1000, callback);
			},
			mimetype: "text/html"
		});
	} else {
		document.body.style.cursor = 'progress';
		link.style.cursor = 'progress';
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				slideShowRack.innerHTML = data;
			},
			mimetype: "text/html"
		});
	}
}

function toggleArticle(link, articleId, url) {
	var node = dojo.byId(articleId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		document.body.style.cursor = 'progress';
		link.style.cursor = 'progress';
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				node.innerHTML = data;
				dojo.fx.html.wipeIn(node, 1000, function() {
					/*
					The following code does not work with ie.
					It is a nice-to-have feature:

					var href = document.location.href;
					var pos = href.indexOf('#');
					if(pos)
					{
						href = href.substring(0,pos);
					}
					document.location.href = href + "#" + articleId;
					document.location.hash = articleId; */
					document.body.style.cursor = 'auto';
					link.style.cursor = 'auto';
				});
			},
			mimetype: "text/html"
		});
	} else {
		dojo.fx.html.wipeOut(node, 100);	
	}
}

function jumpTo(nodeId) {
	document.location.hash = nodeId;
}
