const e = require('express');
const Sequelize = require('sequelize');
const models = require('../../models/models');//DB
const Op = Sequelize.Op;
var fs = require('fs'); // 파일 시스템

// 산책하기! 처음 눌렀을 때, 테이블 두개 생성. 1. 산책 로그 테이블 2. 현재 산책인원 관리 테이블
exports.walk_init = (req, res) => {
    console.log('Walk_service init/table create');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var starttime = req.body.starttime || '';
    var location_data = req.body.location_data || '';
    var date_bylocation = req.body.date_bylocation || '';
    
    var split_location_data = location_data.split(',');
    var location_data_lat = parseFloat(split_location_data[0]);
    var location_data_lng = parseFloat(split_location_data[1]);

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
                location_data : location_data+'|',
                date_bylocation : date_bylocation+'|',
            }).then(walksinfo =>{
                console.log('walksInfoTable 새로운 내용 생성, user의 산책 정보 관리 테이블');

                models.nowWalkingUser.create({
                    id : id,
                    last_location_lat : location_data_lat, // 마지막으로 있었던 위치
                    last_location_lng : location_data_lng,
                    last_date_bylocation : date_bylocation

                }).then(nowwalk=>{
                    console.log('nowwalking 새로운 내용 생성, 지금 산책 중인 유저에 관한 정보 테이블');
                    return res.status(201).json({content: 'table init work OK'});
                });
            });

        }
    });

};

// 산책하기! 중간 업데이트 동작, 10개 위치_시간 데이터 받아오고, 현재 위치 테이블 갱신 동작
exports.walk_update = (req, res) => {
    console.log('\nWalk_service/update_data, map_data(location, date) update and nowwalk user location update\n');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var location_data = req.body.location_data || '';
    var date_bylocation = req.body.date_bylocation || '';
    // db to update values
    
    var last_location = req.body.last_location || '';
    var last_date_bylocation = req.body.last_date_bylocation || '';

    var split_last_location = last_location.split(',');
    var last_location_lat = parseFloat(split_last_location[0]);
    var last_location_lng = parseFloat(split_last_location[1]);
    // now walking update values
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
            models.nowWalkingUser.update(
                {
                    last_location_lat: last_location_lat,
                    last_location_lng: last_location_lng,
                    last_date_bylocation: last_date_bylocation
                },// 위치값, 시간값, 종료시간 update, CONCAT -> 배열 합치는 함수
                {where: {
                    id: id,
                }, returning: true}).then( (nowwalk) =>{
                    console.log('\nnow walk ok, then db update\n');
                    models.walksInfoTable.update(
                        {
                            location_data: Sequelize.fn('CONCAT', Sequelize.col("location_data"), location_data),
                            date_bylocation: Sequelize.fn('CONCAT', Sequelize.col("date_bylocation"), date_bylocation)
                        },// 위치값, 시간값, 종료시간 update, CONCAT -> 배열 합치는 함수
                        {where: {
                            id: id,
                            date: date,
                        }, returning: true}).then((userinfo) => {
                        return res.status(201).json({content: 'Update OK'})
                    });// userinfo_update.then
                });// nowwalk_update.then
            }// else
        });// model_id check.then
};


// 산책하기! 중간 근처 유저 트래킹 동작, 유저 현재 위치 받아서, 현재 위치 테이블에서 근처 유저 return
const { QueryTypes } = require('sequelize');
const { sequelize } = require('../../models/models');
exports.walk_near_user = (req, res) => {
    console.log('near_user tracking api');
    var userid = req.body.id || '';
    var location_data = req.body.location_data || '';
    var split_location_data = location_data.split(',');
    var location_data_lat = parseFloat(split_location_data[0]);
    var location_data_lng = parseFloat(split_location_data[1]);
    
    console.log(userid, location_data);

    if (!userid || !location_data) {
        return res.status(400).json({error: 'Incorrect id or location data'});
    }
    //ABS()절대값, raw Query 사용
    sequelize.query(
        `SELECT * FROM nowWalkingUsers WHERE nowWalkingUsers.id != :userid 
        AND ABS(:lat - nowWalkingUsers.last_location_lat) <0.001 
        AND ABS(:lng - nowWalkingUsers.last_location_lng) <0.001 
        ORDER BY ABS(:lat-nowWalkingUsers.last_location_lat) + ABS(:lng - nowWalkingUsers.last_location_lng)`,
        {
            replacements: { userid: userid, lat: location_data_lat, lng: location_data_lng},
            type: QueryTypes.SELECT
        })
        .then(nowwalk =>{
            for(var i=0;i<nowwalk.length;i++){
                console.log('유저 이름 : ', nowwalk[i]['id']);
                console.log('위치 lat : ',nowwalk[i]['last_location_lat']);
                console.log('위치 lng : ',nowwalk[i]['last_location_lng']);
            }
            return res.json(nowwalk);
        });
    
};


