var button = document.getElementsByClassName("usa-banner__button")[0];
var banner_content = document.getElementsByClassName("usa-banner__content")[0];

button.addEventListener("click", function(){
    var is_hidden = banner_content.getAttribute("hidden");
    if(is_hidden){
        banner_content.removeAttribute("hidden");
        this.setAttribute("aria-expanded", "true");
    }
    else{
        banner_content.setAttribute("hidden", "true");
        this.setAttribute("aria-expanded", "false");
    }
});
