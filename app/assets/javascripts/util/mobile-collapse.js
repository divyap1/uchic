if ($(window).width() < 768) {
  $(".toggle-section").each(function() {
    $($(this).data("target")).addClass("hidden");
    $(this).addClass("collapsed");
  });

  $(".toggle-section").removeClass("hidden").on("click", function() {
    $($(this).data("target")).toggleClass("hidden");
    $(this).toggleClass("collapsed");
  });
}
