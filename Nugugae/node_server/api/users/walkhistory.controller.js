const e = require('express');
const Sequelize = require('sequelize');
const { off } = require('../../app');
const models = require('../../models/models');//DB
const Op = Sequelize.Op;
const { UserTableCount } = require('../../models/models');

// 산책 기록(과거 산책 맵뷰 보기)
exports.history_load_table = (req, res) => {
    console.log('history load table');
    var id = req.body.id || '';
    var offset = req.body.offset || 0;
    var limit = 10
    var int_offset = parseInt(offset)

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
            models.UserTableCount.findOne({
                where: {id: id}
            }).then(usergallerycount =>{
                console.log('\nhistory info load\n');
                var offset_limit = parseInt(usergallerycount.gallerycount);
                console.log('offset : ', offset);
                console.log('count : ', offset_limit);

                if (offset_limit>offset){
                    models.walksInfoTable.findAll({
                        offset: int_offset,
                        limit: limit,
                        where: {
                            id: id
                        },order: [['date', 'DESC']],
                    }).then(history => {
                        if(!history){
                            console.log(history);
                            return res.status(404).json({err: 'No history'});
                        }
                        return res.json(history);
                    })

                }
                else{
                    console.log('No item error return')
                    return res.status(400).json({err: 'No item'})
                }

            });
        }
    });

};