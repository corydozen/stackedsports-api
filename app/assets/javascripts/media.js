var dropArea;
var files = [];

$(document).ready(function(){
  // toggle_sub_nav();
  $(".best_in_place").best_in_place();
  $("#media-filter-icon-container").click(function() {
    $("#media-filters").toggleClass("is-hidden")
  })
  $(".media-filter-checkbox").click(function(e) {
    var vars = getQueryStringVars();

    var tags = [];

    if (typeof vars.tags !== 'undefined' && vars.tags !== '') {
      tags = vars.tags.split(',');
    }

    if ($(e.target).is(':checked')) {
      tags.push(e.target.name)
    } else {
      var indexOf = tags.indexOf(encodeURIComponent(e.target.name));
      if (indexOf > -1) {
        tags.splice(indexOf, 1);
      }
    }
    vars.tags = tags.join(',');
    location.href = getLocationFromVarsArray(vars);
  });
  $(".media-selected-tag").click(function(e) {
    var vars = getQueryStringVars();
    var tags = vars.tags.split(',');
    var indexOf = tags.map(function(t) { return t.toLowerCase() }).indexOf(encodeURIComponent($(e.target).attr('tag')));
    if (indexOf > -1) {
      tags.splice(indexOf, 1);
    }
    vars.tags = tags.join(',');
    location.href = getLocationFromVarsArray(vars);
  });
  $(".media-filter-type").click(function(e) {
    var vars = getQueryStringVars();
    vars.type = $(e.target).attr('data-type');
    location.href = getLocationFromVarsArray(vars);
  });
  $("#media-filter-search").keyup(function(e) {
    if (e.keyCode === 13) {
      var vars = getQueryStringVars();
      vars.name = e.target.value;
      location.href = getLocationFromVarsArray(vars);
    }
  });
  $(".media-hover-checkbox").click(function(e) {
    if ($(e.target).is(":checked")) {
      $(e.target.parentElement.parentElement).addClass('active');
    } else {
      $(e.target.parentElement.parentElement).removeClass('active');
    }
    showOrHideMediaActions();
  });
  $(".clear-selected-button").click(function(e) {
    var arr = $(".media-hover-checkbox:checked").toArray();
    for (var e in arr) {
      $(arr[e]).prop('checked', false);
    }
    showOrHideMediaActions();
  });
  $("#media-add-tag-button").click(function(e) {
    e.preventDefault();
    $("#media-add-tag-modal").addClass('is-active');
  });
  $("#media-add-tag-modal-close,#media-add-tag-cancel").click(function(e) {
    e.preventDefault();
    $("#media-add-tag-modal").removeClass('is-active');
  });
  $("#media-add-tag-radio-new,#media-add-tag-radio-existing").click(function() {
    if ($("#media-add-tag-radio-new").is(':checked')) {
      $("#media-add-tag-existing").attr('disabled', '');
      $("#media-add-tag-new").removeAttr('disabled');
    } else {
      $("#media-add-tag-existing").removeAttr('disabled');
      $("#media-add-tag-new").attr('disabled', '');
    }
  });
  $("#media-add-tag-save").click(function() {
      var $selectedMedia = $("input.media-hover-checkbox[type='checkbox']:checked").toArray();
      var media_ids = [];
      var tag_list = '';
      if ($("#media-add-tag-radio-existing").is(':checked')) {
        tag_list = $("#media-add-tag-existing").val();
      } else if ($("#media-add-tag-radio-new").is(':checked')) {
        tag_list = $("#media-add-tag-new").val();
      }
      for (var m in $selectedMedia) {
        media_ids.push($($selectedMedia[m]).attr('data-id'));
        $($selectedMedia[m]).click();
      }
      $.post('/media-library/add_tags', { media_ids: media_ids, tag_list: [tag_list] })
      .complete(function(msg, status) {
        $("#media-add-tag-modal").removeClass('is-active');
      });
  });
  $(".media-hover-play").click(function(e) {
    if ($(e.target).attr('data-type') === 'video') {
      $("#media-video-player-modal source").attr('src', $(e.target).parent().attr('data-url'));
      $("#media-video-player-modal").addClass("is-active");
      document.getElementById("media-video-player-modal-video").play();
    } else {
      $("#media-image-viewer-modal img").attr('src', $(e.target).parent().attr('data-url'));
      $("#media-image-viewer-modal").addClass("is-active");
    }
  });
  $(".modal-background,.modal-close").click(function(e) {
    $("#media-video-player-modal").removeClass("is-active");
    $("#media-image-viewer-modal").removeClass("is-active");
    $("#media-upload-modal").removeClass("is-active");
  });

  $("#media-new-button").click(function(e) {
    e.preventDefault();
    $("#media-upload-modal").addClass("is-active");
  })

  // https://www.smashingmagazine.com/2018/01/drag-drop-file-uploader-vanilla-js/
  dropArea = document.getElementById('media-upload-modal-drop-area');

  if (dropArea) {
    dropArea.addEventListener('dragenter', dragEnter, false);
    dropArea.addEventListener('dragleave', dragLeave, false);
    dropArea.addEventListener('dragover', dragOver, false);
    dropArea.addEventListener('drop', drop, false);
  }

  $(".media-upload-modal-next").click(function(e) {
    e.preventDefault();
    if ($("#media-upload-modal .modal-card-head .column[data-step='1']").hasClass('has-text-weight-bold') && files.length > 0){
      moveToStep(2);
    } else if ($("#media-upload-modal .modal-card-head .column[data-step='2']").hasClass('has-text-weight-bold')){
      moveToStep(3);
    }
  });
  $(".media-upload-modal-previous").click(function(e) {
    e.preventDefault();
    if ($("#media-upload-modal .modal-card-head .column[data-step='2']").hasClass('has-text-weight-bold') && files.length > 0){
      moveToStep(1);
    } else if ($("#media-upload-modal .modal-card-head .column[data-step='3']").hasClass('has-text-weight-bold')){
      moveToStep(2);
    }
  });
  $("#media-upload-tag-new-text").click(function(e) {
    $("#media-upload-tag-new-checkbox").attr('checked', '');
  });
  $("#media-upload-tag-new-checkbox").click(function(e) {
    if (!$("#media-upload-tag-new-checkbox").is(':checked')) {
      $("#media-upload-tag-new-text").val('');
    }
  });
  $("#media-upload-modal-upload").click(function(e) {
    var media_ids = [];
    for (var f in files) {
      if (!files[f].deleted) {
        media_ids.push(files[f].id);
      }
    }
    var tag_list = [];
    $selectedTags = getSelectedTags();
    for (var t in $selectedTags) {
      if ($($selectedTags[t]).attr('id') === 'media-upload-tag-new-checkbox' && $("#media-upload-tag-new-text").val() !== '') {
        tag_list.push($("#media-upload-tag-new-text").val());
      } else {
        tag_list.push($($selectedTags[t]).attr('data-value'));
      }
    }
    $.post('/media-library/add_tags', { media_ids: media_ids, tag_list: tag_list })
      .complete(function(msg, status) {
        location.reload();
      })
  })
  $(document).on('click', '.media-upload-remove', function(e) {
    e.preventDefault();
    var $mediumDiv = $(e.target).parent().parent();
    var temp_id = $mediumDiv.attr('data-temp-id');
    files[temp_id].deleted = true;
    if ($mediumDiv.attr('data-id') !== '') {
      // If it's done uploading, delete it.
      deleteMedium($mediumDiv.attr('data-id'));
    } else {
      // Otherwise, the upload success function will see the `deleted` attribute and delete it after it's done uploading.
      $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "']").addClass('is-hidden').next().addClass('is-hidden');
    }
  });
  $("#media-upload-modal .modal-background").click(function() {
    deleteAllMedia();
  });
  $("#media-upload-modal .modal-close").click(function() {
    deleteAllMedia();
  });
  $("#media-upload-tag-new-text").keydown(function(e) {
    // Don't let them type in a comma
    if (e.keyCode === 188) {
      return false;
    }
  });
  $("#media-edit-save-button").click(function(e) {
    e.preventDefault();
    var tag_list = [];
    $selectedTags = $(".media-edit-tag-checkbox[type='checkbox']:checked").toArray();
    for (var t in $selectedTags) {
      if ($($selectedTags[t]).attr('id') === 'media-edit-tag-new-text' && $("#media-edit-tag-new-text").val() !== '') {
        tag_list.push($("#media-edit-tag-new-text").val());
      } else {
        tag_list.push($($selectedTags[t]).attr('data-value'));
      }
    }
    $.post('/media-library/add_tags', { media_ids: [$(e.target).attr('data-id')], tag_list: tag_list })
      .complete(function(msg, status) {
        location.reload();
      })
  });
  $(document).on("click", ".media-edit-current-checkbox", function(e) {
    if ($(e.target).is(':checked')) {
      $(".media-edit-tag-checkbox[data-value='" + $(e.target).attr('data-value') + "']").prop('checked', true);
      addTag($(e.target).attr('data-value'));
    } else {
      $(".media-edit-tag-checkbox[data-value='" + $(e.target).attr('data-value') + "']").prop('checked', false);
      removeTag($(e.target).attr('data-value'));
    }
  });
  $(document).on("click", ".media-edit-tag-checkbox", function(e) {
    if ($(e.target).attr('id') === 'media-edit-tag-new-checkbox') {
      if ($("#media-edit-tag-new-text").val() !== "") {
        addTag($("#media-edit-tag-new-text").val());
      }
    } else {
      if ($(e.target).is(':checked')) {
        $(".media-edit-current-checkbox[data-value='" + $(e.target).attr('data-value') + "']").prop('checked', true);
        var tag = '';
        if ($(e.target).attr('id') === 'media-edit-tag-new-checkbox') {
          tag = $("#media-edit-tag-new-text").val();
        } else {
          tag = $(e.target).attr('data-value');
        }
        addTag(tag);
      } else {
        $(".media-edit-current-checkbox[data-value='" + $(e.target).attr('data-value') + "']").prop('checked', false);
        removeTag($(e.target).attr('data-value'));
      }
    }
  });
  $(document).on('keydown', "#media-edit-tag-new-text", function(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      addTag($("#media-edit-tag-new-text").val());
    }
  })
});

