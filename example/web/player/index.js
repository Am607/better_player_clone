function initPlayer() {
    document.addEventListener('DOMContentLoaded', function () {


    console.log("init player----->");
        var options = {};

        var player = videojs('my-player', options);

        player.on(['loadstart', 'play', 'playing', 'firstplay', 'pause', 'ended', 'adplay', 'adplaying', 'adfirstplay', 'adpause', 'adended', 'contentplay', 'contentplaying', 'contentfirstplay', 'contentpause', 'contentended', 'contentupdate'], function (e) {
            console.warn('VIDEOJS player event: ', e.type);
        });


        player.src({
            src:"https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
            type: "application/x-mpegURL",
        });

        player.httpSourceSelector(

        );
    });

}


function setSrc() {
    const player = videojs.getPlayer('my-player');

    // player.src({
    //     src:"https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
    //     type: "application/x-mpegURL",
    // });
}