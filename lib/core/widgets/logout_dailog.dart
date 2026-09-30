// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconsax/iconsax.dart';

// class LogoutDailog extends StatelessWidget {
//   const LogoutDailog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon Container
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF44336).withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(32),
//                   border: Border.all(
//                     color: const Color(0xFFF44336).withValues(alpha: 0.2),
//                     width: 2,
//                   ),
//                 ),
//                 child: const Icon(
//                   Iconsax.logout_1,
//                   color: Color(0xFFF44336),
//                   size: 28,
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Title
//               Text(
//                 'Logout',
//                 style: GoogleFonts.urbanist(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF2D2D2D),
//                 ),
//               ),
              
//               const SizedBox(height: 8),
              
//               // Description
//               Text(
//                 'Are you sure you want to logout?\nYou will need to sign in again to access your account.',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.urbanist(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w400,
//                   height: 1.4,
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size(0, 48),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         side: const BorderSide(
//                           color: Color(0xFFE2E8F0),
//                           width: 1.5,
//                         ),
//                         backgroundColor: Colors.white,
//                         foregroundColor: const Color(0xFF64748B),
//                       ),
//                       onPressed: () => Navigator.pop(context, false),
//                       child: Text(
//                         'Cancel',
//                         style: GoogleFonts.urbanist(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(width: 12),
                  
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(0, 48),
//                         backgroundColor: const Color(0xFFF44336),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shadowColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(context, true),
//                       child: Text(
//                         'Logout',
//                         style: GoogleFonts.urbanist(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }