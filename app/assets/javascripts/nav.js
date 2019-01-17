$( document ).ready(function() {

  // Check for click events on the navbar burger icon
  $(".navbar-burger").click(function() {

    // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
    $(".navbar-burger").toggleClass("is-active");
    $(".navbar-menu").toggleClass("is-active");

  });

  $('.sub-nav-toggle').click(function() {
    toggle_sub_nav();
  });

});


var toggle_sub_nav = function() {

  $(".fa-toggle-on").toggle();
  $(".fa-toggle-off").toggle();

  // $(".fa-eye-slash").toggle();
  $(".hidden-sub-menu").toggle();


  if ($('.is-sidebar-menu').css("width") !== '50px') {
    $('.is-sidebar-menu').css('width', '50px');
    $('.is-sidebar-menu').css('min-width', '50px');
  } else {
    $('.is-sidebar-menu').css('width', '');
    $('.is-sidebar-menu').css('min-width', '');
  }

  $('.sub_nav').toggle();

  // if ($('.is-main-content').hasClass('is-10')){
  //   $('.is-main-content').removeClass('is-10')
  // } else {
  //   $('.is-main-content').addClass('is-10')
  // }
};


// <script type="text/javascript">
//
// $( document ).ready(function() {
//   // TODO add filter menu toggle
//
//   var hoverTimeout,
//     keepOpen = false,
//     stayOpen = $('.stay-open');
//   $(document).on('mouseenter', '.footer-profile-image', function () {
//     clearTimeout(hoverTimeout);
//     stayOpen.show();
//   }).on('mouseleave', '.footer-profile-image', function () {
//     clearTimeout(hoverTimeout);
//     hoverTimeout = setTimeout(function () {
//       if (!keepOpen) {
//         stayOpen.hide();
//       }
//     }, 500);
//   });
//
//   $(document).on('mouseenter', '.stay-open', function () {
//     keepOpen = true;
//     setTimeout(function () {
//       keepOpen = false;
//     }, 1500);
//   }).on('mouseleave', '.stay-open', function () {
//     keepOpen = false;
//     stayOpen.hide();
//   });
//
// });
// </script>
