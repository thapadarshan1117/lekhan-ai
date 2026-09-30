
import 'package:flutter/material.dart';

class BodyTitletext extends StatelessWidget {
   const BodyTitletext({
    super.key,
    required this.title,  this.color=Colors.black,this.fontWeight=FontWeight.w500,
  });
  final String title;
  final Color color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Text(
      
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: fontWeight,color: color
          ),
    );  
  }
}
