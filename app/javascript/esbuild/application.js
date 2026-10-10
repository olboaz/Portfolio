import * as ActiveStorage from "@rails/activestorage";
import Rails from "@rails/ujs";
import $ from "jquery";
import Turbolinks from "turbolinks";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

window.$ = $;
window.jQuery = $;

// Bootstrap 4 et Select2 utilisent jQuery.
// On les charge après avoir exposé jQuery globalement.
require("bootstrap");
const select2 = require("select2/dist/js/select2.full.js");

if (typeof select2 === "function") {
  select2(window, $);
}

document.addEventListener("turbolinks:load", () => {
  const selects = $(".js-example-basic-single");

  selects.each(function () {
    if (!$(this).hasClass("select2-hidden-accessible")) {
      $(this).select2({
        minimumResultsForSearch: Infinity,
      });
    }
  });
});
