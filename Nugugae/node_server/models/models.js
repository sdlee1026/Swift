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

// Login_user info
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

// User 세부 정보
const UserDetailInfo = sequelize.define('UserDetailInfos',{
    id:{
        type: Sequelize.STRING,
        references: {
            model: LoginUser,
            key: 'id'
        },

        primaryKey: true
    },
    // 유저 id(login기준, logintable 참조 외래키_ 기본키)
    nickname:{
        type: Sequelize.STRING,
        defaultValue: ''
    },
    // 별명

    dogscount:{
        type: Sequelize.INTEGER,
        defaultValue: -1
    },
    // 개 몇마리 키우는지..

    birthday:{
        type: Sequelize.STRING,
    },
    // 사용자의 생일
    introduce:{
        type: Sequelize.STRING,
        defaultValue: ''
    },
    // 사용자 자기소개
    image:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 프로필 사진
    image05:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 50%
});

// 개들에 대한 정보
const DogsInfo = sequelize.define('DogsInfos',{
    id:{
        type: Sequelize.STRING,
        references: {
            model: LoginUser,
            key: 'id'
        },

        primaryKey: true
    },
    // 유저 id(login기준, logintable 참조 외래키_ 기본키)

    dogname:{
        type: Sequelize.STRING,
        primaryKey: true
    },
    // 개 이름.. 배열형태의 개 이름 스트링 들어감

    breed:{
        type: Sequelize.STRING,
        allowNull: false
        // not null, 값 들어가야함
    },
    // 견종

    age:{
        type: Sequelize.INTEGER,
        defaultValue: -1
    },
    // 나이

    activity:{
        type: Sequelize.FLOAT,
        defaultValue: 5.0
    },
    // 활동량 range 0.0<->10.0

    Sociability:{
        type: Sequelize.FLOAT,
        defaultValue: 5.0
    },
    // 사회성, 배타적 척도, 얼마나 예민한지 _ 초기값 입력할때만 사용자가 직접 접근 가능.. 그 이후는 다른 사용자의 입력에 따른..
    // 다른 사용자랑 만나서 별일 없이 지나가면 +0.01.. 다툼이 있거나, 다른 사용자의 평가가 안좋게 박히면 -0.10.. 이런식으로 벨류의 차등

    like:{
        type: Sequelize.INTEGER
    },
    // 인기도.. 갤러리 퍼블릭에 노출된 사진이 좋아요를 받았을 경우에.. 견종의 인기도 ++, 달별로 평균값 기준 초기화?처리 해서 이달의 인기견종..?
    // +a기능

    introduce:{
        type: Sequelize.STRING,
        defaultValue: ''
    },
    // 자기소개, free string content
    favoritefood:{
        type: Sequelize.STRING
    },
    // 좋아하는 음식, +a기능에서 쓸 수도..
    image:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 프로필 사진
    image05:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 50%

    
});
// 산책기록
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
    imgindex:{
        type : Sequelize.INTEGER,
        primaryKey: true,
        defaultValue: 0,
    },
    // 동일 시간에 올라온 이미지(여러개) 인덱스로 구분
    imgdate:{
        type : Sequelize.DATE
    },
    // 사진 데이터를 찍은 시간, 변동 가능
    image:{
        type : Sequelize.STRING,
        allowNull: false
    },
    image05:{
        type : Sequelize.STRING,
        allowNull: true
    },
    image01:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 이미지
    content:{
        type : Sequelize.TEXT,
    },
    // 사진의 내용
    location:{
        type : Sequelize.STRING,
        allowNull: true
    },
    like:{
        type: Sequelize.INTEGER,
        defaultValue: 0
    },
    // 좋아요 갯수
    // 위치 정보, 일단은 null 가능.. 차후에 데이터로 처리 어떻게 할지..
    hashtag:{
        type : Sequelize.STRING,
        allowNull: true
    },
    // 사진 해쉬 태그

    // relative 된 강아지.. (+a기능)
});

module.exports = {
    sequelize: sequelize,
    User: LoginUser,
    Walk: WalkTable,
    UserTableCount: UserTabelCount,
    GalleryTable: GalleryTable,
    UserDetailInfo: UserDetailInfo,
    DogsInfo: DogsInfo,
}