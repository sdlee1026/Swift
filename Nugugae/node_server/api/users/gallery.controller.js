const e = require('express');
var fs = require('fs'); // file system
const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

// 모든 id,date gallery, index test

exports.gallery_index = (req, res) => {
    console.log('galleryDB test');
    models.GalleryTable.findAll().then(function(results) {
        res.json(results);
    }).catch(function(err) {
        //TODO: error handling
        return res.status(404).json({err: 'Undefined error!'});
    });
};
// 갤러리 사진() +1_private
// POST '127.0.0.1:3000/gallery/upload/private'   
exports.gallery_upload_private = (req, res) => {
    console.log('galleryDB upload_private test');
    var id = req.body.id;
    var ispublic = 0 // false
    console.log(req.files)
    var date = req.files['image'][0].filename.split('-'+id)[0]
    var imgdate = req.body.imgdate || '';
    var location = req.body.location || '';
    var hashtag = req.body.hashtag || '';
    var content = req.body.content || '';

    console.log(id, ispublic, imgdate, location)
    console.log('date : ',date)
    console.log('hashtag : ',hashtag)
    console.log('content : ',content)
    // console.log(req)
    console.log('img : ')
    console.log(req.files['image'][0].destination)
    console.log(req.files['image'][0].filename)
    console.log('img05 : ')
    console.log(req.files['image05'][0].destination)
    console.log(req.files['image05'][0].filename)
    console.log('img01 : ')
    console.log(req.files['image01'][0].destination)
    console.log(req.files['image01'][0].filename)
    
    
    
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 원본파일
    var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename
    // 50%
    var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename
    // 10%
    var img01 = req.files['image01'][0].destination+'/'+req.files['image01'][0].filename
    // 이미지 파일은 서버에 저장, 디비에는 링크만..
    if (img != null){
        console.log('img 있음, db insert')
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
                models.GalleryTable.create({
                    id: id,
                    ispublic: ispublic,
                    date: date,
                    imgdate: imgdate,
                    image: img,
                    image05: img05,
                    image01: img01,
                    hashtag: hashtag,
                    content: content,
                    location: location,
                }).then((walk) => {
                    models.UserTableCount.update(
                        {gallerycount: models.sequelize.literal('gallerycount + 1')},
                        {
                            where:{
                                id:id
                            }
                        }
                    )
                    return res.status(201).json({content: 'write OK'});
                });
            }

        })
    }

};
// 갤러리 사진() +1_public
// POST '127.0.0.1:3000/gallery/upload/public'   
exports.gallery_upload_public = (req, res) => {
    console.log('galleryDB upload_public test');
    var id = req.body.id;
    var ispublic = 1 // true
    console.log(req.files)
    var date = req.files['image'][0].filename.split('-'+id)[0]
    var imgdate = req.body.imgdate || '';
    var location = req.body.location || '';
    var hashtag = req.body.hashtag || '';
    var content = req.body.content || '';
    
    console.log(id, ispublic, imgdate, location)
    console.log('date : ',date)
    console.log('hashtag : ',hashtag)
    console.log('content : ',content)
    // console.log(req)
    console.log('img : ')
    console.log(req.files['image'][0].destination)
    console.log(req.files['image'][0].filename)
    console.log('img05 : ')
    console.log(req.files['image05'][0].destination)
    console.log(req.files['image05'][0].filename)
    console.log('img01 : ')
    console.log(req.files['image01'][0].destination)
    console.log(req.files['image01'][0].filename)
    
    
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 원본파일
    var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename
    // 50%
    var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename
    // 10%
    var img01 = req.files['image01'][0].destination+'/'+req.files['image01'][0].filename
    // 이미지 파일은 서버에 저장, 디비에는 링크만..
    if (img != null){
        console.log('img 있음, db insert')
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
                models.GalleryTable.create({
                    id: id,
                    ispublic: ispublic,
                    date: date,
                    imgdate: imgdate,
                    image: img,
                    image05: img05,
                    image01: img01,
                    hashtag: hashtag,
                    // 차후에 해쉬태그만 관리하는 DB테이블 만들기..1016
                    content: content,
                    location: location,
                }).then((walk) => {
                    models.UserTableCount.update(
                        {gallerycount: models.sequelize.literal('gallerycount + 1')},
                        {
                            where:{
                                id:id
                            }
                        }
                    )
                    return res.status(201).json({content: 'write OK'});
                });
            }

        })
    }

};

