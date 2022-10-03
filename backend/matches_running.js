const fs = require('fs');
const sdk = require('api')('@developers-pandascore/v2#e90xv1xl4sw7ghr');
const dotenv = require('dotenv')

dotenv.config(({ path: __dirname + '/.env' }))

sdk.auth(process.env.APIKEY);

sdk.get_csgo_matches_running({
    sort: 'begin_at',
    page: '1',
    per_page: '1'
})
    .then(res => {
        console.log(res);
        let data = JSON.stringify(res);
        fs.writeFileSync(__dirname + '/matches_running.json', data);
    })
    .catch(err => console.error(err));