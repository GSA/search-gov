(function () {
  var button = document.querySelector(".usa-banner__button");
  var content = document.getElementById("gov-banner");
  var header = document.querySelector(".usa-banner__header");
  if (!button || !content || !header) return;

  button.addEventListener("click", function () {
    var expanded = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", expanded ? "false" : "true");
    content.hidden = expanded;
    header.classList.toggle("usa-banner__header--expanded", !expanded);
  });
}());