function removeTag(tag) {
  $.ajax('/media-library/' + $("#media-edit-tag-new-checkbox") + '/remove_tag', {
    method: 'DELETE',
    data: {tag: tag},
    dataType: 'script',
    format: 'js',
    complete(res) {
      switch (res.status) {
        case 200:
        case 201:
        case 204:
          reDrawTags(JSON.parse(res.responseText));
          break;
        default:
          console.log('Error saving tag', res);
          break;
      }
    }
  });
}

function addTag(tag) {
  $.post('/media-library/' + $("#media-edit-tag-new-checkbox").attr('data-medium-id') + '/add_tag', {tag: tag})
  .complete(function(res) {
      switch (res.status) {
        case 200:
        case 201:
        case 204:
          reDrawTags(JSON.parse(res.responseText));
          break;
        default:
          console.log('Error saving tag', res);
          break;
      }
    });
}

function reDrawTags(obj) {
  var h = '';
  if (obj.current_tags.length === 0) {
    h = 'No current tags';
  } else {
    for (var t in obj.current_tags) {
      h += `<input type="checkbox" class="media-edit-current-checkbox" checked id="media-edit-current-tag-${obj.current_tags[t].replace(' ', '-')}" data-value="${obj.current_tags[t]}">
          <label for="media-edit-current-tag-${obj.current_tags[t].replace(' ', '-')}">${obj.current_tags[t]}</label><br>`;
    }
  }
  $("#media-edit-current-tags").html(h);
  h = `<div class="column is-1">
            <input type="checkbox" class="media-edit-tag-checkbox" id="media-edit-tag-new-checkbox" data-medium-id="${$("#media-edit-tag-new-checkbox").attr('data-medium-id')}">
          </div>
          <div class="column is-5">
            <label for="media-edit-tag-new-checkbox"><input class="input media-input" type="text" id="media-edit-tag-new-text"></label>
          </div>`;
  for (var t in obj.tags) {
    h += `<div class="column is-1">
                <input type="checkbox" class="media-edit-tag-checkbox" id="media-edit-tag-${obj.tags[t].replace(' ', '-')}-checkbox" ${obj.current_tags.filter(function(f) { return f === obj.tags[t]; }).length > 0 ? 'checked' : '' } data-value="${obj.tags[t]}" data-medium-id="${$("#media-edit-tag-new-checkbox").attr('data-medium-id')}">
              </div>
              <div class="column is-5">
                <label for="media-edit-tag-${obj.tags[t].replace(' ', '-')}-checkbox">${obj.tags[t]}</label>
              </div>`
  }
  $("#media-edit-tags").html(h);
}

