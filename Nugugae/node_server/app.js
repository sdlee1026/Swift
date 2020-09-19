const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
// const dbconfig = require('./config/database.js');

// const connection = mysql.createConnection(dbconfig);

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use('/users', require('./api/users'));

// configuration =========================

app.set('port', process.env.PORT || 3000);

// app.get('/', (req, res) => {
//   res.send('Root');
// });

// app.get('/users', (req, res) => {
//     connection.query('SELECT * from Users', (error, rows) => {
//       if (error) throw error;
//       console.log('User info is: ', rows);
//       res.send(rows);
//     });
// });
  
app.listen(app.get('port'), () => {
    console.log('Express server listening on port ' + app.get('port'));
    require('./models/models.js').sequelize.sync({force: false})// 앱 실행시마다 테이블 초기화? (운용서버는 무조건 false)
        .then(() => {
            console.log('DB connect');
        });
});


module.exports = app;