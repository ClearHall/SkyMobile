class GPA40ScaleRangeList {
  List<GPA40ScaleRange> _rangeList;

  GPA40ScaleRangeList({bool advanced = false, bool will433 = false}) {
    _rangeList = [];
    _generateDefaultList(advanced: advanced, will433: will433);
  }

  _generateDefaultList({bool advanced = false, bool will433 = false}) {
    if (advanced) {
      _rangeList.add(GPA40ScaleRange(
          null, 97, Letter('A', LetterAdvanced.plus), will433 ? 4.3 : 4.0));
      _rangeList
          .add(GPA40ScaleRange(96, 93, Letter('A', LetterAdvanced.none), 4.0));
      _rangeList
          .add(GPA40ScaleRange(92, 90, Letter('A', LetterAdvanced.minus), 3.7));
      _rangeList
          .add(GPA40ScaleRange(89, 87, Letter('B', LetterAdvanced.plus), 3.3));
      _rangeList
          .add(GPA40ScaleRange(86, 83, Letter('B', LetterAdvanced.none), 3.0));
      _rangeList
          .add(GPA40ScaleRange(82, 80, Letter('B', LetterAdvanced.minus), 2.7));
      _rangeList
          .add(GPA40ScaleRange(79, 77, Letter('C', LetterAdvanced.plus), 2.3));
      _rangeList
          .add(GPA40ScaleRange(76, 73, Letter('C', LetterAdvanced.none), 2.0));
      _rangeList
          .add(GPA40ScaleRange(72, 70, Letter('C', LetterAdvanced.minus), 1.7));
      _rangeList
          .add(GPA40ScaleRange(67, 69, Letter('D', LetterAdvanced.plus), 1.3));
      _rangeList
          .add(GPA40ScaleRange(66, 65, Letter('D', LetterAdvanced.none), 1.0));
      _rangeList.add(
          GPA40ScaleRange(64, null, Letter('F', LetterAdvanced.none), 0.0));
    } else {
      for (int i = 65; i <= 69; i++) {
        _rangeList.add(GPA40ScaleRange(
            i == 65 ? null : 100 - (i - 65) * 10 - 1,
            i == 70 ? null : 100 - (i - 64) * 10,
            Letter.fromInt(i == 69 ? 70 : i, LetterAdvanced.none),
            (i - 65) * -1 + 4.0));
      }
    }
  }

  double findGPAScale(int grade) {
    for (GPA40ScaleRange r in _rangeList) {
      if (r.isInRange(grade)) return r.scale40;
    }
    return -1.0;
  }
}

class GPA40ScaleRange {
  int first, last;
  Letter letter;
  double scale40;

  GPA40ScaleRange(int f, int l, Letter let, double scale) {
    first = f;
    last = l;
    letter = let;
    scale40 = scale;
  }

  bool isInRange(int compare) {
    bool isFirstNull = first == null;
    bool isLastNull = last == null;

    if (isFirstNull && isLastNull)
      throw Exception('Trying to find an integer in a double null range.');
    else if (isFirstNull)
      return compare >= last;
    else if (isLastNull)
      return compare <= first;
    else
      return compare <= first && compare >= last;
  }
}

class Letter {
  int letterCharValue = 65;
  LetterAdvanced advanced;

  Letter(String letter, LetterAdvanced a) {
    if (letter.length >= 1) letterCharValue = letter.codeUnitAt(0);
    advanced = a;
  }

  Letter.fromInt(int letter, LetterAdvanced a) {
    letterCharValue = letter;
    advanced = a;
  }

  String getLetter() {
    return String.fromCharCode(letterCharValue) +
        _getLetterFromLetterAdvanced(advanced);
  }

  String _getLetterFromLetterAdvanced(LetterAdvanced x) {
    switch (x) {
      case LetterAdvanced.plus:
        return "+";
      case LetterAdvanced.minus:
        return "-";
      default:
        return "";
    }
  }
}

enum LetterAdvanced { none, plus, minus }