function deleteAllMedia() {
  for (var f in files) {
    if (!files[f].deleted) {
      files[f].deleted = true;
      if (files[f].id) {
        deleteMedium(files[f].id);
      }
    }
  }
  resetTags();
}

function resetTags() {
  $("input[type='checkbox'].media-upload-tag").removeAttr('checked');
  moveToStep(1);
}

function deleteMedium(medium_id) {
  $.ajax('/media-library/' + medium_id, {
    method: 'DELETE',
    dataType: 'script',
    format: 'js',
    complete(msg, status) {
      var medium_id = this.url.split('/')[this.url.split('/').length - 1];
      $(".media-upload-modal-file-uploading[data-id='" + medium_id + "']").addClass('is-hidden').next().addClass('is-hidden');
    }
  })
}

function getSelectedTags() {
  var ret = [];
  $selectedTags = $("input[type='checkbox'].media-upload-tag").toArray();
  for (var t in $selectedTags) {
    if (t < $selectedTags.length && $($selectedTags[t]).is(':checked')) {
      ret.push($selectedTags[t]);
    }
  }
  return ret;
}

function moveToStep(step) {
  // Header
  $("#media-upload-modal .modal-card-head .column").removeClass('has-text-weight-bold');
  for (var s = 1; s < 3; s++) {
    if (s < step) {
      $("#media-upload-modal .modal-card-head .column[data-step='" + s + "'] .step-text").html(`<i class="far fa-check"></i>`);
    } else {
      $("#media-upload-modal .modal-card-head .column[data-step='" + s + "'] .step-text").html(s);
    }
  }
  $("#media-upload-modal .modal-card-head .column[data-step='" + step + "']").addClass('has-text-weight-bold');

  // Body
  $(".media-upload-modal-step-container").addClass('is-hidden');
  $(".media-upload-modal-step-container[data-step='" + step + "']").removeClass('is-hidden');
  if (step === 1) {
    $(".media-upload-modal-previous").addClass('is-hidden');
  } else {
    $(".media-upload-modal-previous").removeClass('is-hidden');
  }
  if (step === 3) {
    $selectedTags = getSelectedTags();
    var h = '';
    for (var t in $selectedTags) {
      if ($($selectedTags[t]).attr('id') === 'media-upload-tag-new-checkbox') {
        h += `<div class="media-selected-tag media-upload-review-tag">${$("#media-upload-tag-new-text").val()}</div>`
      } else {
        h += `<div class="media-selected-tag media-upload-review-tag">${$($selectedTags[t]).attr('data-value')}</div>`
      }
    }
    $("#media-upload-review-selected-tags").html(h);
    $("#media-upload-modal-next").addClass('is-hidden');
    $("#media-upload-modal-upload").removeClass('is-hidden');
    var numberOfFiles = files.filter(function(f) { return !f.deleted }).length;
    $("#media-upload-review-number-of-files").html(numberOfFiles + " File" + (numberOfFiles === 1 ? '' : 's'))
  } else {
    $("#media-upload-modal-next").removeClass('is-hidden');
    $("#media-upload-modal-upload").addClass('is-hidden');
  }
}


