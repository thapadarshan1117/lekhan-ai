import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TextIcon extends StatelessWidget {
  const TextIcon({super.key, required this.iconText, required this.iconUrl});
  final String iconText;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
       SvgPicture.asset(iconUrl,height: 14,width: 14,),
       SizedBox(width: 2,),
      Text(iconText,style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),),
      ],
    );
  }
}