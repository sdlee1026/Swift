// const config = require('../config/environment');
// const Sequelize = require('sequelize');

// const sequelize = new Sequelize(
//     config.mysql.database,
//     config.mysql.username,
//     config.mysql.password, {
//         host: 'localhost',
//         dialect: 'mysql'
//     }
// );

// const User = sequelize.define('user', {
//     name: Sequelize.STRING
// });

// module.exports = {
//     sequelize: sequelize,
//     User: User
// }
// DB Structure
const Sequelize = require('sequelize');
const sequelize = new Sequelize('logindb','Seongdae','Dltjdeo!1026',{
    host:'localhost',
    dialect:'mysql'
});
const LoginUser = sequelize.define('LoginUser',{
    id: {
        type : Sequelize.STRING,
        primaryKey: true
    },
    pw : {
        type : Sequelize.STRING
    }
});
module.exports = {
    sequelize: sequelize,
    User: LoginUser
}