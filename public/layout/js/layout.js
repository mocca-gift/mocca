$('head').append(
    '<style type="text/css">.wrapper { display: none; } #fade, #loader { display: block; }</style>'
);

jQuery.event.add(window,"load",function() { // 全ての読み込み完了後に呼ばれる関数
    var pageH = $(".body").height();
   
    $("#fade").css("height", pageH).delay(1000).fadeOut(1000);
    $("#loader").delay(1000).fadeOut(1000);
    $(".wrapper").css("display", "block");
});

$(document).ready(function(){
  
  
    $('.menu-q > a').hover(
         function(){
             $( '.q_description' ).fadeIn();
         },
         function(){
             $( '.q_description' ).fadeOut();
         }
     );
     $('.menu-n > a').hover(
         function(){
             $( '.n_description' ).fadeIn();
         },
         function(){
             $( '.n_description' ).fadeOut();
         }
     );
 
     $('.menu-i > a').hover(
         function(){
             $( '.i_description' ).fadeIn();
         },
         function(){
             $( '.i_description' ).fadeOut();
         }
     );
     
});