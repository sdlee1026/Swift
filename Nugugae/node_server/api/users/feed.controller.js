const e = require('express');
var fs = require('fs'); // file system
const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

const Sequelize = require('sequelize');
const Op = Sequelize.Op;

exports.search_user = (req,res) => {
    console.log('user search func');
    var id = req.body.id || '';
    models.User.findAll({
        where:{
            id:{
                [Op.like]:"%" + id + "%"
            }// 유사 검색,포함했을 경우 모두 return
        }
    }).then(user => {
        console.log('\n 서칭 결과\n');
        console.log(user);
        if (user.length == 0){
            console.log('결과 없음 에러 메세지 json 리턴');
            return res.status(201).json({err : 'No user'});
        }
        else{
            console.log('결과 존재, 결과값 리턴');
            return res.json(user);
        }
    });
};