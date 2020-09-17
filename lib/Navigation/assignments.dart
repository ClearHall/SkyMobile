import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skymobile/ExtraViewPackages/hunty_dialogs.dart';
import 'package:skymobile/HelperUtilities/global.dart';
import 'package:skymobile/Settings/theme_color_manager.dart';
import 'package:skymobile/SupportWidgets/biometric_blur_view.dart';
import 'package:skymobile/SupportWidgets/flutter_reorderable_list.dart';
import 'package:skyscrapeapi/sky_core.dart';

class AssignmentsViewer extends StatefulWidget {
  final List args;

  AssignmentsViewer(this.args);
  @override
  _AssignmentsViewerState createState() =>
      new _AssignmentsViewerState(args[0], args[1], args[2]);
}

class _AssignmentsViewerState extends BiometricBlur<AssignmentsViewer> {
  String courseName;
  bool editingMode = false;
  DetailedGradingPeriod tmpAssignments;
  DetailedGradingPeriod gradingPeriod;
  Gradebook gradebook;

  _AssignmentsViewerState(this.courseName, this.gradingPeriod, this.gradebook);

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

      var result;
      try {
        result = await account.getAssignmentDetailsFrom(box);
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
        Navigator.pushNamed(context, '/assignmentsinfoviewer',
            arguments: [box.name, result]);
      }
    }
  }

  double finalAverage;

  _recalculateTmp() {
    double tmp = 0;
    double tmpweight = 0;

    tmpAssignments.assignments.forEach((key, value) {
      double weight;
      double localTmp = 0;
      int localNum = 0;
      if (tmpAssignments.attributes.containsKey(key.first.name + 'Weight')) {
        weight =
            double.parse(tmpAssignments.attributes[key.first.name + 'Weight']);
      } else {
        try {
          weight = double.parse(
              key.first.weight.split(' ').last.replaceFirst('%', ''));
        } catch (e) {
          weight = double.parse(key.first.weight
              .split('weighted at ')[1]
              .split(' ')
              .first
              .replaceFirst('%', '')
              .replaceFirst(',', ''));
        }
      }
      for (Assignment a in value) {
        String grade = a.attributes.containsKey('Score(%)')
            ? a.attributes['Score(%)']
            : a.getDecimal();
        double att = double.tryParse(grade);
        if (att != null) {
          localNum++;
          localTmp += att;
        } else {
          a.attributes['Score(%)'] = '';
        }
      }
      if (localNum < 1)
        key.first.attributes['Score(%)'] = '';
      else {
        key.first.attributes['Score(%)'] =
            (localTmp / localNum).toStringAsFixed(2);
        tmp += (localTmp / localNum) * (weight / 100.0);
        tmpweight += weight / 100.0;
      }
    });

    finalAverage = tmp / tmpweight;
  }

  _enterEditingMode() {
    editingMode = true;
    tmpAssignments = DetailedGradingPeriod.define(
        gradingPeriod.assignments, gradingPeriod.attributes);
    _recalculateTmp();
  }

  AssignmentNode getObjFromIndex(int ind) {
    int index = 0;
    AssignmentNode node;
    tmpAssignments.assignments.forEach((cat, assign) {
      if (node != null) return;
      for (CategoryHeader head in cat) {
        if (index == ind) {
          node = head;
          break;
        }
        index++;
      }
      for (Assignment assi in assign) {
        if (index == ind) {
          node = assi;
          break;
        }
        index++;
      }
    });
    return node;
  }

  move(Assignment a, int index) {
    int ind = 0;
    AssignmentNode b;
    bool shouldStop = false;
    tmpAssignments.assignments.forEach((cat, assign) {
      if (shouldStop) return;
      List<AssignmentNode> full = List.from(cat);
      full.addAll(assign);
      for (int i = 0; i < full.length; i++) {
        if (a == null && ind == index) {
          b = assign.removeAt(i - cat.length);
          shouldStop = true;
          break;
        } else if (i == full.length - 1 && index - 1 == ind) {
          assign.add(a);
          shouldStop = true;
          break;
        } else if (ind == index) {
          assign.insert(i - cat.length, a);
          shouldStop = true;
          break;
        }
        ind++;
      }
    });
    if (!shouldStop) {
      tmpAssignments.assignments.values.last.add(a);
    }
    return b;
  }

  int tmpAssignID = 0;
  @override
  Widget generateBody(BuildContext context) {
//    List<CategoryHeader> t = List();
//    t.add(CategoryHeader('PONE', '123', {}));
//    tmpAssignments.assignments[t] = [Assignment('09', '12344', '12905', 'PP', {'Score(%)': '123.1'}),Assignment('09', '12424344', '12905', 'SDDF', {'Score(%)': '13.1'})];
    if (shouldBlur)
      return Scaffold(
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
      );
    int ind = 0;
    List<Widget> body = [];
    (editingMode ? tmpAssignments : gradingPeriod)
        .assignments
        .forEach((catList, assignList) {
      for (CategoryHeader cat in catList) addToBody(body, context, cat, ind++);
      for (Assignment assign in assignList)
        addToBody(body, context, assign, ind++);
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: themeManager.getColor(TypeOfWidget.text), size: 30),
        backgroundColor: themeManager.getColor(TypeOfWidget.background),
        title: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
              child: Text(
                  editingMode
                      ? 'Final: ${finalAverage.toStringAsFixed(2)}'
                      : neiceban
                      ? '内测版'
                      : (courseName != null ? courseName : 'Assignments'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: themeManager.getColor(TypeOfWidget.text),
                      fontSize: 30,
                      fontWeight: FontWeight.w700))),
        ),
        actions: <Widget>[
          editingMode
              ? IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  tmpAssignments.assignments.values.first
                      .add(CustomAssignment(tmpAssignID));
                  tmpAssignID++;
                  _recalculateTmp();
                });
              })
              : Container(),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                if (editingMode) {
                  setState(() {
                    editingMode = false;
                  });
                } else {
                  int currentwei = 0;
                  bool qualify = false;
                  for (List<CategoryHeader> b in (editingMode
                      ? tmpAssignments.assignments.keys
                      : gradingPeriod.assignments.keys)) {
                    for (CategoryHeader a in b) {
                      if (a.weight == null) {
                        if (currentwei > 1) {
                          qualify = true;
                          break;
                        }
                        currentwei = 0;
                      } else
                        currentwei++;
                    }
                  }
                  if (qualify) {
//                showDialog(context: context, builder: (context) =>
//                    HuntyDialogForConfirmation(title: "Warning!",
//                        description: "This is a semester! Using mock assignments on semesters will not be accurate. Are you sure you want to continue?",
//                        runIfUserConfirms: () {
//                          setState(() {
//                            _enterEditingMode();
//                          });
//                        },
//                        btnTextForConfirmation: "Yes",
//                        btnTextForCancel: "No"));
                    showDialog(
                        context: context,
                        builder: (c) => HuntyDialog(
                            title: 'Sorry',
                            description:
                                'Mock assignments currently does not work on semesters, please try in a term!',
                            buttonText: 'Got it!'));
                  } else {
                    showDialog(
                        context: context,
                        builder: (c) => HuntyDialog(
                            title: 'Reminder!',
                            description:
                                'Double tap on an assignment to remove it! Press and hold to move an assignment around.',
                            buttonText: 'Got it!'));
                    setState(() {
                      _enterEditingMode();
                    });
                  }
                }
              }),
          SizedBox(
            width: 10,
          )
        ],
      ),
      backgroundColor: themeManager.getColor(TypeOfWidget.background),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: editingMode
              ? ReorderableList(
                  onReorder: (Key item, Key newPosition) {
                    int draggingIndex = indexOfKey(body, item);
                    int newPositionIndex = indexOfKey(body, newPosition);

                    final draggedItem = getObjFromIndex(draggingIndex);
                    int len =
                        gradingPeriod.assignments.keys.toList().first?.length;
                    if (draggedItem is CategoryHeader ||
                        newPositionIndex <= (len == null ? 0 : len - 1)) {
                      return false;
                    } else {
                      setState(() {
                        debugPrint(
                            "Reordering $draggingIndex -> $newPositionIndex");
                        move(move(null, draggingIndex), newPositionIndex);
                      });
                    }
                    return true;
                  },
                  onReorderDone: (Key item) {
                    final draggedItem = body[indexOfKey(body, item)];
                    setState(() {
                      _recalculateTmp();
                    });
                    debugPrint("Reordering finished for ${draggedItem.key}}");
                  },
                  child: CustomScrollView(slivers: [
                    SliverPadding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return body.elementAt(index);
                            },
                            childCount: body.length,
                          ),
                        )),
                  ]),
                  //)
                )
              : ListView(
                  children: body,
                ),
        ),
      ),
    );
  }

  Map<String, TextEditingController> controllers = Map();

  void addToBody(
      List<Widget> body, BuildContext context, AssignmentNode box, int ind) {
    //if (box is Assignment) print(gradebook.getAssignmentTerm(box));
    bool isBoxCatHeader = box is CategoryHeader;
    String key = isBoxCatHeader
        ? box.name + box.hashCode.toString()
        : (box as Assignment).assignmentID;
    String grade = box.attributes.containsKey('Score(%)')
        ? box.attributes['Score(%)']
        : box.getDecimal();
    if (!editingMode &&
        (((grade != null && grade
            .trim()
            .isEmpty) || grade == null) &&
            box.attributes.containsKey("Points Earned"))) {
      grade = box.attributes["Points Earned"];
    }
    bool secondContNeeded =
        (isBoxCatHeader && (box as CategoryHeader).weight != null);

    TextEditingController controller = controllers[key];
    if (controller == null) {
      controller = TextEditingController();
      controller.text = grade;
      controllers[key] = controller;
    }

    TextStyle standard = TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: editingMode && box is Assignment
            ? getColorFrom(null)
            : getColorFrom(grade));

    Widget a = Container(
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
              onTap: !editingMode
                  ? () {
                      if (box != null && box is Assignment)
                        _goToAssignmentInfo(box);
                    }
                  : () {},
              onDoubleTap: editingMode
                  ? () {
                      setState(() {
                        tmpAssignments.assignments.forEach((key, value) {
                          value.remove(box);
                        });
                        _recalculateTmp();
                      });
                    }
                  : null,
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
                              maxWidth:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width / 6 * 3.5),
                          padding: EdgeInsets.only(
                              top: 15,
                              left: 15,
                              right: 10,
                              bottom: secondContNeeded ? 0 : 15),
                          alignment: Alignment.centerLeft,
                          child: (box is CustomAssignment && editingMode)
                              ? ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: 200, maxHeight: 40),
                              child: TextField(
                                controller: box.namecontroller,
                                style: standard,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(5),
                                    labelStyle: TextStyle(
                                        color: themeManager
                                            .getColor(TypeOfWidget.text)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: themeManager.getColor(
                                                TypeOfWidget.text),
                                            width: 2),
                                        borderRadius:
                                        BorderRadius.circular(16)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: themeManager.getColor(
                                                TypeOfWidget.text),
                                            width: 2),
                                        borderRadius:
                                        BorderRadius.circular(16))),
                                onChanged: (String a) {
                                  setState(() {
                                    box.name = a;
                                  });
                                },
                              ))
                              : Text(
                            box.name,
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
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(minHeight: 60),
                      padding: EdgeInsets.only(right: 15),
                      alignment: Alignment.centerRight,
                      child: (editingMode && box is Assignment)
                          ? ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: 80, maxHeight: 40),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: controller,
                            style: standard,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                labelStyle: TextStyle(
                                    color: themeManager
                                        .getColor(TypeOfWidget.text)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: themeManager
                                              .getColor(TypeOfWidget.text),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(16)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: themeManager
                                              .getColor(TypeOfWidget.text),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(16))),
                            onChanged: (String a) {
                              setState(() {
                                box.attributes['Score(%)'] = a;
                                _recalculateTmp();
                              });
                            },
                          ))
                          : Text(
                        grade ?? '',
                        style: standard,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),)
                ],
              )),
          color: themeManager.getColor(TypeOfWidget.subBackground),
        ));
    body.add(editingMode
        ? ReorderableItem(
            key: Key(key),
            childBuilder: (BuildContext context, ReorderableItemState state) =>
                DelayedReorderableListener(
                    child: Opacity(
                        opacity: state == ReorderableItemState.placeholder
                            ? 0.0
                            : 1.0,
                        child: a)))
        : a);
  }
}

class CustomAssignment extends Assignment {
  TextEditingController namecontroller = TextEditingController();

  CustomAssignment(int ind)
      : super('0', 'CustomAssign$ind', '0', 'Assignment',
      {'Score(%)': '100.00'}) {
    namecontroller.text = 'Assignment';
  }
}
