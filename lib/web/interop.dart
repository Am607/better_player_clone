@JS()
library videojs;




import 'package:js/js.dart';



@JS()
class videojs {
  external factory videojs(String id, Object options);

  external static videojs ? getPlayer(String id);
  external  void src(
    String src,
    String type,
  );
  external void play();
  external void pause();

external double duration();
external bool  isDisposed();
external bool isFullscreen();



 external double ? currentTime([int ? time]);

 external void on(String event,Function onEvent); 

external void  dispose();

  external void httpSourceSelector();
}
