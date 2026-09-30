import 'package:flutter/material.dart';

class ReusableAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const ReusableAppbar({
    super.key,
    this.title = "Travelers' Info",
    this.onBack,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasTitle = (title ?? '').trim().isNotEmpty;

    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        onPressed: onBack ?? () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back,
          size: 18,
        ),
      ),
      title: hasTitle
          ? Text(
              title!,
              style: tt.bodyMedium!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
               
              ),
            )
          : null,
      actions: actions,
    );
  }
}