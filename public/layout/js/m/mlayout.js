$('head').append(
      '<style type="text/css">.contents { display: none; } #fade, #loader { display: block; }</style>'
  );
   
  jQuery.event.add(window,"load",function() { // 全ての読み込み完了後に呼ばれる関数
      var pageH = $(".contents").height()+100;
   
      $("#fade").css("height", pageH).delay(0).fadeOut(1000);
      $("#loader").delay(0).fadeOut(1000);
      $(".contents").css("display", "block");
  });