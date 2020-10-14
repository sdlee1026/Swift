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
// 갤러리 사진 +1
// POST '127.0.0.1:3000/gallery/upload/'   
exports.gallery_upload = (req, res) => {
    console.log('galleryDB upload test');
    var id = req.body.id;
    var ispublic = req.body.ispublic || '0'; // (default)false -> 0, true -> 1
    var date = req.body.date || '';
    var imgdate = req.body.imgdate || '';
    var location = req.body.location;
    console.log(id, ispublic, date, imgdate, location)
    // console.log(req)
    console.log('img : ')
    console.log(req.file)
    console.log(req.file.destination)
    console.log(req.file.filename)
    
    var img = fs.readFileSync(req.file.destination+req.file.filename)

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