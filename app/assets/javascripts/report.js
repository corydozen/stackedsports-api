
$( document ).ready(function() {
  $('#view-more-qc, #view-more-ql, #view-more-commits, #view-more-offers, #view-more-cv').click(function(e){
    e.preventDefault();
    linkText = $(this).text();

    if (~linkText.indexOf("More")) {
      $(this).text('View Less');
      showMore($(this));
    } else {
      $(this).text('View More');
      showLess($(this));
    }

  });
})

var showMore = function(elem){
  elem.parent().parent().siblings().children('.is-hidden').addClass('is-visible');
};

var showLess = function(elem){
  elem.parent().parent().siblings().children('.is-hidden').removeClass('is-visible');
};
