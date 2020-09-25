const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');

router.use(bodyParser.json());
router.use(bodyParser.urlencoded({extended: true}));

const controller = require('./user.controller');

module.exports = router;

router.get('/users/', controller.index);

router.get('/users/:id', controller.show);

router.delete('/users/:id', controller.destroy);

router.post('/users/', controller.create);

router.put('/users/:id', controller.update);

// ID, PW 받아서 로그인 성공/실패 확인후 토큰 반환
router.post('/login/', controller.login);

// 유저 중복 확인
router.post('/users/check', controller.usercheck);