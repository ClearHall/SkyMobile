import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/ExtraViewPackages/biometric_blur_view.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageViewer extends StatefulWidget {
  MessageViewer({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MessageViewerState createState() => _MessageViewerState();
}

class _MessageViewerState extends BiometricBlur<MessageViewer> {
  Map<int, TapGestureRecognizer> recognizer = {};

  @override
  void dispose() {
    for (TapGestureRecognizer a in recognizer.values) {
      a.dispose();
    }

    super.dispose();
  }

  @override
  Widget generateBody(BuildContext context) {
    int indOfRecognizer = 0;
    List<Widget> children = [];

    for (Message message in messages) {
      List<TextSpan> textSpans = [];

      for (int i = 0; i < message.body.getArr().length; i++) {
        var arg = message.body.getArr()[i];
        bool prevIsLink = i > message.body.getArr().length - 2
            ? false
            : message.body.getArr()[i + 1] is Link;
        if (arg is Link) {
          if (!recognizer.containsKey(indOfRecognizer))
            recognizer[indOfRecognizer] = TapGestureRecognizer()
              ..onTap = () {
                launch(arg.link);
              };
          textSpans.add(
            TextSpan(
                text: arg.text,
                style: TextStyle(
                    color: themeManager.getColor(TypeOfWidget.button),
                    fontSize: 13),
                recognizer: recognizer[indOfRecognizer]),
          );
          indOfRecognizer++;
        } else {
          textSpans.add(TextSpan(
              text: arg.toString().trim().isEmpty
                  ? '\n'
                  : prevIsLink ? arg : arg + '\n',
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 13)));
        }
      }

      TapGestureRecognizer tapForAttach;
      if (message?.title?.attachment?.link != null) {
        if (!recognizer.containsKey(indOfRecognizer))
          recognizer[indOfRecognizer] = TapGestureRecognizer()
            ..onTap = () {
              launch(message.title.attachment.link);
            };
        tapForAttach = recognizer[indOfRecognizer];
        indOfRecognizer++;
      }

      children.add(Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: <Widget>[
              message.header != null
                  ? Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message?.header ?? '',
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 20),
                          )),
                      padding: EdgeInsets.only(top: 15, left: 20, right: 20),
                    )
                  : Container(),
              message.title?.title != null
                  ? Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message?.title?.title ?? '',
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 17),
                          )),
                      padding: EdgeInsets.only(top: 15, left: 20, right: 20),
                    )
                  : Container(),
              message.title?.attachment != null
                  ? Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                text: message?.title?.attachment?.text ?? '',
                                style: TextStyle(
                                    color: themeManager
                                        .getColor(TypeOfWidget.button),
                                    fontSize: 15),
                                recognizer: tapForAttach),
                          )),
                      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                    )
                  : Container(),
              message.date != null
                  ? Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message?.date ?? '',
                            style: TextStyle(
                                color: themeManager.getColor(TypeOfWidget.text),
                                fontSize: 15),
                          )),
                      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                    )
                  : Container(),
//              Divider(
//                color: themeManager.getColor(TypeOfWidget.text),
//                indent: 10,
//                endIndent: 10,
//              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: RichText(text: TextSpan(children: textSpans)),
                padding: EdgeInsets.only(left: 20, right: 20),
              )
            ],
          ),
          color: themeManager.getColor(TypeOfWidget.subBackground),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
            alignment: Alignment.center,
            child: Text('Messages',
                style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ))),
        actions: <Widget>[
          SizedBox(
            width: 50,
          )
        ],
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
        child: ListView(children: children),
      ),
    );
  }
}
