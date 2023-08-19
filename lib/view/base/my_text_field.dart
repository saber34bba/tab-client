import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  Widget label;
  final bool isPassword;
  final Function onTap;
  final Function onChanged;
  final Function onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final Color fillColor;
  final bool autoFocus;
  final GlobalKey<FormFieldState<String>> key;
  final bool showBorder;
  final String dateFormat;

  MyTextField(
      {this.hintText = '',
        TextEditingController controller,
        this.dateFormat = "dd MMM yyyy",
        this.focusNode,
        this.nextFocus,
        this.isEnabled = true,
        this.inputType = TextInputType.text,
        this.inputAction = TextInputAction.next,
        this.maxLines = 1,
        this.label,
        this.onSubmit,
        this.onChanged,
        this.capitalization = TextCapitalization.none,
        this.onTap,
        this.fillColor,
        this.isPassword = false,
        this.autoFocus = false,
        this.showBorder = false,
        this.key}) : 
        this.controller = controller ?? TextEditingController();

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  //Map<dynamic,dynamic> map={"January":1,""}
  @override
  initState(){

    //selectedDate=DateTime(widget.controller.text);
    super.initState();
  }
  bool _obscureText = true;
  
 DateTime selectedDate = DateTime(2023,5,3);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), border: widget.showBorder ? Border.all(color: Theme.of(context).disabledColor) : null),
      child: TextField(
        readOnly: widget.inputType != null && widget.inputType == TextInputType.datetime,
        key: widget.key,
        maxLines: widget.maxLines,
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: robotoRegular,
        textInputAction: widget.inputAction,
        keyboardType: widget.inputType,
        cursorColor: Theme.of(context).primaryColor,
        textCapitalization: widget.capitalization,
        enabled: widget.isEnabled,
        autofocus: widget.autoFocus,
        
        //onChanged: widget.isSearch ? widget.languageProvider.searchLanguage : null,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))] : null,
        decoration: InputDecoration(
          label: widget.label,
          hintText: widget.hintText,
          isDense: true,
          filled: true,
          fillColor: widget.fillColor != null ? widget.fillColor : Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), borderSide: BorderSide.none),
          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
          suffixIcon: widget.isPassword ? IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).hintColor.withOpacity(0.3)),
            onPressed: _toggle,
          ) : null,
        ),
        onTap: widget.inputType != null && widget.inputType == TextInputType.datetime ? () async {
           final DateTime pickedDate = await showDatePicker(
        context: context,

        initialDate: selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2999));
    if (pickedDate != null && pickedDate != selectedDate) {
    
        selectedDate = pickedDate;

    }
    widget.controller.text=selectedDate.toString().split(" ").first;
          /*DateTime pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(Duration(days: 18 *365 - 18%4)),
            firstDate: DateTime.now().subtract(Duration(days: 80 *365 - 80%4)),
            lastDate: DateTime.now().subtract(Duration(days: 18 *365 - 18%4)));*/
         // widget.controller.text = DateFormat(widget.dateFormat).format(pickedDate);pickedDate.toIso8601String();
        }: widget.onTap,
        onSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus)
            : widget.onSubmit != null ? widget.onSubmit(text) : null,
        onChanged: widget.onChanged,
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
