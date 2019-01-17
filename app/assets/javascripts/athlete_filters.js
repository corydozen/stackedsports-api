var submit_filters = function(elem) {
  data = {
    search: $('#search').val(),
    years: $('input[type="checkbox"][name="years\\[\\]"]:checked').map(function() {
      return this.value;
    }).get(),
    states: $('input[type="checkbox"][name="states\\[\\]"]:checked').map(function() {
      return this.value;
    }).get(),
    positions: $('input[type="checkbox"][name="position\\[\\]"]:checked').map(function() {
      return this.value;
    }).get(),
    position_type: $('input[type="checkbox"][name="position_type\\[\\]"]:checked').map(function() {
      return this.value;
    }).get(),
    tags: null
  };
  console.log(JSON.stringify(data));

  // Set hidden field to criteria
  $('#filter_criteria').val(JSON.stringify(data));

  $.ajax({
    type: "POST",
    url: elem.data('url'),
    data: data
  });
};

$(document).ready(function() {
  $('.filter.is-checkradio').click(function() {
    submit_filters($(this));
  });
});
