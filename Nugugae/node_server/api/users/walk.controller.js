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
exports.walk_edit = (req,res) => {
    console.log('walk_edit')
    var id = req.body.id || '';
    var content = req.body.content || '';
    console.log(id)
};
exports.walk_delete = (req,res) => {
    console.log('walk_delete')
    var id = req.body.id || '';
    console.log(id)
};

