const models = require('../../models/models');//DB

exports.dog_detail_view = (req, res) => {
    console.log('dog_view test')
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';

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
        console.log(dogsinfo);
        return res.json(dogsinfo);
    });

};

exports.dog_write = (req, res) => {
    console.log('dog_write test')
    var id = req.body.id || '';
    var dogname = req.body.dogname || '';
    var breed = req.body.breed || '';
    var age = req.body.age || '';
    var activity = req.body.activity || -1;
    var Sociability = req.body.Sociability || -1;
    var introduce = req.body.introduce || '';

    console.log(id, dogname, breed, age, introduce)
    var float_activity = parseFloat(activity)
    var float_Sociability = parseFloat(Sociability)
    console.log(float_activity)
    console.log(float_Sociability)

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
            }).then((doginfo) => {
                return res.status(201).json({content: 'write OK'});
            });

        }
    });
};