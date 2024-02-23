// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class MyWidget extends StatelessWidget {
//   const MyWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//                   top: 0,
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: YoutubeValueBuilder(builder: (context, value) {
//                       return Builder(builder: (context) {
//                         return SizedBox(
//                           // width: MediaQuery.of(context).size.width,
//                           width: MediaQuery.of(context).size.width - widget.controlsPadding,
//                           child: Visibility(
//                             visible: value.isControlsVisible,
//                             child: Padding(
//                               padding: const EdgeInsets.fromLTRB(11, 12, 11, 0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Visibility(
//                                     replacement: SizedBox(
//                                       width: 20,
//                                     ),
//                                     visible: widget.isBackVisible,
//                                     child: InkWell(
//                                       onTap: widget.function,
//                                       child: Container(
//                                         width: 31,
//                                         height: 31,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: const Color(0x33263047).withOpacity(.8),
//                                           // color: Colors.white.withOpacity(.8),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(
//                                             Icons.arrow_back,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // Spacer(),
//                                   InkWell(
//                                     child: Row(
//                                       children: [
//                                         SvgPicture.asset(
//                                           fit: BoxFit.scaleDown,
//                                           PlayerImages.speed,
//                                           height: 24,
//                                           width: 24,
//                                         ),
//                                         SizedBox(
//                                           width: 4,
//                                         ),
//                                         Text(
//                                           '1x',
//                                           style: TextStyle(
//                                               color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
//                                         )
//                                       ],
//                                     ),
//                                     onTap: () {
//                                       // showSettingsBottomSheet(context, widget.controller);
//                                       showPlayBackBottomSheet(context, widget.controller);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       });
//                     }),
//                   ),
//                 ),
//   }
// }