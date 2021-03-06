const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const path = require('path');

//파일관련 모듈
var multer = require('multer');

//파일 저장위치와 파일이름 설정
var gallery_private_storage = multer.diskStorage(
    {
        
        destination: function (req, files, cb) {
            //파일이 이미지 파일이면
            if (files.mimetype == "image/jpeg" || files.mimetype == "image/jpg" || files.mimetype == "image/png") {
                console.log("private 이미지 파일 감지")
                cb(null, './user_gallery/private/img')
            }
        },
        //파일이름 설정
        filename: function (req, files, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();

            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정

            cb(null, kr_date + "-" + files.originalname)
        }
        
});
var gallery_public_storage = multer.diskStorage(
    {
        
        destination: function (req, files, cb) {
            //파일이 이미지 파일이면
            if (files.mimetype == "image/jpeg" || files.mimetype == "image/jpg" || files.mimetype == "image/png") {
                console.log("public 이미지 파일 감지")
                cb(null, './user_gallery/public/img')
                console.log('저장완료')
            }
        },
        //파일이름 설정
        filename: function (req, files, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();

            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정
            cb(null, kr_date + "-" + files.originalname)
        }
        
});
var user_profile_storage = multer.diskStorage(
    {
        
        destination: function (req, files, cb) {
            //파일이 이미지 파일이면
            if (files.mimetype == "image/jpeg" || files.mimetype == "image/jpg" || files.mimetype == "image/png") {
                console.log("user_profile 이미지 파일 감지")
                cb(null, './user_profile/img')
            }
        },
        //파일이름 설정
        filename: function (req, files, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();

            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정

            cb(null, kr_date + "-" + files.originalname)
        }
        
});
// 사람 프사

var dog_profile_storage = multer.diskStorage(
    {
        
        destination: function (req, files, cb) {
            //파일이 이미지 파일이면
            if (files.mimetype == "image/jpeg" || files.mimetype == "image/jpg" || files.mimetype == "image/png") {
                console.log("dog_profile 이미지 파일 감지")
                cb(null, './dog_profile/img')
            }
        },
        //파일이름 설정
        filename: function (req, files, cb) {
            var moment = require('moment');
            require('moment-timezone');
            moment.tz.setDefault("Asia/Seoul");
            const kr_date = moment().format();

            console.log("서버 기준 설정 시간_1 : " + kr_date);
            // 한국시 설정

            cb(null, kr_date + "-" + files.originalname)
        }
        
});
// 강아지 프사

//파일 업로드 모듈
var upload_private = multer({ storage: gallery_private_storage });
var upload_public = multer({storage: gallery_public_storage});
var upload_dog_profile = multer({storage: dog_profile_storage});
var upload_user_profile = multer({storage: user_profile_storage});


router.use(bodyParser.json());
router.use(bodyParser.urlencoded({extended: true}));

const login_controller = require('./user.controller');
// login controller 
const walk_controller = require('./walk.controller');
// main view, walk controller
const gallery_controller = require('./gallery.controller');
// gallery controller
const feed_controller = require('./feed.controller');
// feed controller
const infosetting_controller = require('./infosetting.controller');
// infosetting controller
const { info } = require('console');

const walkservice_controller = require('./walkservice.controller');
// walk_service controller . 산책 맵 데이터
const walkhistory_controller = require('./walkhistory.controller');

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

// 산책일지(텍스트)

router.get('/walktest/', walk_controller.walk_index);
// 산책일지 테이블 보기
router.post('/walk/view/', walk_controller.walk_view);
// 산책일지 테이블 내용 보기
router.post('/walk/viewone/', walk_controller.walk_viewone);
router.post('/walk/view/detail/', walk_controller.walk_view_detail);
// 산책일지 글쓰기
router.post('/walk/write/', walk_controller.walk_write);
// 산책일지 수정하기
router.post('/walk/edit/', walk_controller.walk_edit);
// 산책일지 삭제하기
router.post('/walk/delete/', walk_controller.walk_delete);

// 산책하기! 동작 

// 산책하기! init()
router.post('/walkservice/init/', walkservice_controller.walk_init);

// 산책하기! 중간 업데이트 동작, 10개 위치_시간 데이터 받아오고, 현재 위치 테이블 갱신 동작
router.post('/walkservice/update_data/', walkservice_controller.walk_update);
// 산책하기! 중간 근처 유저 트래킹 동작, 유저 현재 위치 받아서, 현재 위치 테이블에서 근처 유저 return
router.post('/walkservice/near_user/view/',walkservice_controller.near_user_detail_view);
// 산책하기! 중간 근처 유저 트래킹 동작 중, 근처 유저 세부 정보 확인하기
router.post('/walkservice/near_user/', walkservice_controller.walk_near_user);

// 산책하기! stop(), 산책 총 거리 계산 하기
router.post('/walkservice/stop/distance/',walkservice_controller.walk_stop_distance);
// 산책하기! stop(), nowwalking 데이터 지우기_ 현재 산책중인 유저 관리 테이블
router.post('/walkservice/stop/nowwalk/', walkservice_controller.walk_stop_nowwalk);
// 산책하기! stop(), 남은 위치 데이터 전송하기
router.post('/walkservice/stop/elsedata/', walkservice_controller.walk_stop_elsedata);

