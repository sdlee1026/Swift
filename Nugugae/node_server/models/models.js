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
    },
    email : {
        type : Sequelize.STRING
    }
});
const WalkTable = sequelize.define('WalkTables',{
    id:{
        type: Sequelize.STRING,
        primaryKey: true,
        references: {
            // This is a reference to another model
            model: LoginUser,
            // This is the column name of the referenced model
            key: 'id'
        }
    },
    date:{
        type : Sequelize.DATE,
        primaryKey: true,
        defaultValue: Sequelize.NOW
    },
    content:{
        type : Sequelize.TEXT
    }
}
);

const UserTabelCount = sequelize.define('UserTabelCounts',{
    id:{
        type: Sequelize.STRING,
        primaryKey: true,
        references: {
            // This is a reference to another model
            model: LoginUser,
            // This is the column name of the referenced model
            key: 'id'
        }
    },
    walkcount:{
        type: Sequelize.INTEGER,
        defaultValue: 0
    },
    gallerycount:{
        type: Sequelize.INTEGER,
        defaultValue: 0
    }
});

const GalleryTable = sequelize.define('GalleryTables',{
    id:{
        type: Sequelize.STRING,
        primaryKey: true,
        references: {
            // This is a reference to another model
            model: LoginUser,
            // This is the column name of the referenced model
            key: 'id'
        }
    },
    imgname:{
        type : Sequelize.STRING,
        primaryKey: true
    },
    date:{
        type : Sequelize.DATE,
        defaultValue: Sequelize.NOW,
        primaryKey: true,
    },
    image:{
        type : Sequelize.BLOB("long"),
        allowNull: false
    }
});

module.exports = {
    sequelize: sequelize,
    User: LoginUser,
    Walk: WalkTable,
    UserTableCount: UserTabelCount,
    GalleryTable: GalleryTable,
}