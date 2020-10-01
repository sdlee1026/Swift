const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');

router.use(bodyParser.json());
router.use(bodyParser.urlencoded({extended: true}));

const login_controller = require('./user.controller');
// login controller 
const walk_controller = require('./walk.controller');
// main view, walk controller

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
router.post('/walk/view/detail/', walk_controller.walk_view_detail);
// 산책기록 글쓰기
router.post('/walk/write/', walk_controller.walk_write);
// 산책기록 수정하기
router.post('/walk/edit/', walk_controller.walk_edit);
// 산책기록 삭제하기
router.post('/walk/delete/', walk_controller.walk_delete);