// 산책기록(과거 산책기록 맵뷰)! 동작

// 과거 산책기록 테이블뷰 불러오기
router.post('/history/loadtable/', walkhistory_controller.history_load_table);
// 과거 산책기록 디테일(1개) 보기
router.post('/history/detail/view/', walkhistory_controller.history_view_detail);
router.post('/history/delete/',walkhistory_controller.history_delete);

// 갤러리

router.get('/gallerytest/', gallery_controller.gallery_index);

// 이미지 업로드
router.post('/gallery/upload/private/', upload_private.fields([{ name: 'image' }, { name: 'image05' }, { name: 'image01' }]), gallery_controller.gallery_upload_private);
router.post('/gallery/upload/public/', upload_public.fields([{ name: 'image' }, { name: 'image05' }, { name: 'image01' }]), gallery_controller.gallery_upload_public);

// 자신의 갤러리 전체 보기 썸네일10% 이미지 사용
router.post('/gallery/my/view/', gallery_controller.gallery_my_view);
// 자신의 갤러리 (선택한 날짜_산책일지 선택시), 그 선택 날짜 보기
router.post('/gallery/my/view/selectday/', gallery_controller.gallery_my_view_selectday);
// 갤러리 게시물 보기, 컬렉션 뷰 선택시 하나의 화면으로 보기
router.post('/gallery/view/', gallery_controller.gallery_view);
// 갤러리 자기 게시물 삭제
router.post('/gallery/delete/', gallery_controller.gallery_delete);
// 갤러리 자기 게시물 수정, 사진 변경 x
router.post('/gallery/update/noimg/', gallery_controller.gallery_update_noimg);
// 갤러리 자기 게시물 수정, 사진 변경 o, 프라이빗
router.post('/gallery/update/img/private/', upload_private.fields([{ name: 'image' }, { name: 'image05' }, { name: 'image01' }]), gallery_controller.gallery_update_img_private);
// 갤러리 자기 게시물 수정, 사진 변경 o, 퍼블릭
router.post('/gallery/update/img/public/', upload_public.fields([{ name: 'image' }, { name: 'image05' }, { name: 'image01' }]), gallery_controller.gallery_update_img_public);
// 갤러리 좋아요(like) 업데이트
router.post('/gallery/like/update/', gallery_controller.like_update);
// 갤러리 댓글, 로드
router.post('/gallery/reply/', gallery_controller.reply_load);
// 댓글 새로 달기
router.post('/gallery/reply/new/', gallery_controller.reply_new);
// 피드

// 피드 다른 유저 검색 기능
router.post('/feed/search/user/', feed_controller.search_user);
// 피드 컬렉션 뷰 로드
router.post('/feed/load/', feed_controller.feed_load);
// 피드검색 or 좋아요누른유저 -> 다른 유저탐색 뷰 로드(퍼블릭 이미지만)
router.post('/feed/otheruser/load/public/', feed_controller.other_user_load_public); 
// 피드검색 or 좋아요 누른유저 -> 다른 유저탐색 뷰 로드(퍼블릭 이미지만) 에서 개 정보 불러오기
router.post('/feed/otheruser/load/dogsinfo/', feed_controller.other_user_load_dogsinfo);
// 선택한 사람 프로필 이미지 불러오기
router.post('/feed/otheruser/load/proflie/', feed_controller.other_user_load_profile);


// 유저 정보

// 유저에 대한 세부 정보 보기
router.post('/setting/userinfo/detail/view/', infosetting_controller.user_detail_view);
// 유저에 대한 세부 정보 수정, (쓰기는 유저 아이디를 생성할때, 이미 생성되게끔 해뒀기 때문에), img포함, 미포함 수정
router.post('/setting/userinfo/detail/update/', infosetting_controller.user_detail_update);
router.post('/setting/userinfo/detail/updateimg/', upload_user_profile.fields([{ name: 'image' }, { name: 'image05' }]), infosetting_controller.user_detail_update_img);

// 개 전체에 대한 정보 보기(테이블을 위해서)
router.post('/setting/doginfo/all/view/', infosetting_controller.dog_all_view);

// 개에 대한 정보 새로 쓰기
router.post('/setting/doginfo/write/', upload_dog_profile.fields([{ name: 'image' }, { name: 'image05' }]), infosetting_controller.dog_write);
// 개에 대한 세부 정보 보기
router.post('/setting/doginfo/detail/view/', infosetting_controller.dog_detail_view);
// 개에 대한 세부 정보 수정, img 포함,미포함 api
router.post('/setting/doginfo/detail/update/', infosetting_controller.dog_detail_update);
router.post('/setting/doginfo/detail/updateimg/', upload_dog_profile.fields([{ name: 'image' }, { name: 'image05' }]), infosetting_controller.dog_detail_update_img);

// 개에 대한 세부 정보 삭제
router.post('/setting/doginfo/detail/delete/', infosetting_controller.dog_detail_delete);