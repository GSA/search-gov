var button = document.getElementsByClassName("usa-banner__button")[0];
var banner_content = document.getElementsByClassName("usa-banner__content")[0];

button.addEventListener("click", function(){
  banner_content.toggleAttribute("hidden");
  this.setAttribute("aria-expanded", 
    this.getAttribute("aria-expanded") === "true" 
      ? "false" : "true");
});
