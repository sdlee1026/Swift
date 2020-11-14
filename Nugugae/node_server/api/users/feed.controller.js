const e = require('express');
var fs = require('fs'); // file system
const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

const Sequelize = require('sequelize');
const Op = Sequelize.Op;

exports.search_user = (req, res) => {
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

exports.feed_load = (req, res) => {
    console.log('feed page load func');
    var offset = req.body.offset || '';

    var ispublic = 1; // 항상 공개된 게시물만
    var limit = 18;// 한번에 9개씩 load
    var int_offset = parseInt(offset)
    var false_count = 0;

    models.UserTableCount.sum('gallerycount').then(hap => {
        console.log('모든 게시물 갯수, offset limit 구함 : ', hap);
        var offset_limit = hap
        console.log(offset_limit, offset);
        if (offset_limit > offset){
            models.GalleryTable.findAll({
                offset: int_offset,
                limit: (offset_limit-offset),
                order: [['date','DESC']],
            }).then(gallery => {
                console.log('\ngallery load, pr_pu check\n');
                for (var i=0; i<gallery.length;i++){
                    if ((i - false_count ) == 9 ){ // index - 실패횟수 가 9개 일때
                        console.log('9개 달성 return');
                        gallery[i]['likecount'] = offset+i; // likecount 에 임시로 offset 담아서 전송
                        console.log(gallery);

                        return res.json(gallery);
                    }
                    else{
                        gallery[i]['likecount'] = -1; // likecount 임시로 offset (-1) 담아서 전송
                        console.log(gallery[i])
                    }
                    
                    console.log('is public?',gallery[i]['ispublic']);
                    if (gallery[i]['ispublic'] == 1){
                        console.log(gallery[i]['image01']);
                        if (gallery[i]['image01'] != null){
                            var img = fs.readFileSync(gallery[i]['image01'], 'base64');
                            gallery[i]['image01'] = img
                        }
                        else{
                            console.log('not have img');
                            gallery[i]['image01'] = null
                            false_count += 1;
                        }// 사진 없을 경우
                    }// 공개 게시물인 경우만
                    else{
                        console.log('not load, private');
                        gallery[i]['image01'] = null
                        false_count += 1;
                    }// 비공개 게시물일 경우 null로 보냄
                    // img 파일 읽기, image01 적재, 10% 썸네일용
                }
                return res.json(gallery);
            });
        }
        else{
            console.log('No item error return, 사진 더 없음')
            return res.status(400).json({err: 'No item'})
        }

    });

};