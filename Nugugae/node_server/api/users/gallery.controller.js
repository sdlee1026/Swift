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
    var date = req.file.filename.split('-'+id)[0]
    var imgdate = req.body.imgdate || '';
    var location = req.body.location;
    console.log(id, ispublic, imgdate, location)
    console.log('date : ',date)
    // console.log(req)
    console.log('img : ')
    console.log(req.file)
    console.log(req.file.destination)
    console.log(req.file.filename)
    
    
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 원본파일
    var img = req.file.destination+req.file.filename
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
    var date = req.file.filename.split('-'+id)[0]
    var imgdate = req.body.imgdate || '';
    var location = req.body.location;
    console.log(id, ispublic, imgdate, location)
    console.log('date : ',date)
    // console.log(req)
    console.log('img : ')
    console.log(req.file)
    console.log(req.file.destination)
    console.log(req.file.filename)
    
    
    // var img = fs.readFileSync(req.file.destination+req.file.filename)
    // 원본파일
    var img = req.file.destination+req.file.filename
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