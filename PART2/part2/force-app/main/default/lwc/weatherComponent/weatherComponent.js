import { LightningElement, api } from 'lwc';
import findCity from '@salesforce/apex/WeatherClass.find_city'

import getDefaultCity from '@salesforce/apex/WeatherClass.get_default_city';

import has_permission from '@salesforce/apex/WeatherClass.has_permission';

const WIND_DIRECTIONS = [
    'north', 'northeastern',
    'east', 'southeastern',
    'south', 'southwestern',
    'west', 'northwestern'
];


export default class WeatherComponent extends LightningElement {
    @api cityName
    status=false;
    loading=false;
    @api maininfo = '';
    @api moreinfo = '';
    iconUrl = '';
    hasPermission=true;

    firstError = true;//it's bad
    
    get_wind_direction(deg) {
        return WIND_DIRECTIONS[Math.floor((deg + 22.5) % 360 / 45)];
    }
    
    get_cloud_state(percent) {
        if (percent <= 11) {
            return 'No clouds';
        }
        else if (percent <= 25) {
            return 'Few clouds';
        }
        else if (percent <= 50) {
            return 'Scattered clouds';
        }
        else if (percent <= 75) {
            return 'Broken clouds';
        }
        else if (percent <= 100) {
            return 'Overcast clouds';
        }
    }

    connectedCallback() {
        has_permission({'permName': 'weather_permission'})
        .then((res) => {
            this.hasPermission = res;
            if(this.hasPermission===true) {
                getDefaultCity()
                .then((data) => {
                    if (data.status) {
                        if (data.cityName != null) {
                            this.cityName = data.cityName;
                            this.handleSearch();
                        }
                    }
                    else {
                    }
                })
                .catch((error) => {
                })
            }
        })
        .catch((err) => {
        })
        
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.cityName = event.target.value;
            this.handleSearch();
        }
    }

    handleSearch() {
        this.loading = true;
        findCity({ 'cityName': this.cityName })
        .then((data) => {
            this.status = data.status;
            if (data.status) {
                this.maininfo = this.main_prettify(data);
                this.moreinfo = this.more_prettify(data);
                let icon = 'http://openweathermap.org/img/wn/' + data.icon + '@2x.png';
                this.iconUrl = icon
            }
            else {

                if (this.firstError) {
                    this.handleSearch();
                    this.firstError = false;
                }
                else {
                    this.errorinfo = data.message;
                }
                
            }
            this.loading = false;
        })
        .catch((error) => {
        });
    }

    main_prettify(data) {

        let result = `Temperature is ${Math.round(data.main.temp)}°C, feels like ${Math.round(data.main.feels_like)}°C. `;

        return result;
    }

    more_prettify(data) {
        let direction = this.get_wind_direction(data.wind.deg);
        let cloud = this.get_cloud_state(data.clouds.all);

        let result = `Pressure is ${data.main.pressure} KPa, humidity is ${data.main.humidity}%. 
        Wind is ${direction} at ${data.wind.speed} km/h. ${cloud}`;
            
        return result;
    }
    
}