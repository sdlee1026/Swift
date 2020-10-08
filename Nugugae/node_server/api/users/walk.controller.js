const e = require('express');
const { UserTableCount } = require('../../models/models');
const models = require('../../models/models');//DB

// WalkTableDB useAPI

// 모든 id,date index test
exports.walk_index = (req, res) => {
    console.log('walkTableDB test');
    models.Walk.findAll().then(function(results) {
        res.json(results);
    }).catch(function(err) {
        //TODO: error handling
        return res.status(404).json({err: 'Undefined error!'});
    });
};

// 산책기록 테이블 상위 하나 뽑기
exports.walk_viewone = (req, res) =>{
    console.log('walkTableDB view one test')
    var id = req.body.id;
    models.Walk.findOne({
        where:{
            id:id
        },order: [['date', 'DESC']],
    }).then(walk=>{
        if(!walk){
            console.log(walk);
            return res.status(404).json({err: 'No User'});
        }
        return res.json(walk)
    })

};
//curl -X POST '127.0.0.1:3000/walk/view/' -d id='test1001' -d offset=0
// 산책 기록 테이블 보기
exports.walk_view = (req, res) => {
    console.log('walkTableDB view test');
    var id = req.body.id || '';
    var offset = req.body.offset || 0;
    var limit = 10;
    var int_offset = parseInt(offset)
    id = String(id)
    console.log(id)
    // if(!id.length){
    //     return res.status(400).json({err: 'Incorrect name'});
    // }
    models.UserTableCount.findOne({
        where:{id: id}
    }).then(UserTableCount =>{
        //console.log(UserTableCount.walkcount);
        var offset_limit = parseInt(UserTableCount.walkcount);
        //console.log(offset_limit,offset)
        if (offset_limit>offset){
            models.Walk.findAll({
                offset: int_offset,
                limit: limit,
                where: {
                    id: id
                },order: [['date', 'DESC']],
            }).then(walk => {
                if(!walk){
                    console.log(walk);
                    return res.status(404).json({err: 'No User'});
                }
                return res.json(walk);
            })
        }
        else{
            console.log('No item error return')
            return res.status(400).json({err: 'No item'})
        }
    }// offset 저장, offset+limit보다 작은 범위를 불러올 경우만..트랜잭션
    );
};

// 산책 기록 테이블 세부 보기
exports.walk_view_detail = (req, res) => {
    console.log('walkTableDB view detail test');
    var id = req.body.id || '';
    var date = req.body.date || '';

    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    if(!date.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.Walk.findOne({
        where: {
            id: id,
            date: date
        }
    }).then(walk => {
        if(!walk){
            console.log(walk);
            return res.status(404).json({err: 'No User'});
        }
        return res.json(walk);
    });
};

// 산책 기록 글쓰기
exports.walk_write = (req, res) => {
    console.log('walkTableDB write test');
    var id = req.body.id || '';
    var content = req.body.content || '';

    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    else if (!content.length){
        return res.status(400).json({err: 'Incorrect content'});
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
            models.UserTableCount.update(
                {walkcount: models.sequelize.literal('walkcount + 1')},
                {
                    where:{
                        id:id
                    }
                }
            )
            models.Walk.create({
                id: id,
                content: content
            }).then((walk) => {
                return res.status(201).json({content: 'write OK'});
            });

        }
    });
    
};

// 산책 기록 테이블 수정
exports.walk_edit = (req,res) => {
    console.log('walk_edit')
    var id = req.body.id || '';
    var content = req.body.content || '';
    console.log(id)
};

// 산책 기록 삭제
exports.walk_delete = (req,res) => {
    console.log('walk_delete')
    var id = req.body.id || '';
    var date = req.body.date || '';

    console.log(id)
    if (!id) {
        return res.status(400).json({error: 'Incorrect id'});
    }
    else if (!date){
        return res.status(400).json({error: 'Incorrect date'});
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
            models.UserTableCount.update(
                {walkcount: models.sequelize.literal('walkcount - 1')},
                {
                    where:{
                        id:id
                    }
                }
            )
            models.Walk.destroy({
                where: {
                    id: id,
                    date: date
                }
            }).then((walk) => {
                return res.status(201).json({content: 'delete OK'});
            });

        }
    });
};