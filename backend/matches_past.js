const fs = require('fs');
const sdk = require('api')('@developers-pandascore/v2#apvn9q1ml4sw7gei');
const dotenv = require('dotenv')

dotenv.config(({path:__dirname+'/.env'}))

sdk.auth(process.env.APIKEY);

sdk.get_matches_past({
    'filter[finished]': true,
    'filter[not_started]': false,
    sort: '',
    page: '1',
    per_page: '1'
})
    .then(res => {
        console.log(res);
        let data = JSON.stringify(res);
        fs.writeFileSync(__dirname + '/matches_past.json', data);
    })
    .catch(err => console.error(err));