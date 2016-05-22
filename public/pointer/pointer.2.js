$(document).ready(function(){
	$('body').pointer();
});

(function($){
	$.fn.pointer = function (options) {
		var settings = {
			size : 80,
			spd : 300,
			color : "rgb(255,0,0)"
		}
		settings = $.extend(settings, options);
		
		var circle_style = {
			"position":"absolute",
			"z-index":9999,
			"height":10,
			"width":10,
			"background-image": "url('/image/emptyheart2.png')",
			"background-size": "80px 80px",
			"background-position": "center center"
		// 	"border":"solid 4px "+settings.color,
		// 	"border-radius":settings.size
	    }
		return this.each(function() {
			var $this = $(this);
			$this.css({"position":"relative"});
			$(document).click(function(e){
				var x = e.pageX;
				var y = e.pageY;
				
				var pos = {
					top :-40+y,
					left :-40+x
				}
		
				$this.append('<div class="circle"></div>');
				$this.find(".circle:last").css(circle_style).css({
					"top":y,
					"left":x
				}).animate({"height":settings.size,"width":settings.size,"left":pos.left,"top":pos.top},{duration:settings.spd,queue:false})
				.fadeOut(settings.spd*1.8,function(){
					$(this).remove();
				});
			});
		});
	}
})(jQuery); 