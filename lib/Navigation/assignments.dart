import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skyscrapeapi/data_types.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';

class AssignmentsViewer extends StatefulWidget {
  final String courseName;

  AssignmentsViewer(this.courseName);
  @override
  _AssignmentsViewerState createState() =>
      new _AssignmentsViewerState(courseName);
}

class _AssignmentsViewerState extends BiometricBlur<AssignmentsViewer> {
  String courseName;
  bool editingMode = false;
  List<AssignmentsGridBox> tmpAssignments;

  _AssignmentsViewerState(this.courseName);

  _goToAssignmentInfo(Assignment box) async {
    if (box.assignmentID != null) {
      bool isCancelled = false;
      var dialog = HuntyDialogLoading('Cancel', () {
        isCancelled = true;
      }, title: 'Loading', description: ('Getting your grades..'));

      showDialog(context: context, builder: (BuildContext context) => dialog)
          .then((val) {
        isCancelled = true;
      });

      try {
        var result = await skywardAPI.getAssignmentInfoFromAssignment(box);
        assignmentInfoBoxes = result;
      } catch (e) {
        Navigator.of(context).pop(dialog);
        String errMsg =
            'An error occured, please contact the developer: ${e.toString()}';

        showDialog(
            context: context,
            builder: (buildContext) {
              return HuntyDialog(
                  title: 'Uh Oh', description: errMsg, buttonText: 'Ok');
            });
        isCancelled = true;
      }

      if (!isCancelled) {
        Navigator.of(context, rootNavigator: true).popUntil((result) {
          return result.settings.name == '/assignmentsviewer';
        });
        Navigator.pushNamed(context, '/assignmentsinfoviewer', arguments: box.assignmentName);
      }
    }
  }

  _enterEditingMode(){
    editingMode = true;
    tmpAssignments = List.from(assignmentsGridBoxes);
  }

  @override
  Widget generateBody(BuildContext context) {
    if (shouldBlur)
      return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
      );
    List<Widget> body = [];
    for (AssignmentsGridBox box in assignmentsGridBoxes) {
      bool isBoxCatHeader = box is CategoryHeader;
      String grade = box.attributes.containsKey('Score(%)')
          ? box.attributes['Score(%)']
          : box.getDecimal();
      if (grade != null &&
          grade.trim().isEmpty &&
          box.attributes.containsKey("Points Earned")) {
        grade = box.attributes["Points Earned"];
      }
      bool secondContNeeded =
          (isBoxCatHeader && (box as CategoryHeader).weight != null);

      body.add(Container(
          padding: EdgeInsets.only(
              left: settings['Hierarchical Grades']['option']
                  ? (isBoxCatHeader ? (secondContNeeded ? 10 : 0) : (20))
                  : 0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: () {
                  if (box != null && box is Assignment)
                    _goToAssignmentInfo(box);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width /
                                    6 *
                                    3.5),
                            padding: EdgeInsets.only(
                                top: 15,
                                left: 15,
                                right: 10,
                                bottom: secondContNeeded ? 0 : 15),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isBoxCatHeader
                                  ? (box as CategoryHeader).catName
                                  : (box as Assignment).assignmentName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isBoxCatHeader
                                      ? secondContNeeded
                                          ? themeManager
                                              .getColor(TypeOfWidget.text)
                                          : themeManager
                                              .getColor(TypeOfWidget.button)
                                      : themeManager.getColor(null),
                                  fontSize: isBoxCatHeader ? 20 : 15),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          secondContNeeded
                              ? Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width /
                                              6 *
                                              4.3),
                                  padding: EdgeInsets.only(
                                      top: 5, left: 15, right: 10, bottom: 15),
                                  alignment: Alignment.centerLeft,
                                  child: Text((box as CategoryHeader).weight,
                                      style: TextStyle(
                                          color: themeManager
                                              .getColor(TypeOfWidget.text),
                                          fontSize: 15),
                                      textAlign: TextAlign.start),
                                )
                              : Container(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(minHeight: 60),
                      padding: EdgeInsets.only(right: 15),
                      alignment: Alignment.centerRight,
                      child: Text(
                        grade == null
                            ? box.attributes.containsKey('Points Earned')
                                ? box.attributes['Points Earned']
                                : ""
                            : grade,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: getColorFrom(grade)),
                      ),
                    ),
                  ],
                )),
            color: themeManager.getColor(TypeOfWidget.subBackground),
          )));
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(neiceban ? '内测版' : (courseName != null ? courseName : 'Assignments'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: themeManager.getColor(TypeOfWidget.text),
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.edit), onPressed: () {
              if(editingMode){
                setState(() {
                  editingMode = false;
                });
              }else{
                int currentwei = 0;
                bool qualify = false;
                for(AssignmentsGridBox a in assignmentsGridBoxes){
                  if(a is CategoryHeader){
                    if(a.weight == null) {
                      if(currentwei > 1){
                        qualify = true;
                        break;
                      }
                      currentwei = 0;
                    }else
                      currentwei++;
                  }
                }
                if(qualify){
                  showDialog(context: context, builder: (context) => HuntyDialogForConfirmation(title: "Warning!", description: "This is a semester! Using mock assignments on semesters will not be accurate. Are you sure you want to continue?", runIfUserConfirms: (){
                    setState(() {
                     _enterEditingMode();
                    });
                  }, btnTextForConfirmation: "Yes", btnTextForCancel: "No"));
                }else{
                  setState(() {
                    _enterEditingMode();
                  });
                }
              }
          }),
          SizedBox(width: 10,)
        ],
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: editingMode ? ReorderableList(
            onReorder: (Key item, Key newPosition) {
              int draggingIndex = _indexOfKey(body, item);
              int newPositionIndex =
              _indexOfKey(widget, newPosition);

              final draggedItem = accounts[draggingIndex];
              setState(() {
                debugPrint("Reordering $draggingIndex -> $newPositionIndex");
                accounts.removeAt(draggingIndex);
                accounts.insert(newPositionIndex, draggedItem);
              });
              return true;
            },
            onReorderDone: (Key item) {
              final draggedItem = widget[_indexOfKey(widget, item)];
              debugPrint("Reordering finished for ${draggedItem.key}}");
            },
            child: CustomScrollView(slivers: [
              SliverPadding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context)
                          .padding
                          .bottom),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return widget.elementAt(index);
                      },
                      childCount: widget.length,
                    ),
                  )),
            ]),
            //)
          ) : ListView(
          children: body,
        ),
        ),
      ),
    );
  }
}
