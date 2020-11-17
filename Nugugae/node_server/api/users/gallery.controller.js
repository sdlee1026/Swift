const e = require('express');
var fs = require('fs'); // file system
const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

const Sequelize = require('sequelize');
const Op = Sequelize.Op;
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
            });
        }// 총 사진 갯수보다 오프셋 기준이 적은 경우만 return, == 아이템이 있는 경우
        else{
            console.log('No item error return, 사진 더 없음')
            return res.status(400).json({err: 'No item'})
        }

    });
};
exports.gallery_my_view_selectday = (req, res) => {
    console.log("walk_view, select day image collections func");
    var id = req.body.id || '';
    var offset = req.body.offset || 0;
    var limit = 9;// 한번에 9개씩 load
    var int_offset = parseInt(offset)
    var selectday = req.body.selectday.split(' ')[0] || '';
    id = String(id)

    console.log(id, offset, selectday)
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
                    id: id,
                    date: {
                        [Op.like]: "%" + selectday + "%"
                    }
                },order: [['date','DESC']],
            }).then(gallery =>{
                console.log(gallery)
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
// 이미지 변경 x, 자기 게시물 수정
exports.gallery_update_noimg = (req, res) => {
    console.log('gallery_update no change img, user self');

    var id = req.body.id || '';
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';
    var pu_pr = req.body.pu_pr || '';
    var content = req.body.content || '';
    console.log(id, date, imgdate, pu_pr, content);
    
    if(!id.length){
        return res.status(400).json({err: 'Incorrect name'});
    }

    models.GalleryTable.update(
        {
            ispublic:pu_pr,
            content: content,
        },// 퍼블릭 or 프라이빗, 사진 텍스트 변경
        {where: {
            id: id,
            date: date,
            imgdate: imgdate,
        }, returning: true}).then((userinfo) => {
        return res.status(201).json({content: 'Update OK'})
    });

};

exports.gallery_update_img_private = (req, res) =>{
    // imgdate만 바뀌어야함, date는 고정
    console.log("private img update");
    var id = req.body.id;
    var ispublic = 0 // false
    console.log(req.files)
    var date = req.body.date;
    var imgdate = req.body.imgdate || '';
    var location = req.body.location || '';
    var hashtag = req.body.hashtag || '';
    var content = req.body.content || '';
    var imgdate_before = req.body.imgdate_before || '';// 과거 이미지 날짜

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

    models.GalleryTable.findOne({
        where: {
            id: id,
            date: date,
            imgdate: imgdate_before,
        }
    }).then(gallery => {
        if(!gallery){
            return res.status(404).json({err: 'No Image'});
        }
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
            // 원본파일
            var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename
            // 50%
            var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename
            // 10%
            var img01 = req.files['image01'][0].destination+'/'+req.files['image01'][0].filename

            models.GalleryTable.update(
                {
                    ispublic: ispublic,
                    imgdate: imgdate,
                    image: img,
                    image05: img05,
                    image01: img01,
                    content: content,
                    location: location,

                },
                {where: {
                    id: id,
                    date: date,
                    imgindex: 0, // 일단은 0으로 고정.. < 차후에 여러장 앨범스택 형태로 되어있는 것 처리할때 필요
                }, returning: true}).then((doginfo) => {
                return res.status(201).json({content: 'Update OK'})
            });
        }// delete if {}, update()
        
    });
    // 과거 파일 삭제 (디비 스토리지)

};
exports.gallery_update_img_public = (req, res) =>{
    console.log("public img update");
    // 과거 파일 삭제 (디비 스토리지)
    var id = req.body.id;
    var ispublic = 1 // true
    console.log(req.files)
    var date = req.body.date;
    var imgdate = req.body.imgdate || '';
    var location = req.body.location || '';
    var hashtag = req.body.hashtag || '';
    var content = req.body.content || '';
    var imgdate_before = req.body.imgdate_before || '';// 과거 이미지 날짜
    
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

    models.GalleryTable.findOne({
        where: {
            id: id,
            date: date,
            imgdate: imgdate_before,
        }
    }).then(gallery => {
        if(!gallery){
            return res.status(404).json({err: 'No Image'});
        }
        // 스토리지 삭제 동작
        console.log('삭제 완료, 이미지 삽입 시작..')
        console.log(gallery['image'], gallery['image05'], gallery['image01']);
        console.log('img check 완료..')

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
            // 원본파일
            var img = req.files['image'][0].destination+'/'+req.files['image'][0].filename
            // 50%
            var img05 = req.files['image05'][0].destination+'/'+req.files['image05'][0].filename
            // 10%
            var img01 = req.files['image01'][0].destination+'/'+req.files['image01'][0].filename

            models.GalleryTable.update(
                {
                    ispublic: ispublic,
                    imgdate: imgdate,
                    image: img,
                    image05: img05,
                    image01: img01,
                    content: content,
                    location: location,

                },
                {where: {
                    id: id,
                    date: date,
                    imgindex: 0, // 일단은 0으로 고정.. < 차후에 여러장 앨범스택 형태로 되어있는 것 처리할때 필요
                }, returning: true}).then((doginfo) => {
                return res.status(201).json({content: 'Update OK'})
            });
        }// delete if {}, update()
        
    });
    // 과거 파일 삭제 (디비 스토리지)

};

