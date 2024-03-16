function initPlayer() {
 
  

        console.log("init player111----->");

        var options = {};

        var player = videojs('my-player', options);
       

        player.on(['loadstart', 'play', 'playing', 'firstplay', 'pause', 'ended', 'adplay', 'adplaying', 'adfirstplay', 'adpause', 'adended', 'contentplay', 'contentplaying', 'contentfirstplay', 'contentpause', 'contentended', 'contentupdate'], function (e) {
            console.warn('VIDEOJS player event: ', e.type);
        });


       

        player.httpSourceSelector(

        );


    
    

}


function setSrc( src ,srcType ) {
    const player = videojs.getPlayer('my-player');

    player.src({
        src:src,
        type: srcType,
    });

    
}


function play(  ) {
    const player = videojs.getPlayer('my-player');

    player.play();

    
}

function pause(  ) {
    const player = videojs.getPlayer('my-player');

    player.pause();

    
}


function getPosition(  ) {
    const player = videojs.getPlayer('my-player');

    let currentTime = player.currentTime();

return currentTime;
    
}

function getTotalDuration(  ) {
    const player = videojs.getPlayer('my-player');

    let duration = player.duration();

return duration;
    
}