const models = require('../../models/models');//DB
// id, pw 파싱 함수
function id_pw_parsing(req){
    console.log(req.body);
    var id = req.body.id || '';
    var pw = req.body.pw || '';

    if (id.length>0 && pw.length>0){
        return [id,pw];
    }
    else return ['',''];
}
// 모든 사용자 불러오기
exports.index = (req, res) => {
    console.log("index func");
    models.User.findAll().then(function(results) {
        res.json(results);
    }).catch(function(err) {
        //TODO: error handling
        return res.status(404).json({err: 'Undefined error!'});
    });
};

// 특정 사용자 불러오기
exports.show = (req, res) => {
    console.log("show func");
    // const id = parseInt(req.params.id, 10);var id,pw;
    const id = req.params.id;
    //console.log(id);
    if(!id){
        return res.status(400).json({err: 'Incorrect id'});
    }

    models.User.findOne({
        where: {
            id: id
        }
    }).then(user => {
        if(!user){
            console.log(user);
            return res.status(404).json({err: 'No User'});
        }
        return res.json(user);
    });
};
//특정 사용자 삭제
exports.destroy = (req, res) => {
    console.log("destory func");
    //const id = parseInt(req.params.id, 10);
    const id = req.params.id;
    if (!id) {
        return res.status(400).json({error: 'Incorrect id'});
    }

    models.User.destroy({
        where: {
            id: id
        }
    }).then(() => res.status(204).send());
};
// curl -X POST '127.0.0.1:3000/users' -d id='test' -d pw='1234' email='1234@asd.com'
// -> { id: 'test', pw: '1234' , email:'1234@asd.asd'}
exports.create = (req, res) => {
    console.log('create func');
    var id,pw;
    var ary=[];
    ary = id_pw_parsing(req)
    id = ary[0], pw =ary[1];
    var email = req.body.email || '';

    if(!id.length || !pw.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    
    models.User.create({
        id: id,
        pw: pw,
        email: email
    }).then((user) => res.status(201).json(user));
};

exports.update = (req, res) => {
    console.log('update func');
    const newName = req.body.name || '';
    const name = models.User.name;
    const id = parseInt(req.params.id, 10);

    if(!name.length){
        return res.status(400).json({err: 'Incrrect name'});
    }

    models.User.update(
        {name: newName},
        {where: {id: id}, returning: true})
        .then(function(result) {
             res.json(result[1][0]);
        }).catch(function(err) {
             //TODO: error handling
             return res.status(404).json({err: 'Undefined error!'});
    });
}
exports.login = (req, res) => {
    console.log('login func');
    var id,pw;
    var ary=[];
    ary = id_pw_parsing(req)
    id = ary[0], pw =ary[1];
    console.log(ary);
    if(!id.length || !pw.length){
        return res.status(400).json({err: 'Login session, Incorrect name'});
    }
    models.User.findOne({
        where: {
            id: id
        }
    }).then(user => {
        if(!user){
            console.log(user)
            return res.status(404).json({err: 'Login session, No User'});
        }
        if(pw == user.pw){
            return res.json({content: 'login OK!'});

        }
        else{
            return res.status(404).json({err: 'Login session, Incorrect PW'});
        }
    });
}
// '127.0.0.1:3000/users/check/'
// curl -X POST '127.0.0.1:3000/users/check/' -d id='hi'
// {"content":"id validation false"}
// curl -X POST '127.0.0.1:3000/users/check/' -d id='test'
// {"content":"ok"}%   
exports.usercheck = (req, res) => {
    console.log("user check func");
    console.log(req.body);
    const id = req.body.id || '';
    if(id==''){
        console.log('id not input')
        return res.status(400).json({content: 'Incorrect id field'});
    }

    models.User.findOne({
        where: {
            id: id
        }
    }).then(user => {
        if(user){
            console.log(user);
            return res.status(400).json({content: 'id validation false'});
            // 유저가 DB에 있기에, 400 msg
        }
        return res.status(200).json({content: 'ok'});
    });
}
