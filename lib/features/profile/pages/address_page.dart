import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SavedAddress {
  final String id;
  final String label;
  final String category;
  final String recipientName;
  final String phoneNumber;
  final String address;
  final String city;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.category,
    required this.recipientName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.isDefault,
  });
}

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // Static saved addresses
  static const List<SavedAddress> savedAddresses = [
    SavedAddress(
      id: '1',
      label: 'Address 01',
      category: 'Home',
      recipientName: 'Aditya Roshan',
      phoneNumber: '+977 9827766068',
      address: 'Kagawashowari Manohara, Birendra Chowk, Thapa Gaun Marga',
      city: 'Kathmandu, Nepal',
      isDefault: true,
    ),
    SavedAddress(
      id: '2',
      label: 'Address 02',
      category: 'Office',
      recipientName: 'Aditya Roshan',
      phoneNumber: '+977 9827766068',
      address: 'Gaushala, Pinglesthan, Badrinath hotel 5th floor',
      city: 'Kathmandu, Nepal',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Address',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved Addresses
            ...savedAddresses.asMap().entries.map((entry) {
              final address = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AddressCard(
                  address: address,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              );
            }),

            const SizedBox(height: 16),

            // Add New Address Button
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to add new address page
                  context.push('/address/add-new');
                },
                icon: Icon(
                  Icons.add,
                  color: colorScheme.secondary,
                  size: 18,
                ),
                label: Text(
                  'Add New Address',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.secondary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============= REUSABLE PIECES =============

class _AddressCard extends StatelessWidget {
  final SavedAddress address;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _AddressCard({
    required this.address,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with label and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle edit
                },
                child: Icon(
                  Iconsax.edit_2,
                  color: colorScheme.secondary,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Category
          Text(
            address.category,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Recipient Name
          Row(
            children: [
              Icon(
                Iconsax.user,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.recipientName,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Phone Number
          Row(
            children: [
              Icon(
                Iconsax.call,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.phoneNumber,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Address
          Text(
            address.address,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),

          // City
          Text(
            address.city,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (address.isDefault) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Default Address',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
