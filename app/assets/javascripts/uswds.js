let [button] = document.getElementsByClassName('usa-banner__button');
let [bannerContent] = document.getElementsByClassName('usa-banner__content');

button.addEventListener('click', function() {
  bannerContent.toggleAttribute('hidden');
  this.setAttribute('aria-expanded', 
    this.getAttribute('aria-expanded') === 'true' 
      ? 'false' : 'true');
});