function dragEnter(e) {
  preventDefaults(e);
  highlight();
}
function dragLeave(e) {
  preventDefaults(e);
  unhighlight();
  
}
function dragOver(e) {
  preventDefaults(e);
  highlight();
  
}
function drop(e) {
  preventDefaults(e);
  unhighlight();
  handleDrop(e);
}

function handleDrop(e) {
  var dt = e.dataTransfer;
  handleFiles(dt.files);
}

function handleFiles(uploadingFiles) {
  $("#media-upload-modal-no-files").addClass('is-hidden');
  $("#media-upload-modal-has-files").removeClass('is-hidden');
  for (var f in uploadingFiles) {
    // This if statement leaves out the 'length' and 'item()' parameters of the object
    if (f < uploadingFiles.length) {
      uploadFile(uploadingFiles[f]);
    }
  }
}

function uploadFile(file) {
  var formData = new FormData();

  var newLength = files.push(file);

  $("#media-upload-modal-has-files").append(`
    <div class="media-upload-modal-file-uploading columns" data-id="" data-temp-id="${newLength - 1}">
      <div class="column is-1">
        <div class="gray-circle"></div>
      </div>
      <div class="column has-text-left">
        <div class="media-uploading">
          Still Uploading...<br>
          <progress max=100 value=5></progress>
        </div>
      </div>
      <div class="column is-1"><a href="#" class="media-upload-remove" data-id="" data-temp-id="${newLength - 1}">&times;</a></div>
    </div>
    <hr class="media-light" />
    `);
  
  files[newLength - 1].interval_id = setInterval(increaseProgressBar.bind(null, newLength - 1), 500)

  formData.append('object', file);

  // I'm only putting the temp_id on the url so that I can access it in the `complete` function
  $.ajax('/media-library/upload?temp_id=' + (newLength - 1), {
    method: 'POST',
    data: formData,
    processData: false,
    contentType: false,
    complete: function(msg, status) {
      var temp_id = this.url.split('=')[1];
      clearInterval(files[temp_id].interval_id);
      $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] .has-text-left .media-uploading").remove();
      switch (msg.status) {
        case 200:
        case 201:
          // success
          if (files[temp_id].deleted) {
            deleteMedium(msg.responseText);
          } else {
            files[temp_id].id = msg.responseText;
            $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "']").attr('data-id', msg.responseText);
            $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] .has-text-left").append(files[temp_id].name);
            $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] .media-upload-remove").attr('data-id', msg.responseText).html(`<i class="far fa-trash"></i>`);
            $(".media-upload-modal-next").removeAttr('disabled');
          }
          break;
        default:
          // failure
          $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] .has-text-left").append('UPLOAD FAILED!');
          $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] .media-upload-remove").attr('data-id', msg.responseText).html('');
          break;
      }
    },
  });
}