exports.near_user_detail_view = (req, res) => {
    console.log('near_user_view detail');
    var id = req.body.id || '';
    console.log(id)
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.UserDetailInfo.findOne({
        where: {
            id: id,
        }
    }).then(userinfo => {
        if(!userinfo){
            return res.status(404).json({err: 'No User'});
        }
        if (userinfo['image05']!=null){
            console.log('userprofile_img 존재')
            var img = fs.readFileSync(userinfo['image05'], 'base64');
            userinfo['image05'] = img
        }// 25% 이미지 전송
        else{
            console.log('userprofile img 없음')
            userinfo['image05'] = null
        }

        return res.json(userinfo);
    });

};
// 산책하기! 중간 근처 유저 트래킹 동작 중, 근처 유저 세부 정보 확인하기

// 산책하기!, 산책 종료시_stop() 하는 nowwalk user del, 남은 데이터 db적재 동작 2개
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
                models.UserTableCount.update(
                    {historycount: models.sequelize.literal('historycount + 1')},
                    {
                        where:{
                            id:id
                        }
                    }
                )
                console.log('\ntablecount, historycount 1++\n');
                
                return res.status(201).json({content: 'delete OK'});
            });

        }
    });

};// 종료 동작으로 인한, 현재 산책중 유저 삭제_ location_data class의 stop()내부 동작으로 실행되는 api

exports.walk_stop_elsedata = (req, res) => {
    console.log('Walk_service/stop else data process');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var location_data = req.body.location_data || '';
    var date_bylocation = req.body.date_bylocation || '';
    var endtime = req.body.endtime || '';

    console.log(id, date, location_data, date_bylocation, endtime);

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
            models.walksInfoTable.update(
                {
                    location_data: Sequelize.fn('CONCAT', Sequelize.col("location_data"), location_data),
                    date_bylocation: Sequelize.fn('CONCAT', Sequelize.col("date_bylocation"), date_bylocation),
                    endtime: endtime
                },// 위치값, 시간값, 종료시간 update, CONCAT -> 배열 합치는 함수
                {where: {
                    id: id,
                    date: date,
                }, returning: true}).then((userinfo) => {
                return res.status(201).json({content: 'Update OK'})
            });
            // 내용 업데이트
        }
    });

};
// 종료 동작으로 인한, 남은 자투리 데이터 db에 적재하는 동작, location_data class의 stop()내부 동작으로 실행되는 api

function getDistanceFromLatLonInKm(lat1,lng1,lat2,lng2) {
    function deg2rad(deg) {
        return deg * (Math.PI/180)
    }

    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lng2-lng1);
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon/2) * Math.sin(dLon/2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
}
exports.walk_stop_distance = (req, res) => {
    console.log('Walk_service/stop distance calculate');
    var id = req.body.id || '';
    var starttime = req.body.starttime || '';

    var distance_str = '';
    var location_ary = [];
    console.log(id, starttime);
    var result_distance = 0.0;

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
            models.walksInfoTable.findOne({
                where:{
                    id: id,
                    date: starttime,
                }
            }).then(distance_data =>{
                distance_str += distance_data['location_data'];
                console.log('str 길이 : ',distance_str.length);
                location_ary = distance_str.split('|');
                for(var i=0;i<location_ary.length;i++){
                    location_ary[i] = location_ary[i].split(',');
                }
                for(var i=0;i<location_ary.length-1;i++){
                    if(location_ary[i+1][0].length != 0){
                        result_distance += getDistanceFromLatLonInKm(location_ary[i][0], location_ary[i][1], 
                            location_ary[i+1][0], location_ary[i+1][1])*1000;
                    }
                }
                console.log('누적거리 계산 : ', result_distance);
                models.walksInfoTable.update({
                    distance: result_distance
                },
                {where: {
                    id: id,
                    starttime: starttime,
                }, returning: true}).then(walkend => {
                    console.log('walk_db, distance update ok');
                    return res.status(201).json({content:String(result_distance)});

                });
            });
        }
    });//then()
};// 산책종료! 시에, 거리계산 Db연산