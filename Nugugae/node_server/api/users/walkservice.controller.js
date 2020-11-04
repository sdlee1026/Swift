const e = require('express');
const models = require('../../models/models');//DB

// 산책하기! 처음 눌렀을 때, 테이블 두개 생성. 1. 산책 로그 테이블 2. 현재 산책인원 관리 테이블
exports.walk_init = (req, res) => {
    console.log('Walk_service init/table create');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var starttime = req.body.starttime || '';
    var location_data = req.body.location_data || '';
    var date_bylocation = req.body.date_bylocation || '';

    console.log(id, date, starttime, location_data, date_bylocation);

    models.User.findOne({
        where: {
            id: id
        }
    }).then(user =>{
        if(!user){
            console.log(user);
            return res.status(404).json({err: 'No User'});
        }// id는 LoginUsers 테이블의 외래키 이므로 체크
        else{
            console.log('외래키 체크 통과, 테이블 2개 생성');
            models.walksInfoTable.create({
                id : id,
                date : date,
                starttime : starttime,
                location_data : location_data,
                date_bylocation : date_bylocation,
            }).then(walksinfo =>{
                console.log('walksInfoTable 새로운 내용 생성, user의 산책 정보 관리 테이블');

                models.nowWalkingUser.create({
                    id : id,
                    last_location : location_data, // 마지막으로 있었던 위치
                    last_date_bylocation : date_bylocation

                }).then(nowwalk=>{
                    console.log('nowwalking 새로운 내용 생성, 지금 산책 중인 유저에 관한 정보 테이블');
                    return res.status(201).json({content: 'table init work OK'});
                });
            });

        }
    });

};

exports.walk_stop_nowwalk = (req, res) =>{
    console.log('Walk_service/stop nowwalk user delete');
    var id = req.body.id || '';

    if (!id) {
        return res.status(400).json({error: 'Incorrect id'});
    }
    models.User.findOne({
        where: {
            id: id
        }
    }).then(user => {
        if(!user){
            console.log(user);
            return res.status(404).json({err: 'No User'});
        }// id는 LoginUsers 테이블의 외래키 이므로 체크
        else{
            models.nowWalkingUser.destroy({
                where: {
                    id: id,
                }
            }).then((walk) => {
                return res.status(201).json({content: 'delete OK'});
            });

        }
    });

};