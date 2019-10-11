class GPA40ScaleRangeList{
  List<GPA40ScaleRange> _rangeList;

  GPA40ScaleRangeList(){
    _rangeList = [];
    _generateDefaultList();
  }

  _generateDefaultList({bool advanced = false}){
      if(advanced){
        _rangeList.add(GPA40ScaleRange(null, 97, Letter('A', LetterAdvanced.plus)));
        _rangeList.add(GPA40ScaleRange(96, 93, Letter('A', LetterAdvanced.none)));
        _rangeList.add(GPA40ScaleRange(92, 90, Letter('A', LetterAdvanced.minus)));
        _rangeList.add(GPA40ScaleRange(89, 87, Letter('B', LetterAdvanced.plus)));
        _rangeList.add(GPA40ScaleRange(86, 83, Letter('B', LetterAdvanced.none)));
        _rangeList.add(GPA40ScaleRange(82, 80, Letter('B', LetterAdvanced.minus)));
        _rangeList.add(GPA40ScaleRange(79, 77, Letter('C', LetterAdvanced.plus)));
        _rangeList.add(GPA40ScaleRange(76, 73, Letter('C', LetterAdvanced.none)));
        _rangeList.add(GPA40ScaleRange(72, 70, Letter('C', LetterAdvanced.minus)));
        _rangeList.add(GPA40ScaleRange(67, 69, Letter('D', LetterAdvanced.plus)));
        _rangeList.add(GPA40ScaleRange(66, 65, Letter('D', LetterAdvanced.none)));
        _rangeList.add(GPA40ScaleRange(64, null, Letter('F', LetterAdvanced.none)));
      }else{
        for(int i = 65; i <= 70; i++){
          if(i != 69){
            _rangeList.add(GPA40ScaleRange(100 - (i-65) * 10 == 100 ? 100 : 100 - (i-65) * 10 - 1, 100 - (i-64) * 10, Letter.fromInt(i, LetterAdvanced.none)));
          }
        }
      }
  }

  analyze
}

class GPA40ScaleRange{
  int first, last;
  Letter letter;

  GPA40ScaleRange(int f, int l, Letter let){
    first = f;
    last = l;
    letter = let;
  }

  bool isInRange(int compare){
    bool isFirstNull = first == null;
    bool isLastNull = last == null;

    if(isFirstNull && isLastNull) throw Exception('Trying to find an integer in a double null range.');
    else if(isFirstNull) return compare <= last;
    else if(isLastNull) return compare >= first;
    else return compare >= first && compare <= last;
  }
}

class Letter{
  int letterCharValue = 65;
  LetterAdvanced advanced;

  Letter(String letter, LetterAdvanced a){
    if(letter.length >= 1)
      letterCharValue = letter.codeUnitAt(0);
    advanced = a;
  }

  Letter.fromInt(int letter, LetterAdvanced a){
    letterCharValue = letter;
    advanced = a;
  }

  String getLetter(){
    return String.fromCharCode(letterCharValue) + _getLetterFromLetterAdvanced(advanced);
  }

  String _getLetterFromLetterAdvanced(LetterAdvanced x){
    switch(x){
      case LetterAdvanced.plus:
        return "+";
      case LetterAdvanced.minus:
        return "-";
      default:
        return "";
    }
  }
}

enum LetterAdvanced{
  none,
  plus,
  minus
}