// 갤러리 게시물 보기, 컬렉션 뷰 선택시 하나의 화면으로 보기
exports.gallery_view = (req, res) => {
    console.log('gallery view item');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';

    models.GalleryTable.findOne({
        where: {
            id: id,
            date: date,
            imgdate: imgdate,
        }
    }).then(gallery => {
        if(!gallery){
            console.log(gallery);
            return res.status(404).json({err: 'No gallery'});
        }
        // 50% 사진 사용
        console.log(gallery['image05']);
        if (gallery['image05'] != null){
            var img = fs.readFileSync(gallery['image05'], 'base64');
            gallery['image05'] = img
        }
        else{
            gallery['image05'] = null
        }
        // img 파일 읽기, image05 적재, 50% 사진 보기 용
        return res.json(gallery);

    });
};

// 자신의 갤러리 전체 보기 썸네일10% 이미지 사용
exports.gallery_my_view = (req, res) =>{
    console.log('gallery my view')
    var id = req.body.id || '';
    var offset = req.body.offset || 0;
    var limit = 9;// 한번에 9개씩 load
    var int_offset = parseInt(offset)
    id = String(id)

    // 카운트 테이블에서 갤러리 카운트
    models.UserTableCount.findOne({
        where: {id: id}
    }).then(usergallerycount =>{
        var offset_limit = parseInt(usergallerycount.gallerycount);
        // 갤러리 내에 들어있는 갯수
        console.log(usergallerycount.gallerycount)
        console.log(offset_limit, offset)
        if (offset_limit > offset){
            models.GalleryTable.findAll({
                offset: int_offset,
                limit: limit,
                where:{
                    id: id
                },order: [['date','DESC']],
            }).then(gallery =>{
                if(!gallery){
                    console.log(gallery);
                    return res.status(404).json({err: 'No User'});
                }
                for (var i=0; i<gallery.length;i++){
                    console.log(gallery[i]['image01']);
                    if (gallery[i]['image01'] != null){
                        var img = fs.readFileSync(gallery[i]['image01'], 'base64');
                        gallery[i]['image01'] = img
                    }
                    else{
                        gallery[i]['image01'] = null
                    }
                    // img 파일 읽기, image01 적재, 10% 썸네일용
                }
                return res.json(gallery);
            })
        }// 총 사진 갯수보다 오프셋 기준이 적은 경우만 return, == 아이템이 있는 경우
        else{
            console.log('No item error return, 사진 더 없음')
            return res.status(400).json({err: 'No item'})
        }

    });
};

exports.gallery_delete = (req, res) => {
    console.log('gallery_delete');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';

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
            models.GalleryTable.findOne({
                where: {
                    id: id,
                    date: date,
                    imgdate: imgdate,
                }
            }).then((gallery)=>{
                // 스토리지 삭제 동작
                console.log(gallery['image'], gallery['image05'], gallery['image01']);

                if (gallery['image'] != '' && gallery['image05'] != '' && gallery['image01'] != ''){
                    fs.unlink(gallery['image'], function(err) {
                        if (err) throw err;
                        console.log('file deleted');
                    });// 비동기
                    fs.unlink(gallery['image05'], function(err) {
                        if (err) throw err;
                        console.log('file deleted');
                    });
                    fs.unlink(gallery['image01'], function(err) {
                        if (err) throw err;
                        console.log('file deleted');
                    });
                    // 삭제 후, 테이블카운트에서 갤러리 카운트 --1
                    models.UserTableCount.update(
                        {gallerycount: models.sequelize.literal('gallerycount - 1')},
                        {
                            where:{
                                id:id
                            }
                        }
                    ).then(gcount =>{
                        console.log('tableCount --1, gallerycount');
                        models.GalleryTable.destroy({
                            where: {
                                id: id,
                                date: date,
                                imgdate: imgdate,
                            }
                        }).then((gallery) => {
                            return res.status(201).json({content: 'delete OK'});
                        });
                    });
                }
            });
        }
    });
};