function increaseProgressBar(temp_id) {
  var $progress = $(".media-upload-modal-file-uploading[data-temp-id='" + temp_id + "'] progress");
  $progress.attr('value', parseInt($progress.attr('value')) + 1)

  if (parseInt($progress.attr('value')) === 85) {
    clearInterval(files[temp_id].interval_id);
  }
}

function highlight() {
  $(dropArea).addClass('highlight');
}

function unhighlight() {
  $(dropArea).removeClass('highlight');
}

function preventDefaults(e) {
  e.preventDefault();
  e.stopPropagation();
}

function getQueryStringVars() {
  if (location.href.split('?').length === 1) {
    return [];
  }
  var querystring = location.href.split('?')[1];
  var vars = [];
  for (var v in querystring.split('&')) {
    vars[querystring.split('&')[v].split('=')[0]] = querystring.split('&')[v].split('=')[1];
  }

  return vars;
}

function getLocationFromVarsArray(vars) {
  var firstPart = location.href.split('?')[0];
  var newLocation = '';
  for (var v in firstPart.split('/')) {
    newLocation += v == firstPart.split('/').length - 1 ? 'media-library?' : firstPart.split('/')[v] + '/';
  }
  var newVars = []
  for (var v in vars) {
    newVars.push(v + '=' + vars[v])
  }
  newLocation += newVars.join('&');
  return newLocation;
}

function showOrHideMediaActions() {
  if ($(".media-hover-checkbox:checked").length === 0) {
    $("#media-actions").removeClass('active');
  } else {
    $("#media-actions").addClass('active');
  }
}
