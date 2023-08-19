class ResponseModel {
  bool _isSuccess;
  String _message;
  Map<String, dynamic> _extra;
  ResponseModel(this._isSuccess, this._message,[Map<String, dynamic> extra]) : this._extra = extra ?? {};

  String get message => _message;
  bool get isSuccess => _isSuccess;
  dynamic  operator[](String name){
    return _extra.containsKey(name) ? _extra[name] : null;
  }
  void  operator[]=(String name, dynamic value){
    _extra[name] = value;
  }
}