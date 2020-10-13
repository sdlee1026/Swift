// DB Structure
console.log('db구조 로드')
const Sequelize = require('sequelize');
const sequelize = new Sequelize('logindb','Seongdae','Dltjdeo!1026',{
    host:'localhost',
    dialect:'mysql',
    timezone: "+09:00",
    dialectOptions: {
        charset: 'utf8mb4',
        dateStrings: true,
        typeCast: true
    }
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
    ispublic:{
        type : Sequelize.BOOLEAN
    },
    // public_true, private_false bool 값으로 넣음..
    date:{
        type : Sequelize.DATE,
        defaultValue: Sequelize.NOW,
        primaryKey: true,
    },
    // 갤러리에 올라오는 날짜 그자체
    imgdate:{
        type : Sequelize.DATE,
        primaryKey: true
    },
    // 사진 데이터를 찍은 시간(반드시 존재_기본키)
    image:{
        type : Sequelize.BLOB("long"),
        allowNull: false
    },
    // 이미지
    location:{
        type : Sequelize.STRING,
        allowNull: true
    }
    // 위치 정보, 일단은 null 가능.. 차후에 데이터로 처리 어떻게 할지..
});

module.exports = {
    sequelize: sequelize,
    User: LoginUser,
    Walk: WalkTable,
    UserTableCount: UserTabelCount,
    GalleryTable: GalleryTable,
}