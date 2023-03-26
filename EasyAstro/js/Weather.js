let Locatio = document.getElementById("search-bar");
let Locbutton = document.getElementById("search-button");
let Visbi = document.getElementById("visibility-number");
let Sunrise = document.getElementById("sunrise-time");
let Sunset = document.getElementById("sunset-time");
let CloudStatus = document.getElementById("cloudiness-desc");
let Hour3 = document.getElementById("soon");
let Hour6 = document.getElementById("later");
let Longi;
let Lati;

let formSubmitHandler = function (event) {
    event.preventDefault();

    let uSer = Locatio.value.trim();

    if (uSer) {
        getWeatherApi(uSer);
        Locatio.value = "";
    }
};

let getWeatherApi = function (pLace) {
    let requestUrl = 'https://api.openweathermap.org/data/2.5/forecast?q=' + pLace + '&appid=3ee6de7b8fdeda946857956b40bd39af';
    fetch(requestUrl)
        .then(function (response) {
            if (response.ok) {

                response.json().then(function (data) {
                    console.log(data);

                    //visibility
                    //console.log(data.list[0].visibility);
                    para = data.list[0].visibility;
                    //console.log(para);
                    let visity = para * 0.000621371;
                    let visityInMile = visity.toFixed(1);
                    //console.log(visityInMile);
                    Visbi.textContent = " " + visityInMile + " miles";

                    // sunrise 
                    //  calling moment function for converting UTC time to current time zone
                    let SunR = moment.unix(data.city.sunrise).format("kk:mm");
                    Sunrise.textContent = SunR;

                    //  Sunset 
                    let SunS = moment.unix(data.city.sunset).format("kk:mm");
                    Sunset.textContent = SunS;

                    // Getting Latitude & Longitude 
                    Longi = data.city.coord.lon;
                    Lati = data.city.coord.lat;
                    // console.log(Longi);
                    //console.log(Lati);

                    // New API 
                    let apiURL = 'https://api.openweathermap.org/data/2.5/onecall?lat=' + Lati + '&lon=' + Longi + '&appid=3ee6de7b8fdeda946857956b40bd39af';
                    console.log(apiURL);
                    fetch(apiURL)
                        .then(function (response) {
                            return response.json();

                        })
                        .then(function (data2) {
                            console.log(data2);
                            //cloud status currently
                            console.log(data2.current.weather[0].description);
                            CloudStatus.textContent = data2.current.weather[0].description;
                            // Cloud status after 3 hours
                            console.log(data2.hourly[3].weather[0].description);
                            // Cloud status after 6 hours
                            console.log(data2.hourly[6].weather[0].description);


                            // * ========= * //
                            // ** WEATHER ** //
                            let weather0Detail = data2.hourly[0].weather[0].description;
                            let weather3Detail = data2.hourly[0].weather[0].description;
                            let weather6Detail = data2.hourly[0].weather[0].description;
                            // collects ID for weather icon
                            let weather0Data = data2.hourly[0].weather[0].icon;
                            let weather0ID = data2.hourly[0].weather[0].id;
                            let weather3Data = data2.hourly[3].weather[0].icon;
                            let weather3ID = data2.hourly[3].weather[0].id;
                            let weather6Data = data2.hourly[6].weather[0].icon;
                            let weather6ID = data2.hourly[6].weather[0].id;
                            // collects % of clouds
                            let cloud0Data = data2.hourly[0].clouds;
                            //let cloud3Data = data2.hourly[3].clouds;
                            //let cloud6Data = data2.hourly[6].clouds;

                            console.log('weather0Data');
                            console.log(weather0Data);

                            let weatherIcon = document.querySelector('#weather-icon');
                            let eveningIcon = document.querySelector('#evening-icon');
                            let nightIcon = document.querySelector('#night-icon');
                            let weather0Text = document.querySelector('#weather-desc');
                            let weather3Text = document.querySelector('#evening-desc');
                            let weather6Text = document.querySelector('#night-desc');
                            let cloudNumber = document.querySelector('#cloudiness-number');

                            weather0Text.innerHTML = weather0Detail;
                            weather3Text.innerHTML = weather0Detail;
                            weather6Text.innerHTML = weather0Detail;
                            cloudNumber.innerHTML = `${cloud0Data}%`

                                                        
                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // ** WEATHER ICONS - 0h ** //
                            // DAYTIME WEATHER ICONS

                            // OpenWeather does not distinguish 'broken clouds' and 'overcast' on their icon codes
                            // 803 = broken clouds
                            if ((weather0ID == 803) && (weather0Data == '03d')) {
                                console.log('803-day');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if ((weather0ID == 803) && (weather0Data == '03n')) {
                                console.log('803-night');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-clouds-moon large-icon theme-cloud"></i>`;
                            // 804 = overcast
                            } else if (weather0ID == 804) {
                                console.log('804');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-clouds large-icon theme-overcast"></i>`;
                            // all other situations following are coded specifically to the #d/#n icon code or they apply to both times of day:
                            } else if (weather0Data == '01d') {
                                console.log('01d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-sun large-icon theme-sun"></i>`;
                            } else if (weather0Data == '02d') {
                                console.log('02d');
                                weatherIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-sun-cloud large-icon theme-sun-cloud"></i>`;
                            } else if (weather0Data == '03d') {
                                console.log('03d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather0Data == '04d') {
                                console.log('04d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather0Data == '09d') {
                                console.log('09d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-rain-snow"></i>`;
                            } else if (weather0Data == '10d') {
                                console.log('10d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-sun-rain large-icon theme-sun-cloud"></i>`;
                            } else if (weather0Data == '11d') {
                                console.log('11d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-thunderstorm-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather0Data == '13d') {
                                console.log('13d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-snow large-icon theme-rain-snow"></i>`;
                            } else if (weather0Data == '50d') {
                                console.log('50d');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-fog large-icon theme-cloud"></i>`;
                            }
                            // NIGHTTIME WEATHER ICONS
                            else if (weather0Data == '01n') {
                                console.log('01n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-moon large-icon theme-moon"></i>`;
                            } else if (weather0Data == '02n') {
                                console.log('02n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-moon-cloud large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '03n') {
                                console.log('03n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '04n') {
                                console.log('04n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-clouds-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '09n') {
                                console.log('09n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '10n') {
                                console.log('10n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-cloud-moon-rain large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '11n') {
                                console.log('11n');
                                weatherIcon.innerHTML = `<i id="weather-icon" class="small-icon fad fa-thunderstorm-moon large-icon theme-moon-cloud"></i>`;
                            };


                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // ** WEATHER ICONS - 3h ** //
                            // DAYTIME WEATHER ICONS

                            // OpenWeather does not distinguish 'broken clouds' and 'overcast' on their icon codes
                            // 803 = broken clouds
                            if ((weather3ID == 803) && (weather3Data == '03d')) {
                                console.log('803-day');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if ((weather3ID == 803) && (weather3Data == '03n')) {
                                console.log('803-night');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-clouds-moon large-icon theme-cloud"></i>`;
                                // 804 = overcast
                            } else if (weather3ID == 804) {
                                console.log('804');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-clouds large-icon theme-overcast"></i>`;
                                // all other situations following are coded specifically to the #d/#n icon code or they apply to both times of day:
                            } else if (weather3Data == '01d') {
                                console.log('01d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-sun large-icon theme-sun"></i>`;
                            } else if (weather3Data == '02d') {
                                console.log('02d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-sun-cloud large-icon theme-sun-cloud"></i>`;
                            } else if (weather3Data == '03d') {
                                console.log('03d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather3Data == '04d') {
                                console.log('04d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather3Data == '09d') {
                                console.log('09d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-rain-snow"></i>`;
                            } else if (weather3Data == '10d') {
                                console.log('10d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-sun-rain large-icon theme-sun-cloud"></i>`;
                            } else if (weather3Data == '11d') {
                                console.log('11d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-thunderstorm-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather3Data == '13d') {
                                console.log('13d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-snow large-icon theme-rain-snow"></i>`;
                            } else if (weather3Data == '50d') {
                                console.log('50d');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-fog large-icon theme-cloud"></i>`;
                            }
                            // NIGHTTIME WEATHER ICONS
                            else if (weather3Data == '01n') {
                                console.log('01n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-moon large-icon theme-moon"></i>`;
                            } else if (weather3Data == '02n') {
                                console.log('02n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-moon-cloud large-icon theme-moon-cloud"></i>`;
                            } else if (weather3Data == '03n') {
                                console.log('03n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather3Data == '04n') {
                                console.log('04n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-clouds-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '09n') {
                                console.log('09n');
                                weatherIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-moon-cloud"></i>`;
                            } else if (weather3Data == '10n') {
                                console.log('10n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-cloud-moon-rain large-icon theme-moon-cloud"></i>`;
                            } else if (weather3Data == '11n') {
                                console.log('11n');
                                eveningIcon.innerHTML = `<i id="evening-icon" class="small-icon fad fa-thunderstorm-moon large-icon theme-moon-cloud"></i>`;
                            };

                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // * ==================== * //
                            // ** WEATHER ICONS - 6h ** //
                            // DAYTIME WEATHER ICONS

                            // OpenWeather does not distinguish 'broken clouds' and 'overcast' on their icon codes
                            // 803 = broken clouds
                            if ((weather6ID == 803) && (weather6Data == '03d')) {
                                console.log('803-day');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if ((weather6ID == 803) && (weather6Data == '03n')) {
                                console.log('803-night');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-clouds-moon large-icon theme-overcast"></i>`;
                                // 804 = overcast
                            } else if (weather6ID == 804) {
                                console.log('804');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-clouds large-icon theme-cloud"></i>`;
                                // all other situations following are coded specifically to the #d/#n icon code or they apply to both times of day:
                            } else if (weather6Data == '01d') {
                                console.log('01d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-sun large-icon theme-sun"></i>`;
                            } else if (weather6Data == '02d') {
                                console.log('02d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-sun-cloud large-icon theme-sun-cloud"></i>`;
                            } else if (weather6Data == '03d') {
                                console.log('03d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather6Data == '04d') {
                                console.log('04d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-clouds-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather6Data == '09d') {
                                console.log('09d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-rain-snow"></i>`;
                            } else if (weather6Data == '10d') {
                                console.log('10d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-sun-rain large-icon theme-sun-cloud"></i>`;
                            } else if (weather6Data == '11d') {
                                console.log('11d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-thunderstorm-sun large-icon theme-sun-cloud"></i>`;
                            } else if (weather6Data == '13d') {
                                console.log('13d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-snow large-icon theme-rain-snow"></i>`;
                            } else if (weather6Data == '50d') {
                                console.log('50d');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-fog large-icon theme-cloud"></i>`;
                            }
                            // NIGHTTIME WEATHER ICONS
                            else if (weather6Data == '01n') {
                                console.log('01n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-moon large-icon theme-moon"></i>`;
                            } else if (weather6Data == '02n') {
                                console.log('02n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-moon-cloud large-icon theme-moon-cloud"></i>`;
                            } else if (weather6Data == '03n') {
                                console.log('03n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather6Data == '04n') {
                                console.log('04n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-clouds-moon large-icon theme-moon-cloud"></i>`;
                            } else if (weather0Data == '09n') {
                                console.log('09n');
                                weatherIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-showers-heavy large-icon theme-moon-cloud"></i>`;
                            } else if (weather6Data == '10n') {
                                console.log('10n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-cloud-moon-rain large-icon theme-moon-cloud"></i>`;
                            } else if (weather6Data == '11n') {
                                console.log('11n');
                                nightIcon.innerHTML = `<i id="night-icon" class="small-icon fad fa-thunderstorm-moon large-icon theme-moon-cloud"></i>`;
                            };

                        })
                }
            );
        };
    })
}
Locbutton.addEventListener('click', formSubmitHandler);
