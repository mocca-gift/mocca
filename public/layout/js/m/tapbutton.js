$(document).ready(function(){
  
     $('.btns').on('touchstart', function(e) {
          $(this).addClass('tapStyle');
      });
      
    $('.btns').on('touchend', function(e) {
          $(this).removeClass('tapStyle');
      });
  });