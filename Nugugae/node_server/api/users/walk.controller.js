const models = require('../../models/models');//DB

// WalkTableDB useAPI
// 모든 id,date 불러오기
exports.index = (req, res) => {
    console.log("walkTableDB test");
    console.log(models.Walk.findAll())
    console.log(models.User.name)
    models.Walk.findAll().then(function(results) {
        res.json(results);
    }).catch(function(err) {
        //TODO: error handling
        return res.status(404).json({err: 'Undefined error!'});
    });
};