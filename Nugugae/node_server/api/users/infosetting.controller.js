var fs = require('fs'); // 파일 시스템
const Blob = require("cross-blob");
const models = require('../../models/models');//DB

exports.user_detail_view = (req, res) => {
    console.log('user_view detail');
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
            userinfo['image'] = img
        }
        else{
            console.log('userprofile img 없음')
            userinfo['image'] = null
        }

        return res.json(userinfo);
    });

};
// 유저에 대해 세부정보 보기

exports.dog_all_view = (req, res) => {
    console.log('user_doginfo all view');
    var id = req.body.id || ''
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.DogsInfo.findAll({
        where: {
            id: id
        },
    }).then(dogs => {
        if(!dogs){
            console.log(dogs);
            return res.status(404).json({err: 'No dogs'});
        }
        for (var i=0; i<dogs.length; i++){
            console.log(dogs[i]['image05'])
            if (dogs[i]['image05']!=null){
                console.log('dogs_profile_img 존재')
                var img = fs.readFileSync(dogs[i]['image05'], 'base64');
                dogs[i]['image'] = img
            }
            else{
                console.log('dogs_profile_img 없음')
                dogs[i]['image'] = null
            }
        }// findall 이므로, for문으로 모든 내용들 서치
        
        return res.json(dogs);
    })
};
// 개정보 테이블을 위한 정보 불러오기

exports.user_detail_update = (req, res) => {
    console.log('user_view update');
    var id = req.body.id || '';
    var nickname = req.body.nickname || '';
    var introduce = req.body.introduce || '';

    console.log(id, nickname, introduce)

    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }

    models.UserDetailInfo.update(
        {
            nickname: nickname,
            introduce: introduce,
        },
        {where: {
            id: id,
        }, returning: true}).then((userinfo) => {
        return res.status(201).json({content: 'Update OK'})
    });
};
// 유저의 세부정보 수정, 이미지 미포함

exports.user_detail_update_img = (req, res) => {
    console.log('user_view update_img');
    var id = req.body.id || '';
    var nickname = req.body.nickname || '';
    var introduce = req.body.introduce || '';

    console.log('img : ')
    console.log(req.files['image'][0].destination)
    console.log(req.files['image'][0].filename)
    console.log('img05 : ')
    console.log(req.files['image05'][0].destination)
    console.log(req.files['image05'][0].filename)

    console.log(id, nickname, introduce)

    models.UserDetailInfo.findOne({
        where: {
            id: id,
        }
    }).then(userinfo => {
        if(!userinfo){
            return res.status(404).json({err: 'No User'});
        }
        console.log("업데이트로 인한.. 과거 파일..삭제");
        console.log(userinfo['image'], userinfo['image05']);

        if (userinfo['image'] != '' && userinfo['image05'] != ''){
            fs.unlink(userinfo['image'], function(err) {
                if (err) throw err;
              
                console.log('file deleted');
              });// 비동기
              fs.unlink(userinfo['image05'], function(err) {
                  if (err) throw err;
                
                  console.log('file deleted');
                });       
        }
        else{
            console.log('first img insert, not delete files')
        }
    });
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 50%파일
    var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename || ''
    // 25%
    var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename || '' 
    // 이미지 파일은 서버에 저장, 디비에는 링크만..

    models.UserDetailInfo.update(
        {
            nickname: nickname,
            introduce: introduce,
            image: img,
            image05: img05,
        },
        {where: {
            id: id,
        }, returning: true}).then((userinfo) => {
        return res.status(201).json({content: 'Update OK'})
    });

};
// 유저의 세부정보 수정, 이미지 포함

