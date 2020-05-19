import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';

class Selector extends StatelessWidget {
  final String preText;
  final List<String> listItems;
  final Function(int) runWhenChanged;
  final int index;

  Selector(this.listItems, this.preText, this.runWhenChanged, this.index);

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: index);
    List<Widget> cupPickerWid = [];

    for (String term in listItems) {
      cupPickerWid.add(Container(
        child: Text(term,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, color: Colors.white)),
        padding: EdgeInsets.only(top: 8),
      ));
    }

    return InkWell(
      child: Card(
        color: themeManager.getColor(TypeOfWidget.text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          child: Text(
            '$preText: ${listItems[index]}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 0, right: 0),
        ),
      ),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => CupertinoPicker(
                scrollController: scrollController,
                backgroundColor: Colors.black,
                children: cupPickerWid,
                itemExtent: 50,
                onSelectedItemChanged: runWhenChanged));
      },
    );
  }
}
