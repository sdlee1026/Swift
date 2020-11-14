const e = require('express');
var fs = require('fs'); // file system
const models = require('../../models/models');//DB
const { UserTableCount } = require('../../models/models');

const Sequelize = require('sequelize');
const { where } = require('sequelize');
const Op = Sequelize.Op;

// 피드 다른 유저 검색 기능
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

// 피드 컬렉션 뷰 로드
exports.feed_load = (req, res) => {
    console.log('\nfeed page load func\n');
    var offset = req.body.offset || '';
    console.log('\noffset is', offset);

    var int_offset = parseInt(offset)
    var false_count = 0;

    var for_end = true
    var end_index = -1

    models.UserTableCount.sum('gallerycount').then(hap => {
        console.log('모든 게시물 갯수, offset limit 구함 : ', hap);
        var offset_limit = hap
        console.log(offset_limit, int_offset);
        if (offset_limit > int_offset){
            models.GalleryTable.findAll({
                offset: int_offset,
                limit: (offset_limit-int_offset),
                order: [['date','DESC']],
            }).then(gallery => {
                console.log('\ngallery load, pr_pu check\n');
                for (var i=0; i<gallery.length;i++){
                    
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

                    if (((i+1) - false_count) <9){
                        gallery[i]['likecount'] = -1;
                        // likecount 임시로 offset (-1) 담아서 전송
                        for_end = true;
                        end_index = i;
                    }
                    else if (((i+1) - false_count ) == 9 ){ // index - 실패횟수 가 9개 일때
                        gallery[i]['likecount'] = (int_offset+i+1); // likecount 에 임시로 offset 담아서 전송
                        console.log('9개 달성, offset : ', int_offset+i+1);
                        i = gallery.length;//for문 종료
                        for_end = false// for문 비정상 종료
                    }
                }
                if (for_end){
                    gallery[end_index]['likecount'] = (int_offset+end_index+1);
                    console.log('끝까지 순회, offset : ', int_offset+end_index+1);
                }
                console.log('\n\nreturn 동작');

                return res.json(gallery);
            });
        }
        else{
            console.log('No item error return, 사진 더 없음')
            return res.status(400).json({err: 'No item'})
        }

    });

};

// 피드검색 or 좋아요누른유저 -> 다른 유저탐색 뷰 로드(퍼블릭만)
exports.other_user_load_public = (req, res) => {
    console.log('other user load func');
    var id = req.body.id || '';
    var offset = req.body.offset || '';
    var int_offset = parseInt(offset);
    var false_count = 0;

    var for_end = true
    var end_index = -1

    models.UserTableCount.sum('gallerycount', { 
        where: { id: id } 
    }).then(hap => {
        console.log('userid의 모든 게시물 갯수, offset limit 구함 : ', hap);
        var offset_limit = hap
        console.log(offset_limit, int_offset);

        if (offset_limit > int_offset){
            models.GalleryTable.findAll({
                offset: int_offset,
                limit: (offset_limit-int_offset),
                where:{
                    id: id
                },order: [['date','DESC']],
            }).then(gallery => {
                console.log('\nuserid of gallery load, pr_pu check\n');
                for (var i=0; i<gallery.length;i++){
                    
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

                    if (((i+1) - false_count) <9){
                        gallery[i]['likecount'] = -1;
                        // likecount 임시로 offset (-1) 담아서 전송
                        for_end = true;
                        end_index = i;
                    }
                    else if (((i+1) - false_count ) == 9 ){ // index - 실패횟수 가 9개 일때
                        gallery[i]['likecount'] = (int_offset+i+1); // likecount 에 임시로 offset 담아서 전송
                        console.log('9개 달성, offset : ', int_offset+i+1);
                        i = gallery.length;//for문 종료
                        for_end = false// for문 비정상 종료
                    }
                }
                if (for_end){
                    gallery[end_index]['likecount'] = (int_offset+end_index+1);
                    console.log('끝까지 순회, offset : ', int_offset+end_index+1);
                }
                console.log('\n\nreturn 동작');

                return res.json(gallery);
            });
        }
        else{
            console.log('No item error return, 사진 더 없음')
            return res.status(400).json({err: 'No item'})
        }
    });


};