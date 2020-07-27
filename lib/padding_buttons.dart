import 'package:flutter/material.dart';
class PaddingButton extends StatelessWidget {
  final String data;
  final onPressed;
  final col;
  PaddingButton({this.data,@required this.onPressed,this.col});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.symmetric(vertical:16.0),
      child: Material(
          color:col,
          borderRadius: BorderRadius.circular(30.0),
          elevation: 5.0,
          child: MaterialButton(
            onPressed:onPressed,
            minWidth: 200.0,
            height: 42.0,
            child: Text(
              data,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
      ),


    );
  }
}
