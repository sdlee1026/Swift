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

// 산책 기록 테이블 보기
exports.walk_view = (req, res) => {
    console.log('walkTableDB view test');
    var id = req.body.id || '';
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.Walk.findAll({
        where: {
            id: id
        }
    }).then(walk => {
        if(!walk){
            console.log(walk);
            return res.status(404).json({err: 'No User'});
        }
        return res.json(walk);
    });
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
            models.Walk.create({
                id: id,
                content: content
            }).then((walk) => res.status(201).json(walk));

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
    console.log(id)
};

