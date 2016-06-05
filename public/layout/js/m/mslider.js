$(function() {
  $('.single-item').slick({
      appendArrows: $('#arrows'),
      // autoplay: true,
      // autoplaySpeed: 2000
  });
    
    $('.slick-next').on('click', function () {
        slickNext();
  });
    
    $('.slick-prev').on('click', function () {
        slickPrev();
  });
});