// 갤러리 자기 게시물 삭제
exports.gallery_delete = (req, res) => {
    console.log('gallery_delete, user self');
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

// 갤러리 댓글, 로드
exports.reply_load = (req, res) => {
    console.log('reply load func');
    var id = req.body.id || ''; // 갤러리 id
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';
    var reply_user = req.body.reply_user || '';// 리플 서비스 접근한 유저

   
    models.GalleryTable.findOne({
        where: {
            id: id,
            date: date,
            imgdate: imgdate,
        }
    }).then(gallery => {
        console.log('\ngallery find, reply load\n');
        console.log(gallery["reply"]);
        var return_reply = gallery["reply"];
        
        return res.json({content: return_reply});

    });
};
exports.reply_new = (req, res) => {
    console.log('new reply func');
    var id = req.body.id || ''; // 갤러리 id
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';
    var reply_user = req.body.reply_user || '';// 리플 서비스 접근한 유저
    var reply = req.body.reply || '';
    models.GalleryTable.update({
        reply: reply

    },{
        where:{
            id: id,
            date: date,
            imgdate: imgdate,
        }

    }).then(gallery =>{
        models.GalleryTable.findOne({
            where: {
                id: id,
                date: date,
                imgdate: imgdate,
            }
        }).then(gallery => {
            console.log('\nupdate andthen -> gallery find, reply load\n');
            console.log(gallery["reply"]);
            var return_reply = gallery["reply"];
            
            return res.json({content: return_reply});
    
        });
    });

};
// 갤러리 좋아요(like) 업데이트
exports.like_update = (req, res) => {
    console.log('like_update func');
    var id = req.body.id || '';
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';
    var like_self = req.body.like_self || ''; // 좋아요 체크 토큰값
    var like_user = req.body.like_user || ''; // 좋아요 접근한 유저

    console.log(id,like_user,like_self);

    models.GalleryTable.findOne({
        where: {
            id: id,
            date: date,
            imgdate: imgdate,
        }
    }).then(gallery => {
        console.log('\ngallery find, like check\n');
        if (like_self == 'true'){
            if (gallery['like'] ==null){
                console.log('아예 빈배열에 처음 넣는 경우');
                var insert_str = like_user+','
                models.GalleryTable.update({
                    like: insert_str
                },
                {
                    where:{
                        id: id,
                        date: date,
                        imgdate: imgdate,
                    }
                }).then(gallery_update => {
                    return res.status(201).json({content: 'like_update'});
                });

            }
            else if (gallery['like'].indexOf(like_user) == -1){
                var insert_str = gallery['like']
                console.log(insert_str);
                insert_str += like_user+','
                console.log(insert_str);
                console.log('str을 id(like_user)를 넣고, update');
                models.GalleryTable.update({
                    like: insert_str
                },
                {
                    where:{
                        id: id,
                        date: date,
                        imgdate: imgdate,
                    }
                }).then(gallery_update => {
                    return res.status(201).json({content: 'like_update'});
                });
            }// gallery['like'] 내에 없는 경우, like가 true일때 update
            else{
                return res.status(201).json({content: 'like_update'});
            }
        }
        else{
            console.log('\nunlike로 들어왔을때, 비교하기 전에 한번 null인지 체크해줘야 한다.\n',gallery['like']);
            if (gallery['like'] == null){
                console.log('null 이기 때문에, 그냥 return');
                return res.status(201).json({content : 'like_update'});
            }
            else if (gallery['like'].indexOf(like_user) != -1){
                var insert_str = gallery['like']
                console.log(insert_str);
                insert_str = insert_str.replace(like_user+',','');
                console.log(insert_str);
                console.log('str에서 id(like_user)를 빼고(replace), update');
                models.GalleryTable.update({
                    like: insert_str
                },
                {
                    where:{
                        id: id,
                        date: date,
                        imgdate: imgdate,
                    }
                }).then(gallery_update => {
                    return res.status(201).json({content: 'like_update'});
                });
            }// gallery['like']에 존재하는 경우, like가 false일때 update
            else{
                return res.status(201).json({content: 'like_update'});
            }
        }
    });
};