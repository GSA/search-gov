function getGeoLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(setGeoCookie);
    }
}

function setGeoCookie(position) {
    var cookie_val = position.coords.latitude + "," + position.coords.longitude;
    document.cookie = "lat_lon=" + encodeURIComponent(cookie_val);
}