exports.dog_detail_view = (req, res) => {
    console.log('dog_view test');
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    console.log(id, dogname)
    if(!id.length || !dogname.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.DogsInfo.findOne({
        where: {
            id: id,
            dogname: dogname,
        }
    }).then(dogsinfo => {
        if(!dogsinfo){
            return res.status(404).json({err: 'No User'});
        }
        console.log(dogsinfo['image05'])
        if (dogsinfo['image05'] != null){
            console.log('img 존재')
            var img = fs.readFileSync(dogsinfo['image05'], 'base64');
            dogsinfo['image'] = img
        }
        else{
            dogsinfo['image'] = null
        }
        //console.log(dogsinfo);
        return res.json(dogsinfo);
    });

};
// 개에 대해 세부정보 보기

exports.dog_detail_update = (req, res) =>{
    console.log('dog_view update');
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    var breed = req.body.breed || '';
    var age = req.body.age || '';
    var activity = req.body.activity || -1;
    var introduce = req.body.introduce || '';

    console.log(id, dogname, breed, age, introduce)
    var float_activity = parseFloat(activity)
    console.log(float_activity)


    models.DogsInfo.update(
        {
            activity: float_activity,
            breed: breed,
            age: age,
            introduce: introduce,
        },
        {where: {
            id: id,
            dogname:dogname
        }, returning: true}).then((doginfo) => {
        return res.status(201).json({content: 'Update OK'})
    });
};
// 개에 대해 세부정보 수정, 이미지 미포함

exports.dog_detail_update_img = (req, res) =>{
    console.log('dog_view update_img');
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    var breed = req.body.breed || '';
    var age = req.body.age || '';
    var activity = req.body.activity || -1;
    var introduce = req.body.introduce || '';

    console.log('img : ')
    console.log(req.files['image'][0].destination)
    console.log(req.files['image'][0].filename)
    console.log('img05 : ')
    console.log(req.files['image05'][0].destination)
    console.log(req.files['image05'][0].filename)

    console.log(id, dogname, breed, age, introduce)
    var float_activity = parseFloat(activity)
    console.log(float_activity)

    models.DogsInfo.findOne({
        where: {
            id: id,
            dogname: dogname,
        }
    }).then(dogsinfo => {
        if(!dogsinfo){
            return res.status(404).json({err: 'No User'});
        }
        console.log("업데이트로 인한.. 과거 파일..삭제");
        console.log(dogsinfo['image'], dogsinfo['image05']);

        if (dogsinfo['image'] != '' && dogsinfo['image05'] != ''){
            fs.unlink(dogsinfo['image'], function(err) {
                if (err) throw err;
              
                console.log('file deleted');
              });// 비동기
              fs.unlink(dogsinfo['image05'], function(err) {
                  if (err) throw err;
                
                  console.log('file deleted');
                });       
        }
        else{
            console.log('first img insert, not delete files')
        }
    });
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 50%파일
    var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename || ''
    // 25%
    var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename || '' 
    // 이미지 파일은 서버에 저장, 디비에는 링크만..

    models.DogsInfo.update(
        {
            activity: float_activity,
            breed: breed,
            age: age,
            introduce: introduce,
            image: img,
            image05: img05,
        },
        {where: {
            id: id,
            dogname:dogname
        }, returning: true}).then((doginfo) => {
        return res.status(201).json({content: 'Update OK'})
    });
};
// 개에 대해 세부정보 수정, 이미지 포함

exports.dog_write = (req, res) => {
    console.log('dog_write test')
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    var breed = req.body.breed || '';
    var age = req.body.age || '';
    var activity = req.body.activity || -1;
    var Sociability = req.body.Sociability || -1;
    var introduce = req.body.introduce || '';

    console.log('img : ')
    console.log(req.files['image'][0].destination)
    console.log(req.files['image'][0].filename)
    console.log('img05 : ')
    console.log(req.files['image05'][0].destination)
    console.log(req.files['image05'][0].filename)

    console.log(id, dogname, breed, age, introduce)
    var float_activity = parseFloat(activity)
    var float_Sociability = parseFloat(Sociability)
    console.log(float_activity)
    console.log(float_Sociability)
    

    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 50%파일
    var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename || '';
    // 25%
    var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename || '';
    // 이미지 파일은 서버에 저장, 디비에는 링크만..
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
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
            models.DogsInfo.create({
                id: id,
                dogname: dogname,
                breed: breed,
                age: age,
                activity: float_activity,
                Sociability: float_Sociability,
                introduce: introduce,
                image: img,
                image05: img05,
            }).then((doginfo) => {
                return res.status(201).json({content: 'write OK'});
            });

        }
    });
};
// 개 정보 쓰기

exports.dog_detail_delete = (req, res) => {
    console.log('dog_detail delete')
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }
    models.DogsInfo.findOne({
        where: {
            id: id,
            dogname: dogname,
        }
    }).then(dogsinfo => {
        if(!dogsinfo){
            return res.status(404).json({err: 'No User'});
        }
        console.log("삭제로 인한.. 서버 스토리지 파일..삭제");
        console.log(dogsinfo['image'], dogsinfo['image05']);

        if (dogsinfo['image'] != '' && dogsinfo['image05'] != ''){
            fs.unlink(dogsinfo['image'], function(err) {
                if (err) throw err;
              
                console.log('file deleted');
              });// 비동기
              fs.unlink(dogsinfo['image05'], function(err) {
                  if (err) throw err;
                
                  console.log('file deleted');
                });       
        }
        else{
            console.log('empty img DB_link, not delete files')
        }
    });
    
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
            models.DogsInfo.destroy({
                where: {
                    id: id,
                    dogname: dogname
                }
            }).then((dogsinfo) => {
                return res.status(201).json({content: 'delete OK'});
            });
        }
    });
};
// 개정보 지우기