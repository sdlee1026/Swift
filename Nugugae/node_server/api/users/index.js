const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const path = require('path');

//파일관련 모듈
var multer = require('multer');

//파일 저장위치와 파일이름 설정
var gallery_private_storage = multer.diskStorage(
    {
        
        destination: function (req, file, cb) {
            //파일이 이미지 파일이면
            if (file.mimetype == "image/jpeg" || file.mimetype == "image/jpg" || file.mimetype == "image/png") {
                console.log("private 이미지 파일 감지")
                cb(null, './user_gallery/private/img')
            }
        },
        //파일이름 설정
        filename: function (req, file, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();
            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정
            
            cb(null, kr_date + "-" + file.originalname)
        }
        
});
var gallery_public_storage = multer.diskStorage(
    {
        
        destination: function (req, file, cb) {
            //파일이 이미지 파일이면
            if (file.mimetype == "image/jpeg" || file.mimetype == "image/jpg" || file.mimetype == "image/png") {
                console.log("public 이미지 파일 감지")
                cb(null, './user_gallery/public/img')
            }
        },
        //파일이름 설정
        filename: function (req, file, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();
            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정
            cb(null, kr_date + "-" + file.originalname)
        }
        
});

//파일 업로드 모듈
var upload_private = multer({ storage: gallery_private_storage });
var upload_public = multer({storage: gallery_public_storage});


router.use(bodyParser.json());
router.use(bodyParser.urlencoded({extended: true}));

const login_controller = require('./user.controller');
// login controller 
const walk_controller = require('./walk.controller');
// main view, walk controller
const gallery_controller = require('./gallery.controller');
// gallery controller
module.exports = router;
router.get('/users/', login_controller.index);
router.get('/users/:id', login_controller.show);
router.delete('/users/:id', login_controller.destroy);
router.post('/users/', login_controller.create);
router.put('/users/:id', login_controller.update);

// ID, PW 받아서 로그인 성공/실패 확인후 토큰 반환
router.post('/login/', login_controller.login);
// 유저 중복 확인
router.post('/users/check', login_controller.usercheck);

// 산책기록
router.get('/walktest/', walk_controller.walk_index);
// 산책기록 테이블 보기
router.post('/walk/view/', walk_controller.walk_view);
// 산책기록 테이블 내용 보기
router.post('/walk/viewone/', walk_controller.walk_viewone);
router.post('/walk/view/detail/', walk_controller.walk_view_detail);
// 산책기록 글쓰기
router.post('/walk/write/', walk_controller.walk_write);
// 산책기록 수정하기
router.post('/walk/edit/', walk_controller.walk_edit);
// 산책기록 삭제하기
router.post('/walk/delete/', walk_controller.walk_delete);

// 갤러리
router.get('/gallerytest/', gallery_controller.gallery_index);
// 이미지 업로드
router.post('/gallery/upload/private', upload_private.single('image'), gallery_controller.gallery_upload_private);
router.post('/gallery/upload/public', upload_public.single('image'), gallery_controller.gallery_upload_public);