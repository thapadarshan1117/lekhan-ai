// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:vatsalaya_app/core/widgets/custom_button.dart';

// class HomeDrawer extends StatelessWidget {
//   const HomeDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       child: SafeArea(
//         child: Column(
//           children: [
//             _buildDrawerHeader(context),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 children: [
//                   _buildDrawerItem('assets/images/therapist/home.svg', "Home",
//                       context: context),
//                   SizedBox(height: 8),
//                   _buildDrawerItem('assets/images/therapist/profile.svg', "My Patients",
//                       onTap: () => context.go('/home/mypatients'),
//                       context: context),
//                   SizedBox(height: 8),

//                   //note  for now in appointment page navigate to progress report page
//                   _buildDrawerItem('assets/images/therapist/calendar.svg', "Appointments",
//                       onTap: () => context.go('/home/progress-report'),
//                       context: context),
//                   SizedBox(height: 8),
//                   _buildDrawerItem('assets/images/therapist/like.svg', "Recommendation",
//                       onTap: () => context.go('/appointment/reschedule'),
//                       context: context),
//                   SizedBox(height: 8),
//                   _buildDrawerItem('assets/images/therapist/finance.svg', "Finance",
//                       context: context,
//                       onTap: () => context.go('/home/finance')),
//                   SizedBox(height: 8),
//                   _buildDrawerItem(
//                     'assets/images/therapist/Task.svg',
//                     "Tasks",
//                     onTap: () => context.go('/home/tasks'),
//                     context: context,
//                   ),
//                   SizedBox(height: 8),
//                   _buildDrawerItem('assets/images/therapist/setting.svg', "Settings",
//                       onTap: () => context.go('/home/settings'),
//                       context: context),
//                   SizedBox(height: 8),
//                   _buildDrawerItem('assets/images/therapist/review.svg', "Reviews",
//                       onTap: () => context.go('/home/review'),
//                       context: context),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
//               child: CustomElevatedButton(
//                 textStyle: TextStyle(
//                   color: Theme.of(context).colorScheme.secondary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 text: 'Log out',
//                 onPressed: () => context.go("/"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDrawerHeader(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 32,
//                 backgroundImage: AssetImage("assets/images/therapist/doctor.jpg"),
//               ),
//               SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Dr. Bibha Thapa",
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   SizedBox(height: 4),
//                   Text("Orthopedic Surgeon",
//                       style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                           color: Theme.of(context).colorScheme.outline,
//                           fontWeight: FontWeight.w400)),
//                 ],
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerItem(String svgPath, String title,
//       {required BuildContext context, VoidCallback? onTap}) {
//     return ListTile(
//       dense: true,
//       contentPadding: EdgeInsets.symmetric(horizontal: 24),
//       leading: SvgPicture.asset(
//         svgPath,
//         width: 22,
//         height: 22,
//         colorFilter: ColorFilter.mode(
//           Theme.of(context).colorScheme.secondary,
//           BlendMode.srcIn,
//         ),
//       ),
//       title: Text(
//         title,
//         style: Theme.of(context)
//             .textTheme
//             .titleMedium!
//             .copyWith(color: Theme.of(context).colorScheme.secondary),
//       ),
//       onTap: onTap ?? () => context.go('/home'),
//     );
//   }
// }
