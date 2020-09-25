/// This widgets pops up when a contact is added it takes [name]
/// [handle] to display the name and the handle of the user and an
/// onTap function named as [onYesTap] for on press of [Yes] button of the dialog

import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class AddContactDialog extends StatelessWidget {
  final String name;
  final String handle;
  final Function() onYesTap;

  const AddContactDialog({Key key, this.name, this.handle, this.onYesTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.toWidth)),
        titlePadding: EdgeInsets.only(
            top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                TextStrings().addContactHeading,
                textAlign: TextAlign.center,
                style: CustomTextStyles.secondaryRegular16,
              ),
            )
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 190.toHeight),
          child: Column(
            children: [
              SizedBox(
                height: 21.toHeight,
              ),
              CustomCircleAvatar(
                image: ImageConstants.test,
                size: 75,
              ),
              SizedBox(
                height: 10.toHeight,
              ),
              Text(
                name ?? 'Levina Thomas',
                style: CustomTextStyles.primaryBold16,
              ),
              SizedBox(
                height: 2.toHeight,
              ),
              Text(
                handle ?? '@levinat',
                style: CustomTextStyles.secondaryRegular16,
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            buttonText: TextStrings().yes,
            onPressed: onYesTap,
          ),
          SizedBox(
            height: 10.toHeight,
          ),
          CustomButton(
            isInverted: true,
            buttonText: TextStrings().no,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}