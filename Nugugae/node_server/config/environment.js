const environment = {
    development: {
        mysql: {
            username: 'Seongdae',
            password: 'Dltjdeo!1026',
            database: 'logindb_test'
        },

        sequelize: {
            force: False
        }
    },

    production: {

    }
}

const nodeEnv = process.env.NODE_ENV || 'development';

module.exports = environment[nodeEnv];