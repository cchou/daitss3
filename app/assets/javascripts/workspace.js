//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ajaxSend(function(e,xhr,options) {
  var token = $("meta[name='csrf-token']").attr('content');
  xhr.setRequestHeader("X-CSRF-Token", token);
});

function update() {
  alert('updating');
}


function init() {
  // update button handler
  $("#updateBtn").on("click",update);

}

window.onload = init;