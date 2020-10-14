// main server 구동
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use('/', require('./api/users'));

app.set('port', process.env.PORT || 3000);

  
app.listen(app.get('port'), () => {
    console.log('Express server listening on port ' + app.get('port'));
    require('./models/models.js').sequelize.sync({force: false})// 앱 실행시마다 테이블 초기화? (운용서버는 무조건 false)
        .then(() => {
            console.log('DB connect');
        });
});


module.exports = app;