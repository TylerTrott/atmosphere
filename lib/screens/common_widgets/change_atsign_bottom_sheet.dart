import 'dart:math';

import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/contact_provider.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AtSignBottomSheet extends StatefulWidget {
  final List<String> atSignList;
  AtSignBottomSheet({Key key, this.atSignList}) : super(key: key);

  @override
  _AtSignBottomSheetState createState() => _AtSignBottomSheetState();
}

class _AtSignBottomSheetState extends State<AtSignBottomSheet> {
  BackendService backendService = BackendService.getInstance();
  bool isLoading = false;
  var atClientPreferenceLocal;
  @override
  Widget build(BuildContext context) {
    backendService
        .getAtClientPreference()
        .then((value) => atClientPreferenceLocal = value);
    Random r = Random();
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            builder: (context) => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: Container(
                height: 100,
                width: SizeConfig().screenWidth,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.atSignList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: isLoading
                            ? () {}
                            : () async {
                                setState(() {
                                  isLoading = true;
                                  Navigator.pop(context);
                                });
                                await backendService.checkToOnboard(
                                    atSignToOnboard: widget.atSignList[index]);

                                Provider.of<ContactProvider>(context,
                                        listen: false)
                                    .selectedAtsign = null;
                                Provider.of<FilePickerProvider>(context,
                                        listen: false)
                                    .selectedFiles = [];

                                setState(() {
                                  isLoading = false;
                                });
                              },
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            children: [
                              Container(
                                height: 40.toFont,
                                width: 40.toFont,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, r.nextInt(255),
                                      r.nextInt(255), r.nextInt(255)),
                                  borderRadius:
                                      BorderRadius.circular(50.toWidth),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.atSignList[index]
                                        .substring(0, 2)
                                        .toUpperCase(),
                                    style: CustomTextStyles.whiteBold(
                                        size: (50 ~/ 3)),
                                  ),
                                ),
                              ),
                              Text(widget.atSignList[index])
                            ],
                          ),
                        ),
                      ),
                    )),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                          // Navigator.pop(context);
                        });
                        await backendService.checkToOnboard(
                            atSignToOnboard: "");

                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.orange,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
                child: Column(
                  children: [
                    Text(
                      'Switching atsign...',
                      style: CustomTextStyles.orangeMedium16,
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorConstants.redText)),
                  ],
                ),
              )
            : SizedBox(
                height: 100,
              ),
      ],
    );
  }
}
