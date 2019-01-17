var toggle_filters = function () {
  if( $('.is-sidebar-menu').css("width") !== '50px' && !$('.athlete-filters').is(':visible')){
    toggle_sub_nav();
  }
    $('.athlete-filters').toggle();
      $(".hidden-filters").toggle();
};
