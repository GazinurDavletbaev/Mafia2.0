class PhaseStack {
  final List<dynamic> _list = [];
  
  void push(dynamic phase) => _list.add(phase);
  
  void pop() {
    if (_list.isNotEmpty) _list.removeLast();
  }
  
  dynamic get current => _list.isEmpty ? null : _list.last;
  
  bool get isEmpty => _list.isEmpty;
  
  void clear() => _list.clear();
}