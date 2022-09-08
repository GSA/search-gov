/* eslint-disable no-var, prefer-const, prefer-destructuring */
var button = document.getElementsByClassName('usa-banner__button')[0];
var bannerContent = document.getElementsByClassName('usa-banner__content')[0];

button.addEventListener('click', function () {
  bannerContent.toggleAttribute('hidden');
  this.setAttribute('aria-expanded', 
    this.getAttribute('aria-expanded') === 'true' 
      ? 'false' : 'true');
});
