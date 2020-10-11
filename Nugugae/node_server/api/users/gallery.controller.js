const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

const multer = require('multer')
const img_multer = multer({dest: '../../temp/img'}) //dest : 저장 위치


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
// POST '127.0.0.1:3000/gallery/upload/'   
exports.gallery_upload = (req, res) => {
    console.log('galleryDB upload test');
    var id = req.body.id || '';
    var imgname = req.body.imgname || '';
    var date = req.body.date || '';
    var image = req.body.img;

};