import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationAvatar extends StatelessWidget {
  const NotificationAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              context.push("/notification");
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Badge(
                label: Text(
                  "0", // Placeholder for notification count
                ),
                isLabelVisible: 0 > 0,
                offset: const Offset(0, 0),
                padding: const EdgeInsets.all(1),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 30,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )

            // BlocBuilder<NotificationBloc, NotificationState>(
            //   builder: (context, state) {
            //     int count = 0;
            //     state.maybeWhen(
            //       loaded: (notifications) {
            //         count = notifications.where((element) => !element.isRead).length;
            //       },
            //       orElse: (){});
            //     return CircleAvatar(
            //       radius: 30,
            //       child: Badge(
            //         label: Text(
            //           count.toString(),
            //         ),
            //         isLabelVisible: count > 0,
            //         offset: const Offset(0, 0),
            //         padding: const EdgeInsets.all(1),
            //         child: Icon(
            //           Icons.notifications_outlined,
            //           size: 30,
            //           color: Theme.of(context).colorScheme.onPrimary,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            ),
        SizedBox(
          height: 8,
        ),
        Text(
          "Notifications",
          style: Theme.of(context).textTheme.labelMedium,
        )
      ],
    );
  }
}
