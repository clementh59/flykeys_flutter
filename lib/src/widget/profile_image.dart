import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_size.dart';

/**
 * Create a profile image with a notificationPoint if he needs to
 */

class ProfileImage extends StatefulWidget {

	ProfileImage();

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {

	bool hasNotification = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
			children: <Widget>[
				Padding(
				  padding: const EdgeInsets.only(top : 3.5, right: 3.5),
				  child: Container(
				  	height: 28,
				    child: ClipRRect(
				    	borderRadius: BorderRadius.circular(20),
				    	child: Image.asset("assets/images/temporary/clement.jpg"),
				    ),
				  ),
				),
				hasNotification? Positioned(
					right: 0,
				  top: 0,
				  child: ClipRRect(
				  	borderRadius: BorderRadius.circular(6),
				    child: Container(
				    	height: 12,
				    	width: 12,
				    	color: CustomColors.backgroundColor,
							child: Center(
							  child: ClipRRect(
							  	borderRadius: BorderRadius.circular(4),
							  	child: Container(
							    	height: 6,
							    	width: 6,
							    	color: CustomColors.blue,
							    ),
							  ),
							),
				    ),
				  ),
				) : SizedBox(),
			],
		);
